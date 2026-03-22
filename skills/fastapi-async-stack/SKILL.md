---
name: fastapi-async-stack
description: FastAPI 异步全栈开发模式，涵盖架构模式、安全实践、测试驱动开发和项目验证循环。基于 FastAPI、TortoiseORM、Celery 和现代 Python 工具链，适用于构建高性能、可维护的生产级 API 和微服务。
---

# FastAPI 异步全栈开发模式

基于 FastAPI、Pydantic v2、PostgreSQL、TortoiseORM、Celery、Redis 的完整异步技术栈开发模式。包含现代化项目架构、异步数据访问、消息队列集成、结构化日志、安全最佳实践、测试策略和生产部署验证。

## 何时激活

- 使用 **FastAPI** 构建高性能异步 REST API 或 WebSocket 服务
- 采用 **TortoiseORM** 进行异步数据库操作（偏好 Django ORM 风格）
- 使用 **Celery + RabbitMQ** 处理后台异步任务（如邮件、报告生成、数据处理）
- 使用 **PostgreSQL** 作为主数据库，**Redis** 用于缓存、会话和消息代理
- 需要 **结构化日志**、完善的 **API 文档** 和完整的 **测试覆盖**
- 构建需要完整异步技术栈的生产级微服务

## 开发模式 (Patterns)

### 项目结构与组织

```bash
myproject/
├── src/
│   ├── core/                    # 核心配置与工具
│   │   ├── __init__.py
│   │   ├── config.py           # Pydantic Settings 配置
│   │   ├── database.py         # TortoiseORM 初始化
│   │   ├── dependencies.py     # FastAPI 依赖项
│   │   ├── security.py         # 认证授权
│   │   ├── celery_app.py       # Celery 应用配置
│   │   └── logging.py          # Structlog 配置
│   ├── models/                 # TortoiseORM 数据模型
│   │   ├── __init__.py         # 集中导入（Aerich 需要）
│   │   ├── base.py             # 基础模型与 Mixin
│   │   ├── user.py
│   │   └── product.py
│   ├── schemas/                # Pydantic 模式（DTO）
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── user.py
│   │   └── product.py
│   ├── repositories/           # 数据访问层
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── user.py
│   │   └── product.py
│   ├── services/               # 业务逻辑层
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── user.py
│   │   └── product.py
│   ├── api/                    # API 层
│   │   ├── __init__.py
│   │   ├── dependencies.py     # API 特定依赖
│   │   ├── errors.py          # 错误处理器
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── api.py         # 路由聚合
│   │       └── endpoints/
│   │           ├── auth.py
│   │           ├── users.py
│   │           └── products.py
│   ├── workers/               # Celery 任务
│   │   ├── __init__.py
│   │   ├── tasks.py           # 任务定义
│   │   ├── email_tasks.py
│   │   └── report_tasks.py
│   ├── utils/                 # 通用工具
│   │   ├── __init__.py
│   │   ├── security.py
│   │   ├── cache.py           # Redis 缓存
│   │   └── validators.py
│   └── main.py               # FastAPI 应用入口
├── tests/                    # 测试
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_api/
│   └── test_services/
├── alembic/                  # 数据库迁移（备用方案）
├── migrations/               # Aerich 迁移
├── .env.example
├── .gitignore
├── pyproject.toml
├── requirements.txt
├── docker-compose.yml
├── Dockerfile
└── README.md
```

### 配置管理 (Pydantic Settings)

