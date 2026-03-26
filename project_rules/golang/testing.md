---
alwaysApply: false
globs:
  - '**/*.go'
  - '**/go.mod'
  - '**/go.sum'
---

# Go 测试

> Go 语言特定的测试框架和策略。

## 测试框架

使用标准的 `go test` 并采用 **表格驱动测试**。

## 表格驱动测试

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 1, 2, 3},
        {"negative", -1, -2, -3},
        {"zero", 0, 0, 0},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := Add(tt.a, tt.b); got != tt.expected {
                t.Errorf("Add() = %v, want %v", got, tt.expected)
            }
        })
    }
}
```

## 竞态检测

始终使用 `-race` 标志运行：

```bash
go test -race ./...
```

## 覆盖率

```bash
go test -cover ./...
```

## 相关智能体

- `testing-expert` - TDD 工作流和测试策略

## 相关技能

- `golang-testing` - Go 测试模式
- `tdd-patterns` - 测试驱动开发
