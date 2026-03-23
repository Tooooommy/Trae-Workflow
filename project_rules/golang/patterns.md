---
alwaysApply: false
globs:
  - '**/*.go'
  - '**/go.mod'
  - '**/go.sum'
---

# Go 模式

> Go 语言特定的架构模式。

## 函数式选项

```go
type Option func(*Server)

func WithPort(port int) Option {
    return func(s *Server) { s.port = port }
}

func NewServer(opts ...Option) *Server {
    s := &Server{port: 8080}
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

## 相关智能体

- `architect` - 架构设计和模式选择

## 相关技能

- `golang-patterns` - Go 惯用模式
- `clean-architecture` - 整洁架构
