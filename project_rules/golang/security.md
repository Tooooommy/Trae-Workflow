---
alwaysApply: false
globs:
  - '**/*.go'
  - '**/go.mod'
  - '**/go.sum'
---

# Go 安全

> Go 语言特定的安全最佳实践。

## 密钥管理

```go
apiKey := os.Getenv("OPENAI_API_KEY")
if apiKey == "" {
    log.Fatal("OPENAI_API_KEY not configured")
}
```

## 安全扫描

使用 **gosec** 进行静态安全分析：

```bash
gosec ./...
```

## 上下文与超时

始终使用 `context.Context` 进行超时控制：

```go
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
```

## SQL 注入防护

使用参数化查询：

```go
// 使用 database/sql
rows, err := db.Query("SELECT * FROM users WHERE email = ?", email)

// 使用 GORM
db.Where("email = ?", email).First(&user)
```

## 相关智能体

- `security-reviewer` - 安全漏洞检测

## 相关技能

- `security-review` - 安全检查清单
- `validation-patterns` - 数据验证模式
