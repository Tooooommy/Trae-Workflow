# 技能系统

Trae Workflow 提供了一套全面的技能系统，涵盖前端、后端、DevOps、数据库、安全等多个领域。

## 🎯 设计理念

- **领域专精**：每个技能专注于一个特定领域
- **最佳实践**：包含经过验证的最佳实践和模式
- **即插即用**：按需加载，不影响项目结构
- **持续更新**：随技术发展持续更新
- **三层对应**：与 Agents 和 Project Rules 保持一致

## 📊 技能分类

### 🎨 前端开发

| 技能              | 描述                                    |
| ----------------- | --------------------------------------- |
| frontend-patterns | React、Next.js、状态管理、性能优化、SPA |
| vue-patterns      | Vue 3 组合式 API、Pinia 状态管理        |
| tailwind-patterns | Tailwind CSS 原子化 CSS 模式            |
| a11y-patterns     | 无障碍设计模式、WCAG 合规               |

### 🔧 后端开发

| 技能             | 描述                              |
| ---------------- | --------------------------------- |
| backend-patterns | 后端架构模式、API 设计            |
| rest-patterns    | REST API 设计、版本控制、错误处理 |
| graphql-patterns | GraphQL Schema 设计、N+1 问题解决 |

### 💾 数据库

| 技能                | 描述                           |
| ------------------- | ------------------------------ |
| postgres-patterns   | PostgreSQL 查询优化、索引策略  |
| mongodb-patterns    | MongoDB 文档设计、聚合管道     |
| database-migrations | 数据库迁移最佳实践、零停机部署 |
| redis-patterns      | Redis 缓存模式、分布式锁       |
| clickhouse-io       | ClickHouse 高性能分析          |

### 🧪 测试

| 技能         | 描述                    |
| ------------ | ----------------------- |
| tdd-workflow | 测试驱动开发工作流      |
| e2e-testing  | Playwright E2E 测试模式 |

### 🚀 DevOps

| 技能                | 描述                               |
| ------------------- | ---------------------------------- |
| deployment-patterns | CI/CD 流水线、部署工作流、健康检查 |
| docker-patterns     | Docker 容器化、多服务编排          |

### 🔒 安全

| 技能            | 描述                   |
| --------------- | ---------------------- |
| security-review | 安全检查清单、漏洞检测 |
| rate-limiting   | API 限流、防滥用       |

### 📱 移动开发

| 技能                    | 描述                          |
| ----------------------- | ----------------------------- |
| react-native-patterns   | React Native 跨平台开发       |
| android-native-patterns | Android 原生、Jetpack Compose |

### 🖥️ 桌面开发

| 技能              | 描述                      |
| ----------------- | ------------------------- |
| electron-patterns | Electron 桌面应用开发     |
| tauri-patterns    | Tauri 桌面应用、Rust 后端 |

### 🦀 语言特定

| 技能                | 描述                                     |
| ------------------- | ---------------------------------------- |
| python-patterns     | Pythonic 惯用法、PEP 8 标准、pytest 测试 |
| golang-patterns     | Go 惯用模式、并发安全、表格驱动测试      |
| rust-patterns       | Rust 惯用模式、所有权系统、并发安全      |
| ios-native-patterns | iOS/SwiftUI 原生开发模式                 |
| django-patterns     | Django 架构模式、安全、测试              |
| coding-standards    | 通用编码标准、最佳实践                   |

### 🏗️ 架构模式

| 技能                   | 描述                     |
| ---------------------- | ------------------------ |
| clean-architecture     | 整洁架构、分层设计       |
| ddd-patterns           | 领域驱动设计、限界上下文 |
| cqrs-patterns          | CQRS 命令查询职责分离    |
| message-queue-patterns | 消息队列、事件驱动架构   |

### 🔄 通信与集成

| 技能               | 描述               |
| ------------------ | ------------------ |
| realtime-websocket | WebSocket 实时通信 |
| webrtc-patterns    | WebRTC 实时音视频  |

### 🛠️ 工具与流程

| 技能                  | 描述                   |
| --------------------- | ---------------------- |
| git-workflow          | Git 分支策略、提交规范 |
| feature-flags         | 功能开关、A/B 测试     |
| i18n-patterns         | 国际化、多语言支持     |
| email-patterns        | 邮件服务、模板最佳实践 |
| file-storage-patterns | 文件上传、对象存储     |
| stripe-patterns       | Stripe 支付集成        |
| paypal-patterns       | PayPal 支付集成        |
| wechatpay-patterns    | 微信支付集成           |
| alipay-patterns       | 支付宝支付集成         |

### ⚡ 性能与优化

| 技能                    | 描述                         |
| ----------------------- | ---------------------------- |
| caching-patterns        | 缓存策略、多级缓存、内容哈希 |
| logging-observability   | 日志、指标、追踪             |
| error-handling-patterns | 统一错误处理、数据验证       |
| background-jobs         | 后台任务、异步处理           |
| circuit-breaker         | 熔断器、服务弹性             |

