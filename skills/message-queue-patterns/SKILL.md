---
name: message-queue-patterns
description: 消息队列模式 - RabbitMQ/Kafka/SQS 消息处理、事件驱动架构、事件溯源和 CQRS 最佳实践。适用于分布式系统和异步处理。**必须激活当**：用户要求实现消息队列、设计事件驱动架构或处理异步任务时。即使用户没有明确说"消息队列"，当涉及 RabbitMQ、Kafka、事件驱动或异步处理时也应使用。
---

# 消息队列与事件驱动模式

> RabbitMQ/Kafka/SQS 消息处理、可靠投递、消费者模式，以及事件驱动架构、事件溯源和 CQRS 最佳实践

## 何时激活

- 实现异步消息处理
- 服务间解耦
- 事件驱动架构
- 流量削峰
- 分布式事务
- 设计事件溯源架构
- 实现 CQRS 模式

## 技术栈版本

| 技术         | 最低版本 | 推荐版本 |
| ------------ | -------- | -------- |
| RabbitMQ     | 3.12+    | 最新     |
| Apache Kafka | 3.0+     | 最新     |
| AWS SQS      | -        | 最新     |
| BullMQ       | 4.0+     | 最新     |
| Redis        | 7.0+     | 最新     |

## 消息队列对比

| 特性     | RabbitMQ | Kafka    | SQS      | Redis    |
| -------- | -------- | -------- | -------- | -------- |
| 消息顺序 | 队列级别 | 分区级别 | 最佳努力 | 队列级别 |
| 持久化   | 可选     | 默认     | 默认     | 可选     |
| 吞吐量   | 中       | 高       | 中       | 高       |
| 延迟     | 低       | 中       | 中       | 极低     |
| 适用场景 | 传统消息 | 日志流   | 云原生   | 轻量队列 |

## RabbitMQ 实现

### 生产者

```typescript
import amqp from 'amqplib';

class RabbitMQProducer {
  private connection: amqp.Connection;
  private channel: amqp.Channel;

  async connect(url: string) {
    this.connection = await amqp.connect(url);
    this.channel = await this.connection.createChannel();
  }

  async publish(exchange: string, routingKey: string, message: object) {
    await this.channel.assertExchange(exchange, 'topic', { durable: true });

    this.channel.publish(exchange, routingKey, Buffer.from(JSON.stringify(message)), {
      persistent: true,
    });
  }

  async sendToQueue(queue: string, message: object) {
    await this.channel.assertQueue(queue, { durable: true });

    this.channel.sendToQueue(queue, Buffer.from(JSON.stringify(message)), { persistent: true });
  }

  async close() {
    await this.channel.close();
    await this.connection.close();
  }
}
```

### 消费者

```typescript
class RabbitMQConsumer {
  private connection: amqp.Connection;
  private channel: amqp.Channel;

  async connect(url: string) {
    this.connection = await amqp.connect(url);
    this.channel = await this.connection.createChannel();
    this.channel.prefetch(10);
  }

  async consume(queue: string, handler: (message: any) => Promise<void>) {
    await this.channel.assertQueue(queue, { durable: true });

    this.channel.consume(queue, async (msg) => {
      if (!msg) return;

      try {
        const content = JSON.parse(msg.content.toString());
        await handler(content);
        this.channel.ack(msg);
      } catch (error) {
        this.channel.nack(msg, false, false);
      }
    });
  }
}
```

## Kafka 实现

### 生产者

```typescript
import { Kafka, Producer } from 'kafkajs';

class KafkaProducer {
  private producer: Producer;

  constructor(brokers: string[]) {
    const kafka = new Kafka({
      brokers,
      clientId: 'my-app',
    });
    this.producer = kafka.producer();
  }

  async connect() {
    await this.producer.connect();
  }

  async send(topic: string, messages: { key: string; value: object }[]) {
    await this.producer.send({
      topic,
      messages: messages.map((m) => ({
        key: m.key,
        value: JSON.stringify(m.value),
      })),
    });
  }

  async disconnect() {
    await this.producer.disconnect();
  }
}
```

