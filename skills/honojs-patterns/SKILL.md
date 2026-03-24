---
name: honojs-patterns
description: Node.js 现代全栈开发模式，基于 HonoJS、TypeScript、PostgreSQL、Prisma、Redis 和 BullMQ。涵盖高性能 API 设计、类型安全、异步处理、安全实践、测试驱动开发和项目验证循环。
---

# Node.js HonoJS 全栈开发模式

基于 HonoJS、TypeScript、PostgreSQL、Prisma、Redis 和 BullMQ 的现代化 Node.js API 开发模式。包含极简高性能框架、类型安全数据库访问、消息队列集成、结构化日志、安全最佳实践、测试策略和生产部署验证。

## 何时激活

- 使用 **HonoJS** 构建高性能、轻量级的 API 和边缘计算应用
- 采用 **TypeScript** 严格模式确保端到端类型安全
- 使用 **Prisma** 进行类型安全的数据库操作和迁移管理
- 使用 **PostgreSQL** 作为主关系型数据库
- 使用 **Redis** 进行缓存、会话存储和 **BullMQ** 消息队列
- 需要 **Pino** 结构化日志和 **Swagger** 自动 API 文档
- 使用 **Jest** 进行全面的测试覆盖
- 构建需要高并发、低延迟的生产级微服务和 API 网关

## 技术栈版本

| 技术        | 最低版本 | 推荐版本 |
| ----------- | -------- | -------- |
| Node.js     | 18.0+    | 20.0+    |
| HonoJS      | 4.0+     | 最新     |
| TypeScript  | 5.0+     | 最新     |
| Prisma      | 5.0+     | 最新     |
| PostgreSQL  | 14.0+    | 16.0+    |
| Redis       | 7.0+     | 最新     |
| BullMQ      | 5.0+     | 最新     |

## 开发模式 (Patterns)

### 项目结构

```bash
my-hono-app/
├── src/
│   ├── core/                    # 核心配置与工具
│   │   ├── __init__.py
│   │   ├── config.ts           # 应用配置
│   │   ├── database.ts         # Prisma 客户端
│   │   ├── redis.ts            # Redis 客户端
│   │   ├── bullmq.ts           # BullMQ 队列
│   │   ├── logger.ts           # Pino 日志配置
│   │   └── swagger.ts          # OpenAPI 文档
│   ├── models/                 # 数据模型 (Prisma 在 prisma/schema.prisma)
│   │   └── types/              # TypeScript 类型定义
│   ├── schemas/                # 验证模式 (Zod)
│   │   ├── auth.ts
│   │   ├── user.ts
│   │   └── product.ts
│   ├── repositories/           # 数据访问层
│   │   ├── base.ts
│   │   ├── user.repository.ts
│   │   └── product.repository.ts
│   ├── services/               # 业务逻辑层
│   │   ├── auth.service.ts
│   │   ├── user.service.ts
│   │   └── product.service.ts
│   ├── middleware/             # Hono 中间件
│   │   ├── auth.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── logger.middleware.ts
│   ├── routes/                 # API 路由
│   │   ├── v1/
│   │   │   ├── auth.routes.ts
│   │   │   ├── user.routes.ts
│   │   │   └── product.routes.ts
│   │   └── index.ts
│   ├── workers/                # BullMQ Worker
│   │   ├── email.worker.ts
│   │   └── report.worker.ts
│   ├── utils/                  # 工具函数
│   │   ├── crypto.ts
│   │   ├── validators.ts
│   │   └── cache.ts
│   └── app.ts                  # Hono 应用入口
├── prisma/
│   ├── schema.prisma           # Prisma 数据模型
│   └── migrations/             # 数据库迁移
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── .env
├── .env.example
├── package.json
├── tsconfig.json
├── docker-compose.yml
└── README.md
```

### 核心配置

