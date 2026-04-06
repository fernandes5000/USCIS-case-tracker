use crate::{
    config::Config,
    error::{AppError, AppResult},
    models::case::{CaseStatusCache, UscisCase},
};
use chrono::Utc;
use reqwest::Client;
use serde::Deserialize;
use serde_json::Value;
use sqlx::SqlitePool;
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::info;

const CACHE_TTL_SECONDS: i64 = 300; // 5 minutes

#[derive(Debug, Deserialize)]
struct UscisTokenResponse {
    access_token: String,
    expires_in: String,
}

struct TokenCache {
    token: String,
    expires_at: chrono::DateTime<Utc>,
}

pub struct UscisService {
    config: Config,
    client: Client,
    pool: SqlitePool,
    token_cache: Arc<RwLock<Option<TokenCache>>>,
}

impl UscisService {
    pub fn new(config: Config, pool: SqlitePool) -> Self {
        let client = Client::builder()
            .timeout(std::time::Duration::from_secs(30))
            .build()
            .expect("Failed to build HTTP client");

        Self {
            config,
            client,
            pool,
            token_cache: Arc::new(RwLock::new(None)),
        }
    }

    async fn get_access_token(&self) -> AppResult<String> {
        // Return cached token if still valid
        {
            let cache = self.token_cache.read().await;
            if let Some(ref cached) = *cache {
                if cached.expires_at > Utc::now() + chrono::Duration::seconds(60) {
                    return Ok(cached.token.clone());
                }
            }
        }

        info!("Fetching new USCIS OAuth2 token from {}", self.config.uscis_token_url);

        let response = self
            .client
            .post(&self.config.uscis_token_url)
            .form(&[
                ("grant_type", "client_credentials"),
                ("client_id", &self.config.uscis_client_id),
                ("client_secret", &self.config.uscis_client_secret),
            ])
            .send()
            .await
            .map_err(|e| AppError::UscisApi(format!("Token request failed: {e}")))?;

        let status = response.status();
        if !status.is_success() {
            let body = response.text().await.unwrap_or_default();
            return Err(AppError::UscisApi(format!(
                "Token endpoint returned {status}: {body}"
            )));
        }

        let raw_body = response
            .text()
            .await
            .map_err(|e| AppError::UscisApi(format!("Failed to read token response: {e}")))?;

        info!("USCIS token response: {}", &raw_body[..raw_body.len().min(200)]);

        let token_resp: UscisTokenResponse = serde_json::from_str(&raw_body)
            .map_err(|e| AppError::UscisApi(format!("Failed to parse token response: {e} — body: {raw_body}")))?;

        let expires_in_secs: i64 = token_resp.expires_in.parse().unwrap_or(3600);
        let expires_at = Utc::now() + chrono::Duration::seconds(expires_in_secs);
        let token = token_resp.access_token.clone();

        let mut cache = self.token_cache.write().await;
        *cache = Some(TokenCache { token: token.clone(), expires_at });

        Ok(token)
    }

    pub async fn get_case_status(&self, receipt_number: &str) -> AppResult<UscisCase> {
        let receipt = receipt_number.to_uppercase();

        // Check DB cache
        if let Some(cached) = self.get_from_cache(&receipt).await? {
            info!("Cache hit for {receipt}");
            let case: UscisCase = serde_json::from_str(&cached.status_json)
                .map_err(|e| anyhow::anyhow!("Cache parse error: {e}"))?;
            return Ok(case);
        }

        info!("Fetching case {receipt} from USCIS API");
        let token = self.get_access_token().await?;

        // Correct endpoint: /case-status/{receiptNumber}
        let url = format!("{}/case-status/{}", self.config.uscis_api_base_url, receipt);
        info!("USCIS request URL: {url}");

        let response = self
            .client
            .get(&url)
            .bearer_auth(&token)
            .header("Accept", "application/json")
            .send()
            .await
            .map_err(|e| AppError::UscisApi(format!("Case request failed: {e}")))?;

        let status = response.status();

        if status == reqwest::StatusCode::NOT_FOUND {
            return Err(AppError::NotFound(format!(
                "Case {receipt} not found in USCIS system"
            )));
        }

        let raw_body = response
            .text()
            .await
            .map_err(|e| AppError::UscisApi(format!("Failed to read response body: {e}")))?;

        info!("USCIS case response (status={status}): {raw_body}");

        if !status.is_success() {
            return Err(AppError::UscisApi(format!(
                "USCIS API returned {status}: {raw_body}"
            )));
        }

        // Parse raw JSON
        let raw: Value = serde_json::from_str(&raw_body)
            .map_err(|e| AppError::UscisApi(format!("Failed to parse JSON: {e}")))?;

        // Map USCIS response format → our UscisCase model
        let case = map_uscis_response(&raw, &receipt);

        // Cache the result
        let status_json = serde_json::to_string(&case)
            .map_err(|e| anyhow::anyhow!(e))?;
        self.upsert_cache(&receipt, &status_json).await?;

        Ok(case)
    }

