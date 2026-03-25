---
alwaysApply: false
globs:
  - '**/Cargo.toml'
  - '**/tauri.conf.json'
---

# Tauri 编码风格

> Tauri 桌面应用编码规范。

## Rust 后端

- 使用 Rust 2021 edition
- 启用 strict Rust
- 使用 clippy 检查

## 前端

- TypeScript 严格模式
- 遵循前端框架规范

## IPC 通信

```rust
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}
```
