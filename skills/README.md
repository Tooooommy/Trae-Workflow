# Skills 技能系统

> 基于领域知识的可复用技能模块，为智能体提供专业的技术指导和最佳实践。

## 技能概览

### 按类别分类

#### 📝 编码标准与模式

| 技能                | 描述                   | 适用场景 |
| ------------------- | ---------------------- | -------- |
| `coding-standards`  | 通用编码标准和最佳实践 | 所有项目 |
| `api-design`        | REST API 设计模式      | API 开发 |
| `backend-patterns`  | 后端架构模式           | 后端开发 |
| `frontend-patterns` | 前端架构模式           | 前端开发 |

#### 💻 语言特定模式

| 技能                  | 语言           | 描述                                |
| --------------------- | -------------- | ----------------------------------- |
| `python-patterns`     | Python         | Pythonic 惯用法、类型提示、最佳实践 |
| `golang-patterns`     | Go             | 惯用 Go 模式、并发、错误处理        |
| `rust-patterns`       | Rust           | Rust 所有权、生命周期、安全模式     |
| `java-patterns`       | Java           | Java 惯用法、Spring 最佳实践        |
| `kotlin-patterns`     | Kotlin         | Kotlin 惯用法、协程模式             |
| `swiftui-patterns`    | Swift          | SwiftUI 视图模式、状态管理          |
| `django-patterns`     | Python/Django  | Django 项目模式                     |
| `fastapi-async-stack` | Python/FastAPI | FastAPI 异步栈模式                  |

#### 🎨 前端框架模式

| 技能               | 框架    | 描述                                 |
| ------------------ | ------- | ------------------------------------ |
| `vue-patterns`     | Vue 3   | 组合式 API、Pinia 状态管理、性能优化 |
| `angular-patterns` | Angular | 模块设计、RxJS 响应式、依赖注入      |
| `svelte-patterns`  | Svelte  | 响应式声明、Store 模式、SvelteKit    |

#### 🧪 测试相关

| 技能                | 描述               | 适用场景    |
| ------------------- | ------------------ | ----------- |
| `tdd-workflow`      | 测试驱动开发工作流 | 所有项目    |
| `python-testing`    | Python 测试模式    | Python 项目 |
| `golang-testing`    | Go 测试模式        | Go 项目     |
| `django-tdd`        | Django TDD 模式    | Django 项目 |
| `e2e-testing`       | E2E 测试模式       | 所有项目    |
| `verification-loop` | 验证循环模式       | 代码验证    |

#### 🔒 安全相关

| 技能              | 描述             | 适用场景    |
| ----------------- | ---------------- | ----------- |
| `security-review` | 安全审查检查清单 | 所有项目    |
| `django-security` | Django 安全模式  | Django 项目 |

#### 🗄️ 数据库相关

| 技能                  | 描述                          | 适用场景        |
| --------------------- | ----------------------------- | --------------- |
| `postgres-patterns`   | PostgreSQL 模式               | PostgreSQL 项目 |
| `mongodb-patterns`    | MongoDB 文档设计、聚合管道    | NoSQL 项目      |
| `redis-patterns`      | Redis 缓存模式、分布式锁      | 缓存系统        |
| `database-migrations` | 数据库迁移模式                | 数据库变更      |
| `graphql-patterns`    | GraphQL Schema 设计、N+1 解决 | API 层          |

#### 🚀 部署与 DevOps

| 技能                  | 描述                | 适用场景   |
| --------------------- | ------------------- | ---------- |
| `deployment-patterns` | 部署模式            | 部署流程   |
| `docker-patterns`     | Docker 容器模式     | 容器化项目 |
| `kubernetes-patterns` | Kubernetes 部署模式 | K8s 部署   |
| `ci-cd-patterns`      | CI/CD 流水线模式    | 自动化部署 |

#### 🔄 版本控制

| 技能           | 描述                             | 适用场景 |
| -------------- | -------------------------------- | -------- |
| `git-workflow` | Git 分支策略、提交规范、版本发布 | 所有项目 |

#### 📱 移动开发

| 技能                      | 描述                                       |
| ------------------------- | ------------------------------------------ |
| `react-native-patterns`   | React Native 跨平台、状态管理、原生模块    |
| `flutter-patterns`        | Flutter Widget 组合、状态管理、平台集成    |
| `ios-native-patterns`     | iOS 原生、SwiftUI/UIKit、Swift 并发        |
| `android-native-patterns` | Android 原生、Jetpack Compose、Kotlin 协程 |

#### 🖥️ 桌面应用

| 技能                | 描述                                  |
| ------------------- | ------------------------------------- |
| `electron-patterns` | Electron 进程通信、原生集成、自动更新 |
| `tauri-patterns`    | Tauri Rust 后端、安全配置、轻量打包   |

#### 🎨 技术栈特定

| 技能                      | 技术栈             | 描述             |
| ------------------------- | ------------------ | ---------------- |
| `nextjs-supabase-stack`   | Next.js + Supabase | 全栈开发模式     |
| `node-hono-stack`         | Node.js + Hono     | 轻量后端模式     |
| `shopify-app-stack`       | Shopify App        | Shopify 应用开发 |
| `remixjs-fullstack-stack` | Remix              | 全栈 React 模式  |
| `react-modern-stack`      | React 18+          | 现代 React 模式  |