    async fn get_from_cache(&self, receipt_number: &str) -> AppResult<Option<CaseStatusCache>> {
        let threshold = (Utc::now() - chrono::Duration::seconds(CACHE_TTL_SECONDS)).to_rfc3339();
        let cached: Option<CaseStatusCache> = sqlx::query_as(
            "SELECT receipt_number, status_json, cached_at FROM case_status_cache
             WHERE receipt_number = ? AND cached_at > ?",
        )
        .bind(receipt_number)
        .bind(&threshold)
        .fetch_optional(&self.pool)
        .await?;
        Ok(cached)
    }

    async fn upsert_cache(&self, receipt_number: &str, status_json: &str) -> AppResult<()> {
        let now = Utc::now().to_rfc3339();
        sqlx::query(
            "INSERT INTO case_status_cache (receipt_number, status_json, cached_at)
             VALUES (?, ?, ?)
             ON CONFLICT(receipt_number) DO UPDATE SET
               status_json = excluded.status_json,
               cached_at = excluded.cached_at",
        )
        .bind(receipt_number)
        .bind(status_json)
        .bind(&now)
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    pub async fn cleanup_cache(&self) -> AppResult<()> {
        let threshold = (Utc::now() - chrono::Duration::hours(24)).to_rfc3339();
        let deleted = sqlx::query("DELETE FROM case_status_cache WHERE cached_at < ?")
            .bind(&threshold)
            .execute(&self.pool)
            .await?;
        if deleted.rows_affected() > 0 {
            info!("Cleaned {} stale cache entries", deleted.rows_affected());
        }
        Ok(())
    }
}

/// Maps the USCIS Case Status API JSON response to our internal UscisCase model.
///
/// Actual USCIS response shape:
/// {
///   "case_status": {
///     "receiptNumber": "EAC9999103403",
///     "formType": "I-130",
///     "submittedDate": "...",
///     "modifiedDate": "...",
///     "current_case_status_text_en": "Case Was Approved",
///     "current_case_status_desc_en": "On September 5, 2023, we approved...",
///     "current_case_status_text_es": "...",
///     "current_case_status_desc_es": "...",
///     "hist_case_status": [
///       { "date": "2023-09-05", "completed_text_en": "...", "completed_text_es": "..." }
///     ]
///   },
///   "message": "Query was successful..."
/// }
fn map_uscis_response(raw: &Value, receipt: &str) -> UscisCase {
    use crate::models::case::{UscisCurrentStatus, UscisHistoryEvent};

    // Data lives under "case_status" key
    let cs = raw.get("case_status").unwrap_or(raw);

    let current_status = Some(UscisCurrentStatus {
        description: cs.get("current_case_status_text_en")
            .and_then(|v| v.as_str())
            .map(str::to_string),
        external_text: cs.get("current_case_status_desc_en")
            .and_then(|v| v.as_str())
            .map(str::to_string),
        // Use modifiedDate as the status date
        status_date: cs.get("modifiedDate")
            .or_else(|| cs.get("submittedDate"))
            .and_then(|v| v.as_str())
            .map(str::to_string),
    });

    // USCIS uses "hist_case_status" (not "hist_case_status_data")
    let history = cs
        .get("hist_case_status")
        .and_then(|v| v.as_array())
        .map(|arr| {
            arr.iter()
                .map(|e| UscisHistoryEvent {
                    date: e.get("date")
                        .and_then(|v| v.as_str())
                        .map(str::to_string),
                    // USCIS uses "completed_text_en" for history items
                    description: e.get("completed_text_en")
                        .and_then(|v| v.as_str())
                        .map(str::to_string),
                    external_text: None,
                })
                .collect()
        })
        .unwrap_or_default();

    UscisCase {
        receipt_number: Some(
            cs.get("receiptNumber")
                .and_then(|v| v.as_str())
                .unwrap_or(receipt)
                .to_string(),
        ),
        case_status: current_status,
        case_history: Some(history),
        form_type: cs.get("formType")
            .or_else(|| cs.get("form_type"))
            .and_then(|v| v.as_str())
            .map(str::to_string),
        applicant_name: None,
    }
}