```python
#src/core/config.py

from typing import List, Optional
from pydantic_settings import BaseSettings
from pydantic import PostgresDsn, RedisDsn, AmqpDsn
from functools import lru_cache

class Settings(BaseSettings):
    """应用配置，支持 .env 文件"""

    # 应用
    APP_NAME: str = "FastAPI Async Stack"
    DEBUG: bool = False
    ENVIRONMENT: str = "development"

    # API
    API_V1_PREFIX: str = "/api/v1"
    PROJECT_NAME: str = "FastAPI Project"

    # 安全
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    CORS_ORIGINS: List[str] = ["http://localhost:3000"]

    # PostgreSQL (TortoiseORM)
    POSTGRES_SERVER: str
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str
    POSTGRES_PORT: int = 5432

    # Redis (缓存 + Celery Broker)
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_PASSWORD: Optional[str] = None
    REDIS_DB_CACHE: int = 0
    REDIS_DB_CELERY: int = 1

    # RabbitMQ (Celery Broker，生产环境推荐)
    RABBITMQ_HOST: Optional[str] = None
    RABBITMQ_PORT: int = 5672
    RABBITMQ_USER: str = "guest"
    RABBITMQ_PASSWORD: str = "guest"
    RABBITMQ_VHOST: str = "/"

    # Celery
    CELERY_BROKER_URL: Optional[str] = None
    CELERY_RESULT_BACKEND: Optional[str] = None

    # TortoiseORM 模型配置 (Aerich 需要)
    MODELS: List[str] = ["src.models", "aerich.models"]

    class Config:
        env_file = ".env"
        case_sensitive = True

    @property
    def database_url(self) -> str:
        """TortoiseORM 数据库 URL"""
        return (
            f"postgres://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    @property
    def tortoise_orm_config(self) -> dict:
        """TortoiseORM 配置字典"""
        return {
            "connections": {
                "default": {
                    "engine": "tortoise.backends.asyncpg",
                    "credentials": {
                        "host": self.POSTGRES_SERVER,
                        "port": self.POSTGRES_PORT,
                        "user": self.POSTGRES_USER,
                        "password": self.POSTGRES_PASSWORD,
                        "database": self.POSTGRES_DB,
                        "minsize": 1,
                        "maxsize": 20,
                    }
                }
            },
            "apps": {
                "models": {
                    "models": self.MODELS,
                    "default_connection": "default",
                }
            },
            "use_tz": True,
            "timezone": "UTC",
        }

    @property
    def redis_url(self) -> str:
        """Redis URL (缓存)"""
        auth = f":{self.REDIS_PASSWORD}@" if self.REDIS_PASSWORD else ""
        return f"redis://{auth}{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB_CACHE}"

    @property
    def celery_broker_url(self) -> str:
        """Celery Broker URL (优先使用 RabbitMQ)"""
        if self.CELERY_BROKER_URL:
            return self.CELERY_BROKER_URL

        if self.RABBITMQ_HOST:
            return (
                f"amqp://{self.RABBITMQ_USER}:{self.RABBITMQ_PASSWORD}"
                f"@{self.RABBITMQ_HOST}:{self.RABBITMQ_PORT}/{self.RABBITMQ_VHOST}"
            )

        # 回退到 Redis
        auth = f":{self.REDIS_PASSWORD}@" if self.REDIS_PASSWORD else ""
        return f"redis://{auth}{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB_CELERY}"

@lru_cache()
def get_settings() -> Settings:
    """获取缓存的配置单例"""
    return Settings()

settings = get_settings()
```

### 依赖注入模式 (FastAPI Depends)

```python
#src/core/dependencies.py

from typing import AsyncGenerator
from fastapi import Depends, HTTPException, status, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt

from .config import get_settings
from src.repositories.user import UserRepository
from src.services.auth import AuthService

settings = get_settings()
security = HTTPBearer()

async def get_user_repository() -> AsyncGenerator[UserRepository, None]:
    """获取用户 Repository"""
    yield UserRepository()

async def get_auth_service(
    user_repo: UserRepository = Depends(get_user_repository)
) -> AsyncGenerator[AuthService, None]:
    """获取认证服务"""
    yield AuthService(user_repo)

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security),
    auth_service: AuthService = Depends(get_auth_service)
):
    """获取当前认证用户（依赖项）"""
    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="无效的凭据"
            )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="凭据验证失败"
        )

    user = await auth_service.get_user_by_id(int(user_id))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户不存在"
        )

    return user
```

### Repository 模式 (TortoiseORM)

```python
#src/repositories/base.py

from typing import Generic, TypeVar, Type, Optional, List, Dict, Any
from tortoise.models import Model
from tortoise.expressions import Q
from tortoise.functions import Count
from pydantic import BaseModel

ModelType = TypeVar("ModelType", bound=Model)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)

class BaseRepository(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    """基础 Repository (数据访问层)"""

    def __init__(self, model: Type[ModelType]):
        self.model = model

    async def get(self, id: int) -> Optional[ModelType]:
        """通过 ID 获取"""
        return await self.model.get_or_none(id=id)

    async def get_by(self, filters) -> Optional[ModelType]:
        """通过条件获取单个"""
        return await self.model.get_or_none(filters)

    async def filter(
        self,
        *,
        offset: int = 0,
        limit: int = 100,
        order_by: Optional[List[str]] = None,
        filters
    ) -> List[ModelType]:
        """过滤查询"""
        query = self.model.filter(filters)

        if order_by:
            query = query.order_by(*order_by)

        return await query.offset(offset).limit(limit)

    async def create(self, obj_in: CreateSchemaType, kwargs) -> ModelType:
        """创建记录"""
        obj_in_data = obj_in.model_dump(exclude_unset=True)
        obj_in_data.update(kwargs)
        return await self.model.create(obj_in_data)

    async def update(
        self,
        db_obj: ModelType,
        obj_in: UpdateSchemaType | Dict[str, Any]
    ) -> ModelType:
        """更新记录"""
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.model_dump(exclude_unset=True)

        for field, value in update_data.items():
            setattr(db_obj, field, value)

        await db_obj.save()
        return db_obj

    async def delete(self, id: int) -> bool:
        """删除记录"""
        obj = await self.get(id)
        if obj:
            await obj.delete()
            return True
        return False

    async def count(self, filters) -> int:
        """统计数量"""
        return await self.model.filter(filters).count()

    async def exists(self, filters) -> bool:
        """判断是否存在"""
        return await self.model.filter(filters).exists()

```

