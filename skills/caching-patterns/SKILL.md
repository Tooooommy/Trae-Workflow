---
name: caching-patterns
description: 缓存策略模式、多级缓存、缓存一致性和性能优化最佳实践。适用于所有需要缓存的项目。**必须激活当**：用户要求实现缓存层、处理缓存失效、设计缓存策略或优化性能时。即使用户没有明确说"缓存"，当涉及 Redis、Memcached 或其他缓存机制时也应使用。
---

# 缓存策略模式

用于构建高性能、高可用缓存系统的模式与最佳实践。

## 何时激活

- 设计缓存策略
- 实现多级缓存
- 解决缓存一致性问题
- 优化缓存性能

## 技术栈版本

| 技术                  | 最低版本 | 推荐版本 |
| --------------------- | -------- | -------- |
| Redis                 | 7.0+     | 7.4+     |
| Memcached             | 1.6+     | 最新     |
| Node.js cache-manager | 5.0+     | 最新     |
| ioredis               | 5.0+     | 最新     |
| TypeScript            | 5.0+     | 最新     |

## 核心概念

### 1. 缓存位置

```
┌─────────────────────────────────────────┐
│           客户端缓存                      │
│  浏览器 Cache │ Service Worker │ LocalStorage │
├─────────────────────────────────────────┤
│           CDN 缓存                       │
│  静态资源 │ API 响应 │ 边缘计算           │
├─────────────────────────────────────────┤
│           应用层缓存                      │
│  内存缓存 │ 本地缓存 │ 分布式缓存          │
├─────────────────────────────────────────┤
│           数据库缓存                      │
│  查询缓存 │ 缓冲池 │ 物化视图             │
└─────────────────────────────────────────┘
```

### 2. 缓存指标

```
命中率 = 缓存命中次数 / 总请求次数
失效率 = 1 - 命中率
平均延迟 = (命中延迟 × 命中率) + (未命中延迟 × 失效率)
```

## 缓存策略

### Cache-Aside (旁路缓存)

```typescript
class CacheAsideService {
  constructor(
    private cache: CacheClient,
    private db: Database
  ) {}

  async get<T>(key: string): Promise<T | null> {
    // 1. 先查缓存
    const cached = await this.cache.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // 2. 缓存未命中，查数据库
    const data = await this.db.query<T>(key);
    if (data !== null) {
      // 3. 写入缓存
      await this.cache.set(key, data, { ttl: 3600 });
    }

    return data;
  }

  async set<T>(key: string, value: T): Promise<void> {
    // 1. 更新数据库
    await this.db.update(key, value);

    // 2. 删除缓存（而非更新）
    await this.cache.delete(key);
  }
}
```

### Read-Through (读穿透)

```typescript
class ReadThroughCache {
  private cache: CacheClient;
  private loader: (key: string) => Promise<any>;

  async get<T>(key: string): Promise<T | null> {
    const cached = await this.cache.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // 自动加载数据
    const data = await this.loader(key);
    if (data !== null) {
      await this.cache.set(key, data);
    }

    return data;
  }
}
```

### Write-Through (写穿透)

```typescript
class WriteThroughCache {
  private cache: CacheClient;
  private db: Database;

  async set<T>(key: string, value: T): Promise<void> {
    // 同时写入缓存和数据库
    await Promise.all([this.cache.set(key, value), this.db.update(key, value)]);
  }
}
```

### Write-Behind (写回)

```typescript
class WriteBehindCache {
  private cache: CacheClient;
  private db: Database;
  private writeQueue: Map<string, any> = new Map();
  private flushInterval = 5000;

  constructor() {
    this.startFlushTimer();
  }

  async set<T>(key: string, value: T): Promise<void> {
    // 只写缓存，异步写数据库
    await this.cache.set(key, value);
    this.writeQueue.set(key, value);
  }

  private startFlushTimer(): void {
    setInterval(() => this.flush(), this.flushInterval);
  }

  private async flush(): Promise<void> {
    if (this.writeQueue.size === 0) return;

    const entries = Array.from(this.writeQueue.entries());
    this.writeQueue.clear();

    for (const [key, value] of entries) {
      try {
        await this.db.update(key, value);
      } catch (error) {
        // 写入失败，重新加入队列
        this.writeQueue.set(key, value);
      }
    }
  }
}
```

### Write-Around (绕写)

```typescript
class WriteAroundCache {
  private cache: CacheClient;
  private db: Database;

  async set<T>(key: string, value: T): Promise<void> {
    // 只写数据库，不写缓存
    await this.db.update(key, value);
  }

  async get<T>(key: string): Promise<T | null> {
    const cached = await this.cache.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // 缓存未命中时从数据库加载
    const data = await this.db.query<T>(key);
    if (data !== null) {
      await this.cache.set(key, data);
    }

    return data;
  }
}
```

## 多级缓存

### L1/L2 缓存