```typescript
// src/core/config.ts
import { z } from 'zod';

// 使用 Zod 验证环境变量
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),

  // 数据库
  DATABASE_URL: z.string().url(),

  // Redis
  REDIS_HOST: z.string().default('localhost'),
  REDIS_PORT: z.coerce.number().default(6379),
  REDIS_PASSWORD: z.string().optional(),
  REDIS_DB_CACHE: z.coerce.number().default(0),
  REDIS_DB_QUEUE: z.coerce.number().default(1),

  // JWT
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('1h'),

  // API
  API_PREFIX: z.string().default('/api'),
  API_VERSION: z.string().default('v1'),

  // CORS
  CORS_ORIGIN: z.string().default('*'),
});

export type EnvConfig = z.infer<typeof envSchema>;

class Config {
  private static instance: Config;
  public readonly config: EnvConfig;

  private constructor() {
    this.config = this.loadConfig();
  }

  public static getInstance(): Config {
    if (!Config.instance) {
      Config.instance = new Config();
    }
    return Config.instance;
  }

  private loadConfig(): EnvConfig {
    const result = envSchema.safeParse(process.env);

    if (!result.success) {
      console.error('❌ 环境变量验证失败:', result.error.format());
      process.exit(1);
    }

    return result.data;
  }

  get isDevelopment(): boolean {
    return this.config.NODE_ENV === 'development';
  }

  get isProduction(): boolean {
    return this.config.NODE_ENV === 'production';
  }

  get isTest(): boolean {
    return this.config.NODE_ENV === 'test';
  }

  get redisUrl(): string {
    const { REDIS_HOST, REDIS_PORT, REDIS_PASSWORD, REDIS_DB_CACHE } = this.config;
    const auth = REDIS_PASSWORD ? :${REDIS_PASSWORD}@ : '';
    return redis://${auth}${REDIS_HOST}:${REDIS_PORT}/${REDIS_DB_CACHE};
  }

  get queueRedisUrl(): string {
    const { REDIS_HOST, REDIS_PORT, REDIS_PASSWORD, REDIS_DB_QUEUE } = this.config;
    const auth = REDIS_PASSWORD ? :${REDIS_PASSWORD}@ : '';
    return redis://${auth}${REDIS_HOST}:${REDIS_PORT}/${REDIS_DB_QUEUE};
  }
}

export const config = Config.getInstance().config;
export const isDevelopment = Config.getInstance().isDevelopment;
export const isProduction = Config.getInstance().isProduction;
```

### HonoJS 应用配置

```typescript
// src/app.ts
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { prettyJSON } from 'hono/pretty-json';
import { secureHeaders } from 'hono/secure-headers';
import { compress } from 'hono/compress';
import { timeout } from 'hono/timeout';
import { config } from './core/config';
import { errorHandler } from './middleware/error.middleware';
import { requestLogger } from './middleware/logger.middleware';
import routes from './routes';
import { setupSwagger } from './core/swagger';

// 创建 Hono 应用
const app = new Hono<{
  Variables: {
    userId?: string;
    userRole?: string;
    requestId: string;
  };
}>();

// 全局中间件
app.use('*', cors({
  origin: config.CORS_ORIGIN,
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
  exposeHeaders: ['Content-Length', 'X-Request-Id'],
  maxAge: 600,
  credentials: true,
}));

app.use('*', secureHeaders());
app.use('*', compress());
app.use('*', timeout(10000)); // 10秒超时
app.use('*', prettyJSON());
app.use('*', requestLogger());

if (isDevelopment) {
  app.use('*', logger());
}

// 错误处理
app.onError(errorHandler);

// 健康检查端点
app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: config.NODE_ENV,
  });
});

// API 路由
app.route(${config.API_PREFIX}/${config.API_VERSION}, routes);

// 设置 Swagger 文档
if (isDevelopment) {
  setupSwagger(app);
}

// 404 处理
app.notFound((c) => {
  return c.json(
    {
      error: 'Not Found',
      message: Route ${c.req.path} not found,
      path: c.req.path,
    },
    404
  );
});

export default app;
export type AppType = typeof app;
```

### 数据库与 Prisma 模式

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  username  String   @unique
  password  String
  name      String?
  role      Role     @default(USER)
  isActive  Boolean  @default(true)
  lastLogin DateTime?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // 关系
  products Product[]
  sessions Session[]

  @@map("users")
  @@index([email])
  @@index([username])
  @@index([createdAt])
}

model Product {
  id          String   @id @default(cuid())
  name        String
  description String?
  price       Float
  stock       Int      @default(0)
  isActive    Boolean  @default(true)
  userId      String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // 关系
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("products")
  @@index([userId])
  @@index([createdAt])
  @@index([price])
  @@index([isActive])
}

model Session {
  id        String   @id @default(cuid())
  userId    String
  token     String   @unique
  expiresAt DateTime
  userAgent String?
  ipAddress String?
  createdAt DateTime @default(now())

  // 关系
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("sessions")
  @@index([userId])
  @@index([token])
  @@index([expiresAt])
}

enum Role {
  USER
  ADMIN
  SUPER_ADMIN
}
```

```typescript
// src/core/database.ts
import { PrismaClient } from '@prisma/client';

// 防止热重载时创建多个 Prisma 实例
const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: isDevelopment ? ['query', 'info', 'warn', 'error'] : ['error'],
});

if (isDevelopment) globalForPrisma.prisma = prisma;

