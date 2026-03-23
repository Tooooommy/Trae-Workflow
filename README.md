# Trae Workflow - Trae 配置项目

Trae Workflow — 智能体指令配置项目，提供生产就绪的 AI 编码插件，包含 **26 个专业智能体**、**89 项技能**以及用于软件开发的自动化工作流。

## 📋 项目概述

本项目为 Trae IDE 提供了一套完整的配置，包括：

- **26 个专业智能体**：覆盖规划、架构、测试、审查、安全、DevOps、全栈开发等各个方面（已优化整合）
- **89 项技能**：涵盖测试驱动开发、代码审查、部署模式、认证、实时通信等
- **完整的规则体系**：通用规则 + 语言特定规则
- **16+ MCP 服务器配置**：优化的 MCP 服务器配置

## 🚀 快速开始

### 方式一：使用 CLI 安装（推荐）

```bash
# 安装 CLI 工具
npm install -g trae-workflow-cli

# 初始化项目
trae init

# 查看状态
trae status

# 更新配置
trae update

# 卸载
trae uninstall
```

### 方式二：手动安装

1. **克隆项目**

   ```bash
   git clone https://github.com/Tooooommy/Trae-Workflow.git
   cd Trae-Workflow
   ```

2. **安装依赖**

   ```bash
   npm install
   ```

3. **配置 Trae**

   ```bash
   # 复制配置到 Trae 目录
   cp -r .trae ~/.trae
   ```

4. **验证安装**
   ```bash
   # 检查智能体和技能
   ls ~/.trae/agents
   ls ~/.trae/skills
   ```

### 配置目录结构

```
~/.trae/
├── agents/           # 智能体配置
├── skills/           # 技能配置
├── rules/            # 规则配置
└── config.json       # 主配置文件
```

#### CLI 命令

| 命令               | 说明                    |
| ------------------ | ----------------------- |
| `trae init`        | 初始化 Trae 配置        |
| `trae status`      | 查看配置状态            |
| `trae update`      | 更新配置到最新版本      |
| `trae uninstall`   | 卸载 Trae 配置          |
| `trae list agents` | 列出所有智能体          |
| `trae list skills` | 列出所有技能            |
| `trae list rules`  | 列出所有规则            |
| `trae info <name>` | 查看智能体/技能详细信息 |

## 🎯 核心架构

### 架构分层

```
┌─────────────────────────────────────────────────────────┐
│                      Agents 层                         │
│ （智能体：决策与执行）                                 │
├─────────────────────────────────────────────────────────┤
│                      Skills 层                         │
│ （技能：具体可执行的能力）                             │
├─────────────────────────────────────────────────────────┤
│                      Rules 层                          │
│ （规则：行为规范与约束）                               │
├─────────────────────────────────────────────────────────┤
│                      MCP 层                           │
│ （通信协议：底层连接与数据交换）                       │
└─────────────────────────────────────────────────────────┘
```

### 分层说明

| 层级       | 角色            | 类比               | 关注点                       |
| ---------- | --------------- | ------------------ | ---------------------------- |
| **MCP**    | 通信协议/连接器 | 高速公路、USB接口  | 如何连接和交换               |
| **Rules**  | 行为规范/约束   | 法律、公司章程     | 什么能做，什么不能做         |
| **Skills** | 原子能力/工具   | 拧螺丝、翻译、画图 | 如何完成特定动作             |
| **Agents** | 自主执行体/大脑 | 员工、机器人       | 为何做、何时做、按什么顺序做 |

### 协同工作流程

```
Agent (决策与执行)
   ├── 通过 MCP 与资源通信
   ├── 遵循 Rules 确保合规
   └── 调用 Skills 完成任务
```

## 🤖 可用智能体

### 规划与设计 (3个)

| 智能体     | 角色   | 触发场景                       |
| ---------- | ------ | ------------------------------ |
| planner    | 规划师 | 功能实现、任务分解、风险评估   |
| architect  | 架构师 | 系统设计、技术决策、架构模式   |
| researcher | 研究员 | 技术调研、方案对比、可行性分析 |

### 开发与编码 (6个)

| 智能体         | 角色             | 触发场景                   |
| -------------- | ---------------- | -------------------------- |
| typescript-dev | TypeScript 专家  | TS/JS/React/Node.js 开发   |
| python-dev     | Python 专家      | Python/FastAPI/Django 开发 |
| go-dev         | Go 专家          | Go 语言开发                |
| rust-dev       | Rust 专家        | Rust 语言开发              |
| swift-dev      | Swift 专家       | Swift/iOS/macOS 开发       |
| java-dev       | Java/Kotlin 专家 | Java/Kotlin/Spring 开发    |

