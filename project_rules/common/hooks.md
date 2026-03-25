---
alwaysApply: false
globs:
  - '**/*'
---

# 通用 Hooks 配置

> 所有项目通用的 Git Hooks 配置。

## Husky 配置

```bash
npx husky install
```

## 通用 Hooks

### pre-commit

- 代码格式检查
- Lint 检查

### commit-msg

- 提交信息规范检查 (Conventional Commits)
