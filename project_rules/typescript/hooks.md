---
alwaysApply: false
globs:
  - '**/*.ts'
  - '**/*.tsx'
  - '**/*.js'
  - '**/*.jsx'
---

# TypeScript/JavaScript 钩子

> TypeScript/JavaScript 特定的钩子配置。

## PostToolUse 钩子

- **Prettier**：编辑后自动格式化 JS/TS 文件
- **TypeScript 检查**：编辑 `.ts`/`.tsx` 文件后运行 `tsc`
- **console.log 警告**：警告编辑过的文件中存在 `console.log`

## Stop 钩子

- **console.log 审计**：在会话结束前，检查所有修改过的文件中是否存在 `console.log`

## 相关智能体

- `devops-expert` - CI/CD 和工具配置

## 相关技能

- `ci-cd-patterns` - CI/CD 流水线模式
