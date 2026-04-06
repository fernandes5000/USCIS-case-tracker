mod api;
mod config;
mod error;
mod middleware;
mod models;
mod services;

use crate::{
    config::Config,
    services::{auth_service::AuthService, uscis_service::UscisService},
};
use axum::{
    middleware as axum_middleware,
    routing::{get, post},
    Router,
};
use sqlx::sqlite::SqlitePoolOptions;
use std::{net::SocketAddr, sync::Arc};
use tower_http::{
    cors::{Any, CorsLayer},
    trace::TraceLayer,
};
use tracing::info;

/// Shared application state injected into every handler
#[derive(Clone)]
pub struct AppState {
    pub pool: sqlx::SqlitePool,
    pub auth_service: Arc<AuthService>,
    pub uscis_service: Arc<UscisService>,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();

    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "uscis_backend=debug,tower_http=info".into()),
        )
        .init();

    let config = Config::from_env()?;

    // Ensure SQLite data directory exists before connecting
    for prefix in &["sqlite://", "sqlite:"] {
        if let Some(path) = config.database_url.strip_prefix(prefix) {
            let path = path.trim_start_matches('/');
            if let Some(dir) = std::path::Path::new(path).parent() {
                if !dir.as_os_str().is_empty() {
                    std::fs::create_dir_all(dir)?;
                    info!("Ensured database directory: {}", dir.display());
                }
            }
            break;
        }
    }

    let connect_opts = sqlx::sqlite::SqliteConnectOptions::new()
        .filename(config.database_url.trim_start_matches("sqlite:").trim_start_matches("//").trim_start_matches("./"))
        .create_if_missing(true);

    let pool = SqlitePoolOptions::new()
        .max_connections(10)
        .connect_with(connect_opts)
        .await?;

    sqlx::migrate!("./migrations").run(&pool).await?;
    info!("Database migrations applied");

    let auth_service = Arc::new(AuthService::new(pool.clone(), config.clone()));
    let uscis_service = Arc::new(UscisService::new(config.clone(), pool.clone()));

    // Periodic cache cleanup
    {
        let uscis_clone = Arc::clone(&uscis_service);
        tokio::spawn(async move {
            let mut interval = tokio::time::interval(std::time::Duration::from_secs(3600));
            loop {
                interval.tick().await;
                if let Err(e) = uscis_clone.cleanup_cache().await {
                    tracing::warn!("Cache cleanup: {:?}", e);
                }
            }
        });
    }

    let state = AppState {
        pool,
        auth_service,
        uscis_service,
    };

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let app = Router::new()
        // Public
        .route("/api/health", get(health))
        .route("/api/auth/register", post(api::auth::register))
        .route("/api/auth/login", post(api::auth::login))
        .route("/api/auth/refresh", post(api::auth::refresh))
        // Protected
        .route("/api/auth/logout", post(api::auth::logout))
        .route("/api/cases", get(api::cases::list_cases).post(api::cases::add_case))
        .route(
            "/api/cases/:receipt_number",
            get(api::cases::get_case_status)
                .patch(api::cases::update_case)
                .delete(api::cases::delete_case),
        )
        .layer(axum_middleware::from_fn_with_state(
            state.clone(),
            middleware::auth::require_auth,
        ))
        .with_state(state)
        .layer(cors)
        .layer(TraceLayer::new_for_http());

    let addr: SocketAddr = format!("{}:{}", config.host, config.port).parse()?;
    info!("Listening on {addr}");

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}

async fn health() -> axum::Json<serde_json::Value> {
    axum::Json(serde_json::json!({ "status": "ok" }))
}
