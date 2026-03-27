---
name: kafka-patterns
description: Apache Kafka 分布式消息流平台模式，涵盖主题设计、分区策略、消费者组、事件溯源和实时数据管道。适用于需要高吞吐量消息队列、微服务通信、实时数据处理和事件驱动架构的场景。**必须激活当**：用户要求构建消息队列、设计事件驱动架构、处理实时数据流、实现微服务间通信或优化 Kafka 性能时。
---

# Kafka 分布式消息流模式

用于构建高吞吐量、低延迟消息系统的 Kafka 模式和最佳实践。

## 何时激活

- 设计消息队列架构
- 实现事件驱动系统
- 构建实时数据管道
- 优化 Kafka 性能
- 实现微服务通信

## 技术栈版本

| 技术               | 最低版本 | 推荐版本 |
| ------------------ | -------- | -------- |
| Kafka              | 3.0+     | 3.7+     |
| KafkaJS            | 2.0+     | 2.2+     |
| confluent-kafka-go | 1.9+     | 最新     |
| Spring Kafka       | 3.0+     | 最新     |

## 核心概念

| 概念           | 说明                 |
| -------------- | -------------------- |
| Topic          | 消息的分类主题       |
| Partition      | 分区实现并行处理     |
| Offset         | 消息消费位置         |
| Consumer Group | 消费者组实现负载均衡 |
| Replication    | 副本保证高可用       |

## 主题设计

### 命名规范

```bash
# 格式: <domain>.<entity>.<event>
orders.created
payments.processed
users.registered
inventory.adjusted
```

### 分区策略

| 策略      | 适用场景     | 实现方式                |
| --------- | ------------ | ----------------------- |
| 按用户 ID | 用户相关事件 | `userId % partitions`   |
| 按实体 ID | 实体操作事件 | `entityId % partitions` |
| 按时间    | 时序数据     | 时间戳分段              |
| 随机      | 无顺序要求   | 轮询                    |

```javascript
// KafkaJS 生产者
const producer = kafka.producer({
  allowAutoTopicCreation: true,
  transactionTimeout: 30000,
});

await producer.send({
  topic: 'orders.created',
  messages: [
    {
      key: order.userId,
      value: JSON.stringify({
        orderId: order.id,
        userId: order.userId,
        total: order.total,
        timestamp: new Date().toISOString(),
      }),
      headers: {
        'correlation-id': uuid(),
        source: 'order-service',
      },
    },
  ],
});
```

## 消费者模式

### 消费者组

```javascript
const consumer = kafka.consumer({
  groupId: 'order-processor-group',
  sessionTimeout: 30000,
  heartbeatInterval: 3000,
});

await consumer.connect();
await consumer.subscribe({ topic: 'orders.created', fromBeginning: false });

await consumer.run({
  eachMessage: async ({ topic, partition, message }) => {
    const value = JSON.parse(message.value.toString());
    console.log({
      topic,
      partition,
      offset: message.offset,
      key: message.key?.toString(),
      value,
    });

    // 业务处理
    await processOrder(value);
  },
});
```

### 消费策略

| 策略          | 说明         | 可靠性 |
| ------------- | ------------ | ------ |
| At Least Once | 至少消费一次 | 高     |
| At Most Once  | 至多消费一次 | 低     |
| Exactly Once  | 精确一次     | 最高   |

## 事件溯源模式

### 事件结构

```typescript
interface DomainEvent<T = unknown> {
  eventId: string;
  eventType: string;
  aggregateId: string;
  aggregateType: string;
  version: number;
  payload: T;
  metadata: {
    timestamp: string;
    correlationId: string;
    causationId?: string;
    userId?: string;
  };
}
```

### 事件存储

```javascript
// 事件写入
await producer.send({
  topic: `domain-events.${aggregateType}`,
  messages: [
    {
      key: aggregateId,
      value: JSON.stringify(event),
      headers: {
        'event-type': event.eventType,
        'aggregate-type': event.aggregateType,
      },
    },
  ],
});
```

## 性能优化

### 生产者优化

```javascript
const optimizedProducer = kafka.producer({
  acks: -1, // 全部副本确认
  compression: 'lz4', // 压缩
  batchSize: 16384, // 批次大小
  lingerMs: 10, // 等待时间
  retry: {
    initialRetryTime: 100,
    retries: 5,
  },
});
```

### 消费者优化

| 参数               | 推荐值 | 说明             |
| ------------------ | ------ | ---------------- |
| fetch.min.bytes    | 1      | 最小获取字节     |
| fetch.max.wait.ms  | 500    | 最大等待时间     |
| max.poll.records   | 500    | 每次轮询最大记录 |
| session.timeout.ms | 30000  | 会话超时         |

## 容错处理

### 重试机制

```javascript
async function withRetry(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await sleep(Math.pow(2, i) * 100);
    }
  }
}
```

### 死信队列

```javascript
// 发送失败消息到 DLQ
await producer.send({
  topic: 'orders.created.dlq',
  messages: [
    {
      key: message.key,
      value: message.value,
      headers: {
        'original-topic': topic,
        error: error.message,
        'failed-at': new Date().toISOString(),
      },
    },
  ],
});
```

## 监控指标

| 指标             | 告警阈值 | 说明       |
| ---------------- | -------- | ---------- |
| consumer_lag     | > 10000  | 消费延迟   |
| produce_rate     | < 100    | 生产速率   |
| disk_usage       | > 80%    | 磁盘使用   |
| under_replicated | > 0      | 未同步副本 |

## 相关技能

| 技能               | 说明              |
| ------------------ | ----------------- |
| kafka-patterns     | Kafka 消息流      |
| rabbitmq-patterns  | RabbitMQ 消息队列 |
| backend-specialist | 后端架构模式      |
