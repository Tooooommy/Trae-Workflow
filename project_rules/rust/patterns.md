---
alwaysApply: false
globs:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Rust 设计模式

> Rust 语言特定的设计模式。

## Builder 模式

```rust
pub struct User {
    name: String,
    email: String,
}

pub struct UserBuilder {
    name: Option<String>,
    email: Option<String>,
}

impl UserBuilder {
    pub fn new() -> Self {
        Self { name: None, email: None }
    }

    pub fn name(mut self, name: impl Into<String>) -> Self {
        self.name = Some(name.into());
        self
    }

    pub fn email(mut self, email: impl Into<String>) -> Self {
        self.email = Some(email.into());
        self
    }

    pub fn build(self) -> Result<User, &'static str> {
        Ok(User {
            name: self.name.ok_or("name is required")?,
            email: self.email.ok_or("email is required")?,
        })
    }
}
```

## Repository 模式

```rust
#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn find_by_id(&self, id: i64) -> Result<Option<User>>;
    async fn create(&self, user: &CreateUser) -> Result<User>;
    async fn update(&self, id: i64, user: &UpdateUser) -> Result<User>;
    async fn delete(&self, id: i64) -> Result<()>;
}
```

## Newtype 模式

```rust
#[derive(Debug, Clone)]
pub struct UserId(i64);

impl UserId {
    pub fn new(id: i64) -> Self {
        Self(id)
    }

    pub fn value(&self) -> i64 {
        self.0
    }
}
```
