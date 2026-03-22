---
name: serverless-patterns
description: 无服务器模式 - Lambda/Functions、事件驱动、冷启动优化最佳实践
---

# 无服务器模式

> Lambda/Functions、事件驱动、冷启动优化的最佳实践

## 何时激活

- 设计无服务器应用
- 优化 Lambda 性能
- 配置事件触发器
- 实现 API Gateway
- 成本优化

## 技术栈版本

| 技术                 | 最低版本   | 推荐版本   |
| -------------------- | ---------- | ---------- |
| AWS Lambda           | Node.js 18 | Node.js 20 |
| AWS CDK              | 2.0+       | 最新       |
| Serverless Framework | 3.0+       | 最新       |
| SST                  | 2.0+       | 最新       |

## 无服务器架构

```
┌─────────────────────────────────────────────────────────────┐
│                     无服务器架构                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │ API Gateway │────>│   Lambda    │────>│  DynamoDB   │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│         │                   │                              │
│         │                   ▼                              │
│         │           ┌─────────────┐                        │
│         │           │     S3      │                        │
│         │           └─────────────┘                        │
│         │                   │                              │
│         │                   ▼                              │
│         │           ┌─────────────┐     ┌─────────────┐   │
│         └──────────>│  EventBridge│────>│   Lambda    │   │
│                     └─────────────┘     └─────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Lambda 函数

### 基础结构

```typescript
import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';

export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  try {
    const body = JSON.parse(event.body || '{}');

    const result = await processRequest(body);

    return {
      statusCode: 200,
      body: JSON.stringify(result),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};
```

### 冷启动优化

```typescript
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event: any) => {
  const result = await docClient.send(
    new GetCommand({ TableName: 'Users', Key: { id: event.id } })
  );
  return result.Item;
};
```

### 层复用

```typescript
import { Logger } from '@aws-lambda-powertools/logger';
import { Tracer } from '@aws-lambda-powertools/tracer';
import { Metrics } from '@aws-lambda-powertools/metrics';

const logger = new Logger();
const tracer = new Tracer();
const metrics = new Metrics();

export const handler = async (event: any) => {
  logger.info('Processing event', { event });

  const segment = tracer.getSegment();
  const subsegment = segment.addNewSubsegment('processEvent');

  try {
    const result = await processEvent(event);
    metrics.addMetric('ProcessedEvents', MetricUnit.Count, 1);
    return result;
  } finally {
    subsegment.close();
  }
};
```

## API Gateway 集成

### 请求验证

```typescript
import { z } from 'zod';

const RequestSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
});

export const handler = async (event: APIGatewayProxyEvent) => {
  const body = JSON.parse(event.body || '{}');

  const result = RequestSchema.safeParse(body);

  if (!result.success) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        error: 'Validation failed',
        details: result.error.issues,
      }),
    };
  }

  const user = await createUser(result.data);

  return {
    statusCode: 201,
    body: JSON.stringify(user),
  };
};
```

### 响应封装

```typescript
class ApiResponse {
  static success(data: any, statusCode = 200) {
    return {
      statusCode,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify(data),
    };
  }

  static error(message: string, statusCode = 500) {
    return {
      statusCode,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({ error: message }),
    };
  }
}
```

## 事件触发器

### S3 触发器

```typescript
import { S3Event } from 'aws-lambda';

export const handler = async (event: S3Event) => {
  for (const record of event.Records) {
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));

    await processFile(bucket, key);
  }
};
```

### DynamoDB Stream

```typescript
import { DynamoDBStreamEvent } from 'aws-lambda';

export const handler = async (event: DynamoDBStreamEvent) => {
  for (const record of event.Records) {
    if (record.eventName === 'INSERT') {
      const newItem = record.dynamodb?.NewImage;
      await handleInsert(newItem);
    } else if (record.eventName === 'MODIFY') {
      const oldItem = record.dynamodb?.OldImage;
      const newItem = record.dynamodb?.NewImage;
      await handleUpdate(oldItem, newItem);
    } else if (record.eventName === 'REMOVE') {
      const oldItem = record.dynamodb?.OldImage;
      await handleDelete(oldItem);
    }
  }
};
```

### SQS 触发器

```typescript
import { SQSEvent } from 'aws-lambda';

export const handler = async (event: SQSEvent) => {
  const batchItemFailures: { itemIdentifier: string }[] = [];

  for (const record of event.Records) {
    try {
      const message = JSON.parse(record.body);
      await processMessage(message);
    } catch (error) {
      batchItemFailures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures };
};
```

## Step Functions

```typescript
import { StateMachine } from '@aws-sdk/client-sfn';

const sfn = new StateMachine({});

export const startWorkflow = async (input: object) => {
  const result = await sfn.startExecution({
    stateMachineArn: process.env.STATE_MACHINE_ARN,
    input: JSON.stringify(input),
  });

  return result.executionArn;
};
```

## Serverless Framework 配置

```yaml
service: my-api

frameworkVersion: '3'

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  environment:
    TABLE_NAME: ${self:service}-${sls:stage}
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
      Resource: arn:aws:dynamodb:${aws:region}:*:table/${self:provider.environment.TABLE_NAME}

functions:
  createUser:
    handler: src/handlers/createUser.handler
    events:
      - http:
          path: users
          method: post
          cors: true

  getUser:
    handler: src/handlers/getUser.handler
    events:
      - http:
          path: users/{id}
          method: get
          cors: true

resources:
  Resources:
    UsersTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:provider.environment.TABLE_NAME}
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST
```

## 性能优化

| 优化项   | 方法                             |
| -------- | -------------------------------- |
| 冷启动   | 初始化外部依赖在 handler 外      |
| 内存     | 根据执行时间调整内存             |
| 包大小   | 使用 Lambda Layers、Tree-shaking |
| 并发     | 预置并发、预留并发               |
| 连接复用 | Keep-alive 连接池                |

## 成本优化

```typescript
const MAX_ITEMS = 100;

export const handler = async (event: any) => {
  const items = event.items.slice(0, MAX_ITEMS);

  const results = await Promise.all(items.map((item) => processItem(item)));

  return results;
};
```

## 快速参考

```typescript
// Lambda handler
export const handler = async (event, context) => {};

// API Gateway 响应
return { statusCode: 200, body: JSON.stringify(data) };

// DynamoDB 操作
await docClient.send(new GetCommand({ TableName, Key }));

// SQS 批处理失败
return { batchItemFailures: [{ itemIdentifier: messageId }] };
```

## 参考

- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Serverless Framework](https://www.serverless.com/framework/docs/)
- [SST Framework](https://sst.dev/)
- [AWS Powertools for Lambda](https://docs.powertools.aws.dev/lambda/typescript/latest/)
