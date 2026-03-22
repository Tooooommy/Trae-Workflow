---
name: event-driven-patterns
description: 事件驱动架构模式、消息队列、事件溯源和 CQRS 最佳实践。适用于分布式系统和异步处理。
---

# 事件驱动架构模式

用于构建松耦合、可扩展和响应式系统的模式与最佳实践。

## 何时激活

- 设计事件驱动系统
- 实现异步消息处理
- 设计事件溯源架构
- 实现 CQRS 模式

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Kafka | 3.5+ | 3.8+ |
| RabbitMQ | 3.12+ | 最新 |
| Redis Streams | 7.0+ | 7.4+ |
| TypeScript | 5.0+ | 最新 |
| kafkajs | 2.2+ | 最新 |

## 核心概念

### 1. 事件 vs 命令

```
命令:
- 意图明确，期望特定行为
- 一对一关系
- 失败需要处理
- 例：CreateOrder, SendEmail

事件:
- 事实陈述，已发生的事情
- 一对多关系
- 发布后不关心谁处理
- 例：OrderCreated, EmailSent
```

### 2. 架构层次

```
┌─────────────────────────────────────────┐
│           服务层              │
├─────────────────────────────────────────┤
│  命令处理器  │  事件处理器  │  查询处理器  │
├─────────────────────────────────────────┤
│           消息基础设施                    │
│  消息队列 │ 事件总线 │ 事件存储          │
└─────────────────────────────────────────┘
```

## 事件模式

### 事件定义

```typescript
// 基础事件接口
interface DomainEvent {
  id: string;
  type: string;
  aggregateId: string;
  aggregateType: string;
  timestamp: number;
  version: number;
  metadata: Record<string, unknown>;
  data: unknown;
}

// 具体事件
interface OrderCreatedEvent extends DomainEvent {
  type: 'OrderCreated';
  data: {
    orderId: string;
    userId: string;
    items: CartItem[];
    totalAmount: number;
  };
}

interface PaymentCompletedEvent extends DomainEvent {
  type: 'PaymentCompleted';
  data: {
    orderId: string;
    paymentId: string;
    amount: number;
    paidAt: number;
  };
}

interface OrderShippedEvent extends DomainEvent {
  type: 'OrderShipped';
  data: {
    orderId: string;
    trackingNumber: string;
    shippedAt: number;
  };
}
```

### 事件发布器

```typescript
interface EventPublisher {
  publish(event: DomainEvent): Promise<void>;
  publishAll(events: DomainEvent[]): Promise<void>;
}

class MessageQueuePublisher implements EventPublisher {
  constructor(private queue: MessageQueue) {}

  async publish(event: DomainEvent): Promise<void> {
    await this.queue.publish({
      topic: event.type,
      key: event.aggregateId,
      value: JSON.stringify(event),
      headers: {
        eventType: event.type,
        aggregateType: event.aggregateType,
        version: event.version.toString(),
      },
    });
  }

  async publishAll(events: DomainEvent[]): Promise<void> {
    await Promise.all(events.map(e => this.publish(e)));
  }
}
```

### 事件处理器

```typescript
interface EventHandler<T extends DomainEvent> {
  eventType: string;
  handle(event: T): Promise<void>;
}

class OrderCreatedHandler implements EventHandler<OrderCreatedEvent> {
  eventType = 'OrderCreated';

  constructor(
    private inventoryService: InventoryService,
    private notificationService: NotificationService
  ) {}

  async handle(event: OrderCreatedEvent): Promise<void> {
    // 预留库存
    for (const item of event.data.items) {
      await this.inventoryService.reserve(item.productId, item.quantity);
    }

    // 发送通知
    await this.notificationService.sendOrderConfirmation({
      orderId: event.data.orderId,
      userId: event.data.userId,
    });
  }
}

// 处理器注册
class EventHandlerRegistry {
  private handlers = new Map<string, EventHandler[]>();

  register(handler: EventHandler): void {
    const existing = this.handlers.get(handler.eventType) || [];
    existing.push(handler);
    this.handlers.set(handler.eventType, existing);
  }

  async dispatch(event: DomainEvent): Promise<void> {
    const handlers = this.handlers.get(event.type) || [];
    await Promise.all(handlers.map(h => h.handle(event as any)));
  }
}
```

## 消息队列模式

### 生产者

```typescript
import { Kafka } from 'kafkajs';

class KafkaProducer {
  private producer;

  constructor(private kafka: Kafka) {
    this.producer = kafka.producer();
  }

  async connect(): Promise<void> {
    await this.producer.connect();
  }

  async publish(topic: string, event: DomainEvent): Promise<void> {
    await this.producer.send({
      topic,
      messages: [
        {
          key: event.aggregateId,
          value: JSON.stringify(event),
          headers: {
            eventType: event.type,
            timestamp: event.timestamp.toString(),
          },
        },
      ],
    });
  }

  async publishBatch(events: Array<{ topic: string; event: DomainEvent }>): Promise<void> {
    const messages = events.map(({ topic, event }) => ({
      topic,
      messages: [
        {
          key: event.aggregateId,
          value: JSON.stringify(event),
        },
      ],
    }));

    await this.producer.sendBatch({ topicMessages: messages });
  }
}
```