// 扩展 Prisma 客户端
export const extendedPrisma = prisma.$extends({
  query: {
    $allModels: {
      async $allOperations({ operation, model, args, query }) {
        const start = performance.now();
        const result = await query(args);
        const end = performance.now();
        const time = end - start;

        if (time > 100) { // 慢查询日志
          console.warn(Slow query detected on ${model}.${operation}: ${time}ms);
        }

        return result;
      },
    },
  },
});
```

### 路由与控制器模式

```typescript
// src/routes/v1/user.routes.ts
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { authMiddleware } from '../../middleware/auth.middleware';
import { roleMiddleware } from '../../middleware/role.middleware';
import { userService } from '../../services/user.service';
import { cacheMiddleware } from '../../middleware/cache.middleware';

const userRoutes = new Hono()
  .use('*', authMiddleware)
  .get(
    '/',
    cacheMiddleware({ ttl: 60 }), // 缓存 60 秒
    async (c) => {
      const { page = 1, limit = 20, search } = c.req.query();
      const users = await userService.getUsers({
        page: Number(page),
        limit: Number(limit),
        search,
      });
      return c.json(users);
    }
  )
  .get('/:id', cacheMiddleware({ ttl: 300 }), async (c) => {
    const id = c.req.param('id');
    const user = await userService.getUserById(id);

    if (!user) {
      return c.json({ error: 'User not found' }, 404);
    }

    return c.json(user);
  })
  .post(
    '/',
    zValidator(
      'json',
      z.object({
        email: z.string().email(),
        username: z.string().min(3).max(50),
        password: z.string().min(8),
        name: z.string().optional(),
      })
    ),
    roleMiddleware(['ADMIN', 'SUPER_ADMIN']),
    async (c) => {
      const data = c.req.valid('json');
      const user = await userService.createUser(data);
      return c.json(user, 201);
    }
  )
  .patch(
    '/:id',
    zValidator(
      'json',
      z.object({
        email: z.string().email().optional(),
        username: z.string().min(3).max(50).optional(),
        name: z.string().optional(),
        isActive: z.boolean().optional(),
      })
    ),
    async (c) => {
      const id = c.req.param('id');
      const data = c.req.valid('json');
      const userId = c.get('userId');

      // 检查权限：用户只能更新自己的信息，管理员可以更新任何用户
      if (id !== userId && !c.get('userRole')?.includes('ADMIN')) {
        return c.json({ error: 'Forbidden' }, 403);
      }

      const user = await userService.updateUser(id, data);
      return c.json(user);
    }
  )
  .delete('/:id', roleMiddleware(['ADMIN', 'SUPER_ADMIN']), async (c) => {
    const id = c.req.param('id');
    await userService.deleteUser(id);
    return c.json({ message: 'User deleted' });
  });

export default userRoutes;
```

### 服务层模式

```typescript
// src/services/user.service.ts
import { prisma } from '../core/database';
import { hashPassword, verifyPassword } from '../utils/crypto';
import { redis } from '../core/redis';
import { emailQueue } from '../core/bullmq';

export class UserService {
  async getUsers(params: {
    page: number;
    limit: number;
    search?: string;
  }) {
    const { page, limit, search } = params;
    const skip = (page - 1) * limit;

    const where = search
      ? {
          OR: [
            { email: { contains: search, mode: 'insensitive' as const } },
            { username: { contains: search, mode: 'insensitive' as const } },
            { name: { contains: search, mode: 'insensitive' as const } },
          ],
        }
      : {};

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          email: true,
          username: true,
          name: true,
          role: true,
          isActive: true,
          createdAt: true,
        },
      }),
      prisma.user.count({ where }),
    ]);

    return {
      data: users,
      meta: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  }

  async getUserById(id: string) {
    // 检查缓存
    const cacheKey = user:${id};
    const cached = await redis.get(cacheKey);

    if (cached) {
      return JSON.parse(cached);
    }

    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        username: true,
        name: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (user) {
      // 缓存用户数据
      await redis.setex(cacheKey, 300, JSON.stringify(user)); // 5分钟
    }

    return user;
  }

  async createUser(data: {
    email: string;
    username: string;
    password: string;
    name?: string;
  }) {
    // 检查邮箱是否已存在
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingUser) {
      throw new Error('Email already exists');
    }

    // 检查用户名是否已存在
    const existingUsername = await prisma.user.findUnique({
      where: { username: data.username },
    });

    if (existingUsername) {
      throw new Error('Username already exists');
    }

    // 哈希密码
    const hashedPassword = await hashPassword(data.password);

    const user = await prisma.user.create({
      data: {
        ...data,
        password: hashedPassword,
      },
      select: {
        id: true,
        email: true,
        username: true,
        name: true,
        role: true,
        isActive: true,
        createdAt: true,
      },
    });

    // 发送欢迎邮件（异步）
    await emailQueue.add('send-welcome-email', {
      email: user.email,
      username: user.username,
    });

    return user;
  }

  async updateUser(id: string, data: any) {
    const user = await prisma.user.update({
      where: { id },
      data,
      select: {
        id: true,
        email: true,
        username: true,
        name: true,
        role: true,
        isActive: true,
        updatedAt: true,
      },
    });

    // 清除缓存
    await redis.del(user:${id});

    return user;
  }

  async deleteUser(id: string) {
    await prisma.user.delete({
      where: { id },
    });

    // 清除缓存
    await redis.del(user:${id});
  }

  async authenticate(email: string, password: string) {
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user || !user.isActive) {
      return null;
    }

    const isValid = await verifyPassword(password, user.password);

    if (!isValid) {
      return null;
    }

    // 更新最后登录时间
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLogin: new Date() },
    });

    return {
      id: user.id,
      email: user.email,
      username: user.username,
      name: user.name,
      role: user.role,
    };
  }
}

