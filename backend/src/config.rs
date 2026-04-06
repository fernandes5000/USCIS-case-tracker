use anyhow::{Context, Result};
use std::env;

#[derive(Clone, Debug)]
pub struct Config {
    pub host: String,
    pub port: u16,
    pub database_url: String,
    pub jwt_secret: String,
    pub jwt_expiration_hours: i64,
    pub jwt_refresh_expiration_days: i64,
    pub uscis_api_base_url: String,
    pub uscis_token_url: String,
    pub uscis_client_id: String,
    pub uscis_client_secret: String,
}

impl Config {
    pub fn from_env() -> Result<Self> {
        Ok(Self {
            host: env::var("HOST").unwrap_or_else(|_| "0.0.0.0".to_string()),
            port: env::var("PORT")
                .unwrap_or_else(|_| "8080".to_string())
                .parse()
                .context("PORT must be a valid number")?,
            database_url: env::var("DATABASE_URL")
                .context("DATABASE_URL must be set")?,
            jwt_secret: env::var("JWT_SECRET")
                .context("JWT_SECRET must be set")?,
            jwt_expiration_hours: env::var("JWT_EXPIRATION_HOURS")
                .unwrap_or_else(|_| "24".to_string())
                .parse()
                .context("JWT_EXPIRATION_HOURS must be a number")?,
            jwt_refresh_expiration_days: env::var("JWT_REFRESH_EXPIRATION_DAYS")
                .unwrap_or_else(|_| "30".to_string())
                .parse()
                .context("JWT_REFRESH_EXPIRATION_DAYS must be a number")?,
            uscis_api_base_url: env::var("USCIS_API_BASE_URL")
                .unwrap_or_else(|_| "https://api-int.uscis.gov".to_string()),
            uscis_token_url: env::var("USCIS_TOKEN_URL")
                .unwrap_or_else(|_| "https://api-int.uscis.gov/oauth/accesstoken".to_string()),
            uscis_client_id: env::var("USCIS_CLIENT_ID")
                .context("USCIS_CLIENT_ID must be set")?,
            uscis_client_secret: env::var("USCIS_CLIENT_SECRET")
                .context("USCIS_CLIENT_SECRET must be set")?,
        })
    }
}
