# Trae IDE 智能体模板

本目录包含可直接导入 Trae IDE 的智能体模板。每个模板为 Markdown 格式，方便复制粘贴。

## 模板格式

每个模板包含以下信息：

| 字段         | 说明                             |
| ------------ | -------------------------------- |
| **名称**     | 智能体显示名称                   |
| **标识名**   | 英文标识名，用于被其他智能体调用 |
| **描述**     | 智能体功能描述                   |
| **何时调用** | 触发条件，描述何时调用此智能体   |
| **工具配置** | 需要的 MCP 服务器和内置工具      |
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

### 核心智能体

| 智能体            | 标识名              | 用途                   | 文件                                         |
| ----------------- | ------------------- | ---------------------- | -------------------------------------------- |
| Orchestrator      | `orchestrator`      | 任务协调、多智能体协作 | [orchestrator.md](orchestrator.md)           |
| Architect         | `architect`         | 系统架构设计           | [architect.md](architect.md)                 |
| Planner           | `planner`           | 实施规划               | [planner.md](planner.md)                     |
| TDD Guide         | `tdd-guide`         | 测试驱动开发           | [tdd-guide.md](tdd-guide.md)                 |
| Code Reviewer     | `code-reviewer`     | TS/JS 代码审查         | [code-reviewer.md](code-reviewer.md)         |
| Security Reviewer | `security-reviewer` | 安全审查               | [security-reviewer.md](security-reviewer.md) |

### 语言特定审查器

| 智能体          | 标识名            | 语言   | 文件                                     |
| --------------- | ----------------- | ------ | ---------------------------------------- |
| Python Reviewer | `python-reviewer` | Python | [python-reviewer.md](python-reviewer.md) |
| Go Reviewer     | `go-reviewer`     | Go     | [go-reviewer.md](go-reviewer.md)         |
| Rust Reviewer   | `rust-reviewer`   | Rust   | [rust-reviewer.md](rust-reviewer.md)     |
| Swift Reviewer  | `swift-reviewer`  | Swift  | [swift-reviewer.md](swift-reviewer.md)   |
| Java Reviewer   | `java-reviewer`   | Java   | [java-reviewer.md](java-reviewer.md)     |
| Kotlin Reviewer | `kotlin-reviewer` | Kotlin | [kotlin-reviewer.md](kotlin-reviewer.md) |

### 专用智能体

| 智能体                | 标识名                  | 用途            | 文件                                                 |
| --------------------- | ----------------------- | --------------- | ---------------------------------------------------- |
| Build Error Resolver  | `build-error-resolver`  | 构建错误修复    | [build-error-resolver.md](build-error-resolver.md)   |
| Go Build Resolver     | `go-build-resolver`     | Go 构建错误修复 | [go-build-resolver.md](go-build-resolver.md)         |
| Database Reviewer     | `database-reviewer`     | 数据库审查      | [database-reviewer.md](database-reviewer.md)         |
| Performance Optimizer | `performance-optimizer` | 性能优化        | [performance-optimizer.md](performance-optimizer.md) |
| E2E Runner            | `e2e-runner`            | E2E 测试        | [e2e-runner.md](e2e-runner.md)                       |
| Refactor Cleaner      | `refactor-cleaner`      | 死代码清理      | [refactor-cleaner.md](refactor-cleaner.md)           |
| Doc Updater           | `doc-updater`           | 文档更新        | [doc-updater.md](doc-updater.md)                     |
| Feedback Analyst      | `feedback-analyst`      | 反馈分析        | [feedback-analyst.md](feedback-analyst.md)           |

### 专业领域智能体

| 智能体           | 标识名             | 用途         | 文件                                       |
| ---------------- | ------------------ | ------------ | ------------------------------------------ |
| DevOps Engineer  | `devops-engineer`  | CI/CD 和部署 | [devops-engineer.md](devops-engineer.md)   |
| QA Engineer      | `qa-engineer`      | 测试策略     | [qa-engineer.md](qa-engineer.md)           |
| ML Engineer      | `ml-engineer`      | 机器学习     | [ml-engineer.md](ml-engineer.md)           |
| Mobile Developer | `mobile-developer` | 移动开发     | [mobile-developer.md](mobile-developer.md) |
| Data Engineer    | `data-engineer`    | 数据管道     | [data-engineer.md](data-engineer.md)       |
| UX Designer      | `ux-designer`      | 用户体验     | [ux-designer.md](ux-designer.md)           |
| Cloud Architect  | `cloud-architect`  | 云架构       | [cloud-architect.md](cloud-architect.md)   |

### 版本控制智能体

| 智能体       | 标识名         | 用途         | 文件                               |
| ------------ | -------------- | ------------ | ---------------------------------- |
| Git Workflow | `git-workflow` | Git 版本控制 | [git-workflow.md](git-workflow.md) |

## 调用方式

### 手动调用

```
@security-reviewer 审查这段认证代码
@python-reviewer 检查这个函数
@architect 帮我设计微服务架构
```

### 自动调用

开启 **可被其他智能体调用** 后，SOLO Coder 会根据 **何时调用** 描述自动判断并调用。

## 可用工具

### MCP 服务器

| 服务器                | 用途              |
| --------------------- | ----------------- |
| `memory`              | 跨会话记忆        |
| `sequential-thinking` | 链式思维推理      |
| `context7`            | 实时文档查找      |
| `github`              | GitHub 操作       |
| `postgres`            | PostgreSQL 数据库 |
| `docker`              | Docker 操作       |
| `kubernetes`          | Kubernetes 操作   |

### 内置工具

| 工具         | 用途         |
| ------------ | ------------ |
| `read`       | 文件读取     |
| `filesystem` | 文件系统操作 |
| `terminal`   | 终端命令     |
| `web-search` | 网络搜索     |
| `preview`    | 预览         |

## 自定义修改

可根据项目需求修改模板：

1. **提示词定制** — 添加项目特定的规范和要求
2. **工具配置** — 根据需要启用/禁用工具
3. **触发条件** — 调整 **何时调用** 描述

## 相关文档

- [Trae 官方文档 - 智能体](https://docs.trae.ai/ide/agent?_lang=zh)
- [Trae 官方文档 - MCP](https://docs.trae.ai/ide/mcp?_lang=zh)
- [agents/README.md](../agents/README.md) — 原始智能体定义
- [agents/AGENT_WORKFLOW.md](../agents/AGENT_WORKFLOW.md) — 智能体调用关系图

## 智能体调用关系

### 调用链概览

```
用户请求 → orchestrator → planner/architect → tdd-guide → 实现 → reviewer → 测试 → doc-updater
```

### 标准工作流程

| 场景     | 调用链                                                              |
| -------- | ------------------------------------------------------------------- |
| 功能开发 | `planner` → `architect` → `tdd-guide` → `*-reviewer` → `e2e-runner` |
| Bug修复  | `tdd-guide` → `*-reviewer` → 验证                                   |
| 构建失败 | `build-error-resolver` / `go-build-resolver`                        |
| 代码审查 | 根据语言选择 `*-reviewer` → `security-reviewer`(如涉及安全)         |
| 性能优化 | `performance-optimizer` → 根据问题类型委托                          |

### 协作规则

每个智能体模板都包含 **协作说明** 部分，定义了：

1. **被调用时机** — 何时被其他智能体调用
2. **完成后委托** — 完成任务后应委托给哪个智能体

### 优先级规则

```
安全 > 功能 > 性能 > 样式
```

详细调用关系请参考 [agents/AGENT_WORKFLOW.md](../agents/AGENT_WORKFLOW.md)
