use crate::{
    error::AppResult,
    models::user::{AuthResponse, LoginRequest, RefreshRequest, RegisterRequest},
    AppState,
};
use axum::{extract::State, Json};
use serde_json::{json, Value};

pub async fn register(
    State(state): State<AppState>,
    Json(req): Json<RegisterRequest>,
) -> AppResult<Json<AuthResponse>> {
    Ok(Json(state.auth_service.register(req).await?))
}

pub async fn login(
    State(state): State<AppState>,
    Json(req): Json<LoginRequest>,
) -> AppResult<Json<AuthResponse>> {
    Ok(Json(state.auth_service.login(req).await?))
}

pub async fn refresh(
    State(state): State<AppState>,
    Json(req): Json<RefreshRequest>,
) -> AppResult<Json<AuthResponse>> {
    Ok(Json(state.auth_service.refresh_token(&req.refresh_token).await?))
}

pub async fn logout(
    State(state): State<AppState>,
    Json(req): Json<RefreshRequest>,
) -> AppResult<Json<Value>> {
    state.auth_service.logout(&req.refresh_token).await?;
    Ok(Json(json!({ "message": "Logged out successfully" })))
}
