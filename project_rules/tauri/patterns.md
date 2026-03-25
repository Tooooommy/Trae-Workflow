---
alwaysApply: false
globs:
  - '**/Cargo.toml'
  - '**/tauri.conf.json'
---

# Tauri 项目规范

> 基于 Tauri 的跨平台桌面应用开发规范。

## 项目总览

- 技术栈: Rust + WebView, TypeScript
- 架构: Rust 后端 + Web 前端

## 项目结构

```
src-tauri/
├── src/
│   ├── main.rs
│   └── lib.rs
├── Cargo.toml
└── tauri.conf.json
src/
├── App.tsx
└── main.tsx
```

## 关键规则

### 安全配置

- 启用 CSP
- 禁用 devtools (生产)
- 配置权限白名单

### 打包配置

- 使用 tauri-cli
- 配置签名
- 自动更新
