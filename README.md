# Trae Workflow - Trae 配置项目

Trae Workflow — 智能体指令配置项目，提供生产就绪的 AI 编码插件，基于 **MCP-Rules-Skills-Agents** 四层架构，构建完整的智能系统。

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

一个典型的智能 Agent 在为您服务时：

1. **底层通信**：通过 MCP 与计算资源、知识库、外部工具等进行通信
2. **规则约束**：遵循预设的 Rules（如安全准则、对话规范）确保行为合规
3. **技能调用**：执行时调用各种 Skills（如文本生成、信息检索、代码解释）
4. **智能决策**：由 Agent 理解意图，规划步骤，协调资源，给出最终回答

**总结**：MCP 管"连接"，Rules 管"边界"，Skills 管"动作"，Agent 管"决策与执行"

## 📋 项目概述

本项目为 Trae IDE 提供了一套完整的配置，包括：

- **27 个专业智能体**：覆盖规划、架构、测试、审查、安全、DevOps、全栈开发等各个方面
- **89 项技能**：涵盖测试驱动开发、代码审查、部署模式、认证、实时通信等
- **完整的规则体系**：通用规则 + 语言特定规则
- **16+ MCP 服务器配置**：优化的 MCP 服务器配置

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

详见下方安装步骤

### CLI 安装

Trae Workflow 提供了命令行工具，可以快速从 GitHub 下载并安装最新版本。

#### 安装 CLI

```bash
npm install -g trae-workflow-cli
```

#### 使用 CLI 安装

```bash
# 从默认仓库安装
traew install

# 从指定仓库安装
traew install username/repo

# 安装时备份现有配置
traew install --backup

# 跳过某些组件
traew install --skip-mcp --skip-skills

# 指定项目规则
traew install --path "C:\myproject" --type typescript
```

#### CLI 命令

| 命令                   | 说明                         |
| ---------------------- | ---------------------------- |
| `traew install [repo]` | 从 GitHub 安装 Trae Workflow |
| `traew update`         | 更新到最新版本               |
| `traew status`         | 显示安装状态和配置信息       |
| `traew config`         | 管理配置文件                 |
| `traew init [path]`    | 初始化项目规则               |
| `traew uninstall`      | 卸载 Trae Workflow           |
| `traew version`        | 显示当前版本                 |

#### CLI 选项

| 选项                   | 说明                     |
| ---------------------- | ------------------------ |
| `-b, --backup`         | 备份现有配置             |
| `--skip-mcp`           | 跳过 MCP 配置            |
| `--skip-skills`        | 跳过 Skills 配置         |
| `--skip-agents`        | 跳过 Agents 配置         |
| `--skip-rules`         | 跳过 Rules 配置          |
| `--skip-tracking`      | 跳过 Tracking 配置       |
| `--skip-project-rules` | 跳过 Project Rules 配置  |
| `-q, --quiet`          | 静默模式                 |
| `-f, --force`          | 强制执行                 |
| `-p, --path <path>`    | Project Rules 的项目路径 |
| `-t, --type <type>`    | 项目类型                 |
| `-l, --local <dir>`    | 从本地目录安装           |

### 前置要求

- Trae IDE 已安装
- Node.js 18+ (用于 MCP 服务器)
- Git

## 📁 项目结构

```
Trae Workflow/
├── agents/           # 智能体配置（27 个专业智能体）
│   ├── planning/     # 规划与设计
│   ├── development/  # 开发与编码
│   ├── testing/      # 测试与质量
│   ├── security/     # 安全与审查
│   ├── devops/       # DevOps 与部署
│   ├── quality/      # 代码质量
│   └── trae-agents/  # Trae CN 格式智能体
├── skills/           # 技能配置（89 项技能）
│   ├── tdd-workflow/ # TDD 工作流
│   ├── security-review/ # 安全审查
│   ├── coding-standards/ # 编码标准
│   └── ...
├── user_rules/       # 用户规则（最高优先级）
│   ├── core-principles.md # 核心原则
│   ├── testing.md    # 测试规范
│   ├── security.md   # 安全规范
│   └── ...
├── project_rules/    # 项目规则（语言特定）
│   ├── typescript/   # TypeScript 规则
│   ├── python/       # Python 规则
│   ├── go/           # Go 规则
│   └── ...
├── mcp/              # MCP 服务器配置
│   ├── core/         # 核心服务器
│   ├── professional/ # 专业服务器
│   └── config.json   # 服务器配置
└── README.md         # 项目说明
```

## 🎯 智能体系统

