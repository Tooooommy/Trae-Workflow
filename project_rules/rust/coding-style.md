---
alwaysApply: false
globs:
  - '**/*.rs'
  - '**/Cargo.toml'
---

# Rust 编码风格

> Rust 语言特定的编码风格和约定。

## 命名约定

| 类型        | 约定                 | 示例              |
| ----------- | -------------------- | ----------------- |
| 类型/结构体 | PascalCase           | `UserAccount`     |
| 函数/方法   | snake_case           | `create_user`     |
| 常量        | SCREAMING_SNAKE_CASE | `MAX_CONNECTIONS` |
| 模块        | snake_case           | `user_service`    |
| 生命周期    | 单引号小写           | `'a`, `'static`   |

## 错误处理

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("User not found: {0}")]
    NotFound(String),

    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
}

pub type Result<T> = std::result::Result<T, AppError>;
```

## 所有权与借用

```rust
// 优先使用借用而非移动
fn process_user(user: &User) -> String {
    user.name.clone()
}

// 使用 Cow 避免不必要的克隆
use std::borrow::Cow;
fn get_name(user: &User) -> Cow<str> {
    Cow::Borrowed(&user.name)
}
```

## 异步编程

```rust
use tokio;

#[tokio::main]
async fn main() -> Result<()> {
    let user = fetch_user(1).await?;
    println!("{:?}", user);
    Ok(())
}
```