### 消费者

```typescript
class KafkaConsumer {
  private consumer;

  constructor(
    private kafka: Kafka,
    private groupId: string,
    private handlers: EventHandlerRegistry
  ) {
    this.consumer = kafka.consumer({ groupId });
  }

  async subscribe(topics: string[]): Promise<void> {
    await this.consumer.connect();
    for (const topic of topics) {
      await this.consumer.subscribe({ topic, fromBeginning: false });
    }
  }

  async run(): Promise<void> {
    await this.consumer.run({
      eachMessage: async ({ topic, partition, message }) => {
        try {
          const event = JSON.parse(message.value!.toString());
          await this.handlers.dispatch(event);
        } catch (error) {
          console.error('Error processing message:', error);
          // 发送到死信队列
        }
      },
    });
  }
}
```

### 死信队列

```typescript
class DeadLetterQueue {
  constructor(private producer: KafkaProducer) {}

  async sendFailed(
    originalEvent: DomainEvent,
    error: Error,
    retries: number
  ): Promise<void> {
    await this.producer.publish('dlq-events', {
      ...originalEvent,
      metadata: {
        ...originalEvent.metadata,
        error: error.message,
        retries,
        failedAt: Date.now(),
      },
    });
  }
}

// 带重试的消费者
class RetryConsumer {
  private maxRetries = 3;

  async processWithRetry(event: DomainEvent): Promise<void> {
    let retries = 0;

    while (retries < this.maxRetries) {
      try {
        await this.handlers.dispatch(event);
        return;
      } catch (error) {
        retries++;
        if (retries >= this.maxRetries) {
          await this.dlq.sendFailed(event, error as Error, retries);
          return;
        }
        await this.delay(Math.pow(2, retries) * 1000);
      }
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

## 事件溯源

### 事件存储

```typescript
interface EventStore {
  append(aggregateId: string, events: DomainEvent[], expectedVersion: number): Promise<void>;
  getEvents(aggregateId: string, afterVersion?: number): Promise<DomainEvent[]>;
  subscribe(aggregateId: string, handler: (event: DomainEvent) => void): () => void;
}

class PostgresEventStore implements EventStore {
  constructor(private db: Pool) {}

