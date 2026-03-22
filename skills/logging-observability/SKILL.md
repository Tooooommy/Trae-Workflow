---
name: logging-observability
description: 日志与可观测性模式 - 结构化日志、指标、追踪三位一体
---

# 日志与可观测性模式

> 结构化日志、性能指标、分布式追踪的最佳实践

## 何时激活

- 实现应用日志系统
- 配置性能监控
- 添加分布式追踪
- 设计告警规则
- 排查生产问题

## 技术栈版本

| 技术          | 最低版本 | 推荐版本 |
| ------------- | -------- | -------- |
| Winston       | 3.0+     | 最新     |
| Pino          | 8.0+     | 最新     |
| OpenTelemetry | 1.0+     | 最新     |
| Prometheus    | 2.0+     | 最新     |
| Grafana       | 10.0+    | 最新     |

## 可观测性三支柱

```
┌─────────────────────────────────────────────────────────────┐
│                     可观测性 (Observability)                  │
├─────────────────┬─────────────────┬─────────────────────────┤
│      日志       │      指标       │         追踪            │
│     (Logs)      │    (Metrics)    │      (Traces)          │
├─────────────────┼─────────────────┼─────────────────────────┤
│   事件记录      │   数值聚合      │     请求路径            │
│   调试分析      │   趋势监控      │     性能分析            │
│   审计追踪      │   告警触发      │     依赖分析            │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 结构化日志

### 日志级别

| 级别  | 用途     | 示例           |
| ----- | -------- | -------------- |
| ERROR | 错误事件 | 异常、失败     |
| WARN  | 警告事件 | 降级、重试     |
| INFO  | 重要事件 | 请求、状态变更 |
| DEBUG | 调试信息 | 变量值、流程   |
| TRACE | 详细追踪 | 函数调用       |

### Winston 配置

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: {
    service: process.env.SERVICE_NAME,
    version: process.env.SERVICE_VERSION,
  },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(winston.format.colorize(), winston.format.simple()),
    }),
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
    }),
    new winston.transports.File({
      filename: 'logs/combined.log',
    }),
  ],
});
```

### Pino 高性能日志

```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  redact: ['req.headers.authorization', 'req.body.password'],
});

logger.info({ userId: 123, action: 'login' }, 'User logged in');
```

### 请求日志中间件

```typescript
function requestLogger(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();
  const requestId = crypto.randomUUID();

  req.requestId = requestId;
  res.setHeader('X-Request-Id', requestId);

  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info(
      {
        requestId,
        method: req.method,
        url: req.url,
        status: res.statusCode,
        duration,
        userAgent: req.headers['user-agent'],
        ip: req.ip,
      },
      'Request completed'
    );
  });

  next();
}
```

## 性能指标

### Prometheus 指标类型

```typescript
import client from 'prom-client';

const register = new client.Registry();

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10],
});

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});

const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Active connections',
});

register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);
register.registerMetric(activeConnections);
```

### 指标中间件

```typescript
function metricsMiddleware(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route?.path || req.path;

    httpRequestDuration.observe(
      { method: req.method, route, status_code: res.statusCode },
      duration
    );

    httpRequestsTotal.inc({
      method: req.method,
      route,
      status_code: res.statusCode,
    });
  });

  next();
}
```

## 分布式追踪

### OpenTelemetry 配置

```typescript
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: process.env.SERVICE_NAME,
    [SemanticResourceAttributes.SERVICE_VERSION]: process.env.SERVICE_VERSION,
  }),
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT,
  }),
});

sdk.start();
```

### 手动追踪

```typescript
import { trace } from '@opentelemetry/api';

const tracer = trace.getTracer('my-service');

async function processOrder(orderId: string) {
  const span = tracer.startSpan('process_order', {
    attributes: { orderId },
  });

  try {
    await validateOrder(orderId);
    await chargePayment(orderId);
    await shipOrder(orderId);
    span.setStatus({ code: SpanStatusCode.OK });
  } catch (error) {
    span.recordException(error);
    span.setStatus({ code: SpanStatusCode.ERROR });
    throw error;
  } finally {
    span.end();
  }
}
```

## 告警规则

### Prometheus 告警示例

```yaml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status_code=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High error rate detected

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High latency detected

      - alert: ServiceDown
        expr: up{job="my-service"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: Service is down
```

## 健康检查

```typescript
interface HealthStatus {
  status: 'healthy' | 'unhealthy' | 'degraded';
  checks: Record<string, { status: string; latency?: number }>;
  timestamp: string;
}

async function healthCheck(): Promise<HealthStatus> {
  const checks: HealthStatus['checks'] = {};

  checks.database = await checkDatabase();
  checks.redis = await checkRedis();
  checks.external = await checkExternalServices();

  const allHealthy = Object.values(checks).every((c) => c.status === 'healthy');
  const anyUnhealthy = Object.values(checks).some((c) => c.status === 'unhealthy');

  return {
    status: anyUnhealthy ? 'unhealthy' : allHealthy ? 'healthy' : 'degraded',
    checks,
    timestamp: new Date().toISOString(),
  };
}
```

## 快速参考

```typescript
// 结构化日志
logger.info({ userId, action: 'create' }, 'Resource created');
logger.error({ error: err.message }, 'Operation failed');

// 指标记录
httpRequestsTotal.inc({ method: 'GET', route: '/users' });
httpRequestDuration.observe({ method: 'GET' }, 0.5);

// 追踪 span
const span = tracer.startSpan('operation');
span.setAttributes({ key: 'value' });
span.end();
```

## 参考

- [OpenTelemetry Docs](https://opentelemetry.io/docs/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)
- [12 Factor App Logs](https://12factor.net/logs)
