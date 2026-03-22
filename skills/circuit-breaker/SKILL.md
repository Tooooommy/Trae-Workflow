---
name: circuit-breaker
description: 熔断器模式 - 服务弹性、故障隔离、自动恢复最佳实践
---

# 熔断器模式

> 服务弹性、故障隔离、自动恢复的最佳实践

## 何时激活

- 微服务间调用
- 外部 API 集成
- 数据库连接
- 实现服务降级
- 故障隔离

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Opossum | 7.0+ | 最新 |
| resilience4j | 2.0+ | 最新 |
| Polly | 8.0+ | 最新 |

## 熔断器状态

```
                    ┌─────────────────┐
                    │     CLOSED      │
                    │   (正常状态)     │
                    └────────┬────────┘
                             │
                    失败率 > 阈值
                             │
                             ▼
┌─────────────────┐    ┌─────────────────┐
│     HALF-OPEN   │<───│      OPEN       │
│    (半开状态)    │    │    (熔断状态)    │
└────────┬────────┘    └─────────────────┘
         │                     ▲
         │    超时后尝试        │
         │    ┌────────────────┘
         │    │
    成功 │    │ 失败
         ▼    │
┌─────────────────┐
│     CLOSED      │
└─────────────────┘
```

## 基础实现

```typescript
enum CircuitState {
  CLOSED = 'CLOSED',
  OPEN = 'OPEN',
  HALF_OPEN = 'HALF_OPEN',
}

interface CircuitBreakerOptions {
  failureThreshold: number;
  successThreshold: number;
  timeout: number;
  resetTimeout: number;
}

class CircuitBreaker<T> {
  private state: CircuitState = CircuitState.CLOSED;
  private failures = 0;
  private successes = 0;
  private lastFailureTime: number | null = null;

  constructor(
    private fn: () => Promise<T>,
    private options: CircuitBreakerOptions
  ) {}

  async execute(): Promise<T> {
    if (this.state === CircuitState.OPEN) {
      if (this.shouldAttemptReset()) {
        this.state = CircuitState.HALF_OPEN;
      } else {
        throw new Error('Circuit breaker is OPEN');
      }
    }

    try {
      const result = await this.executeWithTimeout();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private async executeWithTimeout(): Promise<T> {
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        reject(new Error('Timeout'));
      }, this.options.timeout);

      this.fn()
        .then((result) => {
          clearTimeout(timer);
          resolve(result);
        })
        .catch((error) => {
          clearTimeout(timer);
          reject(error);
        });
    });
  }

  private onSuccess(): void {
    this.failures = 0;

    if (this.state === CircuitState.HALF_OPEN) {
      this.successes++;
      if (this.successes >= this.options.successThreshold) {
        this.state = CircuitState.CLOSED;
        this.successes = 0;
      }
    }
  }

  private onFailure(): void {
    this.failures++;
    this.lastFailureTime = Date.now();

    if (this.state === CircuitState.HALF_OPEN) {
      this.state = CircuitState.OPEN;
      this.successes = 0;
    } else if (this.failures >= this.options.failureThreshold) {
      this.state = CircuitState.OPEN;
    }
  }

  private shouldAttemptReset(): boolean {
    if (!this.lastFailureTime) return false;
    return Date.now() - this.lastFailureTime >= this.options.resetTimeout;
  }

  getState(): CircuitState {
    return this.state;
  }

  getStats() {
    return {
      state: this.state,
      failures: this.failures,
      successes: this.successes,
    };
  }
}
```

## Opossum 实现

```typescript
import CircuitBreaker from 'opossum';

async function externalApiCall(id: string): Promise<any> {
  const response = await fetch(`https://api.example.com/users/${id}`);
  return response.json();
}

const breaker = new CircuitBreaker(externalApiCall, {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000,
  volumeThreshold: 10,
});

breaker.on('open', () => console.log('Circuit opened'));
breaker.on('halfOpen', () => console.log('Circuit half-open'));
breaker.on('close', () => console.log('Circuit closed'));
breaker.fallback(() => ({ cached: true, data: getCachedData() }));