```python
#src/repositories/user.py

from typing import Optional, List
from tortoise.expressions import Q

from .base import BaseRepository
from src.models.user import User
from src.schemas.user import UserCreate, UserUpdate

class UserRepository(BaseRepository[User, UserCreate, UserUpdate]):
    """用户 Repository"""

    def __init__(self):
        super().__init__(User)

    async def get_by_email(self, email: str) -> Optional[User]:
        """通过邮箱获取用户"""
        return await self.model.get_or_none(email=email)

    async def get_with_profile(self, user_id: int) -> Optional[User]:
        """获取用户及其资料（避免 N+1）"""
        return await self.model.get_or_none(id=user_id).prefetch_related("profile")

    async def search(
        self,
        query: str,
        offset: int = 0,
        limit: int = 20
    ) -> List[User]:
        """搜索用户"""
        return await self.model.filter(
            Q(email__icontains=query)
Q(username__icontains=query)

            Q(full_name__icontains=query)
        ).offset(offset).limit(limit)
```

### Service 层模式

```python
#src/services/user.py

from typing import Optional
from fastapi import HTTPException, status
from datetime import datetime, timedelta
from jose import JWTError, jwt

from src.core.config import get_settings
from src.models.user import User
from src.repositories.user import UserRepository
from src.schemas.user import UserCreate, Token

settings = get_settings()

class UserService:
    """用户服务（业务逻辑层）"""

    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo

    async def register(self, user_data: UserCreate) -> User:
        """用户注册"""
        # 检查邮箱是否已存在
        if await self.user_repo.get_by_email(user_data.email):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="邮箱已被注册"
            )

        # 哈希密码
        hashed_password = User.hash_password(user_data.password)

        # 创建用户
        user_dict = user_data.model_dump(exclude={"password"})
        user = await self.user_repo.create(
            {user_dict, "hashed_password": hashed_password}
        )

        return user

    async def authenticate(self, email: str, password: str) -> Optional[User]:
        """用户认证"""
        user = await self.user_repo.get_by_email(email)

        if not user:
            return None

        if not user.verify_password(password):
            return None

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="用户未激活"
            )

        # 更新最后登录时间
        user.last_login = datetime.utcnow()
        await user.save()

        return user

    def create_access_token(self, user_id: int) -> str:
        """创建 JWT Token"""
        to_encode = {
            "sub": str(user_id),
            "exp": datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        }
        return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

    async def create_tokens(self, user_id: int) -> Token:
        """创建 Token 对"""
        return Token(
            access_token=self.create_access_token(user_id)
        )

```

### DTO 模式 (Pydantic Schemas)

```python
#src/schemas/user.py

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, validator
from enum import Enum

from .base import BaseSchema, TimeStampedSchema

class UserRole(str, Enum):
    """用户角色枚举"""
    USER = "user"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"

class UserBase(BaseSchema):
    """用户基础 Schema"""
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50)
    full_name: Optional[str] = Field(None, min_length=1, max_length=100)

class UserCreate(UserBase):
    """用户创建 Schema"""
    password: str = Field(..., min_length=8)
    password_confirm: str

    @validator('password_confirm')
    def passwords_match(cls, v, values, kwargs):
        if 'password' in values and v != values['password']:
            raise ValueError('密码不匹配')
        return v

class UserUpdate(BaseSchema):
    """用户更新 Schema"""
    email: Optional[EmailStr] = None
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    full_name: Optional[str] = Field(None, min_length=1, max_length=100)

class UserInDB(UserBase, TimeStampedSchema):
    """数据库用户 Schema"""
    id: int
    is_active: bool = True
    is_superuser: bool = False
    last_login: Optional[datetime] = None

    class Config:
        from_attributes = True

class UserResponse(UserInDB):
    """用户响应 Schema"""
    pass

class Token(BaseSchema):
    """Token Schema"""
    access_token: str
    token_type: str = "bearer"

```

### 异常处理模式

