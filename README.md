# Trae Workflow

> **专为个人开发者设计** - AI 编码助手配置，基于 MCP-Rules-Skills-Agents 四层架构

---

## 🎯 核心数字

| 智能体 | 技能 | 规则     |
| ------ | ---- | -------- |
| 14     | 62+  | 完整体系 |

---

## 🏗️ 架构分层

```
Agents (决策) → Skills (执行) → Rules (约束) → MCP (连接)
```

| 层级       | 角色       | 关注点                       |
| ---------- | ---------- | ---------------------------- |
| **Agents** | 自主执行体 | 为何做、何时做、按什么顺序做 |
| **Skills** | 原子能力   | 如何完成特定动作             |
| **Rules**  | 行为规范   | 什么能做，什么不能做         |
| **MCP**    | 通信协议   | 如何连接和交换数据           |

---

## 🚀 快速开始

```bash
# 安装 CLI
npm install -g trae-workflow-cli

# 安装配置
traew install

# 更新
traew update
```

---

## 🤖 智能体系统

### 规划层

| 智能体            | 角色     | 说明                         |
| ----------------- | -------- | ---------------------------- |
| **planning-team** | 规划专家 | 功能规划、技术架构、技术决策 |
| **product-team**  | 产品经理 | 需求分析、产品设计、数据分析 |

### 开发团队

| 智能体            | 触发场景                    |
| ----------------- | --------------------------- |
| **backend-team**  | Node.js/Python/Go/Rust 后端 |
| **frontend-team** | React/Vue/Next.js 前端      |
| **mobile-team**   | iOS/Android/React Native    |
| **design-team**   | UI/UX 设计、可视化          |

### 质量保证

| 智能体               | 触发场景              |
| -------------------- | --------------------- |
| **testing-team**     | TDD、E2E 测试、覆盖率 |
| **review-team** | PR 审查、代码质量     |
| **security-team**    | 漏洞检测、安全审查    |

### 基础设施

| 智能体               | 触发场景                |
| -------------------- | ----------------------- |
| **ops-team**         | 运维、CI/CD、构建、部署 |
| **performance-team** | 性能分析、APM           |
| **integration-team** | API 集成、第三方服务    |
| **doc-team**         | API 文档、README        |

### 协作流程

```
product-team → 需求分析
       ↓
planning-team → 技术规划
       ↓
  ┌────────────────────┐
  │  开发团队 (开发实现) │
  └────────────────────┘
       ↓
  ┌────────────────────┐
  │ 质量团队 (测试审查) │
  └────────────────────┘
       ↓
  ┌────────────────────┐
  │ 基础设施 (部署监控) │
  └────────────────────┘
```

---

## 📚 技能速览

### 前端 & UI

- **frontend-patterns** - React、Next.js、状态管理
- **vue-patterns** - Vue 3 组合式 API
- **tailwind-patterns** - Tailwind CSS 原子化
- **design-patterns** - UI/UX 设计模式
- **a11y-patterns** - 无障碍设计、WCAG

### 后端 & API

- **backend-patterns** - 后端架构模式
- **rest-patterns** - REST API 设计
- **graphql-patterns** - GraphQL Schema
- **express-patterns** - Node.js + Express
- **fastapi-patterns** - FastAPI 异步
- **django-patterns** - Django 架构

### 数据库

- **postgres-patterns** - PostgreSQL 优化
- **mongodb-patterns** - MongoDB 聚合
- **redis-patterns** - 缓存、分布式锁
- **database-migrations** - 迁移最佳实践
- **clickhouse-io** - 高性能分析

### 移动开发

- **ios-native-patterns** - SwiftUI 原生
- **android-native-patterns** - Jetpack Compose
- **react-native-patterns** - 跨平台
- **mini-program-patterns** - 微信小程序

### 桌面 & 语言

- **electron-patterns** / **tauri-patterns** - 桌面应用
- **python-patterns** - Pythonic 惯用法
- **golang-patterns** - Go 并发模式
- **rust-patterns** - 所有权系统

### 架构 & 消息

- **clean-architecture** - 整洁架构
- **ddd-patterns** - 领域驱动设计
- **cqrs-patterns** - 命令查询分离
- **kafka-patterns** / **rabbitmq-patterns** - 消息队列

### 测试 & DevOps

- **tdd-workflow** - 测试驱动开发
- **e2e-testing** - Playwright E2E
- **deployment-patterns** - CI/CD 流水线
- **docker-patterns** - 容器化
- **git-workflow** - Git 分支策略

### 安全 & 性能

- **security-review** - 安全检查清单
- **rate-limiting** - API 限流
- **caching-patterns** - 多级缓存
- **logging-observability** - 日志与追踪
- **circuit-breaker** - 熔断器模式

### 支付 & 集成

- **stripe-patterns** / **paypal-patterns** - 支付集成
- **wechatpay-patterns** / **alipay-patterns** - 国内支付
- **realtime-websocket** - WebSocket 实时通信
- **webrtc-patterns** - WebRTC 音视频

### 其他

- **agentic-engineering** - AI 代理工程
- **feature-flags** - 功能开关、A/B 测试
- **i18n-patterns** - 国际化
- **email-patterns** / **file-storage-patterns** - 文件与邮件
- **markdown-patterns** - Markdown 编写
- **skill-creator** - SKILL 创建工具

---

## 📋 规则体系

### 层级结构

```
user_rules/           ← 最高优先级
    ↓
project_rules/<lang>/ ← 语言特定
```

### 核心规则 (user_rules)

| 文件                    | 说明               |
| ----------------------- | ------------------ |
| core-principles.md      | 五条核心原则       |
| project-config.md       | 技术栈、性能目标   |
| coding-style.md         | 代码格式、命名规范 |
| development-workflow.md | 开发流程           |
| testing.md              | TDD、测试策略      |
| security.md             | 安全检查清单       |
| git-workflow.md         | PR 工作流          |
| patterns.md             | 架构模式说明       |

### 项目规则 (project_rules)

按语言组织: `typescript` / `python` / `golang` / `rust` / `swift` / `kotlin`

每个语言目录包含: coding-style、hooks、patterns、security、testing

---

## 🔄 标准工作流

```
1. 规划 → planning-team 进行功能规划和技术架构
2. 分解 → planning-team 分配任务给对应团队
3. 开发 → backend/frontend/mobile-team 实现
4. 测试 → testing-team 遵循 TDD 工作流
5. 审查 → review-team 审查代码
6. 安全 → security-team 进行安全审查
7. 优化 → performance-team 进行性能分析
8. 部署 → ops-team 部署上线
```

---

## 📦 项目结构

```
Trae Workflow/
├── agents/           # 14 个智能体配置
├── skills/           # 62+ 项技能配置
├── user_rules/       # 用户规则（最高优先级）
├── project_rules/    # 项目规则（语言特定）
└── cli/              # CLI 工具
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License
