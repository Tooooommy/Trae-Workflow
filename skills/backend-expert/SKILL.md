---
name: backend-expert
description: 后端开发专家模式。根据PRD和API文档生成后端代码、数据库Schema、API设计与文档、第三方服务集成。当需要进行Node.js/Python/Go后端开发、API设计、数据库设计、第三方服务集成时使用此Skill。
---

# 后端开发专家模式

根据 PRD 和 API 文档生成后端代码，实现数据库设计和第三方服务集成。

## 何时激活

- 根据 PRD 开发后端服务和 API
- 设计数据库 Schema
- 实现 API 接口和文档
- 集成第三方服务（支付、消息队列、存储等）
- 实现业务逻辑和中间件

## 核心职责

1. **PRD 解析** - 从产品需求文档提取后端需求
2. **API 设计** - 设计 RESTful/GraphQL API 并生成文档
3. **数据库设计** - 设计数据库 Schema 和索引
4. **服务开发** - 实现业务逻辑和服务层
5. **集成开发** - 集成第三方服务

## 输入要求

### PRD 文档

```markdown
## 功能需求

- 用户登录后显示个性化仪表盘
- 支持多语言切换

## 数据需求

- 用户数据存储
- 仪表盘配置存储

## 第三方服务

- 短信验证码
- 文件存储
```

### API 接口文档

```markdown
## 用户接口

### GET /api/users/:id

- 请求参数: id (string)
- 响应: User

### POST /api/users

- 请求体: CreateUserDto
- 响应: User
```

## 输出产物

### 代码结构

```
src/
├── controllers/       # 控制器层
│   └── user.controller.ts
├── services/          # 服务层
│   └── user.service.ts
├── repositories/     # 仓储层
│   └── user.repository.ts
├── models/           # 数据模型
│   ├── user.model.ts
│   └── database.ts
├── middleware/        # 中间件
│   ├── auth.middleware.ts
│   └── error.middleware.ts
├── routes/            # 路由定义
│   └── user.routes.ts
├── dto/               # 数据传输对象
│   ├── create-user.dto.ts
│   └── update-user.dto.ts
├── config/            # 配置文件
└── index.ts           # 入口文件
```

### API 设计与自动文档

```typescript
// routes/user.routes.ts
/**
 * @route GET /api/users
 * @desc 获取用户列表
 * @tags User
 * @param {number} page - 页码
 * @param {number} limit - 每页数量
 * @returns {PaginatedResponse<User>} 用户列表
 */
router.get('/', validateQuery(ListUsersQuery), userController.list);

/**
 * @route GET /api/users/:id
 * @desc 获取单个用户
 * @tags User
 * @param {string} id - 用户ID
 * @returns {Response<User>} 用户信息
 */
router.get('/:id', validateParams(IdParam), userController.get);

/**
 * @route POST /api/users
 * @desc 创建用户
 * @tags User
 * @param {CreateUserDto} body - 创建用户参数
 * @returns {Response<User>} 创建的用户
 */
router.post('/', validateBody(CreateUserSchema), userController.create);

/**
 * @route PUT /api/users/:id
 * @desc 更新用户
 * @tags User
 * @param {string} id - 用户ID
 * @param {UpdateUserDto} body - 更新用户参数
 * @returns {Response<User>} 更新后的用户
 */
router.put('/:id', validateParams(IdParam), validateBody(UpdateUserSchema), userController.update);

/**
 * @route DELETE /api/users/:id
 * @desc 删除用户
 * @tags User
 * @param {string} id - 用户ID
 * @returns {Response<void>}
 */
router.delete('/:id', validateParams(IdParam), userController.delete);
```

### 统一响应格式

```typescript
// types/api-response.ts
interface ApiResponse<T> {
  success: boolean;
  data: T | null;
  error: string | null;
  meta?: {
    total?: number;
    page?: number;
    limit?: number;
    totalPages?: number;
  };
}

interface PaginatedResponse<T> extends ApiResponse<T[]> {
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPrevPage: boolean;
  };
}

function successResponse<T>(data: T, meta?: Meta): ApiResponse<T> {
  return { success: true, data, error: null, meta };
}

function errorResponse(error: string): ApiResponse<null> {
  return { success: false, data: null, error };
}
```

## 数据库 Schema 设计

### Prisma Schema

```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  password  String
  avatar    String?
  role      UserRole @default(USER)
  status    UserStatus @default(ACTIVE)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // 关系
  posts     Post[]
  orders    Order[]

  @@index([email])
  @@index([status])
}

model Post {
  id        String   @id @default(uuid())
  title     String
  content   String
  authorId  String
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
}

enum UserRole {
  USER
  ADMIN
}

enum UserStatus {
  ACTIVE
  INACTIVE
  BANNED
}
```

### 迁移命令

```bash
# 生成迁移
npx prisma migrate dev --name add_user_post_relation

# 应用迁移
npx prisma migrate deploy

# 生成客户端
npx prisma generate
```

## 第三方服务集成

### 支付集成

