---
alwaysApply: false
globs:
  - "**/*.go"
  - "**/go.mod"
---
# Go REST API 项目规范与开发指南

> 基于 Gin + GORM + PostgreSQL 技术栈的 Go 项目核心规范。

## 项目总览
* 技术栈: Go 1.26+, Gin(web框架), GORM(ORM), PostgreSQL(主库), Redis(缓存/队列)
* 架构: Controller-Service-Repository 三层清晰架构, 输出纯JSON API

## 关键规则

### Go 约定
* 不使用 fmt.Print()输出业务日志 — 使用 log/slog或 logrus等结构化日志库
* 使用 golangci-lint进行代码检查，配置见 .golangci.yml
* 提交前必须运行go fmt与goimports格式化
* 绝不忽略错误。业务错误应在 internal/pkg/errors中定义明确类型
* 所有业务逻辑和数据库操作都必须有对应的测试用例

### 数据库 (GORM)
* 优先使用 GORM 的链式调用和方法，避免手写原生 SQL
* 模型必须内嵌 gorm.Model或包含 ID, CreatedAt, UpdatedAt, DeletedAt的基础模型
* 使用 Joins或 Preload避免 N+1 查询。
* 确保在 Where(), Order()或 Joins()中使用频繁的字段上建立索引
* 跨表操作必须在Service层使用db.Transaction 

### 认证与授权
* 通过 github.com/golang-jwt/jwt/v5使用 JWT — 访问令牌 (15 分钟) + 刷新令牌 (7 天)
* 通过 Gin 中间件显式设置认证和权限，绝不依赖隐式默认
* 令牌黑名单 (可使用 Redis 存储失效的令牌)

### 请求与响应处理
* 简单 CRUD 使用 Gin 的 ShouldBindJSON与结构体标签绑定，复杂验证在结构体的自定义方法或独立验证函数中进行
* 输入 (Request) 和输出 (Response) 使用不同的结构体定义，保持 API 契约的清晰
* 验证逻辑放在绑定结构体的方法中，或在进入 Service 业务逻辑前完成 — Controller 应保持精简

### 错误处理
* 使用 Gin 的全局中间件或自定义 Recovery中间件确保一致的错误响应格式
* 业务逻辑中的自定义错误放在 internal/pkg/errors/中，定义清晰的错误码和信息
* 绝不向客户端暴露数据库错误、堆栈跟踪等内部细节，在生产环境返回友好信息

### 目录结构
```
app/
├── cmd/                      # 应用程序入口
│   └── server/
│       └── main.go          # 主入口文件
├── internal/                # 私有应用程序代码（禁止外部导入）
│   ├── config/              # 配置文件加载
│   ├── controller/          # 控制器层（HTTP处理）
│   ├── service/             # 业务逻辑层
│   ├── repository/          # 数据访问层
│   │   └── models/          # 数据模型定义
│   ├── middleware/          # 自定义中间件
│   └── pkg/                 # 内部共享包
│       ├── database/        # 数据库初始化
│       ├── cache/           # 缓存客户端
│       └── validator/       # 自定义验证器
├── pkg/                     # 可对外公开的库代码
│   ├── response/            # 统一响应格式
│   └── utils/               # 通用工具函数
├── api/                     # API定义
│   └── docs/                # Swagger/OpenAPI文档
├── scripts/                 # 构建、部署脚本
├── test/                    # 集成测试、E2E测试
├── web/                     # 前端资源（可选）
├── migrations/              # 数据库迁移文件
├── docker-compose.yml       # 开发环境Docker编排
├── Dockerfile              # 生产环境Dockerfile
├── Makefile                # 构建命令封装
├── go.mod                  # Go模块定义
├── go.sum                  # 依赖校验
└── README.md               # 项目说明
```

## 关键模式
* Controller: 处理 HTTP 请求/响应，参数绑定与基础验证
* Service: 实现所有业务逻辑，协调多个 Repository 调用，处理事务
* Repository: 封装所有数据库操作，返回模型或错误

## 测试模式
* 测试位置: 测试文件与被测文件同级，命名为 *_test.go。
* 单元测试: 测试独立的函数、方法。使用 Mock 隔离外部依赖（数据库、缓存、HTTP 客户端）
* 集成测试: 测试多个组件协作，如 Service 层调用真实的 Repository。使用测试数据库（如 Docker 启动的 PostgreSQL 容器）
* E2E测试: 测试完整的 HTTP API 端点。使用 net/http/httptest启动测试服务器
* 测试数据: 使用 Testify 的 Mock 组件​ 模拟依赖，使用 工厂函数 (Factory)​ 或 固定测试数据 (Fixtures)​ 创建模型实例
* 项目核心业务逻辑的测试覆盖率80% 以上

## 环境变量
* .env环境变量文件用于配置开发环境
* .env.prod环境变量文件用于配置生产环境
```bash
# 应用
APP_ENV=development
APP_PORT=8080
APP_SECRET=your-secret-key-change-in-production

# 数据库
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=go_mvp
DB_SSLMODE=disable

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT
JWT_ACCESS_TOKEN_LIFETIME=15    # minutes
JWT_REFRESH_TOKEN_LIFETIME=10080 # minutes (7 days)
```

## 开发与部署
* 在 feature/*分支开发，通过 PR 合并到 main
* 通过 Docker/Docker Compose 部署到生产环境
