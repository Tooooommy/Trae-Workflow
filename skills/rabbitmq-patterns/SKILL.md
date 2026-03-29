---
name: rabbitmq-patterns
description: RabbitMQ 消息队列模式，涵盖交换机、队列、绑定、死信队列和分布式消息处理。适用于微服务异步通信、任务队列、事件驱动架构和分布式系统集成。**必须激活当**：用户要求构建消息队列、实现异步任务处理、设计事件驱动架构或使用 RabbitMQ 进行微服务通信时。
---

# RabbitMQ 消息队列模式

用于构建可靠异步消息系统的 RabbitMQ 模式和最佳实践。

## 何时激活

- 构建消息队列架构
- 实现异步任务处理
- 设计事件驱动系统
- 微服务间通信
- 处理分布式事务

## 技术栈版本

| 技术          | 最低版本 | 推荐版本 |
| ------------- | -------- | -------- |
| RabbitMQ      | 3.8+     | 3.13+    |
| amqplib       | 0.10+    | 最新     |
| amqp.node     | 0.11+    | 最新     |
| Spring AMQP   | 3.0+     | 最新     |
| pika (Python) | 1.3+     | 最新     |

## 核心概念

| 概念        | 说明                 |
| ----------- | -------------------- |
| Exchange    | 消息交换机，路由规则 |
| Queue       | 消息存储队列         |
| Binding     | 交换机与队列的绑定   |
| Routing Key | 消息路由关键字       |
| Consumer    | 消息消费者           |
| Publisher   | 消息生产者           |

## 交换机类型

| 类型    | 路由规则   | 适用场景   |
| ------- | ---------- | ---------- |
| direct  | 完全匹配   | 点对点消息 |
| fanout  | 广播所有   | 发布订阅   |
| topic   | 通配符匹配 | 灵活路由   |
| headers | 属性匹配   | 复杂路由   |

## 基础连接

### Node.js (amqplib)

```javascript
const amqp = require('amqplib');

async function connect() {
  const connection = await amqp.connect('amqp://guest:guest@localhost:5672');
  const channel = await connection.createChannel();

  return { connection, channel };
}

// 优雅关闭
process.on('SIGINT', async () => {
  await channel.close();
  await connection.close();
});
```

### Python (pika)

```python
import pika

def connect():
    credentials = pika.PlainCredentials('guest', 'guest')
    parameters = pika.ConnectionParameters(
        host='localhost',
        port=5672,
        credentials=credentials
    )
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()
    return connection, channel
```

## 发布/订阅模式

### 直接交换机

```javascript
// 创建交换机和队列
await channel.assertExchange('direct.exchange', 'direct', { durable: true });

await channel.assertQueue('user.created.queue', { durable: true });
await channel.assertQueue('user.notified.queue', { durable: true });

// 绑定队列到交换机
await channel.bindQueue('user.created.queue', 'direct.exchange', 'user.created');
await channel.bindQueue('user.notified.queue', 'direct.exchange', 'user.created');

// 发布消息
channel.publish(
  'direct.exchange',
  'user.created',
  Buffer.from(JSON.stringify({ userId: 123, event: 'created' })),
  { persistent: true }
);
```

### 主题交换机

```javascript
// 交换机: topic.exchange
// 路由键: user.# 或 user.*

// 绑定键示例:
// user.# - 匹配 user.created, user.updated, user.deleted
// user.created - 只匹配 user.created
// order.* - 匹配 order.created, order.paid

await channel.assertExchange('topic.exchange', 'topic', { durable: true });

await channel.assertQueue('user.events.queue', { durable: true });
await channel.bindQueue('user.events.queue', 'topic.exchange', 'user.#');

await channel.assertQueue('order.events.queue', { durable: true });
await channel.bindQueue('order.events.queue', 'topic.exchange', 'order.*');
```

### 扇出交换机

