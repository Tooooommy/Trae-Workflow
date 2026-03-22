---
alwaysApply: false
globs:
  - '**/echo.go'
  - '**/main.go'
---

# Echo 项目规范与指南

> 基于 Echo 框架的 Go Web 应用开发规范。

## 项目总览

- 技术栈: Go 1.22+, Echo v4, GORM, PostgreSQL
- 架构: Handler-Service-Repository 三层架构

## 关键规则

### 项目结构

```
app/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── config/
│   │   └── config.go
│   ├── handler/
│   │   ├── user_handler.go
│   │   └── auth_handler.go
│   ├── middleware/
│   │   ├── auth.go
│   │   └── logger.go
│   ├── model/
│   │   └── user.go
│   ├── repository/
│   │   └── user_repo.go
│   ├── service/
│   │   └── user_service.go
│   └── pkg/
│       ├── database/
│       └── validator/
├── pkg/
│   └── response/
├── go.mod
└── go.sum
```

### Handler

```go
package handler

import (
    "net/http"
    "github.com/labstack/echo/v4"
)

type UserHandler struct {
    service UserService
}

func (h *UserHandler) Create(c echo.Context) error {
    var req CreateUserRequest
    if err := c.Bind(&req); err != nil {
        return c.JSON(http.StatusBadRequest, ErrorResponse(err))
    }

    user, err := h.service.Create(c.Request().Context(), &req)
    if err != nil {
        return c.JSON(http.StatusInternalServerError, ErrorResponse(err))
    }

    return c.JSON(http.StatusCreated, SuccessResponse(user))
}
```

### 路由注册

```go
func RegisterRoutes(e *echo.Echo, h *Handler) {
    api := e.Group("/api/v1")

    // Public routes
    api.POST("/auth/login", h.Auth.Login)
    api.POST("/auth/register", h.Auth.Register)

    // Protected routes
    protected := api.Group("")
    protected.Use(middleware.JWTWithConfig(config))
    protected.GET("/users", h.User.List)
    protected.GET("/users/:id", h.User.Get)
}
```

## 环境变量

```bash
APP_ENV=development
APP_PORT=8080
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=echo_app
JWT_SECRET=your-secret-key
```

## 开发命令

```bash
go run cmd/server/main.go    # 开发服务器
go build -o bin/server       # 构建
go test ./...                # 测试
```