### 消费者

```typescript
import { Kafka, Consumer } from 'kafkajs';

class KafkaConsumer {
  private consumer: Consumer;

  constructor(brokers: string[], groupId: string) {
    const kafka = new Kafka({ brokers, clientId: 'my-app' });
    this.consumer = kafka.consumer({ groupId });
  }

  async connect() {
    await this.consumer.connect();
  }

  async subscribe(topic: string, handler: (message: any) => Promise<void>) {
    await this.consumer.subscribe({ topic, fromBeginning: false });

    await this.consumer.run({
      eachMessage: async ({ topic, partition, message }) => {
        const value = JSON.parse(message.value?.toString() || '{}');
        await handler(value);
      },
    });
  }

  async disconnect() {
    await this.consumer.disconnect();
  }
}
```

## AWS SQS 实现

### 生产者

```typescript
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

class SQSProducer {
  private client: SQSClient;

  constructor(region: string) {
    this.client = new SQSClient({ region });
  }

  async send(queueUrl: string, message: object, delaySeconds = 0) {
    const command = new SendMessageCommand({
      QueueUrl: queueUrl,
      MessageBody: JSON.stringify(message),
      DelaySeconds: delaySeconds,
    });

    return this.client.send(command);
  }

  async sendBatch(queueUrl: string, messages: object[]) {
    const command = new SendMessageBatchCommand({
      QueueUrl: queueUrl,
      Entries: messages.map((msg, i) => ({
        Id: `${i}`,
        MessageBody: JSON.stringify(msg),
      })),
    });

    return this.client.send(command);
  }
}
```

### 消费者

```typescript
import { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } from '@aws-sdk/client-sqs';

class SQSConsumer {
  private client: SQSClient;
  private running = false;

  constructor(region: string) {
    this.client = new SQSClient({ region });
  }

  async start(
    queueUrl: string,
    handler: (message: any) => Promise<void>,
    options = { maxMessages: 10, waitTime: 20 }
  ) {
    this.running = true;

    while (this.running) {
      const result = await this.client.send(
        new ReceiveMessageCommand({
          QueueUrl: queueUrl,
          MaxNumberOfMessages: options.maxMessages,
          WaitTimeSeconds: options.waitTime,
        })
      );

      if (!result.Messages) continue;

      for (const message of result.Messages) {
        try {
          const body = JSON.parse(message.Body || '{}');
          await handler(body);
          await this.deleteMessage(queueUrl, message.ReceiptHandle!);
        } catch (error) {
          console.error('Message processing failed:', error);
        }
      }
    }
  }

  stop() {
    this.running = false;
  }

  private async deleteMessage(queueUrl: string, receiptHandle: string) {
    await this.client.send(
      new DeleteMessageCommand({
        QueueUrl: queueUrl,
        ReceiptHandle: receiptHandle,
      })
    );
  }
}
```

## 消息模式

### 发布/订阅

```typescript
class PubSub {
  private exchange = 'events';

  async publish(event: string, data: object) {
    await this.producer.publish(this.exchange, event, data);
  }

  async subscribe(event: string, handler: (data: any) => Promise<void>) {
    const queue = `${event}-queue`;
    await this.consumer.bindQueue(queue, this.exchange, event);
    await this.consumer.consume(queue, handler);
  }
}
```

### 工作队列

```typescript
class WorkQueue {
  async enqueue(queue: string, task: object) {
    await this.producer.sendToQueue(queue, task);
  }

  async process(queue: string, worker: (task: any) => Promise<void>) {
    await this.consumer.consume(queue, async (task) => {
      await worker(task);
    });
  }
}
```

### 延迟消息

```typescript
class DelayedQueue {
  async schedule(queue: string, message: object, delayMs: number) {
    const delaySeconds = Math.ceil(delayMs / 1000);
    await this.sqs.send(queue, message, delaySeconds);
  }
}
```

### 死信队列

