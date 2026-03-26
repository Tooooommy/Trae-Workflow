---
name: gin-patterns
description: Gin Web 框架模式，涵盖路由组、中间件、参数绑定、验证和性能优化。适用于 Go 后端 API 开发、微服务架构和高性能 HTTP 服务。**必须激活当**：用户要求构建 Go 后端 API、使用 Gin 框架、设计 HTTP 中间件或优化 Go Web 服务性能时。
---

# Gin Web 框架模式

用于构建高性能 Go Web 服务的 Gin 框架模式和最佳实践。

## 何时激活

- 构建 Go HTTP API
- 设计 Go Web 中间件
- 实现路由和参数绑定
- 优化 Go 服务性能
- Go 微服务开发

## 技术栈版本

| 技术     | 最低版本 | 推荐版本 |
| -------- | -------- | -------- |
| Go       | 1.20+    | 1.22+    |
| Gin      | 1.9+     | 1.10+    |
| GORM     | 1.25+    | 最新     |
| go-redis | 9.0+     | 最新     |

## 核心概念

| 概念        | 说明         |
| ----------- | ------------ |
| Engine      | Gin 应用核心 |
| RouterGroup | 路由分组     |
| Middleware  | 中间件链     |
| Context     | 请求上下文   |

## 项目结构

```
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── handler/
│   ├── middleware/
│   ├── model/
│   ├── repository/
│   └── service/
├── pkg/
│   ├── response/
│   └── validator/
└── config/
```

## 基础路由

```go
func main() {
    r := gin.Default()

    // 健康检查
    r.GET("/health", func(c *gin.Context) {
        c.JSON(200, gin.H{"status": "ok"})
    })

    // API 路由
    v1 := r.Group("/api/v1")
    {
        v1.GET("/users", listUsers)
        v1.POST("/users", createUser)
        v1.GET("/users/:id", getUser)
        v1.PUT("/users/:id", updateUser)
        v1.DELETE("/users/:id", deleteUser)
    }

    r.Run(":8080")
}
```

## 路由组

```go
func SetupRouter() *gin.Engine {
    r := gin.New()
    r.Use(gin.Logger())
    r.Use(gin.Recovery())

    // 公开路由
    public := r.Group("")
    {
        public.POST("/login", authHandler.Login)
        public.POST("/register", authHandler.Register)
    }

    // 需要认证的路由
    auth := r.Group("/api")
    auth.Use(middleware.AuthRequired())
    {
        users := auth.Group("/users")
        {
            users.GET("", listUsers)
            users.GET("/:id", getUser)
            users.PUT("/:id", updateUser)
            users.DELETE("/:id", deleteUser)
        }

        orders := auth.Group("/orders")
        {
            orders.GET("", listOrders)
            orders.POST("", createOrder)
            orders.GET("/:id", getOrder)
        }
    }

    return r
}
```

## 中间件模式

### 日志中间件

```go
func Logger() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path
        raw := c.Request.URL.RawQuery

        c.Next()

        latency := time.Since(start)
        status := c.Writer.Status()
        clientIP := c.ClientIP()
        method := c.Request.Method

        if raw != "" {
            path = path + "?" + raw
        }

        log.Printf("[GIN] %3d | %13v | %15s | %-7s %s",
            status,
            latency,
            clientIP,
            method,
            path,
        )
    }
}
```

### 认证中间件

```go
func AuthRequired() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            response.Unauthorized(c, "missing token")
            c.Abort()
            return
        }

        claims, err := jwt.ParseToken(token)
        if err != nil {
            response.Unauthorized(c, "invalid token")
            c.Abort()
            return
        }

        c.Set("user_id", claims.UserID)
        c.Next()
    }
}
```

### CORS 中间件

```go
func CORS() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
        c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
        c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Authorization, Accept, X-Requested-With")
        c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE, PATCH")

        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }

        c.Next()
    }
}
```

## 参数绑定与验证

### 绑定 JSON

```go
type CreateUserRequest struct {
    Name     string `json:"name" binding:"required,min=2,max=50"`
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required,min=8"`
    Age      int    `json:"age" binding:"omitempty,min=0,max=150"`
}

