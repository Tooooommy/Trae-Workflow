---
name: rate-limiting
description: 限流模式 - API 保护、流量控制、防滥用最佳实践
---

# 限流模式

> API 保护、流量控制、防滥用的最佳实践

## 何时激活

- API 限流保护
- 防止 DDoS 攻击
- 用户行为限制
- 资源配额管理
- 服务降级

## 技术栈版本

| 技术                  | 最低版本 | 推荐版本 |
| --------------------- | -------- | -------- |
| Redis                 | 6.0+     | 7.0+     |
| express-rate-limit    | 7.0+     | 最新     |
| rate-limiter-flexible | 4.0+     | 最新     |

## 限流算法对比

| 算法     | 特点         | 适用场景 |
| -------- | ------------ | -------- |
| 固定窗口 | 简单、内存小 | 基础限流 |
| 滑动窗口 | 精确、平滑   | 精确控制 |
| 令牌桶   | 允许突发     | API 限流 |
| 漏桶     | 恒定速率     | 流量整形 |

## 固定窗口算法

```typescript
class FixedWindowLimiter {
  private windows = new Map<string, { count: number; resetAt: number }>();

  constructor(
    private maxRequests: number,
    private windowMs: number
  ) {}

  isAllowed(key: string): { allowed: boolean; remaining: number; resetAt: number } {
    const now = Date.now();
    let window = this.windows.get(key);

    if (!window || window.resetAt <= now) {
      window = { count: 0, resetAt: now + this.windowMs };
      this.windows.set(key, window);
    }

    window.count++;
    const allowed = window.count <= this.maxRequests;
    const remaining = Math.max(0, this.maxRequests - window.count);

    return { allowed, remaining, resetAt: window.resetAt };
  }
}
```

## 滑动窗口算法

```typescript
class SlidingWindowLimiter {
  private requests = new Map<string, number[]>();

  constructor(
    private maxRequests: number,
    private windowMs: number
  ) {}

  isAllowed(key: string): { allowed: boolean; remaining: number } {
    const now = Date.now();
    const windowStart = now - this.windowMs;

    let timestamps = this.requests.get(key) || [];

    timestamps = timestamps.filter((ts) => ts > windowStart);

    const allowed = timestamps.length < this.maxRequests;

    if (allowed) {
      timestamps.push(now);
      this.requests.set(key, timestamps);
    }

    const remaining = Math.max(0, this.maxRequests - timestamps.length);

    return { allowed, remaining };
  }
}
```

## 令牌桶算法

```typescript
class TokenBucket {
  private tokens: number;
  private lastRefill: number;

  constructor(
    private capacity: number,
    private refillRate: number,
    private refillInterval: number
  ) {
    this.tokens = capacity;
    this.lastRefill = Date.now();
  }

  consume(tokens: number = 1): boolean {
    this.refill();

    if (this.tokens >= tokens) {
      this.tokens -= tokens;
      return true;
    }

    return false;
  }

  private refill(): void {
    const now = Date.now();
    const elapsed = now - this.lastRefill;
    const tokensToAdd = Math.floor(elapsed / this.refillInterval) * this.refillRate;

    this.tokens = Math.min(this.capacity, this.tokens + tokensToAdd);
    this.lastRefill = now;
  }

  getTokens(): number {
    this.refill();
    return this.tokens;
  }
}
```

## Redis 分布式限流

```typescript
import Redis from 'ioredis';
import { RateLimiterRedis } from 'rate-limiter-flexible';

const redis = new Redis(process.env.REDIS_URL);

const rateLimiter = new RateLimiterRedis({
  storeClient: redis,
  keyPrefix: 'rate_limit',
  points: 100,
  duration: 60,
  blockDuration: 60,
});

async function rateLimitMiddleware(req: Request, res: Response, next: NextFunction) {
  const key = req.ip || req.headers['x-forwarded-for'] || 'unknown';

  try {
    await rateLimiter.consume(key as string);
    next();
  } catch (error) {
    res.setHeader('Retry-After', error.msBeforeNext / 1000);
    res.setHeader('X-RateLimit-Limit', rateLimiter.points);
    res.setHeader('X-RateLimit-Remaining', 0);
    res.setHeader('X-RateLimit-Reset', new Date(Date.now() + error.msBeforeNext).toISOString());

    res.status(429).json({
      error: 'Too many requests',
      retryAfter: Math.ceil(error.msBeforeNext / 1000),
    });
  }
}
```

