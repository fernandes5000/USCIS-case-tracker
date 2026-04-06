use crate::{error::AppError, AppState};
use axum::{
    extract::{Request, State},
    middleware::Next,
    response::Response,
};

#[derive(Clone)]
pub struct AuthenticatedUser {
    pub id: String,
    #[allow(dead_code)]
    pub email: String,
}

pub async fn require_auth(
    State(state): State<AppState>,
    mut req: Request,
    next: Next,
) -> Result<Response, AppError> {
    // Skip auth for public routes
    let path = req.uri().path();
    if path == "/api/auth/register"
        || path == "/api/auth/login"
        || path == "/api/auth/refresh"
        || path == "/api/health"
    {
        return Ok(next.run(req).await);
    }

    let token = extract_bearer_token(&req)
        .ok_or_else(|| AppError::Unauthorized("Missing Authorization header".to_string()))?;

    let claims = state.auth_service.decode_access_token(token)?;

    req.extensions_mut().insert(AuthenticatedUser {
        id: claims.sub,
        email: claims.email,
    });

    Ok(next.run(req).await)
}

fn extract_bearer_token(req: &Request) -> Option<&str> {
    req.headers()
        .get(axum::http::header::AUTHORIZATION)
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.strip_prefix("Bearer "))
}