```typescript
const deadLetterQueueConfig = {
  deadLetterTargetArn: 'arn:aws:sqs:region:account:dlq',
  maxReceiveCount: 3,
};

const queueConfig = {
  RedrivePolicy: JSON.stringify(deadLetterQueueConfig),
};
```

## 可靠性保证

| 机制     | 说明             |
| -------- | ---------------- |
| 消息确认 | 处理成功后确认   |
| 持久化   | 消息写入磁盘     |
| 重试     | 失败后重新投递   |
| 死信队列 | 超过重试次数转入 |
| 幂等性   | 重复消息安全处理 |

## 幂等性实现

```typescript
class IdempotentHandler {
  private processed = new Set<string>();

  async handle(message: { id: string; data: any }) {
    if (this.processed.has(message.id)) {
      return;
    }

    await this.process(message.data);
    this.processed.add(message.id);
  }
}
```

## 快速参考

```typescript
// RabbitMQ
channel.sendToQueue(queue, Buffer.from(JSON.stringify(msg)));
channel.consume(queue, (msg) => {
  channel.ack(msg);
});

// Kafka
await producer.send({ topic, messages: [{ key, value }] });
await consumer.run({ eachMessage: async ({ message }) => {} });

// SQS
await sqs.send(new SendMessageCommand({ QueueUrl, MessageBody }));
await sqs.send(new ReceiveMessageCommand({ QueueUrl, WaitTimeSeconds: 20 }));
```

## 事件驱动架构

### 核心概念

#### 事件 vs 命令

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

#### 架构层次

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

### 事件模式

#### 事件定义

```typescript
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

interface OrderCreatedEvent extends DomainEvent {
  type: 'OrderCreated';
  data: {
    orderId: string;
    userId: string;
    items: CartItem[];
    totalAmount: number;
  };
}
```

#### 事件发布器

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
    await Promise.all(events.map((e) => this.publish(e)));
  }
}
```

#### 事件处理器

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
    for (const item of event.data.items) {
      await this.inventoryService.reserve(item.productId, item.quantity);
    }
    await this.notificationService.sendOrderConfirmation({
      orderId: event.data.orderId,
      userId: event.data.userId,
    });
  }
}

class EventHandlerRegistry {
  private handlers = new Map<string, EventHandler[]>();

  register(handler: EventHandler): void {
    const existing = this.handlers.get(handler.eventType) || [];
    existing.push(handler);
    this.handlers.set(handler.eventType, existing);
  }

  async dispatch(event: DomainEvent): Promise<void> {
    const handlers = this.handlers.get(event.type) || [];
    await Promise.all(handlers.map((h) => h.handle(event as any)));
  }
}
```

### 死信队列

```typescript
class DeadLetterQueue {
  constructor(private producer: KafkaProducer) {}

  async sendFailed(originalEvent: DomainEvent, error: Error, retries: number): Promise<void> {
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
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
```

### 事件溯源

#### 事件存储

```typescript
interface EventStore {
  append(aggregateId: string, events: DomainEvent[], expectedVersion: number): Promise<void>;
  getEvents(aggregateId: string, afterVersion?: number): Promise<DomainEvent[]>;
  subscribe(aggregateId: string, handler: (event: DomainEvent) => void): () => void;
}

class PostgresEventStore implements EventStore {
  constructor(private db: Pool) {}

  async append(aggregateId: string, events: DomainEvent[], expectedVersion: number): Promise<void> {
    const client = await this.db.connect();

    try {
      await client.query('BEGIN');

      const { rows } = await client.query(
        'SELECT MAX(version) as version FROM events WHERE aggregate_id = $1',
        [aggregateId]
      );

      const currentVersion = rows[0]?.version || 0;
      if (currentVersion !== expectedVersion) {
        throw new ConcurrencyError(expectedVersion, currentVersion);
      }

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

#### 聚合根基类

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

## 参考

- [RabbitMQ Docs](https://www.rabbitmq.com/docs)
- [Kafka Docs](https://kafka.apache.org/documentation/)
- [AWS SQS Docs](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/)
- [Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com/)