```python
#src/api/errors.py

from typing import Any, Dict
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import ValidationError
import structlog

logger = structlog.get_logger()

class AppError(Exception):
    """应用基础异常"""

    def __init__(
        self,
        message: str,
        status_code: int = status.HTTP_400_BAD_REQUEST,
        details: Any = None
    ):
        self.message = message
        self.status_code = status_code
        self.details = details
        super().__init__(self.message)

class NotFoundError(AppError):
    """资源未找到异常"""

    def __init__(self, message: str = "资源不存在", details: Any = None):
        super().__init__(message, status.HTTP_404_NOT_FOUND, details)

class UnauthorizedError(AppError):
    """未授权异常"""

    def __init__(self, message: str = "未授权访问", details: Any = None):
        super().__init__(message, status.HTTP_401_UNAUTHORIZED, details)

def setup_exception_handlers(app: FastAPI) -> None:
    """设置全局异常处理器"""

    @app.exception_handler(AppError)
    async def handle_app_error(request: Request, exc: AppError):
        """处理应用自定义异常"""
        logger.error(
            "app_error",
            path=request.url.path,
            error=exc.message,
            details=exc.details
        )

        return JSONResponse(
            status_code=exc.status_code,
            content={
                "message": exc.message,
                "details": exc.details,
                "path": request.url.path
            }
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(request: Request, exc: RequestValidationError):
        """处理请求验证异常"""
        errors = []
        for error in exc.errors():
            errors.append({
                "loc": error["loc"],
                "msg": error["msg"],
                "type": error["type"]
            })

        logger.warning(
            "validation_error",
            path=request.url.path,
            errors=errors
        )

        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={
                "message": "请求数据验证失败",
                "errors": errors,
                "path": request.url.path
            }
        )

    @app.exception_handler(Exception)
    async def handle_generic_error(request: Request, exc: Exception):
        """处理未捕获的异常"""
        logger.exception(
            "unhandled_exception",
            path=request.url.path,
            error=str(exc)
        )

        # 生产环境不暴露内部错误详情
        detail = "内部服务器错误" if not settings.DEBUG else str(exc)

        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "message": "服务器内部错误",
                "detail": detail,
                "path": request.url.path
            }
        )

```

### 缓存模式 (Redis)

```python
#src/utils/cache.py

from typing import Optional, Any, Callable
import pickle
import redis.asyncio as redis
from functools import wraps
import asyncio

from src.core.config import get_settings

settings = get_settings()

class RedisCache:
    """Redis 缓存管理器"""

    def __init__(self):
        self.client = None

    async def get_client(self) -> redis.Redis:
        """获取 Redis 客户端（延迟连接）"""
        if self.client is None or not await self.client.ping():
            self.client = redis.from_url(
                settings.redis_url,
                decode_responses=False,
                encoding="utf-8"
            )
        return self.client

    async def get(self, key: str) -> Optional[Any]:
        """获取缓存"""
        client = await self.get_client()
        data = await client.get(key)
        if data:
            return pickle.loads(data)
        return None

    async def set(self, key: str, value: Any, expire: int = 3600) -> None:
        """设置缓存"""
        client = await self.get_client()
        data = pickle.dumps(value)
        await client.setex(key, expire, data)

    async def delete(self, key: str) -> None:
        """删除缓存"""
        client = await self.get_client()
        await client.delete(key)

    async def delete_pattern(self, pattern: str) -> None:
        """按模式删除缓存"""
        client = await self.get_client()
        keys = await client.keys(pattern)
        if keys:
            await client.delete(*keys)

def cache_response(expire: int = 300):
    """API 响应缓存装饰器"""

    def decorator(func):
        @wraps(func)
        async def wrapper(args, *kwargs):
            # 生成缓存键
            import hashlib
            import inspect

            sig = inspect.signature(func)
            bound_args = sig.bind(args, *kwargs)
            bound_args.apply_defaults()

            key_parts = [
                func.__module__,
                func.__name__,
                str(bound_args.arguments)
            ]
            cache_key = f"cache:{hashlib.md5(str(key_parts).encode()).hexdigest()}"

            # 尝试获取缓存
            cache = RedisCache()
            cached = await cache.get(cache_key)
            if cached is not None:
                return cached

            # 执行函数
            result = await func(args, *kwargs)

            # 设置缓存
            await cache.set(cache_key, result, expire)

            return result

        return wrapper

    return decorator

```

### Celery 异步任务模式

```python
#src/core/celery_app.py

from celery import Celery
from src.core.config import get_settings

settings = get_settings()

创建 Celery 应用

celery_app = Celery(
    "myproject",
    broker=settings.celery_broker_url,
    backend=settings.redis_url,  # 使用 Redis 作为结果后端
    include=["src.workers.tasks"]
)

配置

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,  # 30分钟
    task_soft_time_limit=25 * 60,  # 25分钟
    worker_max_tasks_per_child=1000,  # 每个 worker 处理 1000 个任务后重启
    worker_prefetch_multiplier=1,  # 一次只预取一个任务
)
```

```python
#src/workers/email_tasks.py

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from src.core.celery_app import celery_app
import structlog

logger = structlog.get_logger()

@celery_app.task(bind=True, max_retries=3)
def send_welcome_email(self, email: str, username: str):
    """发送欢迎邮件（Celery 任务）"""
    try:
        # 构建邮件
        msg = MIMEMultipart("alternative")
        msg["Subject"] = f"欢迎加入，{username}！"
        msg["From"] = "noreply@example.com"
        msg["To"] = email

        # HTML 内容
        html = f"""
        <html>
          <body>
            <h1>欢迎，{username}！</h1>
            <p>感谢您注册我们的服务。</p>
          </body>
        </html>
        """

        msg.attach(MIMEText(html, "html"))

        # 发送邮件（实际项目中应使用邮件服务如 SendGrid, SES）
        # with smtplib.SMTP("smtp.example.com", 587) as server:
        #     server.starttls()
        #     server.login("user", "password")
        #     server.send_message(msg)

        logger.info("email_sent", email=email, task_id=self.request.id)

    except Exception as exc:
        logger.error("email_failed", email=email, error=str(exc))
        # 指数退避重试
        raise self.retry(exc=exc, countdown=2  self.request.retries)

@celery_app.task
def process_bulk_emails(emails: list):
    """批量处理邮件"""
    for email in emails:
        send_welcome_email.delay(email["email"], email["username"])

```

