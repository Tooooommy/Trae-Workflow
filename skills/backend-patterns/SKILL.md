---
name: backend-patterns
description: 后端架构模式、API设计、数据库优化以及适用于Node.js、Express和Next.js API路由的服务器端最佳实践。
---

# 后端开发模式

用于可扩展服务器端应用程序的后端架构模式和最佳实践。

## 何时激活

- 设计 REST 或 GraphQL API 端点时
- 实现仓储层、服务层或控制器层时
- 优化数据库查询（N+1问题、索引、连接池）时
- 添加缓存（Redis、内存缓存、HTTP 缓存头）时
- 设置后台作业或异步处理时
- 为 API 构建错误处理和验证结构时
- 构建中间件（认证、日志记录、速率限制）时

## 技术栈版本

| 技术            | 最低版本    | 推荐版本 |
| --------------- | ----------- | -------- |
| Node.js         | 20+         | 22+      |
| TypeScript      | 5.0+        | 最新     |
| Express/Fastify | 4.18+/4.24+ | 最新     |
| Prisma          | 5.0+        | 最新     |
| Redis           | 7.0+        | 7.4+     |

## API 设计模式

### RESTful API 结构

```typescript
// ✅ Resource-based URLs
GET    /api/markets                 # List resources
GET    /api/markets/:id             # Get single resource
POST   /api/markets                 # Create resource
PUT    /api/markets/:id             # Replace resource
PATCH  /api/markets/:id             # Update resource
DELETE /api/markets/:id             # Delete resource

// ✅ Query parameters for filtering, sorting, pagination
GET /api/markets?status=active&sort=volume&limit=20&offset=0
```

### 仓储模式

```typescript
// Abstract data access logic
interface MarketRepository {
  findAll(filters?: MarketFilters): Promise<Market[]>;
  findById(id: string): Promise<Market | null>;
  create(data: CreateMarketDto): Promise<Market>;
  update(id: string, data: UpdateMarketDto): Promise<Market>;
  delete(id: string): Promise<void>;
}

class SupabaseMarketRepository implements MarketRepository {
  async findAll(filters?: MarketFilters): Promise<Market[]> {
    let query = supabase.from('markets').select('*');

    if (filters?.status) {
      query = query.eq('status', filters.status);
    }

    if (filters?.limit) {
      query = query.limit(filters.limit);
    }

    const { data, error } = await query;

    if (error) throw new Error(error.message);
    return data;
  }

  // Other methods...
}
```

### 服务层模式

```typescript
// Business logic separated from data access
class MarketService {
  constructor(private marketRepo: MarketRepository) {}

  async searchMarkets(query: string, limit: number = 10): Promise<Market[]> {
    // Business logic
    const embedding = await generateEmbedding(query);
    const results = await this.vectorSearch(embedding, limit);

    // Fetch full data
    const markets = await this.marketRepo.findByIds(results.map((r) => r.id));

    // Sort by similarity
    return markets.sort((a, b) => {
      const scoreA = results.find((r) => r.id === a.id)?.score || 0;
      const scoreB = results.find((r) => r.id === b.id)?.score || 0;
      return scoreA - scoreB;
    });
  }

  private async vectorSearch(embedding: number[], limit: number) {
    // Vector search implementation
  }
}
```

### 中间件模式

```typescript
// Request/response processing pipeline
export function withAuth(handler: NextApiHandler): NextApiHandler {
  return async (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    try {
      const user = await verifyToken(token);
      req.user = user;
      return handler(req, res);
    } catch (error) {
      return res.status(401).json({ error: 'Invalid token' });
    }
  };
}

// Usage
export default withAuth(async (req, res) => {
  // Handler has access to req.user
});
```

## 数据库模式

### 查询优化

```typescript
// ✅ GOOD: Select only needed columns
const { data } = await supabase
  .from('markets')
  .select('id, name, status, volume')
  .eq('status', 'active')
  .order('volume', { ascending: false })
  .limit(10);

// ❌ BAD: Select everything
const { data } = await supabase.from('markets').select('*');
```

### N+1 查询预防

