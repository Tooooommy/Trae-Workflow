---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/*.kts'
---

# Kotlin 钩子

> Kotlin 特定的钩子配置。

## PostToolUse 钩子

- **ktlint**: 在编辑后自动格式化 `.kt` 文件
- **Detekt**: 在编辑 Kotlin 文件后运行代码检查
- **Gradle**: 在编辑后运行增量编译

## 警告

标记 `Log.d()` / `Log.e()` — 在生产代码中请改用统一的日志框架。

## 相关智能体

- `devops-expert` - CI/CD 和工具配置

## 相关技能

- `ci-cd-patterns` - CI/CD 流水线模式
