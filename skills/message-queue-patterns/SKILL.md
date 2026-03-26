---
name: message-queue-patterns
description: 消息队列模式。涵盖 RabbitMQ/Kafka/SQS 消息处理、事件驱动架构、发布订阅模式和消息模式最佳实践。**必须激活当**：用户要求实现消息队列、设计事件驱动架构、处理异步任务或解耦微服务时。即使用户没有明确说"消息队列"，当涉及异步处理、任务队列或服务间通信时也应使用。
---

# 消息队列模式

用于构建异步通信、事件驱动架构和微服务解耦的消息系统。

## 何时激活

- 构建异步任务处理系统时
- 解耦微服务或模块时
- 实现事件驱动架构时
- 处理高并发消息流量时
- 需要可靠消息传递的场景

## 核心模式

### 1. 发布订阅模式 (Pub/Sub)

```typescript
// 发布者
interface Publisher {
  publish(topic: string, message: Message): Promise<void>;
}

// 订阅者
interface Subscriber {
  subscribe(topic: string, handler: MessageHandler): Promise<void>;
}

// 实现
class EventBus implements Publisher, Subscriber {
  private subscriptions = new Map<string, MessageHandler[]>();

  async publish(topic: string, message: Message): Promise<void> {
    const handlers = this.subscriptions.get(topic) || [];
    await Promise.all(handlers.map((h) => h(message)));
  }

  async subscribe(topic: string, handler: MessageHandler): Promise<void> {
    const handlers = this.subscriptions.get(topic) || [];
    handlers.push(handler);
    this.subscriptions.set(topic, handlers);
  }
}
```

### 2. 工作队列模式 (Work Queue)

```typescript
// 任务队列
class TaskQueue {
  private queue: Task[] = [];
  private workers: Worker[] = [];

  async enqueue(task: Task): Promise<void> {
    this.queue.push(task);
    this.distribute();
  }

  private async distribute(): Promise<void> {
    const availableWorkers = this.workers.filter((w) => w.isAvailable());
    for (const worker of availableWorkers) {
      const task = this.queue.shift();
      if (task) {
        worker.process(task);
      }
    }
  }
}

// 任务处理器
abstract class Worker {
  abstract process(task: Task): Promise<Result>;
}
```

### 3. 路由模式 (Routing)

```typescript
// 多路路由
class MessageRouter {
  private routes = new Map<string, Exchange>();

  registerRoute(pattern: string, exchange: Exchange): void {
    this.routes.set(pattern, exchange);
  }

  async route(message: Message): Promise<void> {
    const exchange = this.findExchange(message.routingKey);
    if (exchange) {
      await exchange.publish(message);
    }
  }

  private findExchange(routingKey: string): Exchange | undefined {
    for (const [pattern, exchange] of this.routes) {
      if (this.match(routingKey, pattern)) {
        return exchange;
      }
    }
  }
}
```

### 4. 死信队列 (Dead Letter Queue)

```typescript
// 死信处理
interface DeadLetterConfig {
  queue: string;
  maxRetries: number;
  retryDelay: number;
  onDeadLetter: (message: Message, error: Error) => Promise<void>;
}

class DeadLetterHandler {
  async handle(message: Message, error: Error): Promise<void> {
    const retryCount = this.getRetryCount(message);

    if (retryCount < this.config.maxRetries) {
      await this.requeueWithDelay(message, retryCount);
    } else {
      await this.sendToDeadLetterQueue(message, error);
    }
  }
}
```

## 消息模式选择

| 场景           | 推荐方案       | 说明                           |
| -------------- | -------------- | ------------------------------ |
| 高吞吐量流处理 | Kafka          | 分布式流平台，适合日志、事件流 |
| 可靠任务队列   | RabbitMQ       | AMQP 协议，功能丰富            |
| 云原生无服务器 | AWS SQS        | 全托管，免维护                 |
| 事务消息       | RabbitMQ       | 支持事务消息                   |
| 延迟任务       | RabbitMQ +死信 | 实现延迟队列                   |

## 消息设计原则

### 消息结构

```typescript
interface Message<T = unknown> {
  id: string;
  type: string;
  timestamp: number;
  payload: T;
  metadata: {
    correlationId?: string;
    replyTo?: string;
    headers?: Record<string, string>;
  };
}
```

### 消息契约

| 原则     | 说明                     |
| -------- | ------------------------ |
| 幂等性   | 消息处理支持重复消费     |
| 顺序性   | 需要时使用分区键保证顺序 |
| 原子性   | 消息处理是原子的         |
| 超时处理 | 消息有明确的处理超时     |

## 可靠性模式

### 1. 消息确认

```typescript
// 生产者确认
async function publishWithConfirm(channel: Channel, msg: Message): Promise<void> {
  await channel.publish('exchange', 'routingKey', msg.content, {
    persistent: true,
    mandatory: true,
  });
  await channel.waitForConfirms();
}

// 消费者确认
async function consumeWithAck(channel: Channel, queue: string): Promise<void> {
  await channel.consume(queue, async (msg) => {
    if (msg) {
      try {
        await processMessage(msg);
        channel.ack(msg);
      } catch (error) {
        channel.nack(msg, false, false); // 不重新入队
      }
    }
  });
}
```

### 2. 事务消息

```typescript
// 确保数据库和消息原子性
async function transactionalOutbox(
  db: Database,
  mq: MessageQueue,
  operation: () => Promise<void>
): Promise<void> {
  await db.transaction(async (tx) => {
    await operation();
    await tx.insert('outbox', { message: mq.pendingMessage });
  });

  // 独立进程发布
  await outboxProcessor.process();
}
```

### 3. 幂等处理

```typescript
class IdempotentProcessor {
  private processed = new Set<string>();

  async process(msg: Message): Promise<Result> {
    if (this.processed.has(msg.id)) {
      return { success: true, duplicated: true };
    }

    const result = await this.doProcess(msg);
    this.processed.add(msg.id);
    return result;
  }
}
```

## 监控指标

| 指标     | 说明                   | 告警阈值 |
| -------- | ---------------------- | -------- |
| 队列深度 | 等待处理的消息数       | > 1000   |
| 消费延迟 | 消息从生产到消费的时间 | > 5s     |
| 失败率   | 消息处理失败比例       | > 1%     |
| 重试次数 | 消息被重试的次数       | > 3      |

## 相关技能

| 技能                    | 说明               |
| ----------------------- | ------------------ |
| kafka-patterns          | Kafka 分布式消息流 |
| rabbitmq-patterns       | RabbitMQ 消息队列  |
| background-jobs         | 后台任务处理       |
| event-handling-patterns | 事件处理模式       |
