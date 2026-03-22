---
name: redis-patterns
description: Redis 缓存模式、数据结构应用、分布式锁和消息队列最佳实践。适用于缓存和实时数据处理。
---

# Redis 缓存模式

用于构建高性能、可扩展缓存和数据存储系统的模式与最佳实践。

## 何时激活

- 实现缓存层
- 使用 Redis 数据结构
- 设计分布式锁
- 构建消息队列

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Redis | 7.0+ | 7.4+ |
| Node.js ioredis | 5.0+ | 最新 |
| Redis Stack | 7.0+ | 最新 |
| RedisInsight | 最新 | 最新 |
| Redis Cluster | 7.0+ | 最新 |

## 核心数据结构

### 1. 字符串 (String)

```typescript
// 基本操作
await redis.set('user:1', JSON.stringify({ name: 'Alice' }));
await redis.set('user:1', JSON.stringify({ name: 'Alice' }), 'EX', 3600); // 1小时过期
const user = await redis.get('user:1');

// 计数器
await redis.incr('page:views');
await redis.incrby('score:user:1', 100);

// 分布式 ID
const id = await redis.incr('global:id');
```

### 2. 哈希 (Hash)

```typescript
// 存储对象
await redis.hset('user:1', {
  name: 'Alice',
  email: 'alice@example.com',
  age: 30,
});

const name = await redis.hget('user:1', 'name');
const user = await redis.hgetall('user:1');
await redis.hdel('user:1', 'age');
```

### 3. 列表 (List)

```typescript
// 队列
await redis.lpush('queue:tasks', JSON.stringify(task));
const task = await redis.rpop('queue:tasks');

// 阻塞队列
const task = await redis.brpop('queue:tasks', 5); // 5秒超时

// 时间线
await redis.lpush('timeline:user:1', postId);
const posts = await redis.lrange('timeline:user:1', 0, 9); // 最新10条
```

### 4. 集合 (Set)

```typescript
// 唯一值
await redis.sadd('tags:article:1', 'redis', 'cache', 'database');
const tags = await redis.smembers('tags:article:1');

// 集合运算
await redis.sadd('users:online', 'user1', 'user2', 'user3');
await redis.sadd('users:premium', 'user1', 'user4');
const onlinePremium = await redis.sinter('users:online', 'users:premium');
```

### 5. 有序集合 (Sorted Set)

```typescript
// 排行榜
await redis.zadd('leaderboard', 100, 'user1');
await redis.zadd('leaderboard', 200, 'user2');
await redis.zincrby('leaderboard', 50, 'user1');

const top10 = await redis.zrange('leaderboard', 0, 9, 'WITHSCORES', 'REV');
const rank = await redis.zrevrank('leaderboard', 'user1');
```

## 缓存模式

### Cache-Aside (旁路缓存)

```typescript
class CacheAsideService {
  private redis: RedisClient;
  private db: Database;

  async get(key: string): Promise<any> {
    // 1. 先查缓存
    const cached = await this.redis.get(key);
    if (cached) {
      return JSON.parse(cached);
    }

    // 2. 缓存未命中，查数据库
    const data = await this.db.query(key);
    if (data) {
      // 3. 写入缓存
      await this.redis.set(key, JSON.stringify(data), 'EX', 3600);
    }

    return data;
  }

  async set(key: string, value: any): Promise<void> {
    // 1. 更新数据库
    await this.db.update(key, value);

    // 2. 删除缓存（而非更新）
    await this.redis.del(key);
  }
}
```

### Read-Through / Write-Through

```typescript
class ReadThroughCache {
  private redis: RedisClient;
  private loader: (key: string) => Promise<any>;

  async get(key: string): Promise<any> {
    const cached = await this.redis.get(key);
    if (cached !== null) {
      return JSON.parse(cached);
    }

    // 自动加载
    const data = await this.loader(key);
    await this.redis.set(key, JSON.stringify(data), 'EX', 3600);
    return data;
  }
}

class WriteThroughCache {
  private redis: RedisClient;
  private writer: (key: string, value: any) => Promise<void>;

  async set(key: string, value: any): Promise<void> {
    // 同时写入缓存和持久层
    await Promise.all([
      this.redis.set(key, JSON.stringify(value), 'EX', 3600),
      this.writer(key, value),
    ]);
  }
}
```

### 缓存预热