#### 🍎 Swift/iOS 特定

| 技能                          | 描述                     |
| ----------------------------- | ------------------------ |
| `swift-concurrency-6-2`       | Swift 6.2 并发模式       |
| `swift-actor-persistence`     | Actor 持久化模式         |
| `swift-protocol-di-testing`   | 协议、DI、测试模式       |
| `foundation-models-on-device` | 设备端 Foundation Models |

#### 🤖 AI/ML 相关

| 技能                       | 描述                         | 适用场景    |
| -------------------------- | ---------------------------- | ----------- |
| `llm-integration-patterns` | LLM 集成模式、Prompt 工程    | AI 应用开发 |
| `rag-patterns`             | RAG 检索增强生成、向量数据库 | 知识库应用  |
| `prompt-engineering`       | Prompt 工程模式              | AI 提示设计 |

#### 🏗️ 架构模式

| 技能                     | 描述                         | 适用场景   |
| ------------------------ | ---------------------------- | ---------- |
| `microservices-patterns` | 微服务架构、服务发现、Saga   | 分布式系统 |
| `event-driven-patterns`  | 事件驱动、消息队列、事件溯源 | 异步系统   |
| `caching-patterns`       | 多级缓存、缓存一致性策略     | 性能优化   |
| `cqrs-patterns`          | CQRS、事件溯源               | 读写分离   |
| `ddd-patterns`           | 领域驱动设计                 | 复杂业务   |
| `clean-architecture`     | 整洁架构                     | 可维护性   |
| `serverless-patterns`    | 无服务器架构                 | 云原生     |
| `message-queue-patterns` | 消息队列模式                 | 异步处理   |

#### 🔐 认证与安全

| 技能                      | 描述                 | 适用场景    |
| ------------------------- | -------------------- | ----------- |
| `authentication-patterns` | OAuth2/JWT/OIDC 认证 | 身份验证    |
| `security-review`         | 安全审查检查清单     | 所有项目    |
| `django-security`         | Django 安全模式      | Django 项目 |

#### 🔄 可靠性模式

| 技能                      | 描述         | 适用场景 |
| ------------------------- | ------------ | -------- |
| `circuit-breaker`         | 熔断器模式   | 服务容错 |
| `rate-limiting`           | 限流算法     | API 保护 |
| `error-handling-patterns` | 错误处理模式 | 异常管理 |
| `validation-patterns`     | 数据验证模式 | 输入验证 |

#### 📊 可观测性

| 技能                    | 描述           | 适用场景 |
| ----------------------- | -------------- | -------- |
| `logging-observability` | 日志与可观测性 | 监控追踪 |
| `feature-flags`         | 功能开关       | 渐进发布 |

#### ⚡ 实时与异步

| 技能                 | 描述               | 适用场景 |
| -------------------- | ------------------ | -------- |
| `realtime-websocket` | WebSocket 实时通信 | 实时应用 |
| `background-jobs`    | 后台任务队列       | 异步处理 |

#### 📁 存储与文件

| 技能                    | 描述           | 适用场景   |
| ----------------------- | -------------- | ---------- |
| `file-storage-patterns` | 文件存储与 CDN | 文件管理   |
| `prisma-patterns`       | Prisma ORM     | 数据库操作 |

#### 🌐 API 设计

| 技能             | 描述         | 适用场景   |
| ---------------- | ------------ | ---------- |
| `api-versioning` | API 版本管理 | API 演进   |
| `grpc-patterns`  | gRPC 通信    | 高性能 RPC |

#### 💳 业务集成

| 技能                      | 描述            | 适用场景 |
| ------------------------- | --------------- | -------- |
| `payment-stripe-patterns` | Stripe 支付集成 | 支付系统 |
| `email-patterns`          | 邮件服务集成    | 通知系统 |

#### 🌍 国际化与可访问性

| 技能            | 描述       | 适用场景   |
| --------------- | ---------- | ---------- |
| `i18n-patterns` | 国际化支持 | 多语言应用 |
| `a11y-patterns` | 无障碍访问 | 可访问性   |

#### 🎨 UI 与样式

| 技能                | 描述         | 适用场景   |
| ------------------- | ------------ | ---------- |
| `tailwind-patterns` | Tailwind CSS | 原子化 CSS |

#### ⚙️ 性能与构建

| 技能                   | 描述          | 适用场景   |
| ---------------------- | ------------- | ---------- |
| `webassembly-patterns` | WebAssembly   | 高性能计算 |
| `monorepo-patterns`    | Monorepo 管理 | 多包项目   |

#### 📞 实时通信

| 技能              | 描述              | 适用场景 |
| ----------------- | ----------------- | -------- |
| `webrtc-patterns` | WebRTC 实时音视频 | 视频通话 |

#### 📊 分析与跟踪

| 技能                 | 描述           | 适用场景 |
| -------------------- | -------------- | -------- |
| `analytics-tracking` | 调用跟踪与分析 | 持续改进 |

