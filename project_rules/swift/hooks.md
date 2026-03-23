---
alwaysApply: false
globs:
  - '**/*.swift'
  - '**/Package.swift'
---

# Swift 钩子

> Swift 特定的钩子配置。

## PostToolUse 钩子

- **SwiftFormat**: 在编辑后自动格式化 `.swift` 文件
- **SwiftLint**: 在编辑 `.swift` 文件后运行代码检查
- **swift build**: 在编辑后对修改的包进行类型检查

## 警告

标记 `print()` 语句 — 在生产代码中请改用 `os.Logger` 或结构化日志记录。

## 相关智能体

- `devops-expert` - CI/CD 和工具配置

## 相关技能

- `ci-cd-patterns` - CI/CD 流水线模式