```typescript
class MultiLevelCache {
  private l1: MemoryCache; // 本地内存缓存
  private l2: RedisCache; // 分布式缓存
  private db: Database;

  async get<T>(key: string): Promise<T | null> {
    // L1 缓存
    const l1Result = this.l1.get<T>(key);
    if (l1Result !== null) {
      return l1Result;
    }

    // L2 缓存
    const l2Result = await this.l2.get<T>(key);
    if (l2Result !== null) {
      // 回填 L1
      this.l1.set(key, l2Result);
      return l2Result;
    }

    // 数据库
    const dbResult = await this.db.query<T>(key);
    if (dbResult !== null) {
      // 回填 L1 和 L2
      this.l1.set(key, dbResult);
      await this.l2.set(key, dbResult);
    }

    return dbResult;
  }

  async set<T>(key: string, value: T, ttl?: number): Promise<void> {
    // 写入所有层级
    this.l1.set(key, value, ttl);
    await this.l2.set(key, value, ttl);
    await this.db.update(key, value);
  }

  async delete(key: string): Promise<void> {
    // 删除所有层级
    this.l1.delete(key);
    await this.l2.delete(key);
  }
}
```

### 缓存同步

```typescript
class CacheSynchronizer {
  private pubsub: PubSub;
  private localCache: MemoryCache;

  constructor() {
    this.pubsub.subscribe('cache:invalidate', this.handleInvalidation);
  }

  async invalidate(key: string): Promise<void> {
    // 删除本地缓存
    this.localCache.delete(key);

    // 通知其他节点
    await this.pubsub.publish('cache:invalidate', { key, nodeId: this.nodeId });
  }

  private handleInvalidation = (message: { key: string; nodeId: string }): void => {
    if (message.nodeId !== this.nodeId) {
      this.localCache.delete(message.key);
    }
  };
}
```

## 缓存一致性

### 缓存穿透防护

```typescript
class CachePenetrationProtection {
  private cache: CacheClient;
  private db: Database;
  private bloomFilter: BloomFilter;

  async get<T>(key: string): Promise<T | null> {
    // 布隆过滤器快速判断
    if (!this.bloomFilter.mightContain(key)) {
      return null;
    }

    const cached = await this.cache.get<T>(key);
    if (cached !== null) {
      return cached === 'NULL' ? null : cached;
    }

    const data = await this.db.query<T>(key);

    if (data === null) {
      // 缓存空值，短 TTL
      await this.cache.set(key, 'NULL', { ttl: 60 });
      return null;
    }

    await this.cache.set(key, data);
    return data;
  }
}
```

### 缓存雪崩防护

```typescript
class CacheAvalancheProtection {
  private cache: CacheClient;
  private baseTtl: number;

  async set<T>(key: string, value: T): Promise<void> {
    // 添加随机偏移，避免同时过期
    const randomOffset = Math.floor(Math.random() * 300);
    const ttl = this.baseTtl + randomOffset;

    await this.cache.set(key, value, { ttl });
  }

  async get<T>(key: string, loader: () => Promise<T>): Promise<T> {
    const cached = await this.cache.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // 使用互斥锁防止缓存击穿
    const lock = await this.acquireLock(key);
    if (!lock) {
      // 等待其他线程加载
      await this.delay(100);
      return this.get(key, loader);
    }

    try {
      const data = await loader();
      await this.set(key, data);
      return data;
    } finally {
      await this.releaseLock(key);
    }
  }
}
```

### 缓存击穿防护

```typescript
class CacheBreakdownProtection {
  private cache: CacheClient;
  private locks: Map<string, Promise<any>> = new Map();

  async get<T>(key: string, loader: () => Promise<T>): Promise<T> {
    const cached = await this.cache.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // 使用单一 Promise 防止重复加载
    let promise = this.locks.get(key);
    if (!promise) {
      promise = this.loadAndCache(key, loader);
      this.locks.set(key, promise);
    }

    try {
      return await promise;
    } finally {
      this.locks.delete(key);
    }
  }

  private async loadAndCache<T>(key: string, loader: () => Promise<T>): Promise<T> {
    const data = await loader();
    await this.cache.set(key, data);
    return data;
  }
}
```

## 缓存预热

### 启动预热

```typescript
class CacheWarmup {
  private cache: CacheClient;
  private db: Database;

  async warmup(): Promise<void> {
    const hotKeys = await this.getHotKeys();

    await Promise.all(
      hotKeys.map(async (key) => {
        const data = await this.db.query(key);
        if (data !== null) {
          await this.cache.set(key, data);
        }
      })
    );
  }

  private async getHotKeys(): Promise<string[]> {
    // 从访问日志分析热门数据
    return ['user:1', 'product:100', 'config:app'];
  }
}
```

### 定时预热

```typescript
class ScheduledWarmup {
  private cache: CacheClient;
  private db: Database;

  start(): void {
    // 每小时预热一次
    setInterval(() => this.warmup(), 3600000);
  }

  private async warmup(): Promise<void> {
    const keys = await this.getExpiringKeys();

    for (const key of keys) {
      const ttl = await this.cache.ttl(key);
      if (ttl < 300) {
        // 5分钟内过期
        const data = await this.db.query(key);
        if (data !== null) {
          await this.cache.set(key, data);
        }
      }
    }
  }
}
```