```typescript
// integrations/payment/stripe.service.ts
import Stripe from 'stripe';

export class PaymentService {
  private stripe: Stripe;

  constructor() {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
  }

  async createPaymentIntent(amount: number, currency: string = 'cny') {
    return this.stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // 转换为分
      currency,
    });
  }

  async refund(paymentIntentId: string) {
    return this.stripe.refunds.create({
      payment_intent: paymentIntentId,
    });
  }
}
```

### 消息队列集成

```typescript
// integrations/queue/kafka.service.ts
import { Kafka, Producer, Consumer } from 'kafkajs';

export class QueueService {
  private kafka: Kafka;
  private producer: Producer;

  constructor() {
    this.kafka = new Kafka({
      clientId: 'my-app',
      brokers: [process.env.KAFKA_BROKER!],
    });
    this.producer = this.kafka.producer();
  }

  async send(topic: string, message: object) {
    await this.producer.send({
      topic,
      messages: [{ value: JSON.stringify(message) }],
    });
  }

  async subscribe(topic: string, handler: (message: object) => Promise<void>) {
    const consumer = this.kafka.consumer();
    await consumer.subscribe({ topic, fromBeginning: false });

    await consumer.run({
      eachMessage: async ({ message }) => {
        if (message.value) {
          await handler(JSON.parse(message.value.toString()));
        }
      },
    });
  }
}
```

### 文件存储集成

```typescript
// integrations/storage/oss.service.ts
import OSS from 'ali-oss';

export class StorageService {
  private client: OSS;

  constructor() {
    this.client = new OSS({
      region: process.env.OSS_REGION!,
      accessKeyId: process.env.OSS_ACCESS_KEY_ID!,
      accessKeySecret: process.env.OSS_ACCESS_KEY_SECRET!,
      bucket: process.env.OSS_BUCKET!,
    });
  }

  async upload(key: string, file: Buffer | string) {
    return this.client.put(key, file);
  }

  async getSignedUrl(key: string, expires: number = 3600) {
    return this.client.signatureUrl(key, { expires });
  }

  async delete(key: string) {
    return this.client.delete(key);
  }
}
```

## 服务层模板

```typescript
// services/user.service.ts
export class UserService {
  constructor(
    private userRepo: UserRepository,
    private cache: CacheService,
    private eventEmitter: EventEmitter
  ) {}

  async createUser(data: CreateUserDto): Promise<User> {
    const existing = await this.userRepo.findByEmail(data.email);
    if (existing) {
      throw new ConflictError('User with this email already exists');
    }

    const hashedPassword = await bcrypt.hash(data.password, 10);
    const user = await this.userRepo.create({
      ...data,
      password: hashedPassword,
    });

    this.eventEmitter.emit('user:created', { userId: user.id });
    return user;
  }

  async getUserById(id: string): Promise<User> {
    const cached = await this.cache.get<User>(`user:${id}`);
    if (cached) return cached;

    const user = await this.userRepo.findById(id);
    if (!user) throw new NotFoundError('User');

    await this.cache.set(`user:${id}`, user, 300);
    return user;
  }

  async updateUser(id: string, data: UpdateUserDto): Promise<User> {
    const user = await this.userRepo.update(id, data);
    await this.cache.del(`user:${id}`);
    this.eventEmitter.emit('user:updated', { userId: id });
    return user;
  }
}
```

## 技术栈版本

| 技术            | 最低版本    | 推荐版本 |
| --------------- | ----------- | -------- |
| Node.js         | 20+         | 22+      |
| TypeScript      | 5.0+        | 最新     |
| Express/Fastify | 4.18+/4.24+ | 最新     |
| Prisma          | 5.0+        | 最新     |
| Redis           | 7.0+        | 7.4+     |
| PostgreSQL      | 15+         | 16+      |
| BullMQ          | 5.0+        | 最新     |

## 质量门禁

| 检查项      | 阈值   |
| ----------- | ------ |
| lint / type | 100%   |
| 单元测试    | ≥ 80%  |
| 安全扫描    | 0 高危 |

## 子技能映射

| 类型              | 调用 Skill                                                 | 触发关键词       |
| ----------------- | ---------------------------------------------------------- | ---------------- |
| Node.js / Express | `express-patterns`                                         | Node.js, Express |
| Python / FastAPI  | `fastapi-patterns`                                         | Python, FastAPI  |
| Go / Gin          | `golang-patterns`                                          | Go, Gin          |
| GraphQL           | `graphql-patterns`                                         | GraphQL, Apollo  |
| 实时通信          | `realtime-websocket`                                       | WebSocket, SSE   |
| 支付集成          | `stripe-patterns`, `alipay-patterns`, `wechatpay-patterns` | 支付             |
| 消息队列          | `message-queue-patterns`                                   | Kafka, RabbitMQ  |
| SQL 数据库        | `postgres-patterns`                                        | PostgreSQL, SQL  |
| NoSQL 数据库      | `mongodb-patterns`                                         | MongoDB, NoSQL   |
| 缓存              | `cache-strategy-patterns`                                         | 缓存, 性能       |
| 后台任务          | `tasks-patterns`                                          | 后台任务, Cron   |
| 安全              | `security-expert`                                          | 安全, 漏洞       |
| REST API          | `rest-patterns`                                            | REST, API        |
| 数据库迁移        | `database-dev`                                        | 迁移, schema     |