export const userService = new UserService();
```

### BullMQ 消息队列模式

```typescript
// src/core/bullmq.ts
import { Queue, Worker, QueueEvents } from 'bullmq';
import IORedis from 'ioredis';
import { config } from './config';
import { logger } from './logger';

// Redis 连接
const connection = new IORedis(config.queueRedisUrl, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

// 创建队列
export const emailQueue = new Queue('email', { connection });
export const reportQueue = new Queue('report', { connection });

// 创建 Worker
const emailWorker = new Worker(
  'email',
  async (job) => {
    logger.info(Processing email job ${job.id});

    switch (job.name) {
      case 'send-welcome-email':
        const { email, username } = job.data;
        // 发送欢迎邮件逻辑
        console.log(Sending welcome email to ${email} for user ${username});
        break;

      case 'send-password-reset':
        const { email: resetEmail, token } = job.data;
        // 发送密码重置邮件逻辑
        console.log(Sending password reset email to ${resetEmail} with token ${token});
        break;
    }
  },
  { connection }
);

// 错误处理
emailWorker.on('failed', (job, err) => {
  logger.error(Job ${job?.id} failed: ${err.message});
});

// 进度报告
emailWorker.on('progress', (job, progress) => {
  logger.info(Job ${job.id} progress: ${progress}%);
});

// 队列事件
const queueEvents = new QueueEvents('email', { connection });

queueEvents.on('completed', ({ jobId }) => {
  logger.info(Job ${jobId} completed);
});

queueEvents.on('failed', ({ jobId, failedReason }) => {
  logger.error(Job ${jobId} failed: ${failedReason});
});

// 清理函数
export async function closeBullMQ() {
  await emailWorker.close();
  await emailQueue.close();
  await reportQueue.close();
  await connection.quit();
}
```

### 中间件模式

```typescript
// src/middleware/auth.middleware.ts
import { createMiddleware } from 'hono/factory';
import { verifyToken } from '../utils/crypto';
import { prisma } from '../core/database';

export const authMiddleware = createMiddleware(async (c, next) => {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized' }, 401);
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = verifyToken(token);

    // 检查会话是否有效
    const session = await prisma.session.findFirst({
      where: {
        token,
        expiresAt: { gt: new Date() },
      },
    });

    if (!session) {
      return c.json({ error: 'Session expired' }, 401);
    }

    // 设置用户信息到上下文
    c.set('userId', payload.userId);
    c.set('userRole', payload.role);
    c.set('sessionId', session.id);

    await next();
  } catch (error) {
    return c.json({ error: 'Invalid token' }, 401);
  }
});
```

```typescript
// src/middleware/rate-limit.middleware.ts
import { createMiddleware } from 'hono/factory';
import { redis } from '../core/redis';

export function rateLimitMiddleware(options: {
  windowMs: number;
  max: number;
  keyPrefix?: string;
}) {
  return createMiddleware(async (c, next) => {
    const { windowMs, max, keyPrefix = 'rate-limit' } = options;
    const ip = c.req.header('x-forwarded-for') |c.req.header('x-real-ip')
| 'unknown';
    const key = ${keyPrefix}:${ip}:${c.req.path};

    const current = await redis.incr(key);

    if (current === 1) {
      await redis.expire(key, windowMs / 1000);
    }

    if (current > max) {
      return c.json({
        error: 'Too Many Requests',
        message: Rate limit exceeded. Try again in ${windowMs / 1000} seconds.,
      }, 429);
    }

    c.header('X-RateLimit-Limit', max.toString());
    c.header('X-RateLimit-Remaining', (max - current).toString());
    c.header('X-RateLimit-Reset', (Date.now() + windowMs).toString());

    await next();
  });
}
```

## 安全实践 (Security)

### 认证与授权

```typescript
// src/utils/crypto.ts
import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { config } from '../core/config';

// 密码哈希
export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 12);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

// JWT
export function signToken(payload: object): string {
  return jwt.sign(payload, config.JWT_SECRET, {
    expiresIn: config.JWT_EXPIRES_IN,
    algorithm: 'HS256',
  });
}

