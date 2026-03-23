---
alwaysApply: false
globs:
  - '**/*.py'
  - '**/*.pyi'
---

# Python 钩子

> Python 特定的钩子配置。

## PostToolUse 钩子

- **black/ruff**：编辑后自动格式化 `.py` 文件
- **mypy/pyright**：编辑 `.py` 文件后运行类型检查

## 警告

- 对编辑文件中的 `print()` 语句发出警告（应使用 `logging` 模块替代）

## 相关智能体

- `devops-expert` - CI/CD 和工具配置

## 相关技能

- `ci-cd-patterns` - CI/CD 流水线模式
