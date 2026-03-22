---
alwaysApply: false
globs:
  - '**/*.rs'
  - '**/Cargo.toml'
---

# Rust 安全规范

> Rust 语言特定的安全最佳实践。

## 输入验证

```rust
use validator::Validate;

#[derive(Validate)]
struct CreateUser {
    #[validate(email)]
    email: String,

    #[validate(length(min = 8))]
    password: String,
}
```

## 密码处理

```rust
use argon2::{self, Config};

fn hash_password(password: &str) -> Result<String> {
    let config = Config::default();
    argon2::hash_encoded(password.as_bytes(), &salt, &config)
}

fn verify_password(hash: &str, password: &str) -> Result<bool> {
    argon2::verify_encoded(hash, password.as_bytes())
}
```

## SQL 注入防护

```rust
// 使用参数化查询
sqlx::query_as!(
    User,
    "SELECT * FROM users WHERE email = $1",
    email
)
.fetch_one(&pool)
.await?;
```

## 敏感数据处理

- 使用 `zeroize` 清理敏感数据
- 使用 `secrecy` 包装敏感类型
- 避免在日志中输出敏感信息
