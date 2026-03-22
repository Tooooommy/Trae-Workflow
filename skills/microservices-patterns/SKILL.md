---
name: microservices-patterns
description: 微服务架构模式、服务发现、通信方式和数据一致性最佳实践。适用于分布式系统设计。
---

# 微服务架构模式

用于构建可扩展、可维护和弹性分布式系统的模式与最佳实践。

## 何时激活

- 设计微服务架构
- 拆分单体应用
- 设计服务间通信
- 处理分布式数据一致性

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Docker | 24+ | 27+ |
| Kubernetes | 1.28+ | 1.31+ |
| Istio/Linkerd | 最新 | 最新 |
| gRPC | 1.60+ | 最新 |
| Kafka | 3.5+ | 3.8+ |

## 核心原则

### 1. 服务设计原则

- **单一职责**：每个服务只做一件事
- **松耦合**：服务间依赖最小化
- **高内聚**：相关功能放在同一服务
- **独立部署**：服务可独立部署和扩展

### 2. 架构层次

```
┌─────────────────────────────────────────┐
│            API Gateway                   │
├─────────────────────────────────────────┤
│  服务 A  │  服务 B  │  服务 C  │  服务 D │
├─────────────────────────────────────────┤
│  消息队列 │ 服务发现 │ 配置中心 │ 监控    │
├─────────────────────────────────────────┤
│            基础设施层                    │
└─────────────────────────────────────────┘
```

## 服务拆分模式

### 按业务能力拆分

```
电商系统:
├── 用户服务 (User Service)
├── 订单服务 (Order Service)
├── 商品服务 (Product Service)
├── 支付服务 (Payment Service)
├── 库存服务 (Inventory Service)
└── 通知服务 (Notification Service)
```

### 按子域拆分 (DDD)

```
核心域:
├── 订单管理 (Order Management)
└── 库存管理 (Inventory Management)

支撑域:
├── 用户管理 (User Management)
└── 支付处理 (Payment Processing)

通用域:
├── 认证授权 (Authentication)
└── 通知发送 (Notification)
```

## 服务通信

### 同步通信 (REST/gRPC)

```typescript
// REST API 客户端
class OrderServiceClient {
  private baseUrl: string;

  async getOrder(orderId: string): Promise<Order> {
    const response = await fetch(`${this.baseUrl}/orders/${orderId}`);
    if (!response.ok) {
      throw new ServiceError('OrderService', response.status);
    }
    return response.json();
  }

  async createOrder(items: CartItem[]): Promise<Order> {
    const response = await fetch(`${this.baseUrl}/orders`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ items }),
    });
    return response.json();
  }
}

// 带重试的客户端
class ResilientClient {
  private maxRetries = 3;
  private retryDelay = 1000;

  async call<T>(fn: () => Promise<T>): Promise<T> {
    let lastError: Error;
    
    for (let i = 0; i < this.maxRetries; i++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        if (this.isRetryable(error)) {
          await this.delay(this.retryDelay * Math.pow(2, i));
        } else {
          throw error;
        }
      }
    }
    
    throw lastError;
  }

  private isRetryable(error: any): boolean {
    return error.status >= 500 || error.code === 'ECONNRESET';
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

### 异步通信 (消息队列)

```typescript
// 事件发布
interface OrderCreatedEvent {
  type: 'OrderCreated';
  data: {
    orderId: string;
    userId: string;
    items: CartItem[];
    totalAmount: number;
  };
  timestamp: number;
}

class EventPublisher {
  private broker: MessageBroker;

  async publish(event: OrderCreatedEvent): Promise<void> {
    await this.broker.publish('order-events', event);
  }
}

// 事件订阅
class InventoryService {
  async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
    for (const item of event.data.items) {
      await this.reserveStock(item.productId, item.quantity);
    }
  }
}

// 事件处理器注册
class EventHandler {
  private broker: MessageBroker;

  subscribe<T>(
    eventType: string,
    handler: (event: T) => Promise<void>
  ): void {
    this.broker.subscribe(eventType, async (message) => {
      const event = JSON.parse(message);
      if (event.type === eventType) {
        await handler(event);
      }
    });
  }
}
```

## API Gateway 模式

### 路由和聚合

```typescript
class ApiGateway {
  private services: Map<string, ServiceClient>;

  async handleRequest(req: Request): Promise<Response> {
    const { path, method } = req;

    // 路由到对应服务
    const route = this.matchRoute(path);
    if (!route) {
      return new Response('Not Found', { status: 404 });
    }

    // 认证
    const user = await this.authenticate(req);
    if (!user && route.requiresAuth) {
      return new Response('Unauthorized', { status: 401 });
    }

    // 转发请求
    return this.forwardRequest(route.service, req);
  }