```typescript
// ❌ BAD: N+1 query problem
const markets = await getMarkets();
for (const market of markets) {
  market.creator = await getUser(market.creator_id); // N queries
}

// ✅ GOOD: Batch fetch
const markets = await getMarkets();
const creatorIds = markets.map((m) => m.creator_id);
const creators = await getUsers(creatorIds); // 1 query
const creatorMap = new Map(creators.map((c) => [c.id, c]));

markets.forEach((market) => {
  market.creator = creatorMap.get(market.creator_id);
});
```

### 事务模式

```typescript
async function createMarketWithPosition(
  marketData: CreateMarketDto,
  positionData: CreatePositionDto
) {
  // Use Supabase transaction
  const { data, error } = await supabase.rpc('create_market_with_position', {
    market_data: marketData,
    position_data: positionData
  })

  if (error) throw new Error('Transaction failed')
  return data
}

// SQL function in Supabase
CREATE OR REPLACE FUNCTION create_market_with_position(
  market_data jsonb,
  position_data jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
AS $
BEGIN
  -- Start transaction automatically
  INSERT INTO markets VALUES (market_data);
  INSERT INTO positions VALUES (position_data);
  RETURN jsonb_build_object('success', true);
EXCEPTION
  WHEN OTHERS THEN
    -- Rollback happens automatically
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$;
```

## Prisma ORM 模式

### Schema 定义

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String    @id @default(cuid())
  email     String    @unique
  name      String?
  posts     Post[]
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  authorId  String
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
}
```

### CRUD 操作

```typescript
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// 创建
const user = await prisma.user.create({
  data: { email: 'user@example.com', name: 'John' },
});

// 查询
const user = await prisma.user.findUnique({
  where: { id: 'user-id' },
  include: { posts: true },
});

// 更新
await prisma.user.update({
  where: { id: 'user-id' },
  data: { name: 'Jane' },
});

// 删除
await prisma.user.delete({ where: { id: 'user-id' } });
```

### 关系查询

```typescript
const postsWithAuthor = await prisma.post.findMany({
  include: {
    author: { select: { id: true, name: true } },
  },
});

const userWithCount = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    _count: { select: { posts: true } },
  },
});
```

### 事务

```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { email, name } });
  await tx.post.create({ data: { title, authorId: user.id } });
});
```

### 快速参考

```bash
# 生成客户端
npx prisma generate

# 创建迁移
npx prisma migrate dev --name init

# 打开 Studio
npx prisma studio
```

## 缓存策略

### Redis 缓存层

```typescript
class CachedMarketRepository implements MarketRepository {
  constructor(
    private baseRepo: MarketRepository,
    private redis: RedisClient
  ) {}

  async findById(id: string): Promise<Market | null> {
    // Check cache first
    const cached = await this.redis.get(`market:${id}`);

    if (cached) {
      return JSON.parse(cached);
    }

    // Cache miss - fetch from database
    const market = await this.baseRepo.findById(id);

    if (market) {
      // Cache for 5 minutes
      await this.redis.setex(`market:${id}`, 300, JSON.stringify(market));
    }

    return market;
  }

  async invalidateCache(id: string): Promise<void> {
    await this.redis.del(`market:${id}`);
  }
}
```

### 旁路缓存模式

```typescript
async function getMarketWithCache(id: string): Promise<Market> {
  const cacheKey = `market:${id}`;

  // Try cache
  const cached = await redis.get(cacheKey);
  if (cached) return JSON.parse(cached);

  // Cache miss - fetch from DB
  const market = await db.markets.findUnique({ where: { id } });

  if (!market) throw new Error('Market not found');

  // Update cache
  await redis.setex(cacheKey, 300, JSON.stringify(market));

  return market;
}
```

## 错误处理模式

### 集中式错误处理程序

```typescript
class ApiError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, ApiError.prototype);
  }
}

export function errorHandler(error: unknown, req: Request): Response {
  if (error instanceof ApiError) {
    return NextResponse.json(
      {
        success: false,
        error: error.message,
      },
      { status: error.statusCode }
    );
  }

  if (error instanceof z.ZodError) {
    return NextResponse.json(
      {
        success: false,
        error: 'Validation failed',
        details: error.errors,
      },
      { status: 400 }
    );
  }

  // Log unexpected errors
  console.error('Unexpected error:', error);

  return NextResponse.json(
    {
      success: false,
      error: 'Internal server error',
    },
    { status: 500 }
  );
}

