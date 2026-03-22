# Trae IDE 智能体模板

本目录包含可直接导入 Trae IDE 的智能体模板。通过合并相似职责的智能体，提供 **10 个核心智能体**，覆盖软件开发全流程。

## 合并说明

为减少重复、提高可维护性，原 28 个智能体已合并为 10 个核心智能体：

| 合并前               | 合并后         | 原因           |
| -------------------- | -------------- | -------------- |
| 6个语言审查器        | code-reviewer  | 多语言整合     |
| 2个构建修复器        | build-resolver | 多语言整合     |
| TDD + E2E            | qa             | 测试能力整合   |
| DevOps + Git         | devops         | DevOps+Git整合 |
| 架构 + 云架构        | architect      | 架构能力整合   |
| ML/移动/数据/UX/反馈 | fullstack      | 全栈能力整合   |

## 模板格式

每个模板包含以下信息：

| 字段         | 说明                             |
| ------------ | -------------------------------- |
| **名称**     | 智能体显示名称                   |
| **标识名**   | 英文标识名，用于被其他智能体调用 |
| **描述**     | 智能体功能描述                   |
| **何时调用** | 触发条件                         |
| **工具配置** | MCP 服务器和内置工具             |
| **提示词**   | 智能体提示词                     |

## 使用方法

### 步骤 1：打开模板文件

选择需要的智能体模板文件（.md 格式）

### 步骤 2：在 Trae IDE 中创建智能体

1. 打开 Trae IDE
2. 在 AI 对话输入框中输入 `@`
3. 点击 **创建智能体** 按钮

### 步骤 3：复制粘贴内容

从模板文件复制以下内容到对应字段：

| 模板字段 | Trae IDE 字段                            |
| -------- | ---------------------------------------- |
| 名称     | 名称                                     |
| 提示词   | 提示词                                   |
| 何时调用 | 何时调用                                 |
| 标识名   | 英文标识名（需开启"可被其他智能体调用"） |

### 步骤 4：配置选项

1. 开启 **可被其他智能体调用** 选项
2. 输入 **标识名** 作为英文标识名
3. 根据需要配置工具
4. 点击 **创建**

## 智能体列表

### 核心智能体（10个）

| 智能体         | 标识名           | 用途                   | 文件                                   |
| -------------- | ---------------- | ---------------------- | -------------------------------------- |
| Orchestrator   | `orchestrator`   | 任务协调、多智能体协作 | [orchestrator.md](orchestrator.md)     |
| Planner        | `planner`        | 实施规划               | [planner.md](planner.md)               |
| Architect      | `architect`      | 系统架构、云架构设计   | [architect.md](architect.md)           |
| Code Reviewer  | `code-reviewer`  | 多语言代码审查         | [code-reviewer.md](code-reviewer.md)   |
| Build Resolver | `build-resolver` | 多语言构建错误修复     | [build-resolver.md](build-resolver.md) |
| QA             | `qa`             | 测试策略、TDD、E2E测试 | [qa.md](qa.md)                         |
| DevOps         | `devops`         | CI/CD、Git工作流、部署 | [devops.md](devops.md)                 |
| Fullstack      | `fullstack`      | ML、移动、数据、UX     | [fullstack.md](fullstack.md)           |

### 保留的独立智能体

以下智能体因职责独特未被合并：

| 智能体                | 标识名                  | 用途           |
| --------------------- | ----------------------- | -------------- |
| Security Reviewer     | `security-reviewer`     | 安全漏洞检测   |
| Database Reviewer     | `database-reviewer`     | PostgreSQL优化 |
| Performance Optimizer | `performance-optimizer` | 性能瓶颈分析   |
| Refactor Cleaner      | `refactor-cleaner`      | 死代码清理     |
| Doc Updater           | `doc-updater`           | 文档同步       |

## 调用方式

### 手动调用

```
@code-reviewer 审查这段代码
@build-resolver 修复构建错误
@qa 帮我写单元测试
@architect 设计微服务架构
```

### 自动调用

开启 **可被其他智能体调用** 后，系统会根据 **何时调用** 描述自动判断并调用。

## 常用工作流

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