  // API 聚合
  async getOrderDetails(orderId: string): Promise<OrderDetails> {
    const [order, user, products] = await Promise.all([
      this.orderService.getOrder(orderId),
      this.userService.getUser(order.userId),
      this.productService.getProducts(order.productIds),
    ]);

    return { order, user, products };
  }
}
```

### 限流和熔断

```typescript
class RateLimiter {
  private requests: Map<string, number[]> = new Map();
  private limit: number;
  private windowMs: number;

  async check(clientId: string): Promise<boolean> {
    const now = Date.now();
    const windowStart = now - this.windowMs;

    let requests = this.requests.get(clientId) || [];
    requests = requests.filter(t => t > windowStart);

    if (requests.length >= this.limit) {
      return false;
    }

    requests.push(now);
    this.requests.set(clientId, requests);
    return true;
  }
}

class CircuitBreaker {
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
  private failures = 0;
  private threshold = 5;
  private resetTimeout = 30000;
  private lastFailure: number = 0;

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailure > this.resetTimeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('Circuit breaker is open');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess(): void {
    this.failures = 0;
    this.state = 'CLOSED';
  }

  private onFailure(): void {
    this.failures++;
    this.lastFailure = Date.now();
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
    }
  }
}
```

## 数据一致性

### Saga 模式

```typescript
// 编排式 Saga
class OrderSaga {
  private steps: SagaStep[] = [
    { service: 'inventory', action: 'reserve', compensate: 'release' },
    { service: 'payment', action: 'charge', compensate: 'refund' },
    { service: 'order', action: 'confirm', compensate: 'cancel' },
  ];

  async execute(orderId: string): Promise<void> {
    const completed: Array<{ service: string; action: string }> = [];

    for (const step of this.steps) {
      try {
        await this.executeStep(step, orderId);
        completed.push({ service: step.service, action: step.action });
      } catch (error) {
        // 补偿已完成的步骤
        for (const c of completed.reverse()) {
          await this.compensateStep(c, orderId);
        }
        throw error;
      }
    }
  }

  private async executeStep(step: SagaStep, orderId: string): Promise<void> {
    const client = this.getClient(step.service);
    await client.post(`/${step.action}`, { orderId });
  }

  private async compensateStep(
    completed: { service: string; action: string },
    orderId: string
  ): Promise<void> {
    const client = this.getClient(completed.service);
    await client.post(`/compensate`, { orderId, action: completed.action });
  }
}

// 事件驱动 Saga
class OrderSagaOrchestrator {
  async handle(event: DomainEvent): Promise<void> {
    switch (event.type) {
      case 'OrderCreated':
        await this.inventoryService.reserveStock(event.data);
        break;
      case 'StockReserved':
        await this.paymentService.charge(event.data);
        break;
      case 'PaymentCompleted':
        await this.orderService.confirm(event.data.orderId);
        break;
      case 'StockReservationFailed':
      case 'PaymentFailed':
        await this.orderService.cancel(event.data.orderId);
        break;
    }
  }
}
```

### 事件溯源

```typescript
interface Event {
  id: string;
  type: string;
  aggregateId: string;
  data: any;
  timestamp: number;
  version: number;
}

class EventStore {
  async append(aggregateId: string, events: Event[]): Promise<void> {
    // 原子性追加事件
    await this.db.query(
      `INSERT INTO events (id, type, aggregate_id, data, timestamp, version)
       VALUES ?`,
      [events.map(e => [e.id, e.type, e.aggregateId, e.data, e.timestamp, e.version])]
    );
  }

  async getEvents(aggregateId: string, fromVersion = 0): Promise<Event[]> {
    return this.db.query(
      `SELECT * FROM events 
       WHERE aggregate_id = ? AND version > ?
       ORDER BY version ASC`,
      [aggregateId, fromVersion]
    );
  }
}

abstract class AggregateRoot {
  protected version = 0;
  protected changes: Event[] = [];

  abstract apply(event: Event): void;

  protected record(event: Omit<Event, 'version'>): void {
    this.version++;
    const fullEvent = { ...event, version: this.version };
    this.changes.push(fullEvent as Event);
    this.apply(fullEvent as Event);
  }

  loadFromHistory(events: Event[]): void {
    for (const event of events) {
      this.apply(event);
      this.version = event.version;
    }
  }
}

