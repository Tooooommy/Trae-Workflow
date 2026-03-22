---
alwaysApply: false
globs:
  - "**/Cargo.toml"
  - "**/main.rs"
---

# Actix-web 项目规范与指南

> 基于 Actix-web 的 Rust Web 应用开发规范。

## 项目总览

* 技术栈: Rust 1.75+, Actix-web 4, SQLx, PostgreSQL
* 架构: Handler-Service-Repository 三层架构

## 关键规则

### 项目结构

```
app/
├── src/
│   ├── main.rs
│   ├── config.rs
│   ├── handlers/
│   │   ├── mod.rs
│   │   ├── user.rs
│   │   └── auth.rs
│   ├── models/
│   │   ├── mod.rs
│   │   └── user.rs
│   ├── services/
│   │   ├── mod.rs
│   │   └── user_service.rs
│   ├── repositories/
│   │   ├── mod.rs
│   │   └── user_repo.rs
│   ├── middleware/
│   │   └── auth.rs
│   └── errors.rs
├── migrations/
├── Cargo.toml
└── .env
```

### Handler

```rust
use actix_web::{web, HttpResponse, Result};
use crate::models::CreateUser;
use crate::services::UserService;

pub async fn create(
    service: web::Data<UserService>,
    body: web::Json<CreateUser>,
) -> Result<HttpResponse> {
    let user = service.create(body.into_inner()).await?;
    Ok(HttpResponse::Created().json(user))
}

pub async fn get(
    service: web::Data<UserService>,
    path: web::Path<i64>,
) -> Result<HttpResponse> {
    let user = service.find_by_id(path.into_inner()).await?;
    match user {
        Some(u) => Ok(HttpResponse::Ok().json(u)),
        None => Ok(HttpResponse::NotFound().finish()),
    }
}
```

### 路由配置

```rust
pub fn configure(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/v1")
            .route("/users", web::post().to(handlers::user::create))
            .route("/users/{id}", web::get().to(handlers::user::get))
    );
}
```

## 环境变量

```bash
DATABASE_URL=postgresql://user:password@localhost:5432/actix_db
SERVER_HOST=0.0.0.0
SERVER_PORT=8080
JWT_SECRET=your-secret-key
```

## 开发命令

```bash
cargo run                    # 开发服务器
cargo build --release        # 生产构建
cargo test                   # 测试
sqlx migrate run             # 数据库迁移
```
