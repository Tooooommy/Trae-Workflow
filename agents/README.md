# Agents 智能体系统

> 基于角色分工的 AI 智能体协作系统，用于软件开发全生命周期管理。

## 智能体概览

本项目包含 **7 大类 26 个专业智能体**，覆盖软件开发的各个方面。

## 智能体分类

### 📋 规划与设计 (Planning)

| 智能体                               | 角色   | 触发场景                       |
| ------------------------------------ | ------ | ------------------------------ |
| [planner](planning/planner.md)       | 规划师 | 功能实现、任务分解、风险评估   |
| [architect](planning/architect.md)   | 架构师 | 系统设计、技术决策、架构模式   |
| [researcher](planning/researcher.md) | 研究员 | 技术调研、方案对比、可行性分析 |

### 💻 开发与编码 (Development)

| 智能体                                          | 角色             | 触发场景                   |
| ----------------------------------------------- | ---------------- | -------------------------- |
| [typescript-dev](development/typescript-dev.md) | TypeScript 专家  | TS/JS/React/Node.js 开发   |
| [python-dev](development/python-dev.md)         | Python 专家      | Python/FastAPI/Django 开发 |
| [go-dev](development/go-dev.md)                 | Go 专家          | Go 语言开发                |
| [rust-dev](development/rust-dev.md)             | Rust 专家        | Rust 语言开发              |
| [swift-dev](development/swift-dev.md)           | Swift 专家       | Swift/iOS/macOS 开发       |
| [java-dev](development/java-dev.md)             | Java/Kotlin 专家 | Java/Kotlin/Spring 开发    |

### 🧪 测试与质量 (Testing)

| 智能体                                  | 角色         | 触发场景                   |
| --------------------------------------- | ------------ | -------------------------- |
| [tdd-guide](testing/tdd-guide.md)       | TDD 专家     | 测试驱动开发、单元测试     |
| [e2e-tester](testing/e2e-tester.md)     | E2E 专家     | 端到端测试、Playwright     |
| [code-quality](testing/code-quality.md) | 代码质量专家 | 代码审查、重构、死代码检测 |

### 🔒 安全与数据 (Security)

| 智能体                                             | 角色         | 触发场景                        |
| -------------------------------------------------- | ------------ | ------------------------------- |
| [security-reviewer](security/security-reviewer.md) | 安全专家     | 漏洞检测、密钥检测、安全审查    |
| [database-expert](security/database-expert.md)     | 数据库专家   | 查询优化、模式设计、RLS         |
| [api-designer](security/api-designer.md)           | API 设计专家 | REST/GraphQL API 设计、版本控制 |

### 🚀 运维与部署 (DevOps)

| 智能体                             | 角色        | 触发场景                     |
| ---------------------------------- | ----------- | ---------------------------- |
| [devops](devops/devops.md)         | DevOps 专家 | CI/CD、Docker、部署自动化    |
| [git-expert](devops/git-expert.md) | Git 专家    | 分支策略、提交规范、冲突解决 |
| [monitor](devops/monitor.md)       | 监控专家    | 性能监控、日志分析、告警配置 |

### 🎯 专业领域 (Specialist)

| 智能体                                           | 角色         | 触发场景                           |
| ------------------------------------------------ | ------------ | ---------------------------------- |
| [ml-engineer](specialist/ml-engineer.md)         | ML 专家      | 机器学习、MLOps                    |
| [mobile-dev](specialist/mobile-dev.md)           | 移动开发专家 | React Native、Flutter、原生开发    |
| [frontend-expert](specialist/frontend-expert.md) | 前端专家     | React/Vue、状态管理、组件设计      |
| [backend-expert](specialist/backend-expert.md)   | 后端专家     | API 开发、微服务、消息队列         |
| [performance](specialist/performance.md)         | 性能专家     | 性能分析、优化建议、基准测试       |
| [project-monitor](specialist/project-monitor.md) | 项目监控专家 | MCP/Agents/Skills/Rules 监控与优化 |

### 📝 文档与协作 (Docs)

| 智能体                           | 角色         | 触发场景                    |
| -------------------------------- | ------------ | --------------------------- |
| [doc-writer](docs/doc-writer.md) | 文档专家     | README、API 文档、用户指南  |
| [reviewer](docs/reviewer.md)     | 代码审查专家 | PR 审查、代码质量、最佳实践 |

## ⚠️ 相似智能体区分

本项目存在功能相似的智能体，以下是它们的明确区分：