### 结构化日志 (Structlog)

```python
#src/core/logging.py

import sys
import structlog
from typing import Any, Dict
from datetime import datetime

配置 structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.StackInfoRenderer(),
        structlog.dev.set_exc_info,
        structlog.processors.TimeStamper(fmt="iso", utc=True),
        structlog.dev.ConsoleRenderer() if settings.DEBUG else structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.BoundLogger,
    logger_factory=structlog.PrintLoggerFactory(),
    cache_logger_on_first_use=True,
)

#创建全局 logger

logger = structlog.get_logger()

#在中间件中使用

async def log_request(request, call_next):
    """请求日志中间件"""
    start_time = datetime.utcnow()

    # 处理请求
    response = await call_next(request)

    # 计算耗时
    duration = (datetime.utcnow() - start_time).total_seconds() * 1000

    # 记录结构化日志
    logger.info(
        "request_completed",
        method=request.method,
        path=request.url.path,
        status_code=response.status_code,
        duration_ms=round(duration, 2),
        client_ip=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent")
    )

    return response

```

### API 端点模式

```python
#src/api/v1/endpoints/users.py

from typing import List
from fastapi import APIRouter, Depends, HTTPException, status, Query, BackgroundTasks
from fastapi_pagination import Page, add_pagination, paginate

from src.core.dependencies import get_current_user, get_current_superuser
from src.repositories.user import UserRepository
from src.services.user import UserService
from src.schemas.user import UserResponse, UserCreate
from src.workers.email_tasks import send_welcome_email
from src.utils.cache import cache_response

router = APIRouter()

@router.get("/", response_model=Page[UserResponse])
@cache_response(expire=60)  # 缓存 1 分钟
async def list_users(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    current_user: dict = Depends(get_current_superuser),
    user_repo: UserRepository = Depends(UserRepository)
):
    """获取用户列表（分页）"""
    users = await user_repo.filter(
        offset=(page - 1) * size,
        limit=size,
        order_by=["-created_at"]
    )

    # 转换为 Pydantic 模型
    user_responses = [UserResponse.model_validate(user) for user in users]

    return paginate(user_responses)

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_in: UserCreate,
    background_tasks: BackgroundTasks,
    user_service: UserService = Depends(UserService)
):
    """创建用户"""
    user = await user_service.register(user_in)

    # 异步发送欢迎邮件
    background_tasks.add_task(
        send_welcome_email.delay,
        user.email,
        user.username
    )

    return UserResponse.model_validate(user)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    current_user: dict = Depends(get_current_user),
    user_repo: UserRepository = Depends(UserRepository)
):
    """获取单个用户"""
    if user_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="无权查看其他用户"
        )

    user = await user_repo.get(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户不存在"
        )

    return UserResponse.model_validate(user)

```

## 安全实践 (Security)

### 认证与授权

#### JWT 认证

```python
#src/core/security.py

from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import HTTPException, status

from .config import get_settings

settings = get_settings()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
"""验证密码"""
return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
"""哈希密码"""
return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
"""创建 JWT Token"""
to_encode = data.copy()
if expires_delta:
expire = datetime.utcnow() + expires_delta
else:
expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({"exp": expire, "sub": str(data.get("sub"))})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> dict:
"""验证 JWT Token"""
try:
payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
return payload
except JWTError:
raise HTTPException(
status_code=status.HTTP_401_UNAUTHORIZED,
detail="无效的令牌",
headers={"WWW-Authenticate": "Bearer"},
)
```

#### 基于角色的访问控制 (RBAC)

```python
#src/api/dependencies.py

from typing import List
from fastapi import Depends, HTTPException, status
from src.core.dependencies import get_current_user
from src.models.user import User, UserRole

def require_role(required_roles: List[UserRole]):
"""角色要求装饰器"""
def role_checker(current_user: User = Depends(get_current_user)):
if current_user.role not in required_roles:
raise HTTPException(
status_code=status.HTTP_403_FORBIDDEN,
detail="权限不足"
)
return current_user
return role_checker

#在端点中使用

@router.get("/admin/stats")
async def get_admin_stats(
current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN]))
):
"""仅管理员可访问的统计信息"""
return {"stats": "管理员数据"}
```

### 输入验证

