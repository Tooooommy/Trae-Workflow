# Agents 智能体系统

> 基于角色分工的 AI 智能体协作系统，用于软件开发全生命周期管理。

## 智能体概览

本项目包含 **28 个专业智能体**，覆盖软件开发的各个方面。

### 核心智能体

| 智能体                                    | 角色       | 触发场景                       |
| ----------------------------------------- | ---------- | ------------------------------ |
| [orchestrator](orchestrator.md)           | 协调器     | 复杂任务、多智能体协作         |
| [planner](planner.md)                     | 规划师     | 功能实现、架构变更、复杂重构   |
| [architect](architect.md)                 | 架构师     | 系统设计、技术决策、可扩展性   |
| [tdd-guide](tdd-guide.md)                 | TDD专家    | 新功能、Bug修复、重构          |
| [code-reviewer](code-reviewer.md)         | 代码审查   | TypeScript/JavaScript 代码变更 |
| [security-reviewer](security-reviewer.md) | 安全审查   | 用户输入、认证、敏感数据       |
| [database-reviewer](database-reviewer.md) | 数据库审查 | SQL、迁移、模式设计            |

### 语言特定审查器

| 智能体                                | 角色       | 触发场景           |
| ------------------------------------- | ---------- | ------------------ |
| [python-reviewer](python-reviewer.md) | Python审查 | Python 代码变更    |
| [go-reviewer](go-reviewer.md)         | Go审查     | Go 代码变更        |
| [rust-reviewer](rust-reviewer.md)     | Rust审查   | Rust 代码变更      |
| [swift-reviewer](swift-reviewer.md)   | Swift审查  | Swift/iOS 代码变更 |
| [java-reviewer](java-reviewer.md)     | Java审查   | Java 代码变更      |
| [kotlin-reviewer](kotlin-reviewer.md) | Kotlin审查 | Kotlin 代码变更    |

### 专用智能体

| 智能体                                          | 角色       | 触发场景                   |
| ----------------------------------------------- | ---------- | -------------------------- |
| [build-error-resolver](build-error-resolver.md) | 构建修复   | TypeScript/JS 构建失败     |
| [go-build-resolver](go-build-resolver.md)       | Go构建修复 | Go 构建失败                |
| [e2e-runner](e2e-runner.md)                     | E2E测试    | 关键用户流程测试           |
| [refactor-cleaner](refactor-cleaner.md)         | 重构清理   | 死代码、重复项、未使用依赖 |
| [doc-updater](doc-updater.md)                   | 文档更新   | 代码映射、README、指南     |

### 专业领域智能体

| 智能体                                            | 角色         | 触发场景                     |
| ------------------------------------------------- | ------------ | ---------------------------- |
| [performance-optimizer](performance-optimizer.md) | 性能优化     | 性能瓶颈、优化建议           |
| [devops-engineer](devops-engineer.md)             | DevOps工程师 | CI/CD、基础设施、部署        |
| [qa-engineer](qa-engineer.md)                     | QA工程师     | 测试策略、质量保证           |
| [ml-engineer](ml-engineer.md)                     | ML工程师     | 模型训练、MLOps              |
| [mobile-developer](mobile-developer.md)           | 移动开发     | React Native/Flutter         |
| [data-engineer](data-engineer.md)                 | 数据工程师   | 数据管道、ETL                |
| [ux-designer](ux-designer.md)                     | UX设计师     | 用户体验、交互设计           |
| [cloud-architect](cloud-architect.md)             | 云架构师     | 云服务选型、成本优化         |
| [feedback-analyst](feedback-analyst.md)           | 反馈分析     | 调用分析、改进建议           |
| [git-workflow](git-workflow.md)                   | Git版本控制  | 分支策略、合并冲突、版本发布 |

## 快速开始

### 智能体模板

查看 [../trae-agents/](../trae-agents/) 目录获取可直接导入 Trae IDE 的智能体模板。

### 智能体协调

查看 [orchestrator.md](orchestrator.md) 了解完整的智能体协调指南，包括：

- 18个智能体的详细说明
- 任务分析与智能体选择
- 4种协作模式
- 标准工作流程
- 触发规则与决策树

### 常用工作流

```
功能开发：planner → architect → tdd-guide → code-reviewer → security-reviewer
Bug修复：tdd-guide → code-reviewer
代码审查：根据语言选择 reviewer → security-reviewer（如涉及安全）
构建失败：build-error-resolver / go-build-resolver
性能优化：performance-optimizer → code-reviewer
CI/CD配置：devops-engineer → security-reviewer
测试策略：qa-engineer → tdd-guide
版本控制：git-workflow → code-reviewer
机器学习：ml-engineer → devops-engineer
移动开发：mobile-developer → qa-engineer
数据管道：data-engineer → performance-optimizer
用户体验：ux-designer → code-reviewer
云架构：cloud-architect → devops-engineer
```

## 扩展指南

### 添加新智能体

1. 创建 `agents/<name>.md` 文件
2. 包含 frontmatter：`name`, `description`
3. 定义核心职责、工作流程
4. 更新本 README 和 [orchestrator.md](orchestrator.md)

### 智能体模板

```markdown
---
name: <name>
description: <简短描述，说明何时使用>
---

# <智能体名称>

<一句话使命说明>

## 核心职责

1. **职责1** — 描述
2. **职责2** — 描述

## 工作流程

### 1. 步骤1

### 2. 步骤2

## 协作说明

完成后委托给：

- **下一步1** → 使用 `agent-name` 智能体
```
