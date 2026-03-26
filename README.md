# Trae Workflow

> **专为个人开发者设计** - 精简高效的 AI 编码助手配置

---

## 🎯 项目概述

Trae Workflow 提供了一套完整的 AI 编码助手配置，基于 **MCP-Rules-Skills-Agents** 四层架构，帮助个人开发者提高开发效率。

### 核心特性

- **14 个精简智能体** - 1 个规划师 + 13 个专业团队
- **62 项专业技能** - 覆盖前端、后端、移动端、桌面端、DevOps 等
- **完整的规则体系** - 通用规则 + 语言特定规则
- **一键安装** - CLI 工具快速安装和配置

---

## 🏗️ 架构分层

```
┌─────────────────────────────────────────────────────────┐
│                      Agents 层                         │
│ （智能体：决策与执行）                                   │
├─────────────────────────────────────────────────────────┤
│                      Skills 层                         │
│ （技能：具体可执行的能力）                               │
├─────────────────────────────────────────────────────────┤
│                      Rules 层                          │
│ （规则：行为规范与约束）                                 │
├─────────────────────────────────────────────────────────┤
│                      MCP 层                           │
│ （通信协议：底层连接与数据交换）                         │
└─────────────────────────────────────────────────────────┘
```

| 层级       | 角色            | 关注点                       |
| ---------- | --------------- | ---------------------------- |
| **MCP**    | 通信协议/连接器 | 如何连接和交换               |
| **Rules**  | 行为规范/约束   | 什么能做，什么不能做         |
| **Skills** | 原子能力/工具   | 如何完成特定动作             |
| **Agents** | 自主执行体/大脑 | 为何做、何时做、按什么顺序做 |

---

## 🚀 快速开始

### 方式一：使用 CLI 安装（推荐）

```bash
# 全局安装 CLI
npm install -g trae-workflow-cli

# 安装 Trae Workflow
traew install

# 查看版本
traew version
```

### 方式二：手动安装

```bash
# 克隆仓库
git clone https://github.com/Tooooommy/Trae-Workflow.git

# 复制配置文件到 Trae 目录
# 详见 INSTALL.md
```

### CLI 命令

| 命令                   | 说明                         |
| ---------------------- | ---------------------------- |
| `traew install [repo]` | 从 GitHub 安装 Trae Workflow |
| `traew update`         | 更新到最新版本               |
| `traew status`         | 显示安装状态和配置信息       |
| `traew init [path]`    | 初始化项目规则               |
| `traew uninstall`      | 卸载 Trae Workflow           |
| `traew version`        | 显示当前版本                 |

---

## 📁 项目结构

```
Trae Workflow/
├── agents/           # 智能体配置（14 个智能体）
├── skills/           # 技能配置（62 项技能）
├── user_rules/       # 用户规则（最高优先级）
├── project_rules/    # 项目规则（语言特定）
└── cli/              # CLI 工具
```

---

## 🤖 智能体系统

### 规划层

| 智能体  | 角色     | 说明                         |
| ------- | -------- | ---------------------------- |
| planner | 技术总监 | 功能规划、技术架构、技术决策 |

### 开发团队

| 智能体        | 角色       | 触发场景                        |
| ------------- | ---------- | ------------------------------- |
| backend-team  | 后端团队   | Node.js/Python/Go/Rust 后端开发 |
| frontend-team | 前端团队   | React/Vue/Next.js 前端开发      |
| mobile-team   | 移动端团队 | iOS/Android/React Native 开发   |
| design-team   | 设计团队   | UI/UX 设计、可视化              |

### 质量保证

| 智能体           | 角色         | 触发场景                     |
| ---------------- | ------------ | ---------------------------- |
| testing-team     | 测试团队     | TDD、E2E 测试、测试覆盖率    |
| code-review-team | 代码审查团队 | PR 审查、代码质量、最佳实践  |
| security-team    | 安全团队     | 漏洞检测、密钥检测、安全审查 |

### 基础设施

| 智能体      | 角色        | 触发场景                       |
| ----------- | ----------- | ------------------------------ |
| devops-team | DevOps 团队 | CI/CD、Git、Docker、监控、部署 |
| build-team  | 构建团队    | 构建错误、编译问题、依赖冲突   |

### 专业团队