```python
#src/lib/validators.py

import re
from typing import Any
from pydantic import BaseModel, validator, ValidationError
import html

class SanitizedString(str):
"""经过清理的字符串"""

    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v: Any) -> str:
        if not isinstance(v, str):
            raise TypeError("必须是字符串")

        # 移除 HTML 标签
        v = re.sub(r'<[^>]*>', '', v)
        # 转义特殊字符
        v = html.escape(v)
        # 移除危险字符
        v = re.sub(r'[<>{}]', '', v)
        return v

class UserCreate(BaseModel):
username: SanitizedString
email: str
password: str

    @validator('email')
    def validate_email(cls, v):
        email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_regex, v):
            raise ValueError('无效的邮箱格式')
        return v.lower()

    @validator('password')
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('密码至少8个字符')
        if not re.search(r'[A-Z]', v):
            raise ValueError('密码必须包含至少一个大写字母')
        if not re.search(r'[a-z]', v):
            raise ValueError('密码必须包含至少一个小写字母')
        if not re.search(r'\d', v):
            raise ValueError('密码必须包含至少一个数字')
        return v

```

### 安全清单

- \[ ] **环境变量安全**：敏感密钥存储在环境变量中，不提交到代码仓库
- \[ ] **HTTPS 强制**：生产环境必须使用 HTTPS，设置 `SECURE_SSL_REDIRECT = True`
- \[ ] **CORS 配置**：限制允许的来源，避免使用通配符
- \[ ] **SQL 注入防护**：使用 ORM 或参数化查询，避免字符串拼接
- \[ ] **XSS 防护**：对所有用户输入进行清理和转义
- \[ ] **CSRF 保护**：对基于会话的应用启用 CSRF 保护
- \[ ] **速率限制**：在关键端点实施速率限制
- \[ ] **依赖安全**：定期运行安全扫描，更新依赖
- \[ ] **错误处理**：生产环境不暴露堆栈跟踪
- \[ ] **文件上传**：验证文件类型、大小，扫描恶意内容

## 测试驱动开发 (TDD)

### 测试策略

#### 1. 先写测试

```python
#tests/unit/services/test_user_service.py

import pytest
from unittest.mock import AsyncMock, MagicMock
from src.services.user import UserService
from src.repositories.user import UserRepository
from src.schemas.user import UserCreate
from src.models.user import User

@pytest.mark.asyncio
async def test_register_user_success():
"""测试用户注册成功""" # Arrange
mock_repo = AsyncMock(spec=UserRepository)
mock_repo.get_by_email.return_value = None
mock_repo.create.return_value = User(id=1, email="test@example.com", username="test")

    service = UserService(mock_repo)
    user_data = UserCreate(
        email="test@example.com",
        username="test",
        password="Password123",
        password_confirm="Password123"
    )

    # Act
    result = await service.register(user_data)

    # Assert
    assert result.email == "test@example.com"
    assert result.username == "test"
    mock_repo.get_by_email.assert_called_once_with("test@example.com")
    mock_repo.create.assert_called_once()

@pytest.mark.asyncio
async def test_register_user_email_exists():
"""测试邮箱已存在时注册失败""" # Arrange
mock_repo = AsyncMock(spec=UserRepository)
mock_repo.get_by_email.return_value = User(id=1, email="test@example.com")

    service = UserService(mock_repo)
    user_data = UserCreate(
        email="test@example.com",
        username="test",
        password="Password123",
        password_confirm="Password123"
    )

    # Act & Assert
    with pytest.raises(Exception) as exc_info:
        await service.register(user_data)

    assert "邮箱已被注册" in str(exc_info.value)
```

#### 2. 实现最小代码

```python
src/services/user.py

async def register(self, user_data: UserCreate) -> User:
"""用户注册""" # 检查邮箱是否已存在
existing_user = await self.user_repo.get_by_email(user_data.email)
if existing_user:
raise HTTPException(
status_code=status.HTTP_400_BAD_REQUEST,
detail="邮箱已被注册"
)

    # 创建用户
    user_dict = user_data.model_dump(exclude={"password"})
    user = await self.user_repo.create(user_dict)
    return user

```

#### 3. 重构与优化

```python
#重构：提取验证逻辑

class UserValidator:
@staticmethod
def validate_password(password: str) -> bool: # 密码强度验证逻辑
pass

    @staticmethod
    def validate_email_format(email: str) -> bool:
        # 邮箱格式验证逻辑
        pass
```

### 测试类型

#### 单元测试 (Pytest + Async)

```python
#tests/unit/api/test_users.py

import pytest
from httpx import AsyncClient
from unittest.mock import AsyncMock, patch
from src.main import app

@pytest.mark.asyncio
async def test_get_users_unauthorized():
"""测试未授权访问用户列表"""
async with AsyncClient(app=app, base_url="http://test") as ac:
response = await ac.get("/api/v1/users/")

    assert response.status_code == 401

@pytest.mark.asyncio
@patch("src.api.v1.endpoints.users.UserRepository")
async def test_get_users_as_admin(mock_repo):
"""测试管理员获取用户列表""" # Mock 数据
mock_users = [
User(id=1, email="admin@example.com", username="admin", role=UserRole.ADMIN),
User(id=2, email="user@example.com", username="user", role=UserRole.USER),
]
mock_repo.return_value.filter.return_value = mock_users
mock_repo.return_value.count.return_value = 2

    # Mock 认证
    with patch("src.api.v1.endpoints.users.get_current_user") as mock_auth:
        mock_auth.return_value = User(id=1, role=UserRole.ADMIN, is_superuser=True)

        async with AsyncClient(app=app, base_url="http://test") as ac:
            response = await ac.get("/api/v1/users/")

    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) == 2

```