// Usage
export async function GET(request: Request) {
  try {
    const data = await fetchData();
    return NextResponse.json({ success: true, data });
  } catch (error) {
    return errorHandler(error, request);
  }
}
```

### 指数退避重试

```typescript
async function fetchWithRetry<T>(fn: () => Promise<T>, maxRetries = 3): Promise<T> {
  let lastError: Error;

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;

      if (i < maxRetries - 1) {
        // Exponential backoff: 1s, 2s, 4s
        const delay = Math.pow(2, i) * 1000;
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError!;
}

// Usage
const data = await fetchWithRetry(() => fetchFromAPI());
```

## 认证与授权

### 认证方案对比

| 方案    | 适用场景   | 优点           | 缺点       |
| ------- | ---------- | -------------- | ---------- |
| JWT     | 无状态 API | 可扩展、自包含 | 无法撤销   |
| Session | 传统 Web   | 可控、安全     | 需要存储   |
| OAuth   | 社交登录   | 用户体验好     | 依赖第三方 |
| API Key | 服务间调用 | 简单直接       | 权限粒度粗 |

### 安全密码存储

```typescript
import { hash, compare } from 'bcrypt';

const SALT_ROUNDS = 12;

async function hashPassword(password: string): Promise<string> {
  return hash(password, SALT_ROUNDS);
}

async function verifyPassword(password: string, hashed: string): Promise<boolean> {
  return compare(password, hashed);
}
```

### JWT 安全配置

```typescript
import { SignJWT, jwtVerify } from 'jose';

const secret = new TextEncoder().encode(process.env.JWT_SECRET!);

async function createToken(payload: object) {
  return new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('2h')
    .sign(secret);
}

async function verifyToken(token: string) {
  const { payload } = await jwtVerify(token, secret);
  return payload;
}
```

### 刷新令牌模式

```typescript
interface TokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  token_type: 'Bearer';
}

async function refreshAccessToken(refreshToken: string): Promise<TokenResponse> {
  const response = await fetch('/oauth/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
    }),
  });
  return response.json();
}
```

### OAuth 2.0 授权码流程

```
User -> Client -> Auth Server -> User Login/Consent
                                        │
User <- Client <- Auth Server (Code) <-┘
                    │
Client -> Auth Server (Code + Secret)
                    │
Client <- Auth Server (Access Token)
```

### 常见安全漏洞防护

| 漏洞     | 防护措施                    |
| -------- | --------------------------- |
| 暴力破解 | 速率限制、账户锁定          |
| 会话劫持 | HTTPS、HttpOnly Cookie      |
| CSRF     | CSRF Token、SameSite Cookie |
| XSS      | 输入验证、输出编码          |
| SQL 注入 | 参数化查询                  |

### RBAC 权限模型

```typescript
interface Permission {
  resource: string;
  action: 'create' | 'read' | 'update' | 'delete';
}

interface Role {
  name: string;
  permissions: Permission[];
}

const roles: Record<string, Role> = {
  admin: {
    name: 'admin',
    permissions: [
      { resource: '*', action: 'create' },
      { resource: '*', action: 'read' },
      { resource: '*', action: 'update' },
      { resource: '*', action: 'delete' },
    ],
  },
  user: {
    name: 'user',
    permissions: [
      { resource: 'profile', action: 'read' },
      { resource: 'profile', action: 'update' },
    ],
  },
};

function hasPermission(role: string, resource: string, action: string): boolean {
  return (
    roles[role]?.permissions.some(
      (p) => (p.resource === '*' || p.resource === resource) && p.action === action
    ) ?? false
  );
}
```

### JWT 令牌验证

```typescript
import jwt from 'jsonwebtoken';

interface JWTPayload {
  userId: string;
  email: string;
  role: 'admin' | 'user';
}

export function verifyToken(token: string): JWTPayload {
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload;
    return payload;
  } catch (error) {
    throw new ApiError(401, 'Invalid token');
  }
}

export async function requireAuth(request: Request) {
  const token = request.headers.get('authorization')?.replace('Bearer ', '');

  if (!token) {
    throw new ApiError(401, 'Missing authorization token');
  }

  return verifyToken(token);
}

// Usage in API route
export async function GET(request: Request) {
  const user = await requireAuth(request);

  const data = await getDataForUser(user.userId);

  return NextResponse.json({ success: true, data });
}
```

### 基于角色的访问控制

```typescript
type Permission = 'read' | 'write' | 'delete' | 'admin';