### 智能体分类

#### 📋 规划与设计 (Planning)

| 智能体                                      | 角色   | 触发场景                       |
| ------------------------------------------- | ------ | ------------------------------ |
| [planner](agents/planning/planner.md)       | 规划师 | 功能实现、任务分解、风险评估   |
| [architect](agents/planning/architect.md)   | 架构师 | 系统设计、技术决策、架构模式   |
| [researcher](agents/planning/researcher.md) | 研究员 | 技术调研、方案对比、可行性分析 |

#### 💻 开发与编码 (Development)

| 智能体                                                 | 角色             | 触发场景                   |
| ------------------------------------------------------ | ---------------- | -------------------------- |
| [typescript-dev](agents/development/typescript-dev.md) | TypeScript 专家  | TS/JS/React/Node.js 开发   |
| [python-dev](agents/development/python-dev.md)         | Python 专家      | Python/FastAPI/Django 开发 |
| [go-dev](agents/development/go-dev.md)                 | Go 专家          | Go 语言开发                |
| [rust-dev](agents/development/rust-dev.md)             | Rust 专家        | Rust 语言开发              |
| [swift-dev](agents/development/swift-dev.md)           | Swift 专家       | Swift/iOS/macOS 开发       |
| [java-dev](agents/development/java-dev.md)             | Java/Kotlin 专家 | Java/Kotlin/Spring 开发    |

#### 🧪 测试与质量 (Testing)

| 智能体                                         | 角色         | 触发场景                 |
| ---------------------------------------------- | ------------ | ------------------------ |
| [tdd-guide](agents/testing/tdd-guide.md)       | TDD 专家     | 测试驱动开发、单元测试   |
| [e2e-tester](agents/testing/e2e-tester.md)     | E2E 测试专家 | 端到端测试、用户流程测试 |
| [code-quality](agents/testing/code-quality.md) | 代码质量专家 | 代码审查、重构清理       |

#### 🔒 安全与审查 (Security)

| 智能体                                                    | 角色         | 触发场景                     |
| --------------------------------------------------------- | ------------ | ---------------------------- |
| [security-reviewer](agents/security/security-reviewer.md) | 安全专家     | 漏洞检测、密钥检测、安全审查 |
| [api-designer](agents/security/api-designer.md)           | API 设计专家 | API 设计、安全考虑           |
| [database-expert](agents/security/database-expert.md)     | 数据库专家   | 数据库安全、性能优化         |

#### 🚀 DevOps 与部署 (DevOps)

| 智能体                                      | 角色        | 触发场景           |
| ------------------------------------------- | ----------- | ------------------ |
| [devops](agents/devops/devops.md)           | DevOps 专家 | CI/CD、部署、监控  |
| [git-expert](agents/devops/git-expert.md)   | Git 专家    | 版本控制、分支策略 |
| [performance](agents/devops/performance.md) | 性能专家    | 性能优化、瓶颈分析 |

#### 📊 代码质量 (Quality)

| 智能体                                                 | 角色     | 触发场景           |
| ------------------------------------------------------ | -------- | ------------------ |
| [reviewer](agents/quality/reviewer.md)                 | 审查专家 | 代码审查、最佳实践 |
| [refactor-cleaner](agents/quality/refactor-cleaner.md) | 重构专家 | 代码重构、清理     |
| [doc-updater](agents/quality/doc-updater.md)           | 文档专家 | 文档更新、API 文档 |

#### 🔧 工具与实用程序 (Utilities)

| 智能体                                                           | 角色             | 触发场景           |
| ---------------------------------------------------------------- | ---------------- | ------------------ |
| [build-error-resolver](agents/utilities/build-error-resolver.md) | 构建错误解决专家 | 构建失败、依赖问题 |
| [systematic-debugging](agents/utilities/systematic-debugging.md) | 系统调试专家     | 复杂问题调试       |
| [brainstorming](agents/utilities/brainstorming.md)               | 头脑风暴专家     | 创意生成、方案探索 |

## 🛠️ 技能系统

### 技能分类

#### 开发技能

- **tdd-workflow** - 测试驱动开发工作流
- **coding-standards** - 通用编码标准
- **python-testing** - Python 测试模式
- **golang-testing** - Go 测试模式
- **rust-patterns** - Rust 惯用模式

#### 架构技能

- **clean-architecture** - 整洁架构模式
- **ddd-patterns** - 领域驱动设计
- **microservices-patterns** - 微服务架构
- **api-design** - API 设计模式

#### 安全技能

