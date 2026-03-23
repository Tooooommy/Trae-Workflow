# 用户规则目录

> **优先级：最高** - 此目录中的规则优先级高于所有其他规则文件

---

## 目录结构

```
user_rules/
├── user-rules.md          # 主文件：成功指标、审查清单
├── core-principles.md     # 核心原则（5条）
├── project-config.md      # 项目配置（技术栈、性能目标）
├── coding-style.md        # 代码规范
├── development-workflow.md # 开发工作流
├── testing.md             # 测试规范
├── security.md            # 安全规范
├── git-workflow.md        # Git 规范
├── patterns.md            # 架构模式
├── hooks.md              # Hooks 系统
├── performance.md        # 性能优化
└── agent-invocation.md   # Agent 调用规则
```

---

## 文件说明

| 文件                                               | 内容                           |
| -------------------------------------------------- | ------------------------------ |
| [user-rules.md](user-rules.md)                     | 主文件：成功指标、代码审查清单 |
| [core-principles.md](core-principles.md)           | 核心原则（5条）                |
| [project-config.md](project-config.md)             | 技术栈、性能目标               |
| [coding-style.md](coding-style.md)                 | 代码格式、命名规范             |
| [development-workflow.md](development-workflow.md) | 详细开发流程                   |
| [testing.md](testing.md)                           | TDD 流程、测试策略             |
| [security.md](security.md)                         | 检查清单、处理流程             |
| [git-workflow.md](git-workflow.md)                 | PR 工作流                      |
| [patterns.md](patterns.md)                         | 模式详细说明                   |
| [hooks.md](hooks.md)                               | Hooks 系统                     |
| [performance.md](performance.md)                   | 性能优化配置                   |
| [agent-invocation.md](agent-invocation.md)         | Agent 调用规则和规范           |

---

## 规则层级

```
user_rules/           ← 最高优先级（项目通用规则）
    ↓
project_rules/<lang>/ ← 语言/框架特定扩展
```

**层级说明**：
- `user_rules/` 是项目通用规则，适用于所有项目
- `project_rules/<lang>/` 是语言特定扩展，继承并覆盖通用规则
- 当规则冲突时，优先级高的规则生效

**与 Skills 的关系**：
- Rules 定义「行为规范和约束」
- Skills 定义「具体可执行的能力」
- Agents 使用 Rules 约束 + Skills 能力来完成任务

---

## 快速开始

1. **查看成功指标**：[user-rules.md](user-rules.md)
2. **了解核心原则**：[core-principles.md](core-principles.md)
3. **查看开发流程**：[development-workflow.md](development-workflow.md)
4. **学习 Agent 调用**：[agent-invocation.md](agent-invocation.md)
5. **选择语言特定规则**：[project_rules/](../project_rules/)
6. **了解智能体系统**：[agents/orchestrator.md](../agents/orchestrator.md)