#### 🔧 其他工具

| 技能                         | 描述                  |
| ---------------------------- | --------------------- |
| `tech-stack-selector`        | 技术栈选择器          |
| `content-hash-cache-pattern` | 内容哈希缓存模式      |
| `clickhouse-io`              | ClickHouse 数据库模式 |
| `liquid-glass-design`        | Liquid Glass 设计系统 |
| `agentic-engineering`        | 智能体工程模式        |
| `ai-first-engineering`       | AI 优先工程模式       |
| `agent-harness-construction` | 智能体框架构建        |

## 技能结构

每个技能目录包含：

```
skill-name/
├── SKILL.md          # 主技能文档（必需）
├── examples/         # 示例代码（可选）
├── templates/        # 模板文件（可选）
└── mvp.md            # MVP 指南（可选）
```

### SKILL.md 格式

```markdown
---
name: skill-name
description: 简短描述技能的用途和适用场景
---

# 技能标题

> 一句话概述

## 何时激活

- 场景 1
- 场景 2

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
| ---- | -------- | -------- |
| XXX  | X.X+     | X.X+     |
| YYY  | X.X+     | 最新     |

## 核心内容

### 1. 主题 1

### 2. 主题 2

## 代码示例

## 最佳实践

## 快速参考

## 参考
```

### 技术栈版本表格规范

所有 SKILL 文件必须包含技术栈版本表格，格式如下：

```markdown
## 技术栈版本

| 技术  | 最低版本 | 推荐版本 |
| ----- | -------- | -------- |
| 技术1 | X.X+     | X.X+     |
| 技术2 | X.X+     | 最新     |
```

**规范要求**：

- 位置：放在"何时激活"之后、"核心内容"之前
- 版本号：使用具体的版本号（如 `18.2+`），避免使用 `latest`
- 推荐版本：可以是具体版本号或 `最新`
- 必须包含该技能涉及的主要技术栈

## 使用指南

### 智能体集成

智能体通过以下方式引用技能：

```markdown
有关详细的模式，请参阅技能：`skill: skill-name`
```

### 技能选择指南

```
问题：我需要什么技能？
│
├─ 编写新代码
│   ├─ Python → python-patterns
│   ├─ Go → golang-patterns
│   ├─ Rust → rust-patterns
│   ├─ Java → java-patterns
│   ├─ Kotlin → kotlin-patterns
│   └─ Swift → swiftui-patterns
│
├─ 前端框架
│   ├─ Vue → vue-patterns
│   ├─ Angular → angular-patterns
│   └─ Svelte → svelte-patterns
│
├─ 移动开发
│   ├─ 跨平台
│   │   ├─ React Native → react-native-patterns
│   │   └─ Flutter → flutter-patterns
│   └─ 原生
│       ├─ iOS → ios-native-patterns
│       └─ Android → android-native-patterns
│
├─ 桌面应用
│   ├─ Electron → electron-patterns
│   └─ Tauri → tauri-patterns
│
├─ 设计 API
│   ├─ REST → api-design
│   └─ GraphQL → graphql-patterns
│
├─ 测试
│   ├─ 通用 → tdd-workflow
│   ├─ Python → python-testing
│   ├─ Go → golang-testing
│   └─ E2E → e2e-testing
│
├─ 安全审查 → security-review
│
├─ 数据库
│   ├─ PostgreSQL → postgres-patterns
│   ├─ MongoDB → mongodb-patterns
│   ├─ Redis → redis-patterns
│   └─ 迁移 → database-migrations
│
├─ 部署
│   ├─ Docker → docker-patterns
│   ├─ K8s → kubernetes-patterns
│   └─ CI/CD → ci-cd-patterns
│
├─ 架构设计
│   ├─ 微服务 → microservices-patterns
│   ├─ 事件驱动 → event-driven-patterns
│   └─ 缓存策略 → caching-patterns
│
└─ AI 集成
    ├─ LLM → llm-integration-patterns
    ├─ RAG → rag-patterns
    └─ Prompt → prompt-engineering
```

## 扩展指南

### 添加新技能

1. 创建 `skills/<skill-name>/` 目录
2. 创建 `SKILL.md` 文件
3. 添加 frontmatter：`name`, `description`
4. 编写核心内容、代码示例、最佳实践
5. 更新本 README

### 技能质量标准

- ✅ 明确的激活场景
- ✅ 实用的代码示例
- ✅ 清晰的最佳实践
- ✅ 与项目技术栈相关
- ✅ 定期更新维护

## 统计

| 类别           | 数量   |
| -------------- | ------ |
| 语言特定模式   | 8      |
| 前端框架模式   | 3      |
| 测试相关       | 6      |
| 安全相关       | 2      |
| 数据库相关     | 5      |
| 部署与 DevOps  | 4      |
| 移动开发       | 4      |
| 桌面应用       | 2      |
| 技术栈特定     | 5      |
| Swift/iOS 特定 | 4      |
| AI/ML 相关     | 3      |
| 架构模式       | 3      |
| 其他工具       | 7      |
| **总计**       | **56** |