| 智能体           | 角色     | 触发场景                   |
| ---------------- | -------- | -------------------------- |
| performance-team | 性能团队 | 性能分析、优化、APM        |
| integration-team | 集成团队 | API 集成、第三方服务集成   |
| doc-team         | 文档团队 | API 文档、技术文档、README |

### 团队协作流程

```
planner (技术总监)
    ↓
分解任务
    ↓
┌─────────────────────────────────────────────────────┐
│                    开发团队                           │
│  backend-team / frontend-team / mobile-team         │
└─────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────┐
│                    质量保证                           │
│  testing-team / code-review-team / security-team     │
└─────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────┐
│                    基础设施                           │
│  devops-team / build-team / performance-team        │
└─────────────────────────────────────────────────────┘
```

### 智能体协作表

| 任务       | 委托目标           |
| ---------- | ------------------ |
| 功能规划   | `planner`          |
| 架构设计   | `planner`          |
| 后端开发   | `backend-team`     |
| 前端开发   | `frontend-team`    |
| 移动端开发 | `mobile-team`      |
| UI 设计    | `design-team`      |
| 测试策略   | `testing-team`     |
| 代码审查   | `code-review-team` |
| 安全审查   | `security-team`    |
| DevOps     | `devops-team`      |
| 构建修复   | `build-team`       |
| 性能优化   | `performance-team` |
| 集成       | `integration-team` |
| 文档       | `doc-team`         |

---

## 📚 技能系统

### 前端开发

| 技能              | 描述                                    |
| ----------------- | --------------------------------------- |
| frontend-patterns | React、Next.js、状态管理、性能优化、SPA |
| vue-patterns      | Vue 3 组合式 API、Pinia 状态管理        |
| tailwind-patterns | Tailwind CSS 原子化 CSS 模式            |
| a11y-patterns     | 无障碍设计模式、WCAG 合规               |

### UI/UX 设计

| 技能            | 描述                                 |
| --------------- | ------------------------------------ |
| design-patterns | UI/UX 设计模式、色彩系统、布局、交互 |

### 后端开发

| 技能             | 描述                              |
| ---------------- | --------------------------------- |
| backend-patterns | 后端架构模式、API 设计            |
| rest-patterns    | REST API 设计、版本控制、错误处理 |
| graphql-patterns | GraphQL Schema 设计、N+1 问题解决 |
| express-patterns | Node.js + Express 全栈            |
| fastapi-patterns | FastAPI 异步全栈                  |
| django-patterns  | Django 架构模式、安全、测试       |

### 数据库

| 技能                | 描述                           |
| ------------------- | ------------------------------ |
| postgres-patterns   | PostgreSQL 查询优化、索引策略  |
| mongodb-patterns    | MongoDB 文档设计、聚合管道     |
| database-migrations | 数据库迁移最佳实践、零停机部署 |
| redis-patterns      | Redis 缓存模式、分布式锁       |
| clickhouse-io       | ClickHouse 高性能分析          |

### 移动开发

| 技能                    | 描述                         |
| ----------------------- | ---------------------------- |
| ios-native-patterns     | iOS/SwiftUI 原生开发模式     |
| android-native-patterns | Android/Jetpack Compose 原生 |
| react-native-patterns   | React Native 跨平台开发      |
| mini-program-patterns   | 微信小程序开发               |

### 桌面开发

| 技能              | 描述                      |
| ----------------- | ------------------------- |
| electron-patterns | Electron 桌面应用开发     |
| tauri-patterns    | Tauri 桌面应用、Rust 后端 |

### 语言特定

| 技能             | 描述                                     |
| ---------------- | ---------------------------------------- |
| python-patterns  | Pythonic 惯用法、PEP 8 标准、pytest 测试 |
| golang-patterns  | Go 惯用模式、并发安全、表格驱动测试      |
| rust-patterns    | Rust 惯用模式、所有权系统、并发安全      |
| coding-standards | 通用编码标准、最佳实践                   |

### 测试

| 技能         | 描述                    |
| ------------ | ----------------------- |
| tdd-workflow | 测试驱动开发工作流      |
| e2e-testing  | Playwright E2E 测试模式 |

### DevOps

| 技能                | 描述                               |
| ------------------- | ---------------------------------- |
| deployment-patterns | CI/CD 流水线、部署工作流、健康检查 |
| docker-patterns     | Docker 容器化、多服务编排          |
| git-workflow        | Git 分支策略、提交规范             |