## Express 中间件

```typescript
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  store: new RedisStore({
    sendCommand: (...args: string[]) => redis.call(...args),
  }),
  keyGenerator: (req) => req.ip || (req.headers['x-forwarded-for'] as string),
  handler: (req, res) => {
    res.status(429).json({
      error: 'Too many requests',
      message: 'Please try again later',
    });
  },
});

app.use('/api/', apiLimiter);
```

## 分层限流

```typescript
class TieredRateLimiter {
  private limits = new Map<string, RateLimit>([
    ['anonymous', { requests: 20, window: 60 }],
    ['free', { requests: 100, window: 60 }],
    ['pro', { requests: 1000, window: 60 }],
    ['enterprise', { requests: 10000, window: 60 }],
  ]);

  async checkLimit(userId: string, tier: string, identifier: string): Promise<LimitResult> {
    const limit = this.limits.get(tier) || this.limits.get('anonymous')!;
    const key = `${tier}:${userId}:${identifier}`;

    const result = await this.redisLimiter.check(key, limit.requests, limit.window);

    return {
      allowed: result.allowed,
      remaining: result.remaining,
      resetAt: result.resetAt,
      limit: limit.requests,
    };
  }
}
```

## 用户级限流

```typescript
class UserRateLimiter {
  private userLimits = new Map<string, UserLimit>();

  async checkUserLimit(userId: string, action: string): Promise<boolean> {
    const key = `user:${userId}:${action}`;
    const limit = this.getLimitForAction(action);

    const current = await this.incrementCounter(key, limit.window);

    if (current > limit.max) {
      return false;
    }

    return true;
  }

  private getLimitForAction(action: string): { max: number; window: number } {
    const limits: Record<string, { max: number; window: number }> = {
      'api:read': { max: 1000, window: 60 },
      'api:write': { max: 100, window: 60 },
      'auth:login': { max: 5, window: 300 },
      'auth:register': { max: 3, window: 3600 },
      'file:upload': { max: 50, window: 3600 },
    };

    return limits[action] || { max: 100, window: 60 };
  }
}
```

## 响应头规范

```typescript
function setRateLimitHeaders(res: Response, limit: number, remaining: number, resetAt: Date) {
  res.setHeader('X-RateLimit-Limit', limit);
  res.setHeader('X-RateLimit-Remaining', remaining);
  res.setHeader('X-RateLimit-Reset', Math.floor(resetAt.getTime() / 1000));
  res.setHeader('X-RateLimit-Reset-After', Math.ceil((resetAt.getTime() - Date.now()) / 1000));
}
```

## 限流策略

| 场景     | 限制       | 窗口   |
| -------- | ---------- | ------ |
| 全局 API | 10000 请求 | 1 分钟 |
| 用户 API | 100 请求   | 1 分钟 |
| 登录尝试 | 5 次       | 5 分钟 |
| 密码重置 | 3 次       | 1 小时 |
| 文件上传 | 50 次      | 1 小时 |

## 快速参考

```typescript
// Express 中间件
app.use(rateLimit({ windowMs: 60000, max: 100 }));

// Redis 限流
await rateLimiter.consume(key);

// 令牌桶
bucket.consume(1);

// 响应头
res.setHeader('X-RateLimit-Limit', 100);
res.setHeader('X-RateLimit-Remaining', 50);
```

## 参考

- [rate-limiter-flexible](https://github.com/animir/node-rate-limiter-flexible)
- [express-rate-limit](https://github.com/nfriedly/express-rate-limit)
- [RFC 6585 - 429 Too Many Requests](https://datatracker.ietf.org/doc/html/rfc6585#section-4)
- [Stripe Rate Limiting](https://stripe.com/blog/rate-limiters)
