use crate::{
    error::{AppError, AppResult},
    middleware::auth::AuthenticatedUser,
    models::case::{AddCaseRequest, CaseWithStatus, UpdateCaseRequest, UserCase},
    AppState,
};
use axum::{
    extract::{Extension, Path, State},
    Json,
};
use serde_json::{json, Value};

pub async fn list_cases(
    State(state): State<AppState>,
    Extension(user): Extension<AuthenticatedUser>,
) -> AppResult<Json<Vec<UserCase>>> {
    let cases: Vec<UserCase> = sqlx::query_as(
        "SELECT id, user_id, receipt_number, nickname, created_at
         FROM user_cases WHERE user_id = ? ORDER BY created_at DESC",
    )
    .bind(&user.id)
    .fetch_all(&state.pool)
    .await?;

    Ok(Json(cases))
}

pub async fn add_case(
    State(state): State<AppState>,
    Extension(user): Extension<AuthenticatedUser>,
    Json(req): Json<AddCaseRequest>,
) -> AppResult<Json<UserCase>> {
    let receipt = req.receipt_number.trim().to_uppercase();

    if receipt.is_empty() {
        return Err(AppError::Validation("Receipt number is required".to_string()));
    }

    if !is_valid_receipt_number(&receipt) {
        return Err(AppError::Validation(
            "Invalid receipt number format. Expected: ABC0000000000".to_string(),
        ));
    }

    let new_case = UserCase::new(user.id, receipt, req.nickname);

    let result = sqlx::query(
        "INSERT INTO user_cases (id, user_id, receipt_number, nickname, created_at)
         VALUES (?, ?, ?, ?, ?)",
    )
    .bind(&new_case.id)
    .bind(&new_case.user_id)
    .bind(&new_case.receipt_number)
    .bind(&new_case.nickname)
    .bind(&new_case.created_at)
    .execute(&state.pool)
    .await;

    match result {
        Ok(_) => Ok(Json(new_case)),
        Err(sqlx::Error::Database(e)) if e.message().contains("UNIQUE") => {
            Err(AppError::Conflict("Case already being tracked".to_string()))
        }
        Err(e) => Err(AppError::Database(e)),
    }
}

pub async fn get_case_status(
    State(state): State<AppState>,
    Extension(user): Extension<AuthenticatedUser>,
    Path(receipt_number): Path<String>,
) -> AppResult<Json<CaseWithStatus>> {
    let receipt = receipt_number.to_uppercase();

    let case: Option<UserCase> = sqlx::query_as(
        "SELECT id, user_id, receipt_number, nickname, created_at
         FROM user_cases WHERE user_id = ? AND receipt_number = ?",
    )
    .bind(&user.id)
    .bind(&receipt)
    .fetch_optional(&state.pool)
    .await?;

    let case = case.ok_or_else(|| AppError::NotFound("Case not found".to_string()))?;

    let uscis_result = state.uscis_service.get_case_status(&receipt).await;
    if let Err(ref e) = uscis_result {
        tracing::error!("USCIS fetch failed for {receipt}: {:?}", e);
    }
    let uscis_data = uscis_result.ok();

    Ok(Json(CaseWithStatus {
        id: case.id,
        receipt_number: case.receipt_number,
        nickname: case.nickname,
        created_at: case.created_at,
        uscis_data,
        cached_at: None,
    }))
}

pub async fn update_case(
    State(state): State<AppState>,
    Extension(user): Extension<AuthenticatedUser>,
    Path(receipt_number): Path<String>,
    Json(req): Json<UpdateCaseRequest>,
) -> AppResult<Json<UserCase>> {
    let receipt = receipt_number.to_uppercase();

    let updated: Option<UserCase> = sqlx::query_as(
        "UPDATE user_cases SET nickname = ?
         WHERE user_id = ? AND receipt_number = ?
         RETURNING id, user_id, receipt_number, nickname, created_at",
    )
    .bind(&req.nickname)
    .bind(&user.id)
    .bind(&receipt)
    .fetch_optional(&state.pool)
    .await?;

    updated
        .map(Json)
        .ok_or_else(|| AppError::NotFound("Case not found".to_string()))
}

pub async fn delete_case(
    State(state): State<AppState>,
    Extension(user): Extension<AuthenticatedUser>,
    Path(receipt_number): Path<String>,
) -> AppResult<Json<Value>> {
    let receipt = receipt_number.to_uppercase();

    let result = sqlx::query(
        "DELETE FROM user_cases WHERE user_id = ? AND receipt_number = ?",
    )
    .bind(&user.id)
    .bind(&receipt)
    .execute(&state.pool)
    .await?;

    if result.rows_affected() == 0 {
        return Err(AppError::NotFound("Case not found".to_string()));
    }

    Ok(Json(json!({ "message": "Case removed successfully" })))
}

fn is_valid_receipt_number(receipt: &str) -> bool {
    if receipt.len() < 10 || receipt.len() > 15 {
        return false;
    }
    let (prefix, suffix) = receipt.split_at(3);
    prefix.chars().all(|c| c.is_ascii_alphabetic())
        && suffix.chars().all(|c| c.is_ascii_digit())
}