```typescript
async function warmupCache(keys: string[]): Promise<void> {
  const pipeline = redis.pipeline();

  for (const key of keys) {
    const data = await db.query(key);
    pipeline.set(key, JSON.stringify(data), 'EX', 3600);
  }

  await pipeline.exec();
}
```

### 缓存穿透防护

```typescript
async function getWithProtection(key: string): Promise<any> {
  const cached = await redis.get(key);

  // 空值缓存
  if (cached === 'NULL') {
    return null;
  }

  if (cached) {
    return JSON.parse(cached);
  }

  const data = await db.query(key);

  if (data === null) {
    // 缓存空值，短过期时间
    await redis.set(key, 'NULL', 'EX', 60);
    return null;
  }

  await redis.set(key, JSON.stringify(data), 'EX', 3600);
  return data;
}
```

### 缓存雪崩防护

```typescript
async function setWithRandomExpiry(
  key: string,
  value: any,
  baseExpiry: number
): Promise<void> {
  // 添加随机偏移，避免同时过期
  const randomOffset = Math.floor(Math.random() * 300); // 0-300秒
  await redis.set(key, JSON.stringify(value), 'EX', baseExpiry + randomOffset);
}
```

## 分布式锁

### 简单锁

```typescript
class RedisLock {
  private redis: RedisClient;

  async acquire(key: string, ttlMs: number): Promise<boolean> {
    const result = await this.redis.set(
      `lock:${key}`,
      process.pid.toString(),
      'NX',
      'PX',
      ttlMs
    );
    return result === 'OK';
  }

  async release(key: string): Promise<boolean> {
    const script = `
      if redis.call("get", KEYS[1]) == ARGV[1] then
        return redis.call("del", KEYS[1])
      else
        return 0
      end
    `;

    const result = await this.redis.eval(
      script,
      1,
      `lock:${key}`,
      process.pid.toString()
    );
    return result === 1;
  }
}
```

### 可重入锁

```typescript
class ReentrantLock {
  private redis: RedisClient;

  async acquire(
    key: string,
    tokenId: string,
    ttlMs: number
  ): Promise<boolean> {
    const script = `
      local key = KEYS[1]
      local tokenId = ARGV[1]
      local ttl = tonumber(ARGV[2])
      
      if redis.call("exists", key) == 0 then
        redis.call("hset", key, tokenId, 1)
        redis.call("pexpire", key, ttl)
        return 1
      end
      
      if redis.call("hexists", key, tokenId) == 1 then
        redis.call("hincrby", key, tokenId, 1)
        redis.call("pexpire", key, ttl)
        return 1
      end
      
      return 0
    `;

    const result = await this.redis.eval(
      script,
      1,
      `lock:${key}`,
      tokenId,
      ttlMs.toString()
    );
    return result === 1;
  }

  async release(key: string, tokenId: string): Promise<boolean> {
    const script = `
      local key = KEYS[1]
      local tokenId = ARGV[1]
      
      if redis.call("hexists", key, tokenId) == 0 then
        return 0
      end
      
      local counter = redis.call("hincrby", key, tokenId, -1)
      if counter > 0 then
        return 1
      else
        redis.call("del", key)
        return 1
      end
    `;

    const result = await this.redis.eval(
      script,
      1,
      `lock:${key}`,
      tokenId
    );
    return result === 1;
  }
}
```

## 消息队列

### 简单队列

```typescript
class SimpleQueue {
  private redis: RedisClient;
  private queueKey: string;

  async enqueue(data: any): Promise<void> {
    await this.redis.lpush(this.queueKey, JSON.stringify(data));
  }

  async dequeue(timeout: number = 0): Promise<any | null> {
    const result = await this.redis.brpop(this.queueKey, timeout);
    if (result) {
      return JSON.parse(result[1]);
    }
    return null;
  }
}
```

### 延迟队列

```typescript
class DelayedQueue {
  private redis: RedisClient;

  async enqueue(data: any, delayMs: number): Promise<void> {
    const executeAt = Date.now() + delayMs;
    await this.redis.zadd(
      'delayed:queue',
      executeAt,
      JSON.stringify({ data, id: generateId() })
    );
  }

  async *consume(): AsyncGenerator<any> {
    while (true) {
      const now = Date.now();
      const items = await this.redis.zrangebyscore(
        'delayed:queue',
        0,
        now,
        'LIMIT',
        0,
        10
      );

      for (const item of items) {
        const removed = await this.redis.zrem('delayed:queue', item);
        if (removed === 1) {
          yield JSON.parse(item).data;
        }
      }

      await new Promise((resolve) => setTimeout(resolve, 100));
    }
  }
}
```