## 缓存淘汰策略

### LRU (最近最少使用)

```typescript
class LRUCache<K, V> {
  private capacity: number;
  private cache: Map<K, V>;

  constructor(capacity: number) {
    this.capacity = capacity;
    this.cache = new Map();
  }

  get(key: K): V | undefined {
    if (!this.cache.has(key)) {
      return undefined;
    }

    // 移到末尾（最近使用）
    const value = this.cache.get(key)!;
    this.cache.delete(key);
    this.cache.set(key, value);
    return value;
  }

  set(key: K, value: V): void {
    if (this.cache.has(key)) {
      this.cache.delete(key);
    } else if (this.cache.size >= this.capacity) {
      // 删除最久未使用的（第一个）
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }

    this.cache.set(key, value);
  }
}
```

### LFU (最不经常使用)

```typescript
class LFUCache<K, V> {
  private capacity: number;
  private cache: Map<K, { value: V; count: number }>;
  private freqMap: Map<number, Set<K>>;
  private minFreq = 0;

  constructor(capacity: number) {
    this.capacity = capacity;
    this.cache = new Map();
    this.freqMap = new Map();
  }

  get(key: K): V | undefined {
    const entry = this.cache.get(key);
    if (!entry) return undefined;

    this.incrementFreq(key);
    return entry.value;
  }

  set(key: K, value: V): void {
    if (this.capacity === 0) return;

    if (this.cache.has(key)) {
      const entry = this.cache.get(key)!;
      entry.value = value;
      this.incrementFreq(key);
      return;
    }

    if (this.cache.size >= this.capacity) {
      this.evict();
    }

    this.cache.set(key, { value, count: 1 });
    this.addToFreqMap(1, key);
    this.minFreq = 1;
  }

  private incrementFreq(key: K): void {
    const entry = this.cache.get(key)!;
    const oldFreq = entry.count;
    const newFreq = oldFreq + 1;

    entry.count = newFreq;
    this.removeFromFreqMap(oldFreq, key);
    this.addToFreqMap(newFreq, key);

    if (this.freqMap.get(oldFreq)?.size === 0 && this.minFreq === oldFreq) {
      this.minFreq = newFreq;
    }
  }

  private evict(): void {
    const keys = this.freqMap.get(this.minFreq);
    if (keys && keys.size > 0) {
      const keyToEvict = keys.values().next().value;
      keys.delete(keyToEvict);
      this.cache.delete(keyToEvict);
    }
  }

  private addToFreqMap(freq: number, key: K): void {
    if (!this.freqMap.has(freq)) {
      this.freqMap.set(freq, new Set());
    }
    this.freqMap.get(freq)!.add(key);
  }

  private removeFromFreqMap(freq: number, key: K): void {
    this.freqMap.get(freq)?.delete(key);
  }
}
```

## 分布式缓存

### 一致性哈希

```typescript
class ConsistentHashing {
  private ring: Map<number, string> = new Map();
  private nodes: string[] = [];
  private virtualNodes = 150;

  addNode(node: string): void {
    this.nodes.push(node);
    for (let i = 0; i < this.virtualNodes; i++) {
      const hash = this.hash(`${node}:${i}`);
      this.ring.set(hash, node);
    }
  }

  removeNode(node: string): void {
    this.nodes = this.nodes.filter((n) => n !== node);
    for (let i = 0; i < this.virtualNodes; i++) {
      const hash = this.hash(`${node}:${i}`);
      this.ring.delete(hash);
    }
  }

  getNode(key: string): string {
    if (this.ring.size === 0) {
      throw new Error('No nodes available');
    }

    const hash = this.hash(key);
    const sortedHashes = Array.from(this.ring.keys()).sort((a, b) => a - b);

    for (const h of sortedHashes) {
      if (hash <= h) {
        return this.ring.get(h)!;
      }
    }

    return this.ring.get(sortedHashes[0])!;
  }

  private hash(key: string): number {
    let hash = 0;
    for (let i = 0; i < key.length; i++) {
      const char = key.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }
}
```

## 快速参考

| 策略          | 读           | 写        | 适用场景 |
| ------------- | ------------ | --------- | -------- |
| Cache-Aside   | 缓存→DB      | DB→删缓存 | 通用     |
| Read-Through  | 缓存自动加载 | 直接写DB  | 读多写少 |
| Write-Through | 缓存自动加载 | 缓存→DB   | 强一致性 |
| Write-Behind  | 缓存自动加载 | 只写缓存  | 高吞吐   |
| Write-Around  | 缓存→DB      | 只写DB    | 写多读少 |

**记住**：缓存不是银弹。选择合适的策略，处理好一致性问题，监控命中率，避免缓存穿透、雪崩和击穿。