interface User {
  id: string;
  role: 'admin' | 'moderator' | 'user';
}

const rolePermissions: Record<User['role'], Permission[]> = {
  admin: ['read', 'write', 'delete', 'admin'],
  moderator: ['read', 'write', 'delete'],
  user: ['read', 'write'],
};

export function hasPermission(user: User, permission: Permission): boolean {
  return rolePermissions[user.role].includes(permission);
}

export function requirePermission(permission: Permission) {
  return (handler: (request: Request, user: User) => Promise<Response>) => {
    return async (request: Request) => {
      const user = await requireAuth(request);

      if (!hasPermission(user, permission)) {
        throw new ApiError(403, 'Insufficient permissions');
      }

      return handler(request, user);
    };
  };
}

// Usage - HOF wraps the handler
export const DELETE = requirePermission('delete')(async (request: Request, user: User) => {
  // Handler receives authenticated user with verified permission
  return new Response('Deleted', { status: 200 });
});
```

## 速率限制

### 简单的内存速率限制器

```typescript
class RateLimiter {
  private requests = new Map<string, number[]>();

  async checkLimit(identifier: string, maxRequests: number, windowMs: number): Promise<boolean> {
    const now = Date.now();
    const requests = this.requests.get(identifier) || [];

    // Remove old requests outside window
    const recentRequests = requests.filter((time) => now - time < windowMs);

    if (recentRequests.length >= maxRequests) {
      return false; // Rate limit exceeded
    }

    // Add current request
    recentRequests.push(now);
    this.requests.set(identifier, recentRequests);

    return true;
  }
}

const limiter = new RateLimiter();

export async function GET(request: Request) {
  const ip = request.headers.get('x-forwarded-for') || 'unknown';

  const allowed = await limiter.checkLimit(ip, 100, 60000); // 100 req/min

  if (!allowed) {
    return NextResponse.json(
      {
        error: 'Rate limit exceeded',
      },
      { status: 429 }
    );
  }

  // Continue with request
}
```

## 后台作业与队列

### 简单队列模式

```typescript
class JobQueue<T> {
  private queue: T[] = [];
  private processing = false;

  async add(job: T): Promise<void> {
    this.queue.push(job);

    if (!this.processing) {
      this.process();
    }
  }

  private async process(): Promise<void> {
    this.processing = true;

    while (this.queue.length > 0) {
      const job = this.queue.shift()!;

      try {
        await this.execute(job);
      } catch (error) {
        console.error('Job failed:', error);
      }
    }

    this.processing = false;
  }

  private async execute(job: T): Promise<void> {
    // Job execution logic
  }
}

// Usage for indexing markets
interface IndexJob {
  marketId: string;
}

const indexQueue = new JobQueue<IndexJob>();

export async function POST(request: Request) {
  const { marketId } = await request.json();

  // Add to queue instead of blocking
  await indexQueue.add({ marketId });

  return NextResponse.json({ success: true, message: 'Job queued' });
}
```

## 日志记录与监控

### 结构化日志记录

```typescript
interface LogContext {
  userId?: string;
  requestId?: string;
  method?: string;
  path?: string;
  [key: string]: unknown;
}

class Logger {
  log(level: 'info' | 'warn' | 'error', message: string, context?: LogContext) {
    const entry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      ...context,
    };

    console.log(JSON.stringify(entry));
  }

  info(message: string, context?: LogContext) {
    this.log('info', message, context);
  }

  warn(message: string, context?: LogContext) {
    this.log('warn', message, context);
  }

  error(message: string, error: Error, context?: LogContext) {
    this.log('error', message, {
      ...context,
      error: error.message,
      stack: error.stack,
    });
  }
}

const logger = new Logger();

// Usage
export async function GET(request: Request) {
  const requestId = crypto.randomUUID();

  logger.info('Fetching markets', {
    requestId,
    method: 'GET',
    path: '/api/markets',
  });

  try {
    const markets = await fetchMarkets();
    return NextResponse.json({ success: true, data: markets });
  } catch (error) {
    logger.error('Failed to fetch markets', error as Error, { requestId });
    return NextResponse.json({ error: 'Internal error' }, { status: 500 });
  }
}
```

**记住**：后端模式支持可扩展、可维护的服务器端应用程序。选择适合你复杂程度的模式。
