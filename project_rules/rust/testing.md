# Rust 测试规范

> Rust 项目测试指南

## 测试类型

| 类型 | 说明 | 位置 |
|------|------|------|
| 单元测试 | 单个函数/模块测试 | `src/` 内 |
| 集成测试 | 多模块交互测试 | `tests/` |
| 文档测试 | 代码示例测试 | `src/` 内 |

## 测试框架

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_example() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    #[should_panic]
    fn test_panic() {
        panic!("This test should panic");
    }

    #[test]
    fn test_result() -> Result<(), Box<dyn std::error::Error>> {
        // ...
        Ok(())
    }
}
```

## 异步测试

```rust
#[tokio::test]
async fn test_async() {
    let result = some_async_function().await;
    assert!(result.is_ok());
}
```

## 常用断言

```rust
assert_eq!(a, b);
assert_ne!(a, b);
assert!(condition);
assert!(!condition);
assert!(result.is_ok());
assert!(result.is_err());
```

## 运行测试

```bash
cargo test
cargo test -- --nocapture  # 显示输出
cargo test --release       # 发布模式测试
```
