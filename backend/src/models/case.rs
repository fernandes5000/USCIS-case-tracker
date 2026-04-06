use serde::{Deserialize, Serialize};
use uuid::Uuid;

// Our DB model for a tracked case
#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct UserCase {
    pub id: String,
    pub user_id: String,
    pub receipt_number: String,
    pub nickname: Option<String>,
    pub created_at: String,
}

impl UserCase {
    pub fn new(user_id: String, receipt_number: String, nickname: Option<String>) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            user_id,
            receipt_number: receipt_number.to_uppercase(),
            nickname,
            created_at: chrono::Utc::now().to_rfc3339(),
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct AddCaseRequest {
    pub receipt_number: String,
    pub nickname: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateCaseRequest {
    pub nickname: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UscisCase {
    #[serde(rename = "receiptNumber")]
    pub receipt_number: Option<String>,
    #[serde(rename = "caseStatus")]
    pub case_status: Option<UscisCurrentStatus>,
    #[serde(rename = "caseHistory")]
    pub case_history: Option<Vec<UscisHistoryEvent>>,
    #[serde(rename = "formType")]
    pub form_type: Option<String>,
    #[serde(rename = "applicantName")]
    pub applicant_name: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UscisCurrentStatus {
    #[serde(rename = "caseStatusDescription")]
    pub description: Option<String>,
    #[serde(rename = "caseStatusExternalText")]
    pub external_text: Option<String>,
    #[serde(rename = "caseStatusDate")]
    pub status_date: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UscisHistoryEvent {
    #[serde(rename = "caseStatusDate")]
    pub date: Option<String>,
    #[serde(rename = "caseStatusDescription")]
    pub description: Option<String>,
    #[serde(rename = "caseStatusExternalText")]
    pub external_text: Option<String>,
}

// Enriched response combining our DB record with USCIS data
#[derive(Debug, Serialize)]
pub struct CaseWithStatus {
    pub id: String,
    pub receipt_number: String,
    pub nickname: Option<String>,
    pub created_at: String,
    pub uscis_data: Option<UscisCase>,
    pub cached_at: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct CaseStatusCache {
    pub receipt_number: String,
    pub status_json: String,
    pub cached_at: String,
}
