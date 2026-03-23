---
alwaysApply: false
globs:
  - '**/*.go'
  - '**/go.mod'
  - '**/go.sum'
---

# Go 编码风格

> Go 语言特定的编码规范。

## 格式化

- **gofmt** 和 **goimports** 是强制性的 —— 无需进行风格辩论

## 设计原则

- 接受接口，返回结构体
- 保持接口小巧（1-3 个方法）

## 错误处理

始终用上下文包装错误：

```go
if err != nil {
    return fmt.Errorf("failed to create user: %w", err)
}
```

## 相关智能体

- `code-reviewer` - 代码质量和规范检查

## 相关技能

- `coding-standards` - 通用编码标准