#### 集成测试

```python
#tests/integration/test_auth_flow.py

import pytest
from httpx import AsyncClient
from tortoise import Tortoise, run_async
from src.main import app
from src.models.user import User
from src.core.database import init_db

@pytest.mark.asyncio
async def test_register_and_login_flow():
"""测试完整的注册登录流程""" # 初始化测试数据库
await init_db()

    async with AsyncClient(app=app, base_url="http://test") as ac:
        # 1. 注册
        register_data = {
            "email": "test@example.com",
            "username": "testuser",
            "password": "TestPass123",
            "password_confirm": "TestPass123"
        }
        register_response = await ac.post("/api/v1/auth/register", json=register_data)
        assert register_response.status_code == 201

        # 2. 登录
        login_data = {
            "username": "test@example.com",
            "password": "TestPass123"
        }
        login_response = await ac.post("/api/v1/auth/login", data=login_data)
        assert login_response.status_code == 200

        token_data = login_response.json()
        assert "access_token" in token_data

        # 3. 使用令牌访问受保护端点
        headers = {"Authorization": f"Bearer {token_data['access_token']}"}
        profile_response = await ac.get("/api/v1/users/me", headers=headers)
        assert profile_response.status_code == 200

        profile_data = profile_response.json()
        assert profile_data["email"] == "test@example.com"

    # 清理
    await User.filter(email="test@example.com").delete()

```

#### 数据库测试 (使用测试数据库)

```python
#tests/conftest.py

import pytest
import asyncio
from tortoise import Tortoise
from httpx import AsyncClient
from src.main import app
from src.core.config import settings

@pytest.fixture(scope="session")
def event_loop():
"""创建事件循环供异步测试使用"""
loop = asyncio.get_event_loop_policy().new_event_loop()
yield loop
loop.close()

@pytest.fixture(scope="session", autouse=True)
async def initialize_db():
"""初始化测试数据库""" # 使用测试数据库配置
test_config = {
"connections": {
"default": {
"engine": "tortoise.backends.asyncpg",
"credentials": {
"host": "localhost",
"port": 5432,
"user": "test",
"password": "test",
"database": "test_db",
}
}
},
"apps": {
"models": {
"models": ["src.models", "aerich.models"],
"default_connection": "default",
}
},
"use_tz": False,
}

    await Tortoise.init(config=test_config)
    await Tortoise.generate_schemas(safe=True)

    yield

    await Tortoise.close_connections()

```

### 测试数据构建器

```python
#tests/factories.py

import factory
from factory import fuzzy
from src.models.user import User
from src.models.product import Product

class UserFactory(factory.Factory):
class Meta:
model = User

    id = factory.Sequence(lambda n: n + 1)
    email = factory.LazyAttribute(lambda o: f"user{o.id}@example.com")
    username = factory.LazyAttribute(lambda o: f"user{o.id}")
    hashed_password = factory.LazyAttribute(lambda o: User.hash_password("password123"))
    is_active = True
    role = "user"

class ProductFactory(factory.Factory):
class Meta:
model = Product

    id = factory.Sequence(lambda n: n + 1)
    name = fuzzy.FuzzyText(length=10)
    price = fuzzy.FuzzyDecimal(10.0, 1000.0)
    stock = fuzzy.FuzzyInteger(0, 100)
    is_active = True

```

## 验证循环 (Verification)

### 阶段 1：代码质量检查

```bash
#1. 类型检查
mypy src/

#2. 代码格式化检查
black --check src/

#3. 导入排序检查
isort --check-only src/

#4. 代码风格检查
flake8 src/

#5. 复杂度检查
radon cc src/ -a
```

### 阶段 2：测试套件

```bash
#运行所有测试
pytest

#运行单元测试
pytest tests/unit/

#运行集成测试
pytest tests/integration/

#运行特定标记的测试
pytest -m "not slow"

#生成覆盖率报告
pytest --cov=src --cov-report=html --cov-report=term
```

**覆盖率要求**：

- 语句覆盖率 ≥ 80%
- 分支覆盖率 ≥ 70%
- 函数覆盖率 ≥ 80%

### 阶段 3：安全扫描

```bash
#1. 依赖漏洞扫描
safety check

#2. 检查代码中的硬编码密钥
grep -r "password\secret\ key\ token" src/ --include="\*.py" grep -v ".pyc" grep -v "**pycache**" grep -v "test\_"
| true

#3. 检查 SQL 注入风险
bandit -r src/ -ll

#4. 检查依赖许可证
pip-licenses

```