export function verifyToken(token: string): any {
  return jwt.verify(token, config.JWT_SECRET, { algorithms: ['HS256'] });
}

// 生成安全随机字符串
export function generateSecureToken(length = 32): string {
  return crypto.randomBytes(length).toString('hex');
}

// 加密敏感数据
export function encrypt(text: string, key: string): string {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv('aes-256-gcm', Buffer.from(key, 'hex'), iv);

  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  const authTag = cipher.getAuthTag();

  return ${iv.toString('hex')}:${encrypted}:${authTag.toString('hex')};
}

export function decrypt(encryptedText: string, key: string): string {
  const [ivHex, encrypted, authTagHex] = encryptedText.split(':');
  const iv = Buffer.from(ivHex, 'hex');
  const authTag = Buffer.from(authTagHex, 'hex');

  const decipher = crypto.createDecipheriv('aes-256-gcm', Buffer.from(key, 'hex'), iv);
  decipher.setAuthTag(authTag);

  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}
```

### 输入验证与清理

```typescript
// src/schemas/user.ts
import { z } from 'zod';

// XSS 清理函数
function sanitizeInput(input: string): string {
  return input
    .replace(/[<>]/g, '') // 移除 < 和 >
    .replace(/javascript:/gi, '')
    .replace(/on\w+=/gi, '')
    .trim();
}

