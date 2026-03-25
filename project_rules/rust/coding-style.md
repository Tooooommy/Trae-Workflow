# Rust 编码规范

> Rust 项目代码风格指南

## 格式化

```bash
cargo fmt
```

## 命名约定

| 类型 | 规则 | 示例 |
|------|------|------|
| 变量 | snake_case | `user_name` |
| 函数 | snake_case | `get_user` |
| 结构体 | PascalCase | `UserProfile` |
| 枚举 | PascalCase | `UserStatus` |
| 常量 | SCREAMING_SNAKE_CASE | `MAX_RETRIES` |
| 模块 | snake_case | `user_auth` |

## 导入排序

```rust
// 标准库 → 外部 crate → 项目模块
use std::collections::HashMap;
use serde::Deserialize;
use crate::models::User;
```

## 错误处理

- 优先使用 `Result` 处理可恢复错误
- 使用 `?` 操作符传播错误
- 使用 `thiserror` 定义自定义错误类型
- 避免使用 `unwrap()` 和 `expect()`