### 阶段 4：性能检查

```bash
#1. 使用 Locust 进行负载测试
locust -f tests/load_test.py

#2. 使用 pytest-benchmark 进行基准测试
pytest tests/benchmarks/ --benchmark-only

#3. 内存使用分析
mprof run python -m src.main
mprof plot

```

### 阶段 5：构建与打包

```bash

#1. 构建 Docker 镜像
docker build -t myapp:latest .

#2. 运行 Docker 组合测试

docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit

#3. 检查镜像大小
docker images myapp

#4. 扫描镜像漏洞
docker scan myapp:latest

```

### 阶段 6：部署前验证

```bash
#1. 应用数据库迁移
aerich upgrade

#2. 验证环境变量
echo "检查关键环境变量:"
echo "DATABASE_URL: ${DATABASE_URL:0:20}..."
echo "SECRET_KEY: ${SECRET_KEY:0:10}..."

#3. 启动健康检查
curl -f http://localhost:8000/health || exit 1

#4. 运行冒烟测试
python scripts/smoke_test.py

```

### 验证报告模板

```markdown
# FASTAPI 应用验证报告

项目: [项目名称]
环境: [development/staging/production]
版本: [版本号]
时间: [时间戳]

[✅/❌] 代码质量检查
◦ 类型检查: 通过/失败 (错误数: X)

    ◦ 代码风格: 通过/失败 (警告数: Y)

    ◦ 复杂度检查: 通过/失败 (文件数: Z)

[✅/❌] 测试套件
◦ 单元测试: A/B 通过

    ◦ 集成测试: C/D 通过

    ◦ 覆盖率: 行: P%, 分支: Q%, 函数: R%

[✅/❌] 安全扫描
◦ 依赖漏洞: 通过/失败 (漏洞数: V)

    ◦ 代码安全: 通过/失败 (问题数: W)

[✅/❌] 性能测试
◦ 平均响应时间: X ms

    ◦ 吞吐量: Y req/s

    ◦ 错误率: Z%

[✅/❌] 构建与部署
◦ Docker 构建: 通过/失败 (镜像大小: S MB)

    ◦ 数据库迁移: 通过/失败

    ◦ 健康检查: 通过/失败

关键问题:

1. [高优先级] [问题描述]
2. [中优先级] [问题描述]

部署就绪: [✅ 是 / ❌ 否]
```

## CI/CD 配置示例

```yaml
.github/workflows/ci.yml

name: CI

on:
push:
branches: [main, develop]
pull_request:
branches: [main]

jobs:
test:
runs-on: ubuntu-latest
services:
postgres:
image: postgres:15
env:
POSTGRES_PASSWORD: test
POSTGRES_USER: test
POSTGRES_DB: test_db
options: >-
--health-cmd pg_isready
--health-interval 10s
--health-timeout 5s
--health-retries 5
ports:
▪ 5432:5432

      redis:
        image: redis:7-alpine
        ports:
          ▪ 6379:6379

      rabbitmq:
        image: rabbitmq:3-management
        ports:
          ▪ 5672:5672

          ▪ 15672:15672


    steps:
      ◦ uses: actions/checkout@v4


      ◦ name: Setup Python

        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'

      ◦ name: Install dependencies

        run: |
          pip install -r requirements.txt
          pip install -r requirements-test.txt

      ◦ name: Run code quality checks

        run: |
          black --check src/
          isort --check-only src/
          flake8 src/
          mypy src/

      ◦ name: Run security checks

        run: |
          safety check
          bandit -r src/ -ll

      ◦ name: Run tests

        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test_db
          SECRET_KEY: test-secret-key
        run: |
          pytest --cov=src --cov-report=xml --cov-report=html

      ◦ name: Upload coverage

        uses: codecov/codecov-action@v3

      ◦ name: Build Docker image

        run: docker build -t myapp:${{ github.sha }} .

```

## 核心原则

1.  **异步优先：**充分利用 FastAPI 和 TortoiseORM 的异步特性，构建高性能应用。
2.  **类型安全：**使用 Pydantic v2 和 TypeScript 实现端到端类型安全。
3.  **关注点分离：**清晰的分层架构（API → Service → Repository → Model），保持代码可维护性。
4.  **测试驱动：**为业务逻辑、API 端点和异步任务编写全面的测试，确保系统稳定性。
5.  **安全默认：**从项目开始就实施安全最佳实践，包括输入验证、认证授权、依赖安全。
6.  **可观测性：**通过结构化日志、指标收集和分布式追踪，确保系统可观测性。
7.  **自动化一切：**通过 CI/CD 自动化测试、检查、构建和部署流程，确保交付质量。

记住：构建生产级 FastAPI 应用不仅仅是实现功能，更是构建可维护、可测试、高性能且安全的系统。良好的架构、严格的质量门禁和自动化的流程是成功项目的基石。