```javascript
await channel.assertExchange('fanout.exchange', 'fanout', { durable: true });

// 多个队列绑定到同一个交换机
await channel.assertQueue('log.file.queue', { durable: true });
await channel.bindQueue('log.file.queue', 'fanout.exchange', '');

await channel.assertQueue('log.database.queue', { durable: true });
await channel.bindQueue('log.database.queue', 'fanout.exchange', '');

// 发布消息，所有绑定的队列都会收到
channel.publish('fanout.exchange', '', Buffer.from('log message'));
```

## 工作队列模式

### 任务消费者

```javascript
// 设置预取数量，实现负载均衡
channel.prefetch(10);

await channel.consume('tasks.queue', async (msg) => {
  if (msg === null) return;

  const task = JSON.parse(msg.content.toString());
  console.log(`Processing task: ${task.id}`);

  try {
    await processTask(task);
    channel.ack(msg);
  } catch (error) {
    console.error(`Task failed: ${error.message}`);
    // 重新入队或发送到死信队列
    channel.nack(msg, false, false);
  }
});
```

### 公平分发

```javascript
// 每次只处理一条消息
channel.prefetch(1);

await channel.consume('tasks.queue', async (msg) => {
  if (msg === null) return;

  const task = JSON.parse(msg.content.toString());

  try {
    await processTask(task);
    channel.ack(msg);
  } catch (error) {
    // 失败的消息，重新入队
    channel.nack(msg, false, true);
  }
});
```

## 死信队列

### 配置死信交换机

```javascript
// 主队列配置死信
await channel.assertQueue('tasks.queue', {
  durable: true,
  arguments: {
    'x-dead-letter-exchange': 'dlx.exchange',
    'x-dead-letter-routing-key': 'tasks.failed',
    'x-message-ttl': 86400000, // 24小时过期
  },
});

// 死信交换机和队列
await channel.assertExchange('dlx.exchange', 'direct', { durable: true });
await channel.assertQueue('tasks.failed.queue', { durable: true });
await channel.bindQueue('tasks.failed.queue', 'dlx.exchange', 'tasks.failed');

// 消费死信消息
channel.consume('tasks.failed.queue', (msg) => {
  const failedTask = JSON.parse(msg.content.toString());
  console.log(`Failed task: ${failedTask.id}`);
  console.log(`Error: ${msg.properties.headers?.error}`);

  // 处理后确认
  channel.ack(msg);
});
```

### 消息重试

```javascript
async function withRetry(channel, msg, fn, maxRetries = 3) {
  const headers = msg.properties.headers || {};
  const retryCount = headers['x-retry-count'] || 0;

  try {
    await fn(JSON.parse(msg.content.toString()));
    channel.ack(msg);
  } catch (error) {
    if (retryCount >= maxRetries) {
      // 超过重试次数，发送到死信队列
      channel.nack(msg, false, false);
    } else {
      // 增加重试次数，重新发布
      channel.ack(msg);
      channel.publish('', msg.fields.routingKey, msg.content, {
        persistent: true,
        headers: {
          ...headers,
          'x-retry-count': retryCount + 1,
          'x-last-error': error.message,
          'x-retry-delay': Math.pow(2, retryCount) * 1000, // 指数退避
        },
      });
    }
  }
}
```

## RPC 模式

### RPC 服务器

```javascript
await channel.assertQueue('rpc.requests', { durable: true });
channel.prefetch(1);

channel.consume('rpc.requests', async (msg) => {
  if (msg === null) return;

  const request = JSON.parse(msg.content.toString());
  const correlationId = msg.properties.correlationId;
  const replyTo = msg.properties.replyTo;

  console.log(`RPC request: ${request.method}`);

  try {
    const result = await handleRPCRequest(request);

    channel.sendToQueue(replyTo, Buffer.from(JSON.stringify(result)), {
      correlationId,
    });
    channel.ack(msg);
  } catch (error) {
    channel.sendToQueue(replyTo, Buffer.from(JSON.stringify({ error: error.message })), {
      correlationId,
    });
    channel.ack(msg);
  }
});
```

### RPC 客户端