func createUser(c *gin.Context) {
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, err.Error())
        return
    }

    user, err := userService.Create(&req)
    if err != nil {
        response.Error(c, err)
        return
    }

    response.Created(c, user)
}
```

### 绑定 URI 参数

```go
func getUser(c *gin.Context) {
    id := c.Param("id")
    userID, err := strconv.ParseUint(id, 10, 64)
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    user, err := userService.GetByID(userID)
    if err != nil {
        response.NotFound(c, "user not found")
        return
    }

    response.OK(c, user)
}
```

### 自定义验证器

```go
import "github.com/go-playground/validator/v10"

func RegisterCustomValidators(v *validator.Validate) {
    v.RegisterValidation("phone", func(fl validator.FieldLevel) bool {
        phone := fl.Field().String()
        return regexp.MustCompile(`^1[3-9]\d{9}$`).MatchString(phone)
    })
}
```

## 统一响应

```go
package response

type Response struct {
    Code int         `json:"code"`
    Msg  string      `json:"msg"`
    Data interface{} `json:"data,omitempty"`
}

func OK(c *gin.Context, data interface{}) {
    c.JSON(200, Response{Code: 0, Msg: "success", Data: data})
}

func Created(c *gin.Context, data interface{}) {
    c.JSON(201, Response{Code: 0, Msg: "created", Data: data})
}

func BadRequest(c *gin.Context, msg string) {
    c.JSON(400, Response{Code: 400, Msg: msg})
}

func Unauthorized(c *gin.Context, msg string) {
    c.JSON(401, Response{Code: 401, Msg: msg})
}

func NotFound(c *gin.Context, msg string) {
    c.JSON(404, Response{Code: 404, Msg: msg})
}

func Error(c *gin.Context, err error) {
    c.JSON(500, Response{Code: 500, Msg: err.Error()})
}
```

## 错误处理

```go
type AppError struct {
    Code    int
    Message string
    Err     error
}

func (e *AppError) Error() string {
    return e.Message
}

func NewAppError(code int, message string, err error) *AppError {
    return &AppError{Code: code, Message: message, Err: err}
}

// 在 service 层使用
func (s *UserService) GetByID(id uint) (*User, error) {
    user, err := s.repo.FindByID(id)
    if err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            return nil, NewAppError(404, "user not found", err)
        }
        return nil, NewAppError(500, "database error", err)
    }
    return user, nil
}
```

## 性能优化

### 连接池

```go
func InitDB() (*gorm.DB, error) {
    db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
    if err != nil {
        return nil, err
    }

    sqlDB, err := db.DB()
    if err != nil {
        return nil, err
    }

    // 连接池设置
    sqlDB.SetMaxIdleConns(10)
    sqlDB.SetMaxOpenConns(100)
    sqlDB.SetConnMaxLifetime(time.Hour)

    return db, nil
}
```

### 缓存中间件

```go
func CacheMiddleware(cache *redis.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        key := c.Request.URL.String()
        cached, err := cache.Get(c.Request.Context(), key).Result()
        if err == nil {
            c.Header("X-Cache", "HIT")
            c.String(200, cached)
            c.Abort()
            return
        }

        c.Header("X-Cache", "MISS")
        c.Next()
    }
}
```

## Gin 特有功能

### 重定向

```go
r.GET("/old-path", func(c *gin.Context) {
    c.Redirect(301, "/new-path")
})
```

### 静态文件

```go
r.Static("/assets", "./public/assets")
r.StaticFile("/favicon.ico", "./public/favicon.ico")
```

### 渲染模板

```go
r.LoadHTMLGlob("templates/*")

r.GET("/page", func(c *gin.Context) {
    c.HTML(200, "index.html", gin.H{
        "title": "Home",
    })
})
```

## 相关技能

| 技能              | 说明            |
| ----------------- | --------------- |
| golang-patterns   | Go 通用模式     |
| backend-expert    | 后端架构模式    |
| postgres-patterns | PostgreSQL 模式 |
| caching-patterns  | 缓存模式        |
| kafka-patterns    | Kafka 消息模式  |