| 智能体组     | 智能体            | 核心职责                     | 使用场景             |
| ------------ | ----------------- | ---------------------------- | -------------------- |
| **代码审查** | `reviewer`        | PR 审查、最佳实践推广        | 代码提交后的全面审查 |
|              | `code-quality`    | 死代码检测、重构、代码清理   | 代码质量深度检查     |
| **性能**     | `performance`     | 性能分析、基准测试、优化方案 | 应用性能问题         |
|              | `monitor`         | 监控配置、日志分析、告警     | 运行时监控设置       |
|              | `project-monitor` | MCP/Agents/Skills/Rules 监控 | 项目整体健康         |
| **后端**     | `backend-expert`  | API、微服务、消息队列        | 后端架构与开发       |
|              | `database-expert` | 查询优化、模式设计、RLS      | 数据库专门问题       |
| **前端**     | `frontend-expert` | React/Vue、组件设计          | 前端架构与开发       |
|              | `typescript-dev`  | TS/JS 开发、类型安全         | 具体语言开发         |

> 💡 **提示**：功能有重叠时，`reviewer` 可处理大多数场景，专项问题再调用对应专家。

## 快速开始

### 常用工作流

```
功能开发：planner → architect → 语言特定开发智能体 → tdd-guide → reviewer
Bug修复：tdd-guide → 语言特定开发智能体 → reviewer
代码审查：reviewer
安全审查：security-reviewer
性能优化：performance
数据库优化：database-expert
CI/CD配置：devops
版本控制：git-expert
```

### 智能体选择指南

| 任务类型         | 推荐智能体        |
| ---------------- | ----------------- |
| 新功能规划       | planner           |
| 架构设计         | architect         |
| TypeScript 开发  | typescript-dev    |
| Python 开发      | python-dev        |
| Go 开发          | go-dev            |
| Rust 开发        | rust-dev          |
| Swift/iOS 开发   | swift-dev         |
| Java/Kotlin 开发 | java-dev          |
| 单元测试         | tdd-guide         |
| E2E 测试         | e2e-tester        |
| 代码质量         | code-quality      |
| 安全审查         | security-reviewer |
| 数据库问题       | database-expert   |
| API 设计         | api-designer      |
| CI/CD            | devops            |
| Git 操作         | git-expert        |
| 监控告警         | monitor           |
| 机器学习         | ml-engineer       |
| 移动开发         | mobile-dev        |
| 前端开发         | frontend-expert   |
| 后端开发         | backend-expert    |
| 性能优化         | `performance`     |
| 项目监控         | `project-monitor` |
| 文档撰写         | `doc-writer`      |
| 代码审查         | `reviewer`        |

## 目录结构

```
agents/
├── planning/           # 规划与设计
│   ├── planner.md
│   ├── architect.md
│   └── researcher.md
├── development/        # 开发与编码
│   ├── typescript-dev.md
│   ├── python-dev.md
│   ├── go-dev.md
│   ├── rust-dev.md
│   ├── swift-dev.md
│   └── java-dev.md
├── testing/            # 测试与质量
│   ├── tdd-guide.md
│   ├── e2e-tester.md
│   └── code-quality.md
├── security/           # 安全与数据
│   ├── security-reviewer.md
│   ├── database-expert.md
│   └── api-designer.md
├── devops/             # 运维与部署
│   ├── devops.md
│   ├── git-expert.md
│   └── monitor.md
├── specialist/         # 专业领域
│   ├── ml-engineer.md
│   ├── mobile-dev.md
│   ├── frontend-expert.md
│   ├── backend-expert.md
│   ├── performance.md
│   └── project-monitor.md
├── docs/               # 文档与协作
│   ├── doc-writer.md
│   └── reviewer.md
└── README.md           # 本文件
```

## 智能体模板

```markdown
---
name: <name>
description: <简短描述，说明何时使用>
mcp_servers:
  - memory
  - sequential-thinking
  - context7
builtin_tools:
  - read
  - filesystem
  - terminal
  - web-search
---

# <智能体名称>

你是一位专注于<领域>的专家。

## 核心职责

1. **职责1** — 描述
2. **职责2** — 描述

## 工作流程

### 1. 步骤1

...
```

## 扩展指南

### 添加新智能体

1. 在对应分类目录下创建 `<name>.md` 文件
2. 包含 frontmatter：`name`, `description`, `mcp_servers`, `builtin_tools`
3. 定义核心职责、工作流程、最佳实践
4. 更新本 README

### 添加新分类

1. 创建新的分类目录
2. 添加智能体文件
3. 更新本 README 的分类表格