### 🤖 AI 与智能体

| 技能                | 描述                                    |
| ------------------- | --------------------------------------- |
| agentic-engineering | 代理工程模式、AI 优先工程、动作空间设计 |

### 📊 全栈框架

| 技能                 | 描述                    |
| -------------------- | ----------------------- |
| express-patterns     | Node.js + Express 全栈  |
| nextjs-patterns      | Next.js + Supabase 全栈 |
| remixjs-patterns     | Remix 全栈应用开发      |
| fastapi-patterns     | FastAPI 异步全栈        |
| shopify-app-patterns | Shopify 应用开发        |
| django-patterns      | Django 架构模式         |

### 🔍 验证与追踪

| 技能               | 描述                 |
| ------------------ | -------------------- |
| verification-loop  | Trade 会话验证系统   |
| analytics-tracking | SKILL/Agent 调用追踪 |

## 🔗 与智能体对应

| 智能体           | 推荐技能                                   |
| ---------------- | ------------------------------------------ |
| typescript-dev   | coding-standards, frontend-patterns        |
| python-dev       | python-patterns, django-patterns           |
| golang-dev       | golang-patterns                            |
| ios-native       | ios-native-patterns                        |
| react-native-dev | react-native-patterns, frontend-patterns   |
| android-native   | android-native-patterns, frontend-patterns |

## 🔗 与规则对应

| 技能                    | 规则目录                      |
| ----------------------- | ----------------------------- |
| python-patterns         | project_rules/python/         |
| golang-patterns         | project_rules/golang/         |
| rust-patterns           | project_rules/rust/           |
| ios-native-patterns     | project_rules/ios-native/     |
| android-native-patterns | project_rules/android-native/ |
| coding-standards        | project_rules/typescript/     |

## 📝 技能结构

每个技能包含以下部分：

```markdown
---
name: skill-name
description: 技能描述
---

# 技能标题

## 何时激活

- 触发条件 1
- 触发条件 2

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |

## 核心原则

### 原则 1

### 原则 2

## 最佳实践

### 实践 1

### 实践 2
```

## 🚀 使用指南

### 1. 技能调用

智能体根据任务类型自动调用相关技能：

```
用户请求: "优化 React 组件性能"
    ↓
typescript-dev (Agent)
    ↓ 分析任务
    ↓ 调用技能
    ├── frontend-patterns (前端优化)
    └── coding-standards (编码标准)
    ↓ 综合建议
```

### 2. 技能发现

基于任务上下文动态发现相关技能：

1. 分析任务关键词
2. 匹配 skills/ 目录中的技能
3. 按相关性排序
4. 调用最相关的技能

### 3. 技能组合

多个技能可以组合使用：

```
任务: "创建 FastAPI 端点"
    ↓
python-dev (Agent)
    ↓ 调用技能
    ├── fastapi-patterns (FastAPI 模式)
    ├── rest-patterns (REST API 设计)
    ├── python-patterns (Python 模式)
    └── tdd-workflow (TDD 工作流)
```

## 📚 技能索引

- **前端**: 4 个技能
- **后端**: 4 个技能
- **数据库**: 6 个技能
- **测试**: 2 个技能
- **DevOps**: 4 个技能
- **安全**: 3 个技能
- **移动**: 2 个技能
- **桌面**: 2 个技能
- **语言特定**: 5 个技能
- **架构**: 5 个技能
- **通信**: 3 个技能
- **工具**: 6 个技能
- **性能**: 5 个技能
- **AI 与智能体**: 1 个技能
- **全栈框架**: 6 个技能
- **验证与追踪**: 2 个技能

**总计**: 60 个技能

## 🔄 更新日志

### 2026-03-24

- **技能结构一致性修复**
  - 统一所有技能的"何时激活"标题（原"何时启用"、"何时使用"、"何时调用"）
  - 为 7 个技术类技能添加"技术栈版本"部分
  - 为 7 个方法论技能添加"不依赖特定技术栈"说明，移除技术栈版本
    - agentic-engineering、clean-architecture、ddd-patterns、coding-standards
    - tdd-workflow、verification-loop、tech-stack-selector
- **大规模合并**：从 73 个技能精简为 60 个
  - api-versioning → rest-patterns
  - content-hash-cache-pattern → caching-patterns
  - ci-cd-patterns → deployment-patterns
  - ai-first-engineering + agent-harness-construction → agentic-engineering
  - python-testing → python-patterns
  - golang-testing → golang-patterns
  - ios-native-patterns → ios-native-patterns
  - react-modern-stack → frontend-patterns
  - react-native-ignite-stack → react-native-patterns
  - validation-patterns → error-handling-patterns
- 删除 angular-patterns 和 svelte-patterns 技能
- 删除 flutter-patterns 技能
- 删除 ml-engineer 智能体及相关技能（llm-integration-patterns、rag-patterns）
- 合并 3 个 Django 技能到 django-patterns
- 合并 5 个 Swift 技能到 ios-native-patterns
