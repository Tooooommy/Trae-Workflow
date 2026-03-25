# 用户规则目录

> **优先级：最高** - 此目录中的规则优先级高于所有其他规则文件

## 目录索引

| 文件                                               | 说明            |
| -------------------------------------------------- | --------------- |
| [core-principles.md](core-principles.md)           | 核心原则（5条） |
| [project-config.md](project-config.md)             | 项目配置        |
| [coding-style.md](coding-style.md)                 | 代码规范        |
| [development-workflow.md](development-workflow.md) | 开发工作流      |
| [testing.md](testing.md)                           | 测试规范        |
| [security.md](security.md)                         | 安全规范        |
| [git-workflow.md](git-workflow.md)                 | Git 规范        |
| [patterns.md](patterns.md)                         | 架构模式        |
| [hooks.md](hooks.md)                               | Hooks 系统      |
| [performance.md](performance.md)                   | 性能优化        |

## 成功指标

- [x] 测试通过且覆盖率 80%+
- [x] 无安全漏洞
- [x] 代码可读可维护
- [x] 性能可接受

## 代码审查清单

- [ ] 符合编码风格
- [ ] 测试通过
- [ ] 覆盖率 >= 80%
- [ ] 无硬编码密钥
- [ ] 输入已验证
- [ ] 错误处理完善
- [ ] 性能/安全已评估

## 规则层级

```
user_rules/           ← 最高优先级
project_rules/<lang>/ ← 语言特定扩展
```

## 快速开始

1. **核心原则**：[core-principles.md](core-principles.md)
2. **开发流程**：[development-workflow.md](development-workflow.md)
3. **语言规则**：[project_rules/](../project_rules/)
4. **智能体**：[agents/README.md](../agents/README.md)