// 示例：订单聚合
class Order extends AggregateRoot {
  private status: OrderStatus = 'PENDING';
  private items: CartItem[] = [];

  create(orderId: string, items: CartItem[]): void {
    this.record({
      id: generateId(),
      type: 'OrderCreated',
      aggregateId: orderId,
      data: { items },
      timestamp: Date.now(),
    });
  }

  confirm(): void {
    if (this.status !== 'PENDING') {
      throw new Error('Invalid state');
    }
    this.record({
      id: generateId(),
      type: 'OrderConfirmed',
      aggregateId: this.id,
      data: {},
      timestamp: Date.now(),
    });
  }

  apply(event: Event): void {
    switch (event.type) {
      case 'OrderCreated':
        this.items = event.data.items;
        this.status = 'PENDING';
        break;
      case 'OrderConfirmed':
        this.status = 'CONFIRMED';
        break;
    }
  }
}
```

## 服务发现

### 客户端发现

```typescript
class ServiceRegistry {
  private services: Map<string, ServiceInstance[]> = new Map();

  register(name: string, instance: ServiceInstance): void {
    const instances = this.services.get(name) || [];
    instances.push(instance);
    this.services.set(name, instances);
  }

  deregister(name: string, instanceId: string): void {
    const instances = this.services.get(name) || [];
    const filtered = instances.filter(i => i.id !== instanceId);
    this.services.set(name, filtered);
  }

  getInstances(name: string): ServiceInstance[] {
    return this.services.get(name) || [];
  }
}

class LoadBalancer {
  private counters: Map<string, number> = new Map();

  select(instances: ServiceInstance[]): ServiceInstance {
    if (instances.length === 0) {
      throw new Error('No instances available');
    }

    // 轮询
    const key = instances[0].service;
    const count = this.counters.get(key) || 0;
    const index = count % instances.length;
    this.counters.set(key, count + 1);

    return instances[index];
  }
}
```

## 配置管理

### 集中配置

```typescript
class ConfigService {
  private config: Map<string, any> = new Map();
  private watchers: Map<string, Set<(value: any) => void>> = new Map();

  async load(): Promise<void> {
    const configs = await this.fetchAll();
    for (const [key, value] of Object.entries(configs)) {
      this.config.set(key, value);
    }
  }

  get<T>(key: string, defaultValue?: T): T {
    return this.config.get(key) ?? defaultValue;
  }

  watch(key: string, callback: (value: any) => void): () => void {
    const watchers = this.watchers.get(key) || new Set();
    watchers.add(callback);
    this.watchers.set(key, watchers);

    return () => {
      watchers.delete(callback);
    };
  }

  async update(key: string, value: any): Promise<void> {
    this.config.set(key, value);
    
    const watchers = this.watchers.get(key);
    if (watchers) {
      for (const callback of watchers) {
        callback(value);
      }
    }
  }
}
```

## 可观测性

### 分布式追踪

```typescript
class Tracer {
  private spans: Span[] = [];

  startSpan(name: string, parent?: Span): Span {
    const span: Span = {
      id: generateId(),
      traceId: parent?.traceId || generateId(),
      parentId: parent?.id,
      name,
      startTime: Date.now(),
    };
    this.spans.push(span);
    return span;
  }

  endSpan(span: Span): void {
    span.endTime = Date.now();
    this.export(span);
  }

  private export(span: Span): void {
    // 发送到追踪系统 (Jaeger, Zipkin)
    console.log(JSON.stringify(span));
  }
}

// 中间件
async function tracingMiddleware(
  req: Request,
  next: () => Promise<Response>
): Promise<Response> {
  const span = tracer.startSpan(
    `${req.method} ${req.path}`,
    req.span // 父 span
  );

  try {
    const response = await next();
    span.status = response.status;
    return response;
  } catch (error) {
    span.error = error.message;
    throw error;
  } finally {
    tracer.endSpan(span);
  }
}
```

## 快速参考

| 模式 | 用途 | 实现方式 |
|------|------|----------|
| API Gateway | 统一入口 | 路由、认证、限流 |
| 服务发现 | 动态定位 | 客户端/服务端发现 |
| Saga | 分布式事务 | 编排/协同 |
| 事件溯源 | 状态管理 | 事件日志 |
| CQRS | 读写分离 | 命令/查询模型 |
| 熔断器 | 故障隔离 | 状态机 |
| 限流 | 流量控制 | 令牌桶/滑动窗口 |

**记住**：微服务增加了系统复杂性。确保有完善的监控、日志和追踪系统。从单体开始，按需拆分。
