---
alwaysApply: false
globs:
  - '**/*.rs'
  - '**/Cargo.toml'
---

# Rust 测试规范

> Rust 语言特定的测试框架和策略。

## 单元测试

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_user() {
        let user = User::new("test@example.com", "password");
        assert_eq!(user.email, "test@example.com");
    }

    #[tokio::test]
    async fn test_async_operation() {
        let result = async_function().await;
        assert!(result.is_ok());
    }
}
```

## 集成测试

```
tests/
├── common/
│   └── mod.rs        # 共享测试工具
└── api_test.rs       # 集成测试
```

## 测试覆盖率

```bash
cargo tarpaulin --out Html    # 生成覆盖率报告
cargo test --all-features     # 运行所有测试
```

## 相关智能体

- `testing-expert` - TDD 工作流和测试策略

## 相关技能

- `rust-patterns` - Rust 模式（包含测试模式）
- `tdd-workflow` - 测试驱动开发