```javascript
const correlationId = uuid();
const responseQueue = await channel.assertQueue('', { exclusive: true });

channel.sendToQueue(
  'rpc.requests',
  Buffer.from(
    JSON.stringify({
      method: 'getUser',
      params: { id: 123 },
    })
  ),
  {
    correlationId,
    replyTo: responseQueue.queue,
  }
);

channel.consume(
  responseQueue.queue,
  (msg) => {
    if (msg.properties.correlationId === correlationId) {
      const result = JSON.parse(msg.content.toString());
      console.log('RPC result:', result);
    }
  },
  { noAck: true }
);
```

## 延迟队列

### 使用延迟插件

```javascript
// 延迟消息插件 x-delayed-message
await channel.assertExchange('delayed.exchange', 'x-delayed-message', {
  durable: true,
  arguments: {
    'x-delayed-type': 'direct',
  },
});

await channel.assertQueue('delayed.queue', { durable: true });
await channel.bindQueue('delayed.queue', 'delayed.exchange', 'delay.key');

// 发送延迟消息 (延迟 5 秒)
channel.publish('delayed.exchange', 'delay.key', Buffer.from('Delayed message'), {
  headers: {
    'x-delay': 5000, // 5 秒 = 5000 毫秒
  },
});
```

### TTL 实现延迟

```javascript
// 创建 TTL 队列
await channel.assertQueue('delay.ttl.queue', {
  durable: true,
  arguments: {
    'x-message-ttl': 5000, // 5 秒
    'x-dead-letter-exchange': 'dlx.exchange',
    'x-dead-letter-routing-key': 'delayed.key',
  },
});

// 实际处理队列
await channel.assertExchange('dlx.exchange', 'direct', { durable: true });
await channel.assertQueue('delayed.process.queue', { durable: true });
await channel.bindQueue('delayed.process.queue', 'dlx.exchange', 'delayed.key');

channel.consume('delayed.process.queue', (msg) => {
  console.log('Received delayed message');
  channel.ack(msg);
});

// 发送消息到延迟队列
channel.sendToQueue('delay.ttl.queue', Buffer.from('TTL message'), { persistent: true });
```

## 集群和高可用

### 镜像队列

```javascript
// Policy 配置（通过管理界面或 CLI）
// rabbitmqctl set_policy ha-all "^ha\." '{"ha-mode":"all","ha-sync-mode":"automatic"}'
// 队列名称以 ha. 开头的都会自动镜像到所有节点
```

### 连接池

```javascript
class RabbitMQPool {
  constructor(url, size = 10) {
    this.pool = [];
    this.size = size;
    this.url = url;
  }

  async acquire() {
    if (this.pool.length > 0) {
      return this.pool.pop();
    }
    const connection = await amqp.connect(this.url);
    const channel = await connection.createChannel();
    return { connection, channel, used: true };
  }

  async release({ connection, channel }) {
    if (this.pool.length < this.size) {
      this.pool.push({ connection, channel });
    } else {
      await channel.close();
      await connection.close();
    }
  }
}
```

## 性能优化

| 参数        | 推荐值 | 说明       |
| ----------- | ------ | ---------- |
| prefetch    | 10-50  | 预取消息数 |
| channel.max | 2048   | 最大通道数 |
| heartbeat   | 60     | 心跳间隔   |
| frame_max   | 131072 | 最大帧大小 |

### 批量发布

```javascript
// 开启发布确认
await channel.confirmSelect();

const messages = generateMessages();
for (const msg of messages) {
  channel.publish('exchange', 'routing.key', Buffer.from(JSON.stringify(msg)), {
    persistent: true,
  });
}

// 等待所有消息确认
await channel.waitForConfirms();
```

## 监控

| 指标                 | 告警阈值 | 说明       |
| -------------------- | -------- | ---------- |
| queue.messages       | > 10000  | 队列堆积   |
| consumer_utilisation | < 50%    | 消费利用率 |
| connections          | > 1000   | 连接数     |
| channels             | > 10000  | 通道数     |

## 相关技能

| 技能              | 说明               |
| ----------------- | ------------------ |
| kafka-patterns    | Kafka 分布式消息流 |
| rabbitmq-patterns | RabbitMQ 消息队列  |
| dev-engineer      | 开发工程师模式     |
