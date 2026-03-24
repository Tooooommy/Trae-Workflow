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
│   ├── planning/     # 规划与设计
│   ├── development/  # 开发与编码
│   ├── testing/      # 测试与质量
│   ├── security/     # 安全与审查
│   ├── devops/       # DevOps 与部署
│   ├── quality/      # 代码质量
│   ├── specialist/   # 专家智能体
│   └── docs/         # 文档智能体
├── skills/           # 技能配置（90+ 项技能）
│   ├── *-patterns/   # 各种开发模式
│   └── *-stack/      # 全栈技术栈
├── user_rules/       # 用户规则（最高优先级）
├── project_rules/    # 项目规则（语言特定）
├── cli/              # CLI 工具
└── mcp/              # MCP 服务器配置
```

---

## 🤖 智能体系统

### 规划与设计

| 智能体    | 角色   | 触发场景                     |
| --------- | ------ | ---------------------------- |
| planner   | 规划师 | 功能实现、任务分解、风险评估 |
| architect | 架构师 | 系统设计、技术决策、架构模式 |

### 开发与编码

| 智能体           | 角色              | 触发场景                    |
| ---------------- | ----------------- | --------------------------- |
| typescript-dev   | TypeScript 专家   | TS/JS/React/Node.js 开发    |
| python-dev       | Python 专家       | Python/FastAPI/Django 开发  |
| go-dev           | Go 专家           | Go 语言开发                 |
| swift-dev        | Swift 专家        | Swift/iOS/macOS 开发        |
| react-native-dev | React Native 专家 | React Native 跨平台开发     |
| kotlin-dev       | Kotlin 专家       | Kotlin/Android/Compose 开发 |

### 测试与质量

| 智能体         | 角色     | 触发场景                |
| -------------- | -------- | ----------------------- |
| testing-expert | 测试专家 | TDD、E2E 测试、代码质量 |
| reviewer       | 审查专家 | 代码审查、最佳实践      |

### 安全与 DevOps

| 智能体            | 角色        | 触发场景                     |
| ----------------- | ----------- | ---------------------------- |
| security-reviewer | 安全专家    | 漏洞检测、密钥检测、安全审查 |
| devops-expert     | DevOps 专家 | CI/CD、Git、Docker、监控     |

### 专家智能体

| 智能体           | 角色              | 触发场景                |
| ---------------- | ----------------- | ----------------------- |
| backend-expert   | 后端专家          | API 设计、数据库        |
| frontend-expert  | 前端专家          | 前端架构、UI 组件       |
| react-native-dev | React Native 专家 | React Native 跨平台开发 |
| doc-expert       | 文档专家          | 文档编写、API 文档      |

---

## 🔄 标准工作流

### 开发新功能

```
1. 规划阶段    → 使用 planner 进行功能规划
2. 架构设计    → 使用 architect 进行架构设计
3. 开发实现    → 使用语言特定智能体（如 typescript-dev）
4. 测试验证    → 使用 testing-expert 遵循 TDD 工作流
5. 代码审查    → 使用 reviewer 审查代码
6. 安全审查    → 使用 security-reviewer 进行安全审查
7. 部署上线    → 使用 devops-expert 部署
```

### 智能体协作关系

所有智能体遵循统一的协作模式：

| 任务     | 委托目标            |
| -------- | ------------------- |
| 功能规划 | `planner`           |
| 架构设计 | `architect`         |
| 测试策略 | `testing-expert`    |
| 安全审查 | `security-reviewer` |
| DevOps   | `devops-expert`     |

---

## 📚 技能系统

### 技能分类

| 类别     | 示例技能                                         |
| -------- | ------------------------------------------------ |
| 前端开发 | frontend-patterns, vue-patterns                  |
| 后端开发 | backend-patterns, rest-patterns                  |
| 数据库   | postgres-patterns, mongodb-patterns              |
| 测试     | tdd-workflow, e2e-testing                        |
| DevOps   | deployment-patterns, docker-patterns             |
| 安全     | security-review, authentication-patterns         |
| 移动开发 | react-native-patterns, android-native-patterns   |
| 语言特定 | python-patterns, golang-patterns, swift-patterns |
| 架构模式 | clean-architecture, ddd-patterns                 |

### 智能体与技能对应

| 智能体            | 核心技能                                   |
| ----------------- | ------------------------------------------ |
| planner           | clean-architecture, tdd-workflow           |
| architect         | clean-architecture, ddd-patterns           |
| typescript-dev    | frontend-patterns, coding-standards        |
| python-dev        | python-patterns, django-patterns           |
| golang-dev        | golang-patterns                            |
| swift-dev         | swift-patterns                             |
| react-native-dev  | react-native-patterns, frontend-patterns   |
| kotlin-dev        | android-native-patterns, frontend-patterns |
| testing-expert    | tdd-workflow, e2e-testing                  |
| reviewer          | coding-standards, clean-architecture       |
| security-reviewer | security-review                            |
| devops-expert     | ci-cd-patterns, docker-patterns            |
| backend-expert    | rest-patterns, postgres-patterns           |
| frontend-expert   | frontend-patterns, vue-patterns            |
| react-native-dev  | react-native-patterns, frontend-patterns   |

---

## 📋 规则体系

### 规则层级

```
user_rules/           ← 最高优先级（项目配置）
    ↓
project_rules/<lang>/ ← 语言特定扩展
```

### 核心规则

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

---

## 🛠️ CLI 工具

### 安装

```bash
npm install -g trae-workflow-cli
```

### 使用

```bash
# 安装 Trae Workflow
traew install

# 初始化项目规则
traew init ./my-project

# 查看状态
traew status
```

---

## 📖 文档

- [安装指南](INSTALL.md)
- [智能体系统](agents/README.md)
- [技能系统](skills/README.md)
- [规则体系](user_rules/user-rules.md)
- [CLI 工具](cli/README.md)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License
