---
alwaysApply: false
globs:
  - '**/*.go'
  - '**/go.mod'
  - '**/go.sum'
---

# Go 钩子

> Go 特定的钩子配置。

## PostToolUse 钩子

- **gofmt/goimports**：编辑后自动格式化 `.go` 文件
- **go vet**：编辑 `.go` 文件后运行静态分析
- **staticcheck**：对修改的包运行扩展静态检查

## 相关智能体

- `devops-expert` - CI/CD 和工具配置

## 相关技能

- `ci-cd-patterns` - CI/CD 流水线模式