### 安全

| 技能            | 描述                   |
| --------------- | ---------------------- |
| security-review | 安全检查清单、漏洞检测 |
| rate-limiting   | API 限流、防滥用       |

### 架构模式

| 技能               | 描述                     |
| ------------------ | ------------------------ |
| clean-architecture | 整洁架构、分层设计       |
| ddd-patterns       | 领域驱动设计、限界上下文 |
| cqrs-patterns      | CQRS 命令查询职责分离    |
| kafka-patterns     | Kafka 分布式消息流       |
| rabbitmq-patterns  | RabbitMQ 消息队列        |

### 性能与优化

| 技能                    | 描述                         |
| ----------------------- | ---------------------------- |
| caching-patterns        | 缓存策略、多级缓存、内容哈希 |
| logging-observability   | 日志、指标、追踪             |
| error-handling-patterns | 统一错误处理、数据验证       |
| background-jobs         | 后台任务、异步处理           |
| circuit-breaker         | 熔断器、服务弹性             |

### 通信与集成

| 技能               | 描述               |
| ------------------ | ------------------ |
| realtime-websocket | WebSocket 实时通信 |
| webrtc-patterns    | WebRTC 实时音视频  |

### 支付集成

| 技能               | 描述            |
| ------------------ | --------------- |
| stripe-patterns    | Stripe 支付集成 |
| paypal-patterns    | PayPal 支付集成 |
| wechatpay-patterns | 微信支付集成    |
| alipay-patterns    | 支付宝支付集成  |

### AI 与智能体

| 技能                | 描述                                    |
| ------------------- | --------------------------------------- |
| agentic-engineering | 代理工程模式、AI 优先工程、动作空间设计 |

### 其他

| 技能                  | 描述                   |
| --------------------- | ---------------------- |
| feature-flags         | 功能开关、A/B 测试     |
| i18n-patterns         | 国际化、多语言支持     |
| email-patterns        | 邮件服务、模板最佳实践 |
| file-storage-patterns | 文件上传、对象存储     |
| markdown-patterns     | Markdown 文档编写      |
| webassembly-patterns  | WASM 模块、性能优化    |

### 全栈框架

| 技能                 | 描述                    |
| -------------------- | ----------------------- |
| nextjs-patterns      | Next.js + Supabase 全栈 |
| remixjs-patterns     | Remix 全栈应用开发      |
| shopify-app-patterns | Shopify 应用开发        |

### 技能创建

| 技能          | 描述                     |
| ------------- | ------------------------ |
| skill-creator | SKILL 创建工具和最佳实践 |

---

## 📋 规则体系

### 规则层级

```
user_rules/           ← 最高优先级（项目配置）
    ↓
project_rules/<lang>/ ← 语言特定扩展
```

### 核心规则（user_rules）

| 规则文件                | 内容               |
| ----------------------- | ------------------ |
| core-principles.md      | 五条核心原则       |
| project-config.md       | 技术栈、性能目标   |
| coding-style.md         | 代码格式、命名规范 |
| development-workflow.md | 详细开发流程       |
| testing.md              | TDD 流程、测试策略 |
| security.md             | 检查清单、处理流程 |
| git-workflow.md         | PR 工作流          |
| patterns.md             | 模式详细说明       |

### 项目规则（project_rules）

| 语言       | 规则文件                                         |
| ---------- | ------------------------------------------------ |
| typescript | coding-style, hooks, patterns, security, testing |
| python     | coding-style, hooks, patterns, security, testing |
| golang     | coding-style, hooks, patterns, security, testing |
| rust       | coding-style, hooks, patterns, security, testing |
| swift      | coding-style, hooks, patterns, security, testing |
| kotlin     | coding-style, hooks, patterns, security, testing |

---

## 🔄 标准工作流

### 开发新功能

```
1. 规划阶段    → 使用 planner 进行功能规划和技术架构
2. 任务分解    → planner 分解任务并分配给对应团队
3. 开发实现    → backend-team / frontend-team / mobile-team
4. 测试验证    → testing-team 遵循 TDD 工作流
5. 代码审查    → code-review-team 审查代码
6. 安全审查    → security-team 进行安全审查
7. 性能优化    → performance-team 进行性能分析
8. 部署上线    → devops-team 部署
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License
