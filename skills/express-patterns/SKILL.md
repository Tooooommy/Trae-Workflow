---
name: express-patterns
description: Node.js 现代全栈开发模式，基于 Express、TypeScript、PostgreSQL、Prisma、Redis 和 BullMQ。涵盖高性能 API 设计、类型安全、异步处理、安全实践、测试驱动开发和项目验证循环。
---

# Node.js Express 全栈开发模式

基于 Express、TypeScript、PostgreSQL、Prisma、Redis 和 BullMQ 的现代化 Node.js API 开发模式。包含极简高性能框架、类型安全数据库访问、消息队列集成、结构化日志、安全最佳实践、测试策略和生产部署验证。

## 何时激活

- 使用 **Express** 构建高性能、轻量级的 API 和 Web 应用
- 采用 **TypeScript** 严格模式确保端到端类型安全
- 使用 **Prisma** 进行类型安全的数据库操作和迁移管理
- 使用 **PostgreSQL** 作为主关系型数据库
- 使用 **Redis** 进行缓存、会话存储和 **BullMQ** 消息队列
- 需要 **Pino** 结构化日志和 **Swagger** 自动 API 文档
- 使用 **Jest** 进行全面的测试覆盖
- 构建需要高并发、低延迟的生产级微服务和 API 网关

## 技术栈版本

| 技术       | 最低版本 | 推荐版本 |
| ---------- | -------- | -------- |
| Node.js    | 18.0+    | 20.0+    |
| Express    | 4.18+    | 最新     |
| TypeScript | 5.0+     | 最新     |
| Prisma     | 5.0+     | 最新     |
| PostgreSQL | 14.0+    | 16.0+    |
| Redis      | 7.0+     | 最新     |
| BullMQ     | 5.0+     | 最新     |

## 开发模式 (Patterns)

### 项目结构

```bash
my-express-app/
├── src/
│   ├── core/                    # 核心配置与工具
│   │   ├── config.ts           # 应用配置
│   │   ├── database.ts         # Prisma 客户端
│   │   ├── redis.ts            # Redis 客户端
│   │   ├── bullmq.ts           # BullMQ 队列
│   │   ├── logger.ts           # Pino 日志配置
│   │   └── swagger.ts          # OpenAPI 文档
│   ├── models/                 # 数据模型 (Prisma)
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
│   ├── middleware/             # Express 中间件
│   │   ├── auth.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── logger.middleware.ts
│   ├── routes/                 # API 路由
│   │   ├── v1/
│   │   │   ├── auth.routes.ts
│   │   │   ├── user.routes.ts
│   │   │   └── product.routes.ts
│   │   └── index.ts
│   ├── controllers/            # 控制器
│   │   ├── auth.controller.ts
│   │   ├── user.controller.ts
│   │   └── product.controller.ts
│   ├── workers/                # BullMQ Worker
│   │   ├── email.worker.ts
│   │   └── report.worker.ts
│   ├── utils/                  # 工具函数
│   │   ├── crypto.ts
│   │   ├── validators.ts
│   │   └── cache.ts
│   └── app.ts                  # Express 应用入口
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

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_HOST: z.string().default('localhost'),
  REDIS_PORT: z.coerce.number().default(6379),
  REDIS_PASSWORD: z.string().optional(),
  REDIS_DB_CACHE: z.coerce.number().default(0),
  REDIS_DB_QUEUE: z.coerce.number().default(1),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('1h'),
  API_PREFIX: z.string().default('/api'),
  API_VERSION: z.string().default('v1'),
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

  get redisUrl(): string {
    const { REDIS_HOST, REDIS_PORT, REDIS_PASSWORD, REDIS_DB_CACHE } = this.config;
    const auth = REDIS_PASSWORD ? `:${REDIS_PASSWORD}@` : '';
    return `redis://${auth}${REDIS_HOST}:${REDIS_PORT}/${REDIS_DB_CACHE}`;
  }
}

export const config = Config.getInstance().config;
export const isDevelopment = Config.getInstance().isDevelopment;
export const isProduction = Config.getInstance().isProduction;
```

### Express 应用配置

```typescript
// src/app.ts
import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { config } from './core/config';
import { errorHandler } from './middleware/error.middleware';
import { requestLogger } from './middleware/logger.middleware';
import routes from './routes';
import { setupSwagger } from './core/swagger';

const app: Application = express();

app.use(
  cors({
    origin: config.CORS_ORIGIN,
    credentials: true,
  })
);

app.use(helmet());
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(requestLogger);

if (isDevelopment) {
  const morgan = require('morgan');
  app.use(morgan('dev'));
}

app.get('/health', (_req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: config.NODE_ENV,
  });
});

app.use(`${config.API_PREFIX}/${config.API_VERSION}`, routes);

