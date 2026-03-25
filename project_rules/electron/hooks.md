---
alwaysApply: false
globs:
  - '**/package.json'
---

# Electron Hooks 配置

> Electron 桌面应用 Git Hooks 配置。

## Husky 配置

```bash
npx husky install
```

## 推荐 Hooks

### pre-commit

- 代码格式检查 (prettier)
- Lint 检查 (eslint)

### commit-msg

- 提交信息规范检查

## 依赖

```json
{
  "devDependencies": {
    "husky": "^9.0.0",
    "lint-staged": "^15.0.0"
  }
}
```