- **security-review** - 安全审查
- **authentication-patterns** - 认证模式
- **django-security** - Django 安全
- **validation-patterns** - 验证模式

#### DevOps 技能

- **git-workflow** - Git 工作流
- **ci-cd-patterns** - CI/CD 模式
- **docker-patterns** - Docker 模式
- **kubernetes-patterns** - Kubernetes 模式

#### 前端技能

- **react-modern-stack** - React 现代栈
- **vue-patterns** - Vue 模式
- **angular-patterns** - Angular 模式
- **svelte-patterns** - Svelte 模式

#### 移动端技能

- **react-native-ignite-stack** - React Native 栈
- **flutter-patterns** - Flutter 模式
- **android-native-patterns** - Android 原生
- **ios-native-patterns** - iOS 原生

#### 数据库技能

- **postgres-patterns** - PostgreSQL 模式
- **mongodb-patterns** - MongoDB 模式
- **redis-patterns** - Redis 模式
- **prisma-patterns** - Prisma ORM

#### 实时通信技能

- **realtime-websocket** - WebSocket 模式
- **webrtc-patterns** - WebRTC 模式
- **message-queue-patterns** - 消息队列
- **grpc-patterns** - gRPC 模式

#### AI/ML 技能

- **llm-integration-patterns** - LLM 集成
- **rag-patterns** - RAG 模式
- **foundation-models-on-device** - 设备上模型

## 📋 规则体系

### 核心原则

1. **智能体优先** - 将领域任务委托给专业智能体
2. **测试驱动** - 先写测试再实现，要求 80%+ 覆盖率
3. **安全第一** - 绝不妥协安全；验证所有输入
4. **不可变性** - 总是创建新对象，永不修改现有对象
5. **先规划后执行** - 在编写代码前规划复杂功能

### 规则文件

- [core-principles.md](user_rules/core-principles.md) - 核心原则
- [testing.md](user_rules/testing.md) - 测试规范
- [security.md](user_rules/security.md) - 安全规范
- [coding-style.md](user_rules/coding-style.md) - 代码规范
- [development-workflow.md](user_rules/development-workflow.md) - 开发工作流
- [git-workflow.md](user_rules/git-workflow.md) - Git 规范

## 🔌 MCP 服务器

### 核心服务器

- **memory** - 内存管理
- **sequential-thinking** - 顺序思考
- **context7** - 上下文管理

### 专业服务器

- **file-storage** - 文件存储
- **email** - 邮件服务
- **payment-stripe** - Stripe 支付
- **analytics** - 分析跟踪

## 🔄 标准工作流

### 开发新功能

1. 使用 **planner** 智能体进行功能规划
2. 使用 **tdd-guide** 智能体遵循 TDD 工作流
3. 使用 **code-quality** 智能体审查代码
4. 使用 **security-reviewer** 智能体进行安全审查
5. 使用 **devops** 智能体配置 CI/CD

### 修复 Bug

1. 使用 **systematic-debugging** 技能分析问题
2. 使用 **tdd-guide** 智能体编写测试
3. 修复代码
4. 验证测试通过
5. 如涉及安全问题，使用 **security-reviewer** 智能体

### 架构决策

1. 使用 **architect** 智能体进行架构设计
2. 使用 **researcher** 智能体进行技术调研
3. 使用 **planner** 智能体制定实施计划
4. 按计划实施
5. 如涉及性能问题，使用 **performance** 智能体

## 📖 详细文档

- [安装指南](INSTALL.md) - 详细的安装和配置步骤
- [智能体文档](agents/) - 各智能体的详细说明（27 个专业智能体）
- [技能文档](skills/) - 各技能的详细说明（89 项技能）
- [规则文档](user_rules/) - 规则体系的详细说明
- [MCP 文档](mcp/) - MCP 服务器的配置说明

## 🤝 贡献

欢迎贡献！请遵循以下步骤：

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证。

## 🆘 支持

如遇问题，请：

1. 搜索现有 Issues
2. 创建新的 Issue 并提供详细信息

## 📞 联系方式

---

**注意**：本配置项目专为 Trae IDE 设计，确保您的 Trae IDE 版本兼容。

- 项目主页：[GitHub Repository](https://github.com/Tooooommy/Trae-Workflow)
- 问题反馈：[GitHub Issues](https://github.com/Tooooommy/Trae-Workflow/issues)

---

**架构理念**：MCP 管"连接"，Rules 管"边界"，Skills 管"动作"，Agent 管"决策与执行"。它们从底层到高层，共同构成了一个完整的智能系统。