### 测试与质量 (3个)

| 智能体       | 角色         | 触发场景                   |
| ------------ | ------------ | -------------------------- |
| tdd-guide    | TDD 专家     | 测试驱动开发、单元测试     |
| e2e-tester   | E2E 专家     | 端到端测试、Playwright     |
| code-quality | 代码质量专家 | 代码审查、重构、死代码检测 |

### 安全与数据 (3个)

| 智能体            | 角色         | 触发场景                        |
| ----------------- | ------------ | ------------------------------- |
| security-reviewer | 安全专家     | 漏洞检测、密钥检测、安全审查    |
| database-expert   | 数据库专家   | 查询优化、模式设计、RLS         |
| api-designer      | API 设计专家 | REST/GraphQL API 设计、版本控制 |

### 运维与部署 (3个)

| 智能体     | 角色        | 触发场景                     |
| ---------- | ----------- | ---------------------------- |
| devops     | DevOps 专家 | CI/CD、Docker、部署自动化    |
| git-expert | Git 专家    | 分支策略、提交规范、冲突解决 |
| monitor    | 监控专家    | 性能监控、日志分析、告警配置 |

### 专业领域 (6个)

| 智能体          | 角色         | 触发场景                           |
| --------------- | ------------ | ---------------------------------- |
| ml-engineer     | ML 专家      | 机器学习、MLOps                    |
| mobile-dev      | 移动开发专家 | React Native、Flutter、原生开发    |
| frontend-expert | 前端专家     | React/Vue、状态管理、组件设计      |
| backend-expert  | 后端专家     | API 开发、微服务、消息队列         |
| performance     | 性能专家     | 性能分析、优化建议、基准测试       |
| project-monitor | 项目监控专家 | MCP/Agents/Skills/Rules 监控与优化 |

### 文档与协作 (2个)

| 智能体     | 角色         | 触发场景                    |
| ---------- | ------------ | --------------------------- |
| doc-writer | 文档专家     | README、API 文档、用户指南  |
| reviewer   | 代码审查专家 | PR 审查、代码质量、最佳实践 |

## � 技能系统

### 主要技能类别

| 类别             | 数量 | 描述                                                                                               |
| ---------------- | ---- | -------------------------------------------------------------------------------------------------- |
| 编码标准与模式   | 4    | 通用编码标准、API 设计、前后端架构                                                                 |
| 语言特定模式     | 8    | Python、Go、Rust、Java、Kotlin、Swift                                                              |
| 前端框架模式     | 3    | Vue、Angular、Svelte                                                                               |
| 测试相关         | 6    | TDD 工作流、语言特定测试、E2E 测试                                                                 |
| 安全相关         | 2    | 安全审查、框架特定安全                                                                             |
| 数据库相关       | 5    | PostgreSQL、MongoDB、Redis、迁移、GraphQL                                                          |
| 部署与 DevOps    | 4    | 部署模式、Docker、Kubernetes、CI/CD                                                                |
| 移动开发         | 4    | React Native、Flutter、iOS 原生、Android 原生                                                      |
| 桌面应用         | 2    | Electron、Tauri                                                                                    |
| 技术栈特定       | 5    | Next.js+Supabase、Node.js+Hono、Shopify、Remix、React                                              |
| AI/ML 相关       | 3    | LLM 集成、RAG、Prompt 工程                                                                         |
| 架构模式         | 8    | 微服务、事件驱动、缓存、CQRS、DDD、整洁架构、无服务器、消息队列                                    |
| 认证与安全       | 3    | OAuth2/JWT、安全审查、框架特定安全                                                                 |
| 可靠性模式       | 4    | 熔断器、限流、错误处理、数据验证                                                                   |
| 可观测性         | 2    | 日志与可观测性、功能开关                                                                           |
| 实时与异步       | 2    | WebSocket、后台任务                                                                                |
| 存储与文件       | 2    | 文件存储、Prisma ORM                                                                               |
| API 设计         | 2    | API 版本管理、gRPC                                                                                 |
| 业务集成         | 2    | Stripe 支付、邮件服务                                                                              |
| 国际化与可访问性 | 2    | 国际化、无障碍访问                                                                                 |
| UI 与样式        | 1    | Tailwind CSS                                                                                       |
| 性能与构建       | 2    | WebAssembly、Monorepo                                                                              |
| 实时通信         | 1    | WebRTC                                                                                             |
| 分析与跟踪       | 1    | 调用跟踪与分析                                                                                     |
| 其他工具         | 7    | 技术栈选择器、内容哈希缓存、ClickHouse、Liquid Glass 设计、智能体工程、AI 优先工程、智能体框架构建 |

