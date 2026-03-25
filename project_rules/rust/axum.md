# Axum Web 框架

> Rust Axum Web 框架模式

## 快速开始

```rust
use axum::{
    routing::get,
    Router,
};

async fn hello() -> &'static str {
    "Hello, World!"
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(hello));

    axum::Server::bind(&"0.0.0.0:3000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

## 路由定义

```rust
Router::new()
    .route("/users", get(list_users).post(create_user))
    .route("/users/:id", get(get_user).delete(delete_user))
```

## 提取器

```rust
async fn get_user(Path(id): Path<u32>) -> Result<Json<User>, AppError> {
    // ...
}

async fn create_user(
    State(state): State<AppState>,
    Json(payload): Json<CreateUser>,
) -> Result<Json<User>, AppError> {
    // ...
}
```

## 状态管理

```rust
#[derive(Clone)]
struct AppState {
    db: Database,
}

let state = AppState { db: Database::new() };
let app = Router::with_state(state);
```