async function getUser(id: string) {
  try {
    return await breaker.fire(id);
  } catch (error) {
    console.error('Circuit breaker error:', error);
    return null;
  }
}
```

## 降级策略

```typescript
class ResilientService {
  private breaker: CircuitBreaker<any>;
  private cache = new Map<string, any>();

  constructor() {
    this.breaker = new CircuitBreaker(
      this.callExternalService.bind(this),
      {
        failureThreshold: 5,
        successThreshold: 2,
        timeout: 5000,
        resetTimeout: 30000,
      }
    );
  }

  async getData(key: string): Promise<any> {
    try {
      const data = await this.breaker.execute();
      this.cache.set(key, data);
      return data;
    } catch (error) {
      return this.fallback(key);
    }
  }

  private fallback(key: string): any {
    if (this.cache.has(key)) {
      return { ...this.cache.get(key), cached: true };
    }
    return { error: 'Service unavailable', cached: false };
  }

  private async callExternalService(): Promise<any> {
    // External API call
  }
}
```

## 重试 + 熔断组合

```typescript
class ResilientClient {
  private breaker: CircuitBreaker<any>;

  async request<T>(fn: () => Promise<T>, retries = 3): Promise<T> {
    return this.retry(() => this.breaker.execute(), retries);
  }

  private async retry<T>(fn: () => Promise<T>, retries: number): Promise<T> {
    let lastError: Error;
    
    for (let i = 0; i < retries; i++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        await this.delay(Math.pow(2, i) * 1000);
      }
    }
    
    throw lastError;
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

## 监控指标

```typescript
interface CircuitMetrics {
  state: CircuitState;
  failures: number;
  successes: number;
  rejects: number;
  timeouts: number;
  latency: {
    mean: number;
    p95: number;
    p99: number;
  };
}

class CircuitMonitor {
  private metrics: CircuitMetrics;

  recordSuccess(latency: number) {
    this.metrics.successes++;
    this.updateLatency(latency);
  }

  recordFailure(latency: number) {
    this.metrics.failures++;
    this.updateLatency(latency);
  }

  recordReject() {
    this.metrics.rejects++;
  }

  recordTimeout() {
    this.metrics.timeouts++;
  }

  getMetrics(): CircuitMetrics {
    return { ...this.metrics };
  }

  private updateLatency(latency: number) {
    // Update latency statistics
  }
}
```

## Express 中间件

```typescript
function circuitBreakerMiddleware(breaker: CircuitBreaker<any>) {
  return async (req: Request, res: Response, next: NextFunction) => {
    if (breaker.getState() === CircuitState.OPEN) {
      return res.status(503).json({
        error: 'Service temporarily unavailable',
        retryAfter: 30,
      });
    }
    
    try {
      await breaker.execute();
      next();
    } catch (error) {
      res.status(503).json({ error: 'Service unavailable' });
    }
  };
}
```

## 配置建议

| 参数 | 推荐值 | 说明 |
|------|--------|------|
| failureThreshold | 5-10 | 触发熔断的失败次数 |
| successThreshold | 2-3 | 恢复正常的成功次数 |
| timeout | 3-5s | 单次请求超时 |
| resetTimeout | 30-60s | 熔断恢复等待时间 |

## 快速参考

```typescript
// 创建熔断器
const breaker = new CircuitBreaker(fn, {
  failureThreshold: 5,
  resetTimeout: 30000,
});

// 执行请求
const result = await breaker.execute();

// 降级处理
breaker.fallback(() => getCachedData());

// 监听状态
breaker.on('open', () => {});
breaker.on('close', () => {});
```

## 参考

- [Circuit Breaker Pattern (Martin Fowler)](https://martinfowler.com/bliki/CircuitBreaker.html)
- [Opossum](https://github.com/nodeshift/opossum)
- [Resilience4j](https://resilience4j.readme.io/)
- [Microsoft Azure - Circuit Breaker](https://docs.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker)
