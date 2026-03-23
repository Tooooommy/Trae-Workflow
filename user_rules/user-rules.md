# 用户规则目录

> **优先级：最高** - 此目录中的规则优先级高于所有其他规则文件

---

## 目录索引

| 文件                                               | 说明                         |
| -------------------------------------------------- | ---------------------------- |
| [core-principles.md](core-principles.md)           | 核心原则（5条）              |
| [project-config.md](project-config.md)             | 项目配置（技术栈、性能目标） |
| [coding-style.md](coding-style.md)                 | 代码规范                     |
| [development-workflow.md](development-workflow.md) | 开发工作流                   |
| [testing.md](testing.md)                           | 测试规范                     |
| [security.md](security.md)                         | 安全规范                     |
| [git-workflow.md](git-workflow.md)                 | Git 规范                     |
| [patterns.md](patterns.md)                         | 架构模式                     |
| [hooks.md](hooks.md)                               | Hooks 系统                   |
| [performance.md](performance.md)                   | 性能优化                     |

---

## 成功指标

- [x] 所有测试通过且覆盖率 80%+
- [x] 没有安全漏洞
- [x] 代码可读且可维护
- [x] 性能可接受
- [x] 满足用户需求

---

## 代码审查清单

在提交代码之前，确保：

- [ ] 代码符合项目编码风格
- [ ] 所有测试通过
- [ ] 测试覆盖率 >= 80%
- [ ] 没有硬编码的密钥或敏感信息
- [ ] 所有用户输入都经过验证
- [ ] 错误处理完善
- [ ] 代码有适当的注释
- [ ] 文档已更新（如需要）
- [ ] 性能影响已评估
- [ ] 安全影响已评估

---

## 规则层级

```
user_rules/           ← 最高优先级（项目配置）
    ↓
project_rules/<lang>/ ← 语言特定扩展
```

当规则冲突时，优先级高的规则生效。

---

## 快速开始

1. **查看成功指标**：本文档
2. **了解核心原则**：[core-principles.md](core-principles.md)
3. **查看开发流程**：[development-workflow.md](development-workflow.md)
4. **选择语言特定规则**：[project_rules/](../project_rules/)
5. **了解智能体系统**：[agents/README.md](../agents/README.md)

---

## 核心原则

| #   | 原则             | 说明                             |
| --- | ---------------- | -------------------------------- |
| 1   | **智能体优先**   | 将领域任务委托给专业智能体       |
| 2   | **测试驱动**     | 先写测试再实现，要求 80%+ 覆盖率 |
| 3   | **安全第一**     | 绝不妥协安全；验证所有输入       |
| 4   | **不可变性**     | 总是创建新对象，永不修改现有对象 |
| 5   | **先规划后执行** | 在编写代码前规划复杂功能         |

---

## 标准工作流

```
1. 规划 → 使用 planner 智能体，识别依赖项和风险，分解为阶段
2. TDD  → 使用 testing-expert 智能体，先写测试，实现，重构
3. 审查 → 立即使用 reviewer 智能体，解决 CRITICAL/HIGH 问题
4. 提交 → 约定式提交格式，全面的 PR 摘要
```

---

## 智能体协作

所有智能体遵循统一的协作模式：

| 任务     | 委托目标            |
| -------- | ------------------- |
| 功能规划 | `planner`           |
| 架构设计 | `architect`         |
| 测试策略 | `testing-expert`    |
| 安全审查 | `security-reviewer` |
| DevOps   | `devops-expert`     |

---

## 相关文档

- [智能体系统](../agents/README.md)
- [技能系统](../skills/README.md)
- [项目规则](../project_rules/README.md)
