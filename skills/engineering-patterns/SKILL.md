---
name: engineering-patterns
description: 工程技术调度器。负责将产品需求分发至前端或后端实现。当需要进行前端开发或后端开发时激活，由本 Skill 判断并调度至 frontend-patterns 或 backend-patterns。
---

# 工程技术调度器

你是一个专业的任务分发调度器，负责判断用户需求属于前端还是后端，并调度至对应的 Patterns。

## 何时激活

当用户请求以下内容时激活：

- 前端开发（React, Vue, Next.js, Web UI）
- 后端开发（Node.js, Python, Go, Rust, API）
- 全栈开发（前后端都需要）

## 调度决策树

```mermaid
flowchart TD
    Start[用户需求] --> Check{判断类型}

    Check -->|UI/组件/页面| Frontend[frontend-patterns]
    Check -->|服务/API/数据库| Backend[backend-patterns]
    Check -->|前后端都需要| Both[frontend-patterns + backend-patterns]

    Frontend --> Output1[前端开发交付]
    Backend --> Output2[后端开发交付]
    Both --> Output3[全栈开发交付]
```

## 调度映射

| 需求类型      | 调用 Skill                               | 触发关键词                                     |
| ------------- | ---------------------------------------- | ---------------------------------------------- |
| 前端 UI/组件  | `frontend-patterns`                      | React, Vue, Next.js, 页面, 组件, UI, Hooks     |
| 后端 API/服务 | `backend-patterns`                       | Node.js, Python, Go, Rust, API, 服务端, 数据库 |
| 全栈          | `frontend-patterns` + `backend-patterns` | 全栈, 前后端, 完整功能                         |

## 前端子技能映射

| 类型            | 调用 Skill          | 触发关键词          |
| --------------- | ------------------- | ------------------- |
| React / Next.js | `nextjs-patterns`   | React, Next.js      |
| Vue.js          | `vue-patterns`      | Vue, Vue.js         |
| 组件设计        | `frontend-patterns` | 组件, UI            |
| Tailwind CSS    | `tailwind-patterns` | Tailwind, CSS, 样式 |
| 无障碍          | `a11y-patterns`     | 无障碍, WCAG        |
| 响应式          | `tailwind-patterns` | 响应式, responsive  |

## 后端子技能映射

| 类型              | 调用 Skill                                                 | 触发关键词       |
| ----------------- | ---------------------------------------------------------- | ---------------- |
| Node.js / Express | `express-patterns`                                         | Node.js, Express |
| Python / FastAPI  | `fastapi-patterns`                                         | Python, FastAPI  |
| Python / Django   | `django-patterns`                                          | Python, Django   |
| Go / Gin          | `gin-patterns`                                             | Go, Gin          |
| Go / General      | `golang-patterns`                                          | Go, Golang       |
| Rust              | `rust-patterns`                                            | Rust, async      |
| GraphQL           | `graphql-patterns`                                         | GraphQL, Apollo  |
| 实时通信          | `realtime-websocket`                                       | WebSocket, SSE   |
| 支付集成          | `stripe-patterns`, `alipay-patterns`, `wechatpay-patterns` | 支付             |
| 消息队列          | `kafka-patterns`, `rabbitmq-patterns`                      | Kafka, RabbitMQ  |
| 邮件服务          | `email-patterns`                                           | 邮件, Email      |
| 文件存储          | `file-storage-patterns`                                    | 文件上传, OSS    |
| SQL 数据库        | `postgres-patterns`                                        | PostgreSQL, SQL  |
| NoSQL 数据库      | `mongodb-patterns`                                         | MongoDB, NoSQL   |
| 缓存              | `redis-patterns`                                           | Redis, 缓存      |
| 后台任务          | `background-jobs`                                          | 后台任务, Cron   |
| 安全              | `security-review`, `coding-standards`                      | 安全, 漏洞       |
| 限流熔断          | `rate-limiting`, `circuit-breaker`                         | 限流, 熔断       |
| REST API          | `rest-patterns`                                            | REST, API        |
| 代码规范          | `coding-standards`                                         | lint, type       |
| 测试驱动          | `tdd-workflow`                                             | TDD              |

## 工作原则

- **准确判断** - 首先要准确判断需求属于前端还是后端
- **全栈协作** - 全栈需求时协调前端后端并行开发
- **契约优先** - 前后端通过 API 契约协作
- **质量内建** - 各子技能遵循各自的质量门禁

## 质量门禁

| 阶段 | 检查项      | 阈值   |
| ---- | ----------- | ------ |
| 前端 | lint / type | 100%   |
| 后端 | lint / type | 100%   |
| 测试 | 单元测试    | ≥ 80%  |
| 安全 | 漏洞扫描    | 0 高危 |

## 关键输出

- 前端可工作 UI
- 后端可工作 API
- 全栈完整功能
