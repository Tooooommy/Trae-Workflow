---
name: background-jobs
description: 后台任务模式 - 任务队列、定时任务、异步处理最佳实践
---

# 后台任务模式

> 任务队列、定时任务、异步处理的最佳实践

## 何时激活

- 实现异步任务处理
- 配置定时任务
- 处理长时间运行任务
- 实现任务重试机制
- 设计任务优先级

## 技术栈版本

| 技术     | 最低版本 | 推荐版本 |
| -------- | -------- | -------- |
| BullMQ   | 4.0+     | 最新     |
| Redis    | 6.0+     | 7.0+     |
| Agenda   | 5.0+     | 最新     |
| Temporal | 1.0+     | 最新     |

## 任务队列方案对比

| 方案     | 特点       | 适用场景     |
| -------- | ---------- | ------------ |
| BullMQ   | Redis 队列 | 通用任务队列 |
| Agenda   | MongoDB    | 定时任务     |
| Temporal | 工作流引擎 | 复杂工作流   |
| RabbitMQ | 消息代理   | 企业级消息   |
| SQS      | AWS 服务   | 云原生应用   |

## BullMQ 实现

### 任务定义

```typescript
import { Queue, Worker, Job } from 'bullmq';
import Redis from 'ioredis';

const connection = new Redis(process.env.REDIS_URL);

interface EmailJob {
  to: string;
  subject: string;
  template: string;
  data: object;
}

const emailQueue = new Queue<EmailJob>('email', { connection });

const emailWorker = new Worker<EmailJob>(
  'email',
  async (job: Job<EmailJob>) => {
    const { to, subject, template, data } = job.data;

    await sendEmail(to, subject, template, data);

    return { sent: true, to };
  },
  {
    connection,
    concurrency: 5,
    limiter: {
      max: 100,
      duration: 1000,
    },
  }
);

emailWorker.on('completed', (job) => {
  console.log(`Job ${job.id} completed`);
});

emailWorker.on('failed', (job, err) => {
  console.error(`Job ${job?.id} failed:`, err);
});
```

### 添加任务

```typescript
async function scheduleEmail(data: EmailJob) {
  const job = await emailQueue.add('send', data, {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 1000,
    },
    removeOnComplete: 100,
    removeOnFail: 50,
  });

  return job.id;
}

async function scheduleDelayedEmail(data: EmailJob, delay: number) {
  const job = await emailQueue.add('send', data, {
    delay,
    attempts: 3,
  });

  return job.id;
}

async function scheduleRecurringEmail(data: EmailJob, pattern: string) {
  const job = await emailQueue.add('send', data, {
    repeat: {
      pattern,
    },
  });

  return job.id;
}
```

## 任务优先级

```typescript
const priorityQueue = new Queue('priority-tasks', { connection });

await priorityQueue.add('urgent', { task: 'urgent-task' }, { priority: 1 });
await priorityQueue.add('normal', { task: 'normal-task' }, { priority: 5 });
await priorityQueue.add('low', { task: 'low-task' }, { priority: 10 });
```

## 任务重试策略

```typescript
const worker = new Worker(
  'retry-tasks',
  async (job) => {
    if (shouldRetry(job)) {
      throw new Error('Retry needed');
    }
    return processTask(job.data);
  },
  {
    connection,
    attempts: 5,
    backoff: {
      type: 'exponential',
      delay: 2000,
    },
  }
);
```

## 定时任务 (Agenda)

```typescript
import Agenda from 'agenda';

const agenda = new Agenda({
  db: { address: process.env.MONGODB_URL, collection: 'jobs' },
});

agenda.define('send report', async (job) => {
  const { userId } = job.attrs.data;
  await generateAndSendReport(userId);
});

await agenda.start();

await agenda.every('1 day', 'send report', { userId: 123 });

await agenda.schedule('tomorrow at noon', 'send report', { userId: 456 });

await agenda.cancel({ name: 'send report' });
```

## 工作流 (Temporal)

```typescript
import { proxyActivities, defineWorkflow, defineSignal } from '@temporalio/workflow';

const { sendEmail, updateDatabase, notifySlack } = proxyActivities({
  startToCloseTimeout: '1 minute',
});

export const orderWorkflow = defineWorkflow({
  name: 'orderWorkflow',
  signals: {
    cancel: defineSignal(),
  },
  async execute(orderId: string) {
    try {
      await updateDatabase(orderId, 'processing');
      await sendEmail(orderId);
      await updateDatabase(orderId, 'completed');
      await notifySlack(orderId);
    } catch (error) {
      await updateDatabase(orderId, 'failed');
      throw error;
    }
  },
});
```

## 任务监控

```typescript
import { QueueEvents } from 'bullmq';

const queueEvents = new QueueEvents('email', { connection });

queueEvents.on('waiting', ({ jobId }) => {
  console.log(`Job ${jobId} is waiting`);
});

queueEvents.on('active', ({ jobId }) => {
  console.log(`Job ${jobId} is active`);
});

queueEvents.on('completed', ({ jobId, returnvalue }) => {
  console.log(`Job ${jobId} completed:`, returnvalue);
});

queueEvents.on('failed', ({ jobId, failedReason }) => {
  console.error(`Job ${jobId} failed:`, failedReason);
});

queueEvents.on('progress', ({ jobId, data }) => {
  console.log(`Job ${jobId} progress:`, data);
});
```

## 任务状态管理

```typescript
interface TaskStatus {
  pending: number;
  active: number;
  completed: number;
  failed: number;
  delayed: number;
}

async function getQueueStats(): Promise<TaskStatus> {
  const [waiting, active, completed, failed, delayed] = await Promise.all([
    emailQueue.getWaitingCount(),
    emailQueue.getActiveCount(),
    emailQueue.getCompletedCount(),
    emailQueue.getFailedCount(),
    emailQueue.getDelayedCount(),
  ]);

  return { pending: waiting, active, completed, failed, delayed };
}
```

## 最佳实践

| 实践     | 说明             |
| -------- | ---------------- |
| 幂等性   | 任务可安全重试   |
| 超时设置 | 防止任务无限运行 |
| 死信队列 | 处理失败任务     |
| 监控告警 | 任务积压告警     |
| 优先级   | 紧急任务优先处理 |
| 批处理   | 合并小任务       |

## 快速参考

```typescript
// 添加任务
await queue.add('task', data, { attempts: 3, delay: 5000 });

// 定时任务
await queue.add('task', data, { repeat: { pattern: '0 * * * *' } });

// 优先级
await queue.add('task', data, { priority: 1 });

// 进度更新
await job.updateProgress(50);

// 获取状态
const state = await job.getState();
```

## 参考

- [BullMQ Docs](https://docs.bullmq.io/)
- [Agenda Docs](https://github.com/agenda/agenda)
- [Temporal Docs](https://docs.temporal.io/)
- [Redis Queue Patterns](https://redis.com/redis-enterprise/technology/redis-queues/)
