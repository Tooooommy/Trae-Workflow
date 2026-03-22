---
alwaysApply: false
globs:
  - "**/*.py"
  - "**/*.pyi"
---

# FastAPI MVP 项目规范与指南

> 基于 FastAPI 和 TortoiseORM 构建的现代化、高性能、异步优先的 RESTful API 项目模板与开发规范。

## 项目总览
*技术栈: Python 3.12+, FastAPI, TortoiseORM, PostgreSQL, Pydantic v2, Aerich, Redis
*架构: 异步优先，无状态 API，使用 JWT 认证

## 关键规则

### Python 约定
* 所有函数签名必须使用完整的类型提示
* 必须使用 logging.getLogger(__name__)并根据场景选择合适日志级别 (DEBUG, INFO, ERROR)
* 字符串格式化统一使用 f-string。
* 路径操作使用 pathlib.Path，而非 os.path。
* 导入排序使用 ruff或 isort规范：标准库 → 第三方库 → 本地模块。

### 数据库与 TortoiseORM
* 所有查询必须使用 TortoiseORM 的异步 API
* 迁移使用 Aerich 管理，迁移文件提交到 git
* 使用 select_related()和 prefetch_related()防止 N+1 查询，使用 .only()限制返回字段以优化性能
* 所有模型应继承自包含 id, created_at, updated_at的 BaseModel
* 在频繁用于 filter()、order_by()的字段上建立索引

### 认证与安全
* 通过 python-jose和 passlib使用 JWT 认证，配合 FastAPI 的 OAuth2PasswordBearer
* API 端点必须通过依赖项显式声明权限要求（如 Depends(get_current_user)）
* 密码必须使用 passlib哈希存储，绝不在响应中返回

### Pydantic 模式 (Schemas)
* 严格区分请求模式​ (Request) 和响应模式​ (Response)
* 业务规则验证放在 Pydantic 模型的 @field_validator中
* 利用 Pydantic V2 的 model_config进行高级配置（如 from_attributes=True以支持 ORM 对象转换）。

### API 设计
* 遵循 RESTful 原则，在 URL 中使用名词复数（如 /api/v1/users），并通过 HTTP 方法区分操作。
* 所有列表接口必须支持分页（skip， limit参数）。
* 响应格式统一为包含 status、data、error、meta的 JSON 结构。
* 使用正确的 HTTP 状态码：200成功，201创建，400请求错误，401未认证，403无权限，404不存在，422验证错误，500服务器错误。

### 错误处理
* 在 core/exceptions.py中定义业务自定义异常
* 通过 FastAPI 的异常处理器确保一致的错误响应格式
* 生产环境下，错误响应中禁止暴露堆栈跟踪、SQL 语句等内部细节

## 文件结构
```
fastapi-tortoise-project/
├── app/
│   ├── api/                    # API 层
│   │   ├── v1/               # API 版本
│   │   │   ├── __init__.py
│   │   │   ├── endpoints/    # 路由端点
│   │   │   │   ├── __init__.py
│   │   │   │   ├── auth.py
│   │   │   │   ├── users.py
│   │   │   │   └── posts.py
│   │   │   ├── dependencies.py  # 路由级依赖
│   │   │   └── router.py     # 路由注册
│   │   └── __init__.py
│   ├── core/                  # 核心配置
│   │   ├── __init__.py
│   │   ├── config.py         # 配置管理 (Pydantic Settings)
│   │   ├── database.py       # TortoiseORM 配置
│   │   ├── security.py       # 认证、JWT、密码
│   │   ├── exceptions.py     # 自定义异常
│   │   ├── middleware.py     # 中间件
│   │   └── dependencies.py   # 应用级依赖
│   ├── models/               # TortoiseORM 模型
│   │   ├── __init__.py
│   │   ├── base.py          # 模型基类
│   │   ├── user.py
│   │   ├── post.py
│   │   └── comment.py
│   ├── schemas/              # Pydantic 模式
│   │   ├── __init__.py
│   │   ├── base.py          # 基础模式
│   │   ├── token.py
│   │   ├── user/
│   │   │   ├── __init__.py
│   │   │   ├── request.py   # 请求模式
│   │   │   └── response.py  # 响应模式
│   │   └── post/
│   │       ├── __init__.py
│   │       ├── request.py
│   │       └── response.py
│   ├── services/            # 业务逻辑层
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── auth_service.py
│   │   ├── user_service.py
│   │   └── post_service.py
│   ├── repositories/        # 数据访问层 (可选，TortoiseORM 已提供类似功能)
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── user_repo.py
│   │   └── post_repo.py
│   ├── utils/               # 工具函数
│   │   ├── __init__.py
│   │   ├── validators.py
│   │   ├── pagination.py
│   │   ├── logging_config.py
│   │   └── cache.py         # Redis 缓存工具
│   ├── workers/             # 异步任务 (可选)
│   │   ├── __init__.py
│   │   └── tasks.py
│   ├── main.py             # FastAPI 应用入口
│   └── __init__.py
├── migrations/              # Aerich 迁移目录
│   ├── models/             # 模型定义快照
│   └── versions/           # 迁移版本
├── tests/                  # 测试
│   ├── __init__.py
│   ├── conftest.py
│   ├── api/
│   │   └── v1/
│   │       ├── test_auth.py
│   │       └── test_users.py
│   ├── services/
│   │   └── test_user_service.py
│   └── factories.py       # Factory Boy 工厂
├── requirements/
│   ├── base.txt           # 基础依赖
│   ├── dev.txt           # 开发依赖
│   └── prod.txt         # 生产依赖
├── alembic.ini           # Aerich 使用 tortoise-orm 的配置
├── docker-compose.yml
├── Dockerfile
├── .env.example
├── .pre-commit-config.yaml
├── pyproject.toml        # 项目配置
├── aerich.ini           # Aerich 配置文件
└── README.md
```
## 关键模式

### 服务层与端点 (依赖注入)
```python
# services/user_service.py
class UserService:
    async def create_user(self, user_in: UserCreate) -> User:
        if await User.filter(email=user_in.email).exists():
            raise BusinessError("DUPLICATE_EMAIL", "邮箱已注册")
        hashed_pw = get_password_hash(user_in.password)
        return await User.create(**user_in.dict(exclude={"password"}), hashed_password=hashed_pw)

# api/v1/endpoints/users.py
@router.post("/", response_model=UserResponse)
async def create_user(
    user_in: UserCreate,
    user_service: UserService = Depends(get_user_service) # 依赖注入
):
    return await user_service.create_user(user_in)
```

### 测试模式
* 测试工具: pytest + pytest-asyncio + HTTPX AsyncClient
* 独立性: 使用独立的测试数据库，通过 pytestfixture 实现数据隔离 
* 确定性: 测试结果必须一致，不使用随机数据
* 覆盖重点: 优先覆盖成功路径、关键业务错误和输入验证

## 环境变量
* .env环境变量文件用于配置开发环境
* .env.prod环境变量文件用于配置生产环境
```bash
# 项目核心
PROJECT_NAME=My FastAPI App
ENVIRONMENT=development  # development, production
SECRET_KEY=your-secret-key-change-this

# 数据库 (PostgreSQL)
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=fastapi_db

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALGORITHM=HS256
```
## 开发与部署
* 在 feature/*分支开发，通过 PR 合并到 main
* 通过 Docker/Docker Compose 部署到生产环境