  async append(
    aggregateId: string,
    events: DomainEvent[],
    expectedVersion: number
  ): Promise<void> {
    const client = await this.db.connect();

    try {
      await client.query('BEGIN');

      // 乐观锁检查
      const { rows } = await client.query(
        'SELECT MAX(version) as version FROM events WHERE aggregate_id = $1',
        [aggregateId]
      );

      const currentVersion = rows[0]?.version || 0;
      if (currentVersion !== expectedVersion) {
        throw new ConcurrencyError(expectedVersion, currentVersion);
      }

      // 插入事件
      for (let i = 0; i < events.length; i++) {
        const event = events[i];
        await client.query(
          `INSERT INTO events (id, type, aggregate_id, aggregate_type, data, metadata, version, timestamp)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
          [
            event.id,
            event.type,
            event.aggregateId,
            event.aggregateType,
            JSON.stringify(event.data),
            JSON.stringify(event.metadata),
            expectedVersion + i + 1,
            event.timestamp,
          ]
        );
      }

      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async getEvents(aggregateId: string, afterVersion = 0): Promise<DomainEvent[]> {
    const { rows } = await this.db.query(
      `SELECT * FROM events 
       WHERE aggregate_id = $1 AND version > $2 
       ORDER BY version ASC`,
      [aggregateId, afterVersion]
    );

    return rows.map(this.rowToEvent);
  }
}
```

### 聚合根基类

```typescript
abstract class AggregateRoot {
  protected id: string;
  protected version = 0;
  protected changes: DomainEvent[] = [];

  abstract apply(event: DomainEvent): void;

  protected record(event: Omit<DomainEvent, 'version' | 'timestamp'>): void {
    const fullEvent: DomainEvent = {
      ...event,
      version: this.version + 1,
      timestamp: Date.now(),
    } as DomainEvent;

    this.changes.push(fullEvent);
    this.apply(fullEvent);
    this.version++;
  }

  loadFromHistory(events: DomainEvent[]): void {
    for (const event of events) {
      this.apply(event);
      this.version = event.version;
    }
  }

  getUncommittedChanges(): DomainEvent[] {
    return [...this.changes];
  }

  markChangesAsCommitted(): void {
    this.changes = [];
  }
}

// 具体聚合根
class Order extends AggregateRoot {
  private status: OrderStatus = 'PENDING';
  private items: OrderItem[] = [];
  private totalAmount = 0;

  static create(id: string, items: CartItem[]): Order {
    const order = new Order();
    order.record({
      id: generateId(),
      type: 'OrderCreated',
      aggregateId: id,
      aggregateType: 'Order',
      data: {
        orderId: id,
        items,
        totalAmount: items.reduce((sum, i) => sum + i.price * i.quantity, 0),
      },
      metadata: {},
    });
    return order;
  }

  pay(paymentId: string): void {
    if (this.status !== 'PENDING') {
      throw new Error('Invalid state');
    }
    this.record({
      id: generateId(),
      type: 'PaymentCompleted',
      aggregateId: this.id,
      aggregateType: 'Order',
      data: { orderId: this.id, paymentId, amount: this.totalAmount },
      metadata: {},
    });
  }

  apply(event: DomainEvent): void {
    switch (event.type) {
      case 'OrderCreated':
        this.id = event.aggregateId;
        this.items = (event.data as any).items;
        this.totalAmount = (event.data as any).totalAmount;
        this.status = 'PENDING';
        break;
      case 'PaymentCompleted':
        this.status = 'PAID';
        break;
    }
  }
}
```

## CQRS 模式

### 命令模型

```typescript
// 命令
interface CreateOrderCommand {
  type: 'CreateOrder';
  orderId: string;
  userId: string;
  items: CartItem[];
}

interface CompletePaymentCommand {
  type: 'CompletePayment';
  orderId: string;
  paymentId: string;
}

// 命令处理器
interface CommandHandler<T> {
  handle(command: T): Promise<void>;
}

class CreateOrderHandler implements CommandHandler<CreateOrderCommand> {
  constructor(
    private eventStore: EventStore,
    private publisher: EventPublisher
  ) {}

  async handle(command: CreateOrderCommand): Promise<void> {
    const order = Order.create(command.orderId, command.items);
    
    await this.eventStore.append(
      command.orderId,
      order.getUncommittedChanges(),
      0
    );

    await this.publisher.publishAll(order.getUncommittedChanges());
    order.markChangesAsCommitted();
  }
}
```

### 查询模型

```typescript
// 读模型
interface OrderReadModel {
  id: string;
  userId: string;
  status: string;
  items: OrderItemReadModel[];
  totalAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

// 查询
interface GetOrderQuery {
  orderId: string;
}

interface ListOrdersQuery {
  userId?: string;
  status?: string;
  limit: number;
  offset: number;
}

// 查询处理器
class OrderQueryHandler {
  constructor(private db: Pool) {}

  async getOrder(query: GetOrderQuery): Promise<OrderReadModel | null> {
    const { rows } = await this.db.query(
      'SELECT * FROM order_read_model WHERE id = $1',
      [query.orderId]
    );
    return rows[0] || null;
  }

  async listOrders(query: ListOrdersQuery): Promise<OrderReadModel[]> {
    let sql = 'SELECT * FROM order_read_model WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;

    if (query.userId) {
      sql += ` AND user_id = $${paramIndex++}`;
      params.push(query.userId);
    }
    if (query.status) {
      sql += ` AND status = $${paramIndex++}`;
      params.push(query.status);
    }

    sql += ` ORDER BY created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
    params.push(query.limit, query.offset);

    const { rows } = await this.db.query(sql, params);
    return rows;
  }
}
```

### 投影器

```typescript
class OrderProjection {
  constructor(private db: Pool) {}

  async project(event: DomainEvent): Promise<void> {
    switch (event.type) {
      case 'OrderCreated':
        await this.handleOrderCreated(event as OrderCreatedEvent);
        break;
      case 'PaymentCompleted':
        await this.handlePaymentCompleted(event as PaymentCompletedEvent);
        break;
    }
  }

  private async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
    await this.db.query(
      `INSERT INTO order_read_model (id, user_id, status, items, total_amount, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [
        event.data.orderId,
        event.data.userId,
        'PENDING',
        JSON.stringify(event.data.items),
        event.data.totalAmount,
        new Date(event.timestamp),
        new Date(event.timestamp),
      ]
    );
  }

  private async handlePaymentCompleted(event: PaymentCompletedEvent): Promise<void> {
    await this.db.query(
      `UPDATE order_read_model 
       SET status = 'PAID', updated_at = $1 
       WHERE id = $2`,
      [new Date(event.timestamp), event.data.orderId]
    );
  }
}
```

## 幂等性处理

### 幂等消费者

```typescript
class IdempotentConsumer {
  constructor(
    private db: Pool,
    private handlers: EventHandlerRegistry
  ) {}

  async process(event: DomainEvent): Promise<void> {
    const client = await this.db.connect();

    try {
      await client.query('BEGIN');

      // 检查是否已处理
      const { rows } = await client.query(
        'SELECT 1 FROM processed_events WHERE id = $1',
        [event.id]
      );

      if (rows.length > 0) {
        await client.query('COMMIT');
        return; // 已处理，跳过
      }

      // 处理事件
      await this.handlers.dispatch(event);

      // 标记为已处理
      await client.query(
        'INSERT INTO processed_events (id, processed_at) VALUES ($1, $2)',
        [event.id, new Date()]
      );

      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
}
```

## 快速参考

| 模式 | 用途 |
|------|------|
| 事件 | 已发生事实的记录 |
| 命令 | 执行动作的意图 |
| 事件溯源 | 状态由事件重建 |
| CQRS | 读写分离 |
| 投影器 | 更新读模型 |
| 幂等性 | 安全重试 |

**记住**：事件驱动架构增加了复杂性但提供了解耦和可扩展性。确保事件是不可变的，处理器是幂等的。
