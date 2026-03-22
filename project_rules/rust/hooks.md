---
alwaysApply: false
globs:
  - '**/*.rs'
  - '**/Cargo.toml'
---

# Rust Hooks 配置

> Rust 语言特定的 Hooks 配置。

## PreToolUse

- 运行 `cargo check` 验证语法
- 运行 `cargo clippy` 代码检查

## PostToolUse

- 运行 `cargo fmt` 格式化代码
- 运行 `cargo test` 执行测试

## 常用命令

```bash
cargo check           # 快速语法检查
cargo clippy          # Lint 检查
cargo fmt             # 格式化
cargo test            # 测试
cargo build --release # 生产构建
```
