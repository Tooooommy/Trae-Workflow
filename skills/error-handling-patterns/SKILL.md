---
name: error-handling-patterns
description: 统一错误处理模式 - 结构化错误响应与异常管理最佳实践
---

# 错误处理模式

> 结构化、可追踪、用户友好的错误处理方案

## 何时激活

- 设计 API 错误响应格式
- 实现全局错误处理
- 添加错误日志和监控
- 处理异步错误
- 设计错误恢复策略

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| TypeScript | 5.0+ | 最新 |
| Zod | 3.0+ | 最新 |
| Sentry SDK | 7.0+ | 最新 |

## 核心模式

### 1. 结构化错误响应

```typescript
interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  stack?: string;
  timestamp: string;
  requestId: string;
}

interface ErrorResponse {
  success: false;
  error: ApiError;
}
```

### 2. 自定义错误类

```typescript
class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public statusCode: number = 500,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'AppError';
  }
}

class ValidationError extends AppError {
  constructor(details: Record<string, string>) {
    super('VALIDATION_ERROR', 'Validation failed', 400, details);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super('NOT_FOUND', `${resource} not found`, 404);
  }
}

class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super('UNAUTHORIZED', message, 401);
  }
}

class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') {
    super('FORBIDDEN', message, 403);
  }
}
```

### 3. 全局错误处理中间件

```typescript
function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  const requestId = req.headers['x-request-id'] || crypto.randomUUID();
  
  if (err instanceof AppError) {
    const response: ErrorResponse = {
      success: false,
      error: {
        code: err.code,
        message: err.message,
        details: err.details,
        timestamp: new Date().toISOString(),
        requestId: requestId as string,
      },
    };
    
    return res.status(err.statusCode).json(response);
  }
  
  console.error('Unhandled error:', err);
  
  const response: ErrorResponse = {
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
      timestamp: new Date().toISOString(),
      requestId: requestId as string,
    },
  };
  
  return res.status(500).json(response);
}
```

## 错误代码规范

| 前缀 | 类别 | 示例 |
|------|------|------|
| `VAL_` | 验证错误 | VAL_001: 必填字段缺失 |
| `AUTH_` | 认证错误 | AUTH_001: 令牌过期 |
| `PERM_` | 权限错误 | PERM_001: 无访问权限 |
| `RES_` | 资源错误 | RES_001: 资源不存在 |
| `SYS_` | 系统错误 | SYS_001: 数据库连接失败 |
| `EXT_` | 外部服务 | EXT_001: 第三方 API 超时 |

## 异步错误处理

### Result 模式

```typescript
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E };

async function safeAsync<T>(
  fn: () => Promise<T>
): Promise<Result<T>> {
  try {
    const data = await fn();
    return { success: true, data };
  } catch (error) {
    return { success: false, error: error as Error };
  }
}

const result = await safeAsync(() => fetchUser(id));
if (result.success) {
  console.log(result.data);
} else {
  console.error(result.error);
}
```

### Try-Catch 工具

```typescript
function tryCatch<T, E = Error>(
  fn: () => T
): [T | null, E | null] {
  try {
    return [fn(), null];
  } catch (error) {
    return [null, error as E];
  }
}

const [data, error] = tryCatch(() => JSON.parse(input));
if (error) {
  console.error('Parse failed:', error);
}
```

## 验证错误处理

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

function validate<T>(schema: z.ZodSchema<T>, data: unknown): T {
  const result = schema.safeParse(data);
  
  if (!result.success) {
    const details = result.error.issues.reduce((acc, issue) => {
      const path = issue.path.join('.');
      acc[path] = issue.message;
      return acc;
    }, {} as Record<string, string>);
    
    throw new ValidationError(details);
  }
  
  return result.data;
}
```

## 错误恢复策略

| 策略 | 适用场景 | 实现 |
|------|----------|------|
| 重试 | 网络请求 | 指数退避重试 |
| 降级 | 非核心功能 | 返回缓存/默认值 |
| 熔断 | 外部服务 | Circuit Breaker |
| 补偿 | 分布式事务 | Saga 模式 |

## 日志集成

```typescript
function logError(error: Error, context: Record<string, unknown> = {}) {
  const logEntry = {
    timestamp: new Date().toISOString(),
    level: 'error',
    message: error.message,
    stack: error.stack,
    ...context,
  };
  
  console.error(JSON.stringify(logEntry));
  
  if (process.env.NODE_ENV === 'production') {
    Sentry.captureException(error, { extra: context });
  }
}
```

## 快速参考

```typescript
// 抛出特定错误
throw new ValidationError({ email: 'Invalid email format' });
throw new NotFoundError('User');
throw new UnauthorizedError('Token expired');

// 安全异步调用
const [data, error] = await safeAsync(() => api.fetchUser(id));

// 验证输入
const user = validate(UserSchema, input);
```

## 参考

- [RFC 7807 Problem Details](https://datatracker.ietf.org/doc/html/rfc7807)
- [Sentry Error Handling](https://docs.sentry.io/platforms/javascript/)
- [Zod Error Handling](https://zod.dev/ERROR_HANDLING)
