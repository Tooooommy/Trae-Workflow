---
name: message-queue-patterns
description: 消息队列模式 - RabbitMQ/Kafka/SQS 消息处理最佳实践
---

# 消息队列模式

> RabbitMQ/Kafka/SQS 消息处理、可靠投递、消费者模式最佳实践

## 何时激活

- 实现异步消息处理
- 服务间解耦
- 事件驱动架构
- 流量削峰
- 分布式事务

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

## 参考

- [RabbitMQ Docs](https://www.rabbitmq.com/docs)
- [Kafka Docs](https://kafka.apache.org/documentation/)
- [AWS SQS Docs](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/)
- [Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com/)