### 发布订阅

```typescript
class PubSub {
  private redis: RedisClient;
  private subscriber: RedisClient;

  async publish(channel: string, message: any): Promise<void> {
    await this.redis.publish(channel, JSON.stringify(message));
  }

  async subscribe(
    channel: string,
    handler: (message: any) => void
  ): Promise<void> {
    await this.subscriber.subscribe(channel);
    this.subscriber.on('message', (ch, msg) => {
      if (ch === channel) {
        handler(JSON.parse(msg));
      }
    });
  }
}
```

## 限流

### 令牌桶

```typescript
class TokenBucket {
  private redis: RedisClient;
  private rate: number;
  private capacity: number;

  async consume(key: string, tokens: number = 1): Promise<boolean> {
    const script = `
      local key = KEYS[1]
      local rate = tonumber(ARGV[1])
      local capacity = tonumber(ARGV[2])
      local requested = tonumber(ARGV[3])
      local now = tonumber(ARGV[4])
      
      local bucket = redis.call("hmget", key, "tokens", "last_time")
      local tokens = tonumber(bucket[1]) or capacity
      local lastTime = tonumber(bucket[2]) or now
      
      local elapsed = now - lastTime
      local filled = math.min(capacity, tokens + elapsed * rate)
      
      if filled < requested then
        return 0
      end
      
      redis.call("hmset", key, "tokens", filled - requested, "last_time", now)
      redis.call("expire", key, math.ceil(capacity / rate) + 1)
      return 1
    `;

    const result = await this.redis.eval(
      script,
      1,
      `ratelimit:${key}`,
      this.rate.toString(),
      this.capacity.toString(),
      tokens.toString(),
      Date.now().toString()
    );

    return result === 1;
  }
}
```

### 滑动窗口

```typescript
class SlidingWindow {
  private redis: RedisClient;
  private windowMs: number;
  private maxRequests: number;

  async isAllowed(key: string): Promise<boolean> {
    const script = `
      local key = KEYS[1]
      local window = tonumber(ARGV[1])
      local max = tonumber(ARGV[2])
      local now = tonumber(ARGV[3])
      
      redis.call("zremrangebyscore", key, 0, now - window)
      local count = redis.call("zcard", key)
      
      if count >= max then
        return 0
      end
      
      redis.call("zadd", key, now, now .. "-" .. math.random())
      redis.call("expire", key, math.ceil(window / 1000))
      return 1
    `;

    const result = await this.redis.eval(
      script,
      1,
      `ratelimit:${key}`,
      this.windowMs.toString(),
      this.maxRequests.toString(),
      Date.now().toString()
    );

    return result === 1;
  }
}
```

## 性能优化

### Pipeline 批量操作

```typescript
async function batchSet(items: Array<{ key: string; value: any }>): Promise<void> {
  const pipeline = redis.pipeline();

  for (const { key, value } of items) {
    pipeline.set(key, JSON.stringify(value), 'EX', 3600);
  }

  await pipeline.exec();
}
```

### Lua 脚本

```typescript
const atomicUpdateScript = `
  local key = KEYS[1]
  local delta = tonumber(ARGV[1])
  local current = tonumber(redis.call("get", key)) or 0
  local newValue = current + delta
  
  if newValue < 0 then
    return {err = "value cannot be negative"}
  end
  
  redis.call("set", key, newValue)
  return {ok = newValue}
`;

async function atomicUpdate(key: string, delta: number): Promise<number> {
  const result = await redis.eval(atomicUpdateScript, 1, key, delta.toString());
  return result.ok;
}
```

## 快速参考

| 模式 | 用途 | 数据结构 |
|------|------|----------|
| 缓存 | 加速读取 | String |
| 会话 | 用户状态 | Hash |
| 队列 | 异步处理 | List |
| 排行榜 | 排序数据 | Sorted Set |
| 分布式锁 | 互斥访问 | String + Lua |
| 限流 | 流量控制 | Sorted Set |
| 发布订阅 | 消息广播 | Pub/Sub |

**记住**：Redis 是内存数据库，注意内存使用。合理设置过期时间，避免内存溢出。使用 Pipeline 和 Lua 脚本减少网络往返。
