# Agents 智能体系统

> 基于角色分工的 AI 智能体协作系统，用于软件开发全生命周期管理。

## 智能体概览

本项目包含 **10 个专业智能体**，覆盖软件开发的各个方面。通过整合相似职责的智能体，减少重复，提高可维护性。

### 核心智能体

| 智能体                              | 角色     | 触发场景                     |
| ----------------------------------- | -------- | ---------------------------- |
| [orchestrator](orchestrator.md)     | 协调器   | 复杂任务、多智能体协作       |
| [planner](planner.md)               | 规划师   | 功能实现、架构变更、复杂重构 |
| [architect](architect.md)           | 架构师   | 系统设计、技术决策、云架构   |
| [code-reviewer](code-reviewer.md)   | 代码审查 | 所有代码变更（多语言支持）   |
| [build-resolver](build-resolver.md) | 构建修复 | 构建失败、类型错误（多语言） |
| [qa](qa.md)                         | QA工程师 | 测试策略、TDD、E2E测试       |
| [devops](devops.md)                 | DevOps   | CI/CD、Git工作流、部署自动化 |
| [fullstack](fullstack.md)           | 全栈专家 | ML、移动、数据、UX、反馈分析 |

## 智能体职责

### orchestrator

智能体协调器，负责分析复杂任务并协调多个智能体协作完成。当任务涉及多个领域、需要多步骤协作或不确定使用哪个智能体时使用。

### planner

复杂功能和重构的专家规划专家。当用户请求功能实现、架构变更或复杂重构时，请主动使用。计划任务自动激活。

### architect

软件架构专家，整合系统设计、云架构和技术决策能力。负责设计可扩展系统架构、评估技术权衡、推荐模式和最佳实践、进行云服务选型和成本优化。在规划新功能、重构大型系统或进行架构决策时主动使用。

### code-reviewer

专业代码审查专家，整合多语言审查能力。主动审查代码的质量、安全性和可维护性。支持 Python、Go、Rust、Swift、Java、Kotlin、TypeScript/JavaScript。在编写或修改代码后立即使用。

### build-resolver

构建错误解决专家，整合多语言构建问题修复能力。支持 TypeScript/JavaScript、Python、Go、Rust、Swift、Java/Kotlin 等语言的构建错误、类型错误、lint 警告。以最小改动修复问题，专注于快速使构建通过。

### qa

QA工程师专家，整合测试策略、TDD实践和E2E测试能力。负责测试策略设计、测试驱动开发、端到端测试、测试自动化。在编写新功能、修复错误或重构代码时主动使用。

### devops

DevOps 和 Git 工作流专家，整合 CI/CD、基础设施、部署自动化和版本控制能力。负责设计 CI/CD 流水线、管理基础设施即代码、处理 Git 分支策略和合并冲突、自动化部署和回滚。

### fullstack

全栈开发专家，整合机器学习、移动开发、数据工程、UX设计和反馈分析能力。负责机器学习模型训练部署、React Native/Flutter移动开发、数据管道ETL设计、用户体验设计、分析用户反馈数据。在涉及这些专业领域时主动使用。

## 快速开始

### 智能体模板

查看 [../trae-agents/](../trae-agents/) 目录获取可直接导入 Trae IDE 的智能体模板。

### 智能体协调

查看 [orchestrator.md](orchestrator.md) 了解完整的智能体协调指南。

### 常用工作流

```
功能开发：planner → architect → qa(code) → code-reviewer
Bug修复：qa(tdd) → code-reviewer
构建失败：build-resolver
代码审查：code-reviewer（自动识别语言）
测试策略：qa
CI/CD配置：devops
版本控制：devops(git)
机器学习：fullstack(ml)
移动开发：fullstack(mobile)
数据管道：fullstack(data)
用户体验：fullstack(ux)
云架构：architect
```

## 合并历史

| 原智能体                                           | 合并到         | 原因           |
| -------------------------------------------------- | -------------- | -------------- |
| python/go/rust/swift/java/kotlin-reviewer          | code-reviewer  | 多语言整合     |
| go-build-resolver                                  | build-resolver | 多语言整合     |
| tdd-guide + e2e-runner                             | qa             | 测试能力整合   |
| devops-engineer + git-workflow                     | devops         | DevOps+Git整合 |
| cloud-architect                                    | architect      | 架构能力整合   |
| ml/mobile/data/ux/feedback-engineer                | fullstack      | 全栈能力整合   |
| security/database/refactor/performance/doc-updater | 保留独立       | 职责独特       |

## 扩展指南

### 添加新智能体

1. 创建 `agents/<name>.md` 文件
2. 包含 frontmatter：`name`, `description`, `mcp_servers`, `builtin_tools`
3. 定义核心职责、工作流程
4. 更新本 README 和 [orchestrator.md](orchestrator.md)

### 智能体模板

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

<一句话使命说明>

## 核心职责

1. **职责1** — 描述
2. **职责2** — 描述

## 工作流程

### 1. 步骤1
```
