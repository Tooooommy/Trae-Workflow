# Trae Workflow

> **专为个人开发者设计** - 精简高效的 AI 编码助手配置

---

## 🎯 项目概述

Trae Workflow 提供了一套完整的 AI 编码助手配置，基于 **MCP-Rules-Skills-Agents** 四层架构，帮助个人开发者提高开发效率。

### 核心特性

- **15 个精简智能体** - 覆盖规划、开发、测试、安全、DevOps 等领域
- **60+ 专业技能** - 保留所有主流语言的开发技能
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
├── agents/           # 智能体配置（15 个核心智能体）
├── skills/           # 技能配置（60+ 项技能）
├── user_rules/       # 用户规则（最高优先级）
├── project_rules/    # 项目规则（语言特定）
└── cli/              # CLI 工具
```

---

## 🤖 智能体系统

### 规划与设计

| 智能体    | 角色   | 触发场景                     |
| --------- | ------ | ---------------------------- |
| planner   | 规划师 | 功能实现、任务分解、风险评估 |
| architect | 架构师 | 系统设计、技术决策、架构模式 |

### 开发与编码

| 智能体           | 角色              | 触发场景                   |
| ---------------- | ----------------- | -------------------------- |
| typescript-dev   | TypeScript 专家   | TS/JS/React/Node.js 开发   |
| python-dev       | Python 专家       | Python/FastAPI/Django 开发 |
| golang-dev       | Go 专家           | Go 语言开发                |
| rust-dev         | Rust 专家         | Rust 语言开发              |
| ios-native       | iOS 专家          | iOS/macOS 开发             |
| react-native-dev | React Native 专家 | React Native 跨平台开发    |
| android-native   | Android 专家      | Android/Compose 开发       |
| mini-program-dev | 小程序专家        | 微信小程序开发             |

### 测试与质量

| 智能体         | 角色     | 触发场景                |
| -------------- | -------- | ----------------------- |
| testing-expert | 测试专家 | TDD、E2E 测试、代码质量 |
| code-reviewer  | 审查专家 | 代码审查、最佳实践      |

### 安全与 DevOps

| 智能体            | 角色        | 触发场景                     |
| ----------------- | ----------- | ---------------------------- |
| security-reviewer | 安全专家    | 漏洞检测、密钥检测、安全审查 |
| devops-expert     | DevOps 专家 | CI/CD、Git、Docker、监控     |

### 专家智能体

| 智能体          | 角色     | 触发场景           |
| --------------- | -------- | ------------------ |
| backend-expert  | 后端专家 | API 设计、数据库   |
| frontend-expert | 前端专家 | 前端架构、UI 组件  |
| doc-expert      | 文档专家 | 文档编写、API 文档 |

### 智能体协作

| 任务     | 委托目标            |
| -------- | ------------------- |
| 功能规划 | `planner`           |
| 架构设计 | `architect`         |
| 测试策略 | `testing-expert`    |
| 安全审查 | `security-reviewer` |
| DevOps   | `devops-expert`     |

---

## 📚 技能系统

### 前端开发

| 技能              | 描述                                    |
| ----------------- | --------------------------------------- |
| frontend-patterns | React、Next.js、状态管理、性能优化、SPA |
| vue-patterns      | Vue 3 组合式 API、Pinia 状态管理        |
| tailwind-patterns | Tailwind CSS 原子化 CSS 模式            |
| a11y-patterns     | 无障碍设计模式、WCAG 合规               |

### 后端开发

| 技能             | 描述                              |
| ---------------- | --------------------------------- |
| backend-patterns | 后端架构模式、API 设计            |
| rest-patterns    | REST API 设计、版本控制、错误处理 |
| graphql-patterns | GraphQL Schema 设计、N+1 问题解决 |

### 数据库

| 技能                | 描述                           |
| ------------------- | ------------------------------ |
| postgres-patterns   | PostgreSQL 查询优化、索引策略  |
| mongodb-patterns    | MongoDB 文档设计、聚合管道     |
| database-migrations | 数据库迁移最佳实践、零停机部署 |
| redis-patterns      | Redis 缓存模式、分布式锁       |
| clickhouse-io       | ClickHouse 高性能分析          |

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

### 安全

| 技能            | 描述                   |
| --------------- | ---------------------- |
| security-review | 安全检查清单、漏洞检测 |
| rate-limiting   | API 限流、防滥用       |

### 移动开发

| 技能                    | 描述                          |
| ----------------------- | ----------------------------- |
| react-native-patterns   | React Native 跨平台开发       |
| android-native-patterns | Android 原生、Jetpack Compose |
| mini-program-patterns   | 微信小程序开发                |

### 桌面开发

| 技能              | 描述                      |
| ----------------- | ------------------------- |
| electron-patterns | Electron 桌面应用开发     |
| tauri-patterns    | Tauri 桌面应用、Rust 后端 |

### 语言特定

| 技能                | 描述                                     |
| ------------------- | ---------------------------------------- |
| python-patterns     | Pythonic 惯用法、PEP 8 标准、pytest 测试 |
| golang-patterns     | Go 惯用模式、并发安全、表格驱动测试      |
| rust-patterns       | Rust 惯用模式、所有权系统、并发安全      |
| ios-native-patterns | iOS/SwiftUI 原生开发模式                 |
| django-patterns     | Django 架构模式、安全、测试              |
| coding-standards    | 通用编码标准、最佳实践                   |

### 架构模式

| 技能                   | 描述                     |
| ---------------------- | ------------------------ |
| clean-architecture     | 整洁架构、分层设计       |
| ddd-patterns           | 领域驱动设计、限界上下文 |
| cqrs-patterns          | CQRS 命令查询职责分离    |
| message-queue-patterns | 消息队列、事件驱动架构   |

### 通信与集成

| 技能               | 描述               |
| ------------------ | ------------------ |
| realtime-websocket | WebSocket 实时通信 |
| webrtc-patterns    | WebRTC 实时音视频  |

### 工具与流程

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

### 性能与优化

| 技能                    | 描述                         |
| ----------------------- | ---------------------------- |
| caching-patterns        | 缓存策略、多级缓存、内容哈希 |
| logging-observability   | 日志、指标、追踪             |
| error-handling-patterns | 统一错误处理、数据验证       |
| background-jobs         | 后台任务、异步处理           |
| circuit-breaker         | 熔断器、服务弹性             |

### AI 与智能体

| 技能                | 描述                                    |
| ------------------- | --------------------------------------- |
| agentic-engineering | 代理工程模式、AI 优先工程、动作空间设计 |

### 全栈框架

| 技能                 | 描述                    |
| -------------------- | ----------------------- |
| express-patterns     | Node.js + Express 全栈  |
| nextjs-patterns      | Next.js + Supabase 全栈 |
| remixjs-patterns     | Remix 全栈应用开发      |
| fastapi-patterns     | FastAPI 异步全栈        |
| shopify-app-patterns | Shopify 应用开发        |

### 智能体与技能对应

| 智能体           | 核心技能                                   |
| ---------------- | ------------------------------------------ |
| planner          | clean-architecture, tdd-workflow           |
| architect        | clean-architecture, ddd-patterns           |
| typescript-dev   | frontend-patterns, coding-standards        |
| python-dev       | python-patterns, django-patterns           |
| golang-dev       | golang-patterns                            |
| rust-dev         | rust-patterns                              |
| ios-native       | ios-native-patterns                        |
| react-native-dev | react-native-patterns, frontend-patterns   |
| android-native   | android-native-patterns, frontend-patterns |
| mini-program-dev | mini-program-patterns                      |
| testing-expert   | tdd-workflow, e2e-testing                  |
| code-reviewer    | coding-standards, clean-architecture       |
| devops-expert    | deployment-patterns, docker-patterns       |
| backend-expert   | rest-patterns, postgres-patterns           |
| frontend-expert  | frontend-patterns, vue-patterns            |

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
| hooks.md                | Hooks 系统         |
| performance.md          | 性能优化配置       |

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
1. 规划阶段    → 使用 planner 进行功能规划
2. 架构设计    → 使用 architect 进行架构设计
3. 开发实现    → 使用语言特定智能体（如 typescript-dev）
4. 测试验证    → 使用 testing-expert 遵循 TDD 工作流
5. 代码审查    → 使用 code-reviewer 审查代码
6. 安全审查    → 使用 security-reviewer 进行安全审查
7. 部署上线    → 使用 devops-expert 部署
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License
