---
alwaysApply: false
globs:
  - "**/fiber.go"
  - "**/main.go"
---

# Fiber 项目规范与指南

> 基于 Fiber 框架的 Go Web 应用开发规范。

## 项目总览

* 技术栈: Go 1.22+, Fiber v2, GORM, PostgreSQL
* 架构: Handler-Service-Repository 三层架构

## 关键规则

### 项目结构

```
app/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── config/
│   ├── handler/
│   ├── middleware/
│   ├── model/
│   ├── repository/
│   ├── service/
│   └── pkg/
├── pkg/
├── go.mod
└── go.sum
```

### Handler

```go
package handler

import (
    "github.com/gofiber/fiber/v2"
)

type UserHandler struct {
    service UserService
}

func (h *UserHandler) Create(c *fiber.Ctx) error {
    var req CreateUserRequest
    if err := c.BodyParser(&req); err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error": "Invalid request body",
        })
    }

    user, err := h.service.Create(c.Context(), &req)
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": err.Error(),
        })
    }

    return c.Status(fiber.StatusCreated).JSON(fiber.Map{
        "data": user,
    })
}
```

### 路由注册

```go
func RegisterRoutes(app *fiber.App, h *Handler) {
    api := app.Group("/api/v1")

    // Public routes
    api.Post("/auth/login", h.Auth.Login)
    api.Post("/auth/register", h.Auth.Register)

    // Protected routes
    protected := api.Group("")
    protected.Use(middleware.Protected())
    protected.Get("/users", h.User.List)
    protected.Get("/users/:id", h.User.Get)
}
```

## 环境变量

```bash
APP_ENV=development
APP_PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=fiber_app
JWT_SECRET=your-secret-key
```

## 开发命令

```bash
go run cmd/server/main.go    # 开发服务器
go build -o bin/server       # 构建
go test ./...                # 测试
```