if (isDevelopment) {
  setupSwagger(app);
}

app.use((_req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route not found`,
  });
});

app.use(errorHandler);

const PORT = config.PORT;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

export default app;
```

### Prisma Schema

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

  products Product[]
  sessions Session[]

  @@map("users")
  @@index([email])
  @@index([username])
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

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("products")
  @@index([userId])
  @@index([price])
}

model Session {
  id        String   @id @default(cuid())
  userId    String
  token     String   @unique
  expiresAt DateTime
  userAgent String?
  ipAddress String?
  createdAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("sessions")
  @@index([token])
  @@index([expiresAt])
}

enum Role {
  USER
  ADMIN
  SUPER_ADMIN
}
```

### 数据库客户端

```typescript
// src/core/database.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: isDevelopment ? ['query', 'info', 'warn', 'error'] : ['error'],
  });

if (isDevelopment) globalForPrisma.prisma = prisma;

export const extendedPrisma = prisma.$extends({
  query: {
    $allModels: {
      async $allOperations({ operation, model, args, query }) {
        const start = performance.now();
        const result = await query(args);
        const end = performance.now();
        const time = end - start;

        if (time > 100) {
          console.warn(`Slow query detected on ${model}.${operation}: ${time}ms`);
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
import { Router } from 'express';
import { z } from 'zod';
import { userController } from '../../controllers/user.controller';
import { authMiddleware } from '../../middleware/auth.middleware';
import { roleMiddleware } from '../../middleware/role.middleware';
import { validate } from '../../middleware/validate.middleware';
import { cacheMiddleware } from '../../middleware/cache.middleware';

const userRoutes = Router();

const createUserSchema = z.object({
  email: z.string().email(),
  username: z.string().min(3).max(50),
  password: z.string().min(8),
  name: z.string().optional(),
});

const updateUserSchema = z.object({
  email: z.string().email().optional(),
  username: z.string().min(3).max(50).optional(),
  name: z.string().optional(),
  isActive: z.boolean().optional(),
});

userRoutes.get('/', authMiddleware, cacheMiddleware({ ttl: 60 }), userController.getUsers);
userRoutes.get('/:id', authMiddleware, cacheMiddleware({ ttl: 300 }), userController.getUserById);
userRoutes.post(
  '/',
  authMiddleware,
  roleMiddleware(['ADMIN', 'SUPER_ADMIN']),
  validate(createUserSchema),
  userController.createUser
);
userRoutes.patch('/:id', authMiddleware, validate(updateUserSchema), userController.updateUser);
userRoutes.delete(
  '/:id',
  authMiddleware,
  roleMiddleware(['ADMIN', 'SUPER_ADMIN']),
  userController.deleteUser
);

export default userRoutes;
```

```typescript
// src/controllers/user.controller.ts
import { Request, Response, NextFunction } from 'express';
import { userService } from '../services/user.service';

export class UserController {
  async getUsers(req: Request, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search } = req.query;
      const result = await userService.getUsers({
        page: Number(page),
        limit: Number(limit),
        search: search as string,
      });
      res.json(result);
    } catch (error) {
      next(error);
    }
  }

  async getUserById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const user = await userService.getUserById(id);

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json(user);
    } catch (error) {
      next(error);
    }
  }

  async createUser(req: Request, res: Response, next: NextFunction) {
    try {
      const user = await userService.createUser(req.body);
      res.status(201).json(user);
    } catch (error) {
      next(error);
    }
  }

  async updateUser(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const userId = (req as any).user?.userId;

      if (id !== userId && !(req as any).user?.role?.includes('ADMIN')) {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const user = await userService.updateUser(id, req.body);
      res.json(user);
    } catch (error) {
      next(error);
    }
  }

  async deleteUser(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      await userService.deleteUser(id);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }
}

export const userController = new UserController();
```

### 服务层模式

```typescript
// src/services/user.service.ts
import { prisma } from '../core/database';
import { hashPassword, verifyPassword } from '../utils/crypto';
import { redis } from '../core/redis';
import { emailQueue } from '../core/bullmq';

export class UserService {
  async getUsers(params: { page: number; limit: number; search?: string }) {
    const { page, limit, search } = params;
    const skip = (page - 1) * limit;

    const where = search
      ? {
          OR: [
            { email: { contains: search, mode: 'insensitive' } },
            { username: { contains: search, mode: 'insensitive' } },
            { name: { contains: search, mode: 'insensitive' } },
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

    return { data: users, meta: { page, limit, total, pages: Math.ceil(total / limit) } };
  }

  async getUserById(id: string) {
    const cacheKey = `user:${id}`;
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

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
      await redis.setex(cacheKey, 300, JSON.stringify(user));
    }

    return user;
  }

  async createUser(data: { email: string; username: string; password: string; name?: string }) {
    const existingUser = await prisma.user.findUnique({ where: { email: data.email } });
    if (existingUser) throw new Error('Email already exists');

    const existingUsername = await prisma.user.findUnique({ where: { username: data.username } });
    if (existingUsername) throw new Error('Username already exists');

    const hashedPassword = await hashPassword(data.password);

    const user = await prisma.user.create({
      data: { ...data, password: hashedPassword },
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

    await emailQueue.add('send-welcome-email', { email: user.email, username: user.username });

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

    await redis.del(`user:${id}`);
    return user;
  }

  async deleteUser(id: string) {
    await prisma.user.delete({ where: { id } });
    await redis.del(`user:${id}`);
  }

  async authenticate(email: string, password: string) {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.isActive) return null;

    const isValid = await verifyPassword(password, user.password);
    if (!isValid) return null;

    await prisma.user.update({ where: { id: user.id }, data: { lastLogin: new Date() } });

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

### BullMQ 消息队列

```typescript
// src/core/bullmq.ts
import { Queue, Worker, QueueEvents } from 'bullmq';
import IORedis from 'ioredis';
import { config } from './config';
import { logger } from './logger';

const connection = new IORedis(config.queueRedisUrl, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

export const emailQueue = new Queue('email', { connection });
export const reportQueue = new Queue('report', { connection });

const emailWorker = new Worker(
  'email',
  async (job) => {
    logger.info(`Processing email job ${job.id}`);

    switch (job.name) {
      case 'send-welcome-email':
        const { email, username } = job.data;
        console.log(`Sending welcome email to ${email} for user ${username}`);
        break;
      case 'send-password-reset':
        const { email: resetEmail, token } = job.data;
        console.log(`Sending password reset email to ${resetEmail} with token ${token}`);
        break;
    }
  },
  { connection }
);

emailWorker.on('failed', (job, err) => {
  logger.error(`Job ${job?.id} failed: ${err.message}`);
});

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
import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/crypto';
import { prisma } from '../core/database';

export const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = verifyToken(token);

    const session = await prisma.session.findFirst({
      where: { token, expiresAt: { gt: new Date() } },
    });

    if (!session) {
      return res.status(401).json({ error: 'Session expired' });
    }

    (req as any).user = { userId: payload.userId, role: payload.role, sessionId: session.id };
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

```typescript
// src/middleware/rate-limit.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { redis } from '../core/redis';

export function rateLimitMiddleware(options: {
  windowMs: number;
  max: number;
  keyPrefix?: string;
}) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const { windowMs, max, keyPrefix = 'rate-limit' } = options;
    const key = `${keyPrefix}:${req.ip}`;
    const now = Date.now();

    const requests = await redis.lrange(key, 0, -1);
    const recentRequests = requests.map(Number).filter((time) => now - time < windowMs);

    if (recentRequests.length >= max) {
      return res.status(429).json({ error: 'Too many requests' });
    }

    await redis.lpush(key, now.toString());
    await redis.expire(key, Math.ceil(windowMs / 1000));

    next();
  };
}
```

```typescript
// src/middleware/error.middleware.ts
import { Request, Response, NextFunction } from 'express';

export class ApiError extends Error {
  constructor(
    public statusCode: number,
    public message: string
  ) {
    super(message);
    Object.setPrototypeOf(this, ApiError.prototype);
  }
}

export function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({ error: err.message });
  }

  if (err.name === 'ZodError') {
    return res.status(400).json({ error: 'Validation failed', details: err });
  }

  console.error('Unexpected error:', err);
  return res.status(500).json({ error: 'Internal server error' });
}
```

```typescript
// src/middleware/logger.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { logger } from '../core/logger';

export const requestLogger = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info({
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
    });
  });

  next();
};
```

### Swagger 文档

```typescript
// src/core/swagger.ts
import express, { Application } from 'express';
import swaggerJsdoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';
import { config } from './config';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Express API',
      version: '1.0.0',
    },
    servers: [{ url: `http://localhost:${config.PORT}` }],
  },
  apis: ['./src/routes/**/*.ts'],
};

const specs = swaggerJsdoc(options);

export function setupSwagger(app: Application) {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
}
```

## 快速参考

```bash
# 安装依赖
npm install express cors helmet compression morgan
npm install -D typescript @types/express @types/node

# 开发模式
npm run dev

# 生产构建
npm run build
npm start

# Prisma
npx prisma generate
npx prisma migrate dev
```

## 参考

- [Express.js 文档](https://expressjs.com/)
- [Prisma 文档](https://www.prisma.io/docs)
- [BullMQ 文档](https://docs.bullmq.io/)
