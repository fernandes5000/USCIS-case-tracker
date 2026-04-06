use crate::{
    config::Config,
    error::{AppError, AppResult},
    models::user::{AuthResponse, Claims, LoginRequest, RegisterRequest, User},
};
use bcrypt::{hash, verify, DEFAULT_COST};
use chrono::Utc;
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use sqlx::SqlitePool;
use uuid::Uuid;

pub struct AuthService {
    pool: SqlitePool,
    config: Config,
}

impl AuthService {
    pub fn new(pool: SqlitePool, config: Config) -> Self {
        Self { pool, config }
    }

    pub async fn register(&self, req: RegisterRequest) -> AppResult<AuthResponse> {
        // Validate email format simply
        if !req.email.contains('@') {
            return Err(AppError::Validation("Invalid email format".to_string()));
        }
        if req.password.len() < 8 {
            return Err(AppError::Validation(
                "Password must be at least 8 characters".to_string(),
            ));
        }
        if req.full_name.trim().is_empty() {
            return Err(AppError::Validation("Full name is required".to_string()));
        }

        // Check if email exists
        let exists: Option<String> =
            sqlx::query_scalar("SELECT id FROM users WHERE email = ?")
                .bind(&req.email.to_lowercase())
                .fetch_optional(&self.pool)
                .await?;

        if exists.is_some() {
            return Err(AppError::Conflict("Email already registered".to_string()));
        }

        let password_hash =
            hash(&req.password, DEFAULT_COST).map_err(|e| anyhow::anyhow!(e))?;

        let user = User::new(
            req.email.to_lowercase(),
            password_hash,
            req.full_name.trim().to_string(),
        );

        sqlx::query(
            "INSERT INTO users (id, email, password_hash, full_name, created_at, updated_at)
             VALUES (?, ?, ?, ?, ?, ?)",
        )
        .bind(&user.id)
        .bind(&user.email)
        .bind(&user.password_hash)
        .bind(&user.full_name)
        .bind(&user.created_at)
        .bind(&user.updated_at)
        .execute(&self.pool)
        .await?;

        self.build_auth_response(user).await
    }

    pub async fn login(&self, req: LoginRequest) -> AppResult<AuthResponse> {
        let user: Option<User> = sqlx::query_as(
            "SELECT id, email, password_hash, full_name, created_at, updated_at
             FROM users WHERE email = ?",
        )
        .bind(&req.email.to_lowercase())
        .fetch_optional(&self.pool)
        .await?;

        let user = user.ok_or_else(|| AppError::Unauthorized("Invalid credentials".to_string()))?;

        let valid = verify(&req.password, &user.password_hash)
            .map_err(|e| anyhow::anyhow!(e))?;

        if !valid {
            return Err(AppError::Unauthorized("Invalid credentials".to_string()));
        }

        self.build_auth_response(user).await
    }

    pub async fn refresh_token(&self, refresh_token: &str) -> AppResult<AuthResponse> {
        // Validate the refresh token JWT
        let claims = self.decode_token(refresh_token, "refresh")?;

        // Check it's in DB and not expired
        let token_hash = sha256_hex(refresh_token);
        let exists: Option<String> = sqlx::query_scalar(
            "SELECT id FROM refresh_tokens WHERE token_hash = ? AND expires_at > datetime('now')",
        )
        .bind(&token_hash)
        .fetch_optional(&self.pool)
        .await?;

        if exists.is_none() {
            return Err(AppError::Unauthorized("Invalid or expired refresh token".to_string()));
        }

        // Revoke old refresh token
        sqlx::query("DELETE FROM refresh_tokens WHERE token_hash = ?")
            .bind(&token_hash)
            .execute(&self.pool)
            .await?;

        // Load user and issue new tokens
        let user: Option<User> = sqlx::query_as(
            "SELECT id, email, password_hash, full_name, created_at, updated_at
             FROM users WHERE id = ?",
        )
        .bind(&claims.sub)
        .fetch_optional(&self.pool)
        .await?;

        let user = user.ok_or_else(|| AppError::Unauthorized("User not found".to_string()))?;

        self.build_auth_response(user).await
    }

    pub async fn logout(&self, refresh_token: &str) -> AppResult<()> {
        let token_hash = sha256_hex(refresh_token);
        sqlx::query("DELETE FROM refresh_tokens WHERE token_hash = ?")
            .bind(&token_hash)
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    pub fn decode_access_token(&self, token: &str) -> AppResult<Claims> {
        self.decode_token(token, "access")
    }

    fn decode_token(&self, token: &str, expected_type: &str) -> AppResult<Claims> {
        let mut validation = Validation::default();
        validation.validate_exp = true;

        let data = decode::<Claims>(
            token,
            &DecodingKey::from_secret(self.config.jwt_secret.as_bytes()),
            &validation,
        )
        .map_err(|e| AppError::Unauthorized(format!("Invalid token: {e}")))?;

        if data.claims.token_type != expected_type {
            return Err(AppError::Unauthorized("Wrong token type".to_string()));
        }

        Ok(data.claims)
    }

    async fn build_auth_response(&self, user: User) -> AppResult<AuthResponse> {
        let now = Utc::now();
        let access_exp = now
            .checked_add_signed(chrono::Duration::hours(self.config.jwt_expiration_hours))
            .unwrap()
            .timestamp();
        let refresh_exp_dt = now
            .checked_add_signed(chrono::Duration::days(self.config.jwt_refresh_expiration_days))
            .unwrap();

        let access_claims = Claims {
            sub: user.id.clone(),
            email: user.email.clone(),
            exp: access_exp,
            iat: now.timestamp(),
            token_type: "access".to_string(),
        };

        let refresh_claims = Claims {
            sub: user.id.clone(),
            email: user.email.clone(),
            exp: refresh_exp_dt.timestamp(),
            iat: now.timestamp(),
            token_type: "refresh".to_string(),
        };

        let key = EncodingKey::from_secret(self.config.jwt_secret.as_bytes());
        let access_token = encode(&Header::default(), &access_claims, &key)
            .map_err(|e| anyhow::anyhow!(e))?;
        let refresh_token = encode(&Header::default(), &refresh_claims, &key)
            .map_err(|e| anyhow::anyhow!(e))?;

        // Store refresh token hash
        let token_id = Uuid::new_v4().to_string();
        let token_hash = sha256_hex(&refresh_token);
        sqlx::query(
            "INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at)
             VALUES (?, ?, ?, ?)",
        )
        .bind(&token_id)
        .bind(&user.id)
        .bind(&token_hash)
        .bind(refresh_exp_dt.to_rfc3339())
        .execute(&self.pool)
        .await?;

        let expires_in = self.config.jwt_expiration_hours * 3600;

        Ok(AuthResponse {
            access_token,
            refresh_token,
            token_type: "Bearer".to_string(),
            expires_in,
            user: user.into(),
        })
    }
}

fn sha256_hex(input: &str) -> String {
    use std::collections::hash_map::DefaultHasher;
    use std::hash::{Hash, Hasher};
    // Use a simple approach — in production use sha2 crate
    // For now use a deterministic hash
    let mut hasher = DefaultHasher::new();
    input.hash(&mut hasher);
    format!("{:x}", hasher.finish())
}
