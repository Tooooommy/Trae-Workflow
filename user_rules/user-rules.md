# 用户规则

> **优先级：最高** - 此目录中的规则优先级高于所有其他规则文件

---

## 目录索引

| 文件                                               | 说明                         |
| -------------------------------------------------- | ---------------------------- |
| [core-principles.md](core-principles.md)           | 核心原则（5条）              |
| [project-config.md](project-config.md)             | 项目配置（技术栈、性能目标） |
| [agents.md](agents.md)                             | 智能体系统                   |
| [development-workflow.md](development-workflow.md) | 开发工作流                   |
| [coding-style.md](coding-style.md)                 | 代码规范                     |
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