export const createUserSchema = z.object({
  email: z
    .string()
    .email('Invalid email format')
    .transform(sanitizeInput)
    .refine((email) => email.length <= 255, 'Email too long'),

  username: z
    .string()
    .min(3, 'Username must be at least 3 characters')
    .max(50, 'Username must be at most 50 characters')
    .regex(/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers and underscores')
    .transform(sanitizeInput),

  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number')
    .regex(/[^A-Za-z0-9]/, 'Password must contain at least one special character'),

  name: z
    .string()
    .max(100, 'Name must be at most 100 characters')
    .transform(sanitizeInput)
    .optional(),
});

export const updateUserSchema = z.object({
  email: z.string().email('Invalid email format').transform(sanitizeInput).optional(),

  username: z
    .string()
    .min(3, 'Username must be at least 3 characters')
    .max(50, 'Username must be at most 50 characters')
    .regex(/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers and underscores')
    .transform(sanitizeInput)
    .optional(),

  name: z
    .string()
    .max(100, 'Name must be at most 100 characters')
    .transform(sanitizeInput)
    .optional(),

  isActive: z.boolean().optional(),
});
```

### 安全清单

- \[ ] **环境变量安全**：敏感密钥存储在环境变量中，通过 Zod 验证
- \[ ] **HTTPS 强制**：生产环境必须使用 HTTPS，配置 HSTS
- \[ ] **CORS 配置**：精确配置允许的来源，避免使用通配符
- \[ ] **SQL 注入防护**：使用 Prisma 参数化查询，避免原始 SQL
- \[ ] **XSS 防护**：对所有用户输入进行清理和转义
- \[ ] **CSRF 保护**：对敏感操作实施 CSRF 令牌验证
- \[ ] **速率限制**：在关键端点实施基于 IP 和用户的速率限制
- \[ ] **依赖安全**：定期运行 `npm audit` 和 `snyk test`
- \[ ] **错误处理**：生产环境不暴露堆栈跟踪和数据库错误详情
- \[ ] **文件上传**：验证文件类型、大小，扫描恶意内容
- \[ ] **会话管理**：使用 HttpOnly、Secure、SameSite 的 Cookie
- \[ ] **安全头**：配置 CSP、X-Frame-Options、X-Content-Type-Options 等

## 测试驱动开发 (TDD)

### 测试配置

```typescript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['/__tests__//*.ts', '/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src//*.ts',
    '!src//*.d.ts',
    '!src//index.ts',
    '!src//*.test.ts',
    '!src//*.spec.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  moduleNameMapper: {
    '^@/(.*)': '<rootDir>/src/1',
  },
};
```

```typescript
// tests/setup.ts
import { redis } from '../src/core/redis';
import { prisma } from '../src/core/database';
import { closeBullMQ } from '../src/core/bullmq';

// 全局测试配置
beforeAll(async () => {
  // 清理测试数据库
  await prisma.$transaction([prisma.session.deleteMany(), prisma.user.deleteMany()]);

  // 清理 Redis
  await redis.flushdb();
});

afterAll(async () => {
  // 关闭连接
  await prisma.$disconnect();
  await redis.quit();
  await closeBullMQ();
});

afterEach(async () => {
  // 清理测试数据
  await prisma.session.deleteMany();
  await prisma.user.deleteMany();
  await redis.flushdb();
});
```

### 单元测试示例

```typescript
// tests/unit/services/user.service.test.ts
import { userService } from '../../../src/services/user.service';
import { prisma } from '../../../src/core/database';
import { redis } from '../../../src/core/redis';
import { hashPassword } from '../../../src/utils/crypto';

jest.mock('../../../src/core/bullmq', () => ({
  emailQueue: {
    add: jest.fn().mockResolvedValue({ id: 'job-123' }),
  },
}));

describe('UserService', () => {
  beforeEach(async () => {
    await prisma.user.deleteMany();
    await redis.flushdb();
  });

  describe('createUser', () => {
    it('创建用户成功', async () => {
      const userData = {
        email: 'test@example.com',
        username: 'testuser',
        password: 'Password123!',
        name: 'Test User',
      };

      const user = await userService.createUser(userData);

      expect(user).toHaveProperty('id');
      expect(user.email).toBe(userData.email);
      expect(user.username).toBe(userData.username);
      expect(user.name).toBe(userData.name);

      // 验证密码被哈希
      const dbUser = await prisma.user.findUnique({
        where: { id: user.id },
      });
      expect(dbUser?.password).not.toBe(userData.password);
    });

    it('邮箱已存在时抛出错误', async () => {
      const existingUser = await prisma.user.create({
        data: {
          email: 'existing@example.com',
          username: 'existing',
          password: await hashPassword('Password123!'),
        },
      });

      await expect(
        userService.createUser({
          email: existingUser.email,
          username: 'newuser',
          password: 'Password123!',
        })
      ).rejects.toThrow('Email already exists');
    });

    it('用户名已存在时抛出错误', async () => {
      const existingUser = await prisma.user.create({
        data: {
          email: 'user1@example.com',
          username: 'existing',
          password: await hashPassword('Password123!'),
        },
      });

      await expect(
        userService.createUser({
          email: 'user2@example.com',
          username: existingUser.username,
          password: 'Password123!',
        })
      ).rejects.toThrow('Username already exists');
    });
  });

  describe('getUserById', () => {
    it('从数据库获取用户', async () => {
      const user = await prisma.user.create({
        data: {
          email: 'test@example.com',
          username: 'testuser',
          password: await hashPassword('Password123!'),
        },
      });

      const result = await userService.getUserById(user.id);

      expect(result?.id).toBe(user.id);
      expect(result?.email).toBe(user.email);
    });

    it('从缓存获取用户', async () => {
      const user = await prisma.user.create({
        data: {
          email: 'test@example.com',
          username: 'testuser',
          password: await hashPassword('Password123!'),
        },
      });

      // 第一次从数据库获取
      const firstCall = await userService.getUserById(user.id);

      // 第二次应该从缓存获取
      const secondCall = await userService.getUserById(user.id);

      expect(firstCall?.id).toBe(user.id);
      expect(secondCall?.id).toBe(user.id);
    });
  });

  describe('authenticate', () => {
    it('使用有效凭据认证成功', async () => {
      const password = 'Password123!';
      const hashedPassword = await hashPassword(password);

      const user = await prisma.user.create({
        data: {
          email: 'test@example.com',
          username: 'testuser',
          password: hashedPassword,
        },
      });

      const result = await userService.authenticate(user.email, password);

      expect(result?.id).toBe(user.id);
      expect(result?.email).toBe(user.email);
    });

    it('使用无效密码认证失败', async () => {
      const user = await prisma.user.create({
        data: {
          email: 'test@example.com',
          username: 'testuser',
          password: await hashPassword('Password123!'),
        },
      });

      const result = await userService.authenticate(user.email, 'WrongPassword!');

      expect(result).toBeNull();
    });

    it('非活跃用户认证失败', async () => {
      const password = 'Password123!';
      const hashedPassword = await hashPassword(password);

      const user = await prisma.user.create({
        data: {
          email: 'test@example.com',
          username: 'testuser',
          password: hashedPassword,
          isActive: false,
        },
      });

      const result = await userService.authenticate(user.email, password);

      expect(result).toBeNull();
    });
  });
});
```

### 集成测试示例

```typescript
// tests/integration/user.routes.test.ts
import request from 'supertest';
import app from '../../src/app';
import { prisma } from '../../src/core/database';
import { hashPassword, signToken } from '../../src/utils/crypto';

describe('User Routes', () => {
  let authToken: string;
  let userId: string;

  beforeAll(async () => {
    // 创建测试用户
    const user = await prisma.user.create({
      data: {
        email: 'test@example.com',
        username: 'testuser',
        password: await hashPassword('Password123!'),
        role: 'ADMIN',
      },
    });

    userId = user.id;
    authToken = signToken({ userId: user.id, role: user.role });
  });

  afterAll(async () => {
    await prisma.user.deleteMany();
  });

  describe('GET /api/v1/users', () => {
    it('需要认证', async () => {
      const response = await request(app.fetch)
        .get('/api/v1/users');

      expect(response.status).toBe(401);
    });

    it('认证用户获取用户列表', async () => {
      const response = await request(app.fetch)
        .get('/api/v1/users')
        .set('Authorization', Bearer ${authToken});

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('data');
      expect(response.body).toHaveProperty('meta');
    });

    it('支持分页', async () => {
      const response = await request(app.fetch)
        .get('/api/v1/users?page=1&limit=5')
        .set('Authorization', Bearer ${authToken});

      expect(response.status).toBe(200);
      expect(response.body.meta).toMatchObject({
        page: 1,
        limit: 5,
      });
    });
  });

  describe('GET /api/v1/users/:id', () => {
    it('获取单个用户', async () => {
      const response = await request(app.fetch)
        .get(/api/v1/users/${userId})
        .set('Authorization', Bearer ${authToken});

      expect(response.status).toBe(200);
      expect(response.body.id).toBe(userId);
    });

    it('用户不存在返回404', async () => {
      const response = await request(app.fetch)
        .get('/api/v1/users/nonexistent')
        .set('Authorization', Bearer ${authToken});

      expect(response.status).toBe(404);
    });
  });

  describe('POST /api/v1/users', () => {
    it('创建新用户', async () => {
      const userData = {
        email: 'new@example.com',
        username: 'newuser',
        password: 'Password123!',
        name: 'New User',
      };

      const response = await request(app.fetch)
        .post('/api/v1/users')
        .set('Authorization', Bearer ${authToken})
        .send(userData);

      expect(response.status).toBe(201);
      expect(response.body.email).toBe(userData.email);
    });

    it('验证输入数据', async () => {
      const invalidData = {
        email: 'invalid-email',
        username: 'ab', // 太短
        password: 'weak',
      };

      const response = await request(app.fetch)
        .post('/api/v1/users')
        .set('Authorization', Bearer ${authToken})
        .send(invalidData);

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
    });
  });
});
```

### E2E 测试示例

```typescript
// tests/e2e/auth-flow.e2e.test.ts
import request from 'supertest';
import app from '../../src/app';
import { prisma } from '../../src/core/database';

describe('Auth Flow E2E', () => {
  beforeAll(async () => {
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    await prisma.user.deleteMany();
  });

  describe('完整注册登录流程', () => {
    it('注册、登录、访问受保护端点', async () => {
      // 1. 注册
      const registerResponse = await request(app.fetch)
        .post('/api/v1/auth/register')
        .send({
          email: 'e2e@example.com',
          username: 'e2euser',
          password: 'Password123!',
          name: 'E2E Test User',
        });

      expect(registerResponse.status).toBe(201);
      expect(registerResponse.body).toHaveProperty('id');

      const userId = registerResponse.body.id;

      // 2. 登录
      const loginResponse = await request(app.fetch)
        .post('/api/v1/auth/login')
        .send({
          email: 'e2e@example.com',
          password: 'Password123!',
        });

      expect(loginResponse.status).toBe(200);
      expect(loginResponse.body).toHaveProperty('token');

      const authToken = loginResponse.body.token;

      // 3. 访问受保护端点
      const profileResponse = await request(app.fetch)
        .get('/api/v1/users/me')
        .set('Authorization', Bearer ${authToken});

      expect(profileResponse.status).toBe(200);
      expect(profileResponse.body.id).toBe(userId);

      // 4. 更新用户信息
      const updateResponse = await request(app.fetch)
        .patch(/api/v1/users/${userId})
        .set('Authorization', Bearer ${authToken})
        .send({
          name: 'Updated Name',
        });

      expect(updateResponse.status).toBe(200);
      expect(updateResponse.body.name).toBe('Updated Name');
    });
  });
});
```

## 验证循环 (Verification)

### 阶段 1：代码质量检查

```bash
#1. TypeScript 类型检查
npm run type-check
#或
npx tsc --noEmit

#2. ESLint 检查
npm run lint
#自动修复
npm run lint:fix

#3. 代码格式化检查
npm run format:check
#自动格式化
npm run format:fix

#4. 导入排序检查
npx sort-package-json
```

### 阶段 2：测试套件

```bash
#运行所有测试
npm test

#运行单元测试
npm run test:unit

#运行集成测试
npm run test:integration

#运行 E2E 测试
npm run test:e2e

#生成覆盖率报告
npm run test:coverage
```

**覆盖率要求**：

- 语句覆盖率 ≥ 80%
- 分支覆盖率 ≥ 70%
- 函数覆盖率 ≥ 80%
- 行覆盖率 ≥ 80%

### 阶段 3：安全扫描

```bash
#1. 依赖漏洞扫描
npm audit
#修复漏洞
npm audit fix

#2. 使用 Snyk
npx snyk test

#3. 检查代码中的安全漏洞
npx npm-audit-html
npm audit --json | npx npm-audit-html > audit.html

#4. 检查许可证
npx license-checker --summary

```

### 阶段 4：性能检查

```bash
#1. 使用 Autocannon 进行负载测试
npx autocannon -c 100 -d 30 http://localhost:3000/health

#2. 使用 Clinic.js 进行性能分析
npx clinic doctor -- node dist/index.js
npx clinic bubbleprof -- node dist/index.js
npx clinic flame -- node dist/index.js

#3. 内存使用分析
node --inspect dist/index.js
#然后使用 Chrome DevTools 分析内存泄漏

```

### 阶段 5：构建与打包

```bash
#1. TypeScript 编译
npm run build

#2. 检查编译产物
npx tsc-alias

#3. 运行 Prisma 生成
npx prisma generate
npx prisma migrate deploy

#4. 构建 Docker 镜像
docker build -t myapp:latest .

#5. 扫描镜像漏洞
docker scan myapp:latest
```

### 阶段 6：部署前验证

```bash
#1. 验证环境变量
echo "检查关键环境变量:"
echo "DATABASE_URL: ${DATABASE_URL:0:20}..."
echo "JWT_SECRET: ${JWT_SECRET:0:10}..."
echo "REDIS_HOST: ${REDIS_HOST}"

#2. 健康检查
curl -f http://localhost:3000/health || exit 1

#3. 运行数据库迁移
npx prisma migrate status
npx prisma migrate deploy

#4. 运行冒烟测试
npm run test:smoke
```

### 验证报告模板

```markdown
# NODE.JS HONO 应用验证报告

项目: [项目名称]
环境: [development/staging/production]
版本: [版本号]
时间: [时间戳]

[✅/❌] 代码质量检查
◦ 类型检查: 通过/失败 (错误数: X)

    ◦ 代码风格: 通过/失败 (警告数: Y)

    ◦ 格式化: 通过/失败

[✅/❌] 测试套件
◦ 单元测试: A/B 通过

    ◦ 集成测试: C/D 通过

    ◦ E2E 测试: M/N 通过

    ◦ 覆盖率: 行: P%, 分支: Q%, 函数: R%

[✅/❌] 安全扫描
◦ 依赖漏洞: 通过/失败 (漏洞数: V)

    ◦ 代码安全: 通过/失败 (问题数: W)

[✅/❌] 性能测试
◦ 平均响应时间: X ms

    ◦ 吞吐量: Y req/s

    ◦ 错误率: Z%

[✅/❌] 构建与部署
◦ TypeScript 编译: 通过/失败

    ◦ 数据库迁移: 通过/失败

    ◦ Docker 构建: 通过/失败 (镜像大小: S MB)

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


    steps:
      ◦ uses: actions/checkout@v4


      ◦ name: Setup Node.js

        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      ◦ name: Install dependencies

        run: npm ci

      ◦ name: Run code quality checks

        run: |
          npm run type-check
          npm run lint
          npm run format:check

      ◦ name: Run security checks

        run: |
          npm audit
          npx snyk test --severity-threshold=high

      ◦ name: Run tests

        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test_db
          JWT_SECRET: test-secret-key-for-ci
          REDIS_HOST: localhost
        run: |
          npm run test:coverage

      ◦ name: Upload coverage

        uses: codecov/codecov-action@v3

      ◦ name: Build

        run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      ◦ uses: actions/checkout@v4


      ◦ name: Setup Docker Buildx

        uses: docker/setup-buildx-action@v3

      ◦ name: Login to Docker Hub

        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      ◦ name: Build and push Docker image

        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/myapp:latest
            {{ secrets.DOCKER_USERNAME }}/myapp:{{ github.sha }}
```

### 核心原则

1.  **性能优先：**HonoJS 专为高性能设计，充分利用其轻量级特性和边缘计算能力
2.  **类型安全：**使用 TypeScript 严格模式，结合 Prisma 实现从数据库到 API 的端到端类型安全
3.  **异步处理：**利用 BullMQ 处理后台任务，避免阻塞主线程
4.  **缓存策略：**合理使用 Redis 缓存，减少数据库压力
5.  **测试驱动：**为业务逻辑、API 端点和异步任务编写全面的测试，确保代码质量和功能稳定性
6.  **安全默认：**从项目开始就实施安全最佳实践，包括输入验证、认证授权、依赖安全
7.  **可观测性：**通过结构化日志、指标收集和健康检查，确保系统可观测性
8.  **自动化一切：**通过 CI/CD 自动化测试、检查、构建和部署流程，确保快速、可靠的交付

记住：Node.js 生态快速发展，保持依赖更新，关注安全公告，定期进行代码审计。良好的架构、严格的质量门禁和自动化的流程是构建稳定、可扩展的生产级应用的关键。
