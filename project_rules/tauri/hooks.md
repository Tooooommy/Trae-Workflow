---
alwaysApply: false
globs:
  - '**/Cargo.toml'
  - '**/tauri.conf.json'
---

# Tauri Hooks 配置

> Tauri 桌面应用 Git Hooks 配置。

## Husky 配置

```bash
npx husky install
```

## 推荐 Hooks

### pre-commit

- Rust 格式检查 (cargo fmt)
- Clippy 检查
- 前端 lint

### commit-msg

- 提交信息规范检查
