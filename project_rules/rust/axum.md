---
alwaysApply: false
globs:
  - "**/Cargo.toml"
  - "**/main.rs"
---

# Axum 项目规范与指南

> 基于 Axum 的 Rust Web 应用开发规范。

## 项目总览

* 技术栈: Rust 1.75+, Axum 0.7, Tower, SQLx, PostgreSQL
* 架构: Handler-Service-Repository 三层架构

## 关键规则

### 项目结构

```
app/
├── src/
│   ├── main.rs
│   ├── config.rs
│   ├── routes/
│   │   ├── mod.rs
│   │   └── users.rs
│   ├── handlers/
│   │   ├── mod.rs
│   │   └── users.rs
│   ├── models/
│   │   ├── mod.rs
│   │   └── user.rs
│   ├── services/
│   │   └── user_service.rs
│   ├── repositories/
│   │   └── user_repo.rs
│   └── error.rs
├── migrations/
├── Cargo.toml
└── .env
```

### Handler

```rust
use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use crate::models::{CreateUser, User};
use crate::services::UserService;

pub async fn create(
    State(service): State<UserService>,
    Json(body): Json<CreateUser>,
) -> Result<Json<User>, AppError> {
    let user = service.create(body).await?;
    Ok(Json(user))
}

pub async fn get(
    State(service): State<UserService>,
    Path(id): Path<i64>,
) -> Result<Json<User>, AppError> {
    let user = service.find_by_id(id).await?;
    Ok(Json(user))
}
```

### 路由配置

```rust
use axum::{
    routing::{get, post},
    Router,
};

pub fn router(service: UserService) -> Router {
    Router::new()
        .route("/users", post(handlers::users::create))
        .route("/users/:id", get(handlers::users::get))
        .with_state(service)
}
```

## 环境变量

```bash
DATABASE_URL=postgresql://user:password@localhost:5432/axum_db
SERVER_HOST=0.0.0.0
SERVER_PORT=3000
JWT_SECRET=your-secret-key
```

## 开发命令

```bash
cargo run                    # 开发服务器
cargo build --release        # 生产构建
cargo test                   # 测试
sqlx migrate run             # 数据库迁移
```