## 📝 规则体系

### 规则层级

```
user_rules/           ← 最高优先级（项目通用规则）
    ↓
project_rules/<lang>/ ← 语言/框架特定扩展
```

### 核心规则文件

| 文件                    | 内容                           |
| ----------------------- | ------------------------------ |
| user-rules.md           | 主文件：成功指标、代码审查清单 |
| core-principles.md      | 核心原则（5条）                |
| project-config.md       | 技术栈、性能目标               |
| coding-style.md         | 代码格式、命名规范             |
| development-workflow.md | 详细开发流程                   |
| testing.md              | TDD 流程、测试策略             |
| security.md             | 检查清单、处理流程             |
| git-workflow.md         | PR 工作流                      |
| patterns.md             | 模式详细说明                   |
| hooks.md                | Hooks 系统                     |
| performance.md          | 性能优化配置                   |
| agent-invocation.md     | Agent 调用规则和规范           |

### 语言特定规则

| 语言       | 规则文件数量 | 覆盖范围                                           |
| ---------- | ------------ | -------------------------------------------------- |
| TypeScript | 14           | React、Next.js、NestJS、React Native、安全、测试等 |
| Python     | 8            | FastAPI、Django、Flask、安全、测试等               |
| Go         | 8            | Gin、Echo、Fiber、安全、测试等                     |
| Rust       | 7            | Actix、Axum、安全、测试等                          |
| Java       | 7            | Spring、Quarkus、安全、测试等                      |
| Kotlin     | 7            | Spring、Ktor、安全、测试等                         |
| Swift      | 7            | SwiftUI、Vapor、安全、测试等                       |

## 🛠️ MCP 服务器

### 核心服务器（默认启用）

| 服务器              | 描述       | 用途       |
| ------------------- | ---------- | ---------- |
| memory              | 内存管理   | 上下文记忆 |
| sequential-thinking | 顺序思考   | 逐步推理   |
| context7            | 上下文管理 | 上下文窗口 |
| terminal            | 终端操作   | 命令执行   |
| filesystem          | 文件系统   | 文件操作   |
| web-search          | 网络搜索   | 信息检索   |
| read                | 文件读取   | 代码分析   |
| write               | 文件写入   | 代码生成   |

### 专业服务器（按需启用）

| 服务器     | 描述            | 用途         |
| ---------- | --------------- | ------------ |
| docker     | Docker 操作     | 容器管理     |
| kubernetes | Kubernetes 操作 | 集群管理     |
| github     | GitHub 操作     | 代码仓库管理 |
| supabase   | Supabase 操作   | 数据库管理   |
| openai     | OpenAI 操作     | LLM 集成     |
| anthropic  | Anthropic 操作  | Claude 集成  |
| google     | Google 操作     | 搜索和 AI    |
| aws        | AWS 操作        | 云服务管理   |

## � 工作流程

### 开发新功能

1. 使用 **planner** 智能体制定实施计划
2. 使用 **tdd-guide** 智能体遵循 TDD 工作流
3. 编写代码
4. 使用 **code-quality** 智能体进行代码质量检查
5. 使用 **security-reviewer** 智能体进行安全审查
6. 使用 **reviewer** 智能体进行最终代码审查
7. 使用 **doc-writer** 智能体更新文档
8. 使用 **devops** 智能体配置 CI/CD

### 修复 Bug

1. 使用 **tdd-guide** 智能体编写失败测试
2. 修复代码
3. 使用 **code-quality** 智能体检查代码质量
4. 使用 **security-reviewer** 智能体进行安全审查
5. 使用 **reviewer** 智能体进行代码审查

### 代码审查

1. 使用 **reviewer** 智能体进行 PR 审查
2. 如涉及安全问题，使用 **security-reviewer** 智能体
3. 如涉及数据库问题，使用 **database-expert** 智能体
4. 如涉及性能问题，使用 **performance** 智能体

### 架构设计

1. 使用 **architect** 智能体设计系统架构
2. 使用 **researcher** 智能体进行技术调研
3. 使用 **planner** 智能体制定实施计划
4. 按计划实施

## 📄 许可证

本项目采用 MIT 许可证。

## 🆘 支持

如遇问题，请：

1. 搜索现有 Issues
2. 创建新的 Issue 并提供详细信息

## 📞 联系方式

- 项目主页：[GitHub Repository]
- 问题反馈：[GitHub Issues]
