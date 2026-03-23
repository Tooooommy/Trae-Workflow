# 智能体系统

Trae Workflow 提供了一套完整的智能体系统，基于 **MCP-Rules-Skills-Agents** 四层架构，涵盖软件开发的各个方面。

## 🎯 架构分层

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

## 📊 智能体分类

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

| 智能体                                  | 角色         | 触发场景                 |
| --------------------------------------- | ------------ | ------------------------ |
| [tdd-guide](testing/tdd-guide.md)       | TDD 专家     | 测试驱动开发、单元测试   |
| [e2e-tester](testing/e2e-tester.md)     | E2E 测试专家 | 端到端测试、用户流程测试 |
| [code-quality](testing/code-quality.md) | 代码质量专家 | 代码审查、重构清理       |

### 🔒 安全与审查 (Security)

| 智能体                                             | 角色         | 触发场景                     |
| -------------------------------------------------- | ------------ | ---------------------------- |
| [security-reviewer](security/security-reviewer.md) | 安全专家     | 漏洞检测、密钥检测、安全审查 |
| [api-designer](security/api-designer.md)           | API 设计专家 | API 设计、安全考虑           |
| [database-expert](security/database-expert.md)     | 数据库专家   | 数据库安全、性能优化         |

### 🚀 DevOps 与部署 (DevOps)

| 智能体                               | 角色        | 触发场景           |
| ------------------------------------ | ----------- | ------------------ |
| [devops](devops/devops.md)           | DevOps 专家 | CI/CD、部署、监控  |
| [git-expert](devops/git-expert.md)   | Git 专家    | 版本控制、分支策略 |
| [performance](devops/performance.md) | 性能专家    | 性能优化、瓶颈分析 |

### 📊 代码质量 (Quality)

| 智能体                                | 角色     | 触发场景           |
| ------------------------------------- | -------- | ------------------ |
| [reviewer](quality/reviewer.md)       | 审查专家 | 代码审查、最佳实践 |
| [doc-updater](quality/doc-updater.md) | 文档专家 | 文档更新、API 文档 |

### � 工具与实用程序 (Utilities)

| 智能体                                                    | 角色             | 触发场景           |
| --------------------------------------------------------- | ---------------- | ------------------ |
| [build-error-resolver](utilities/build-error-resolver.md) | 构建错误解决专家 | 构建失败、依赖问题 |
| [systematic-debugging](utilities/systematic-debugging.md) | 系统调试专家     | 复杂问题调试       |
| [brainstorming](utilities/brainstorming.md)               | 头脑风暴专家     | 创意生成、方案探索 |

## 🔄 协同工作流程

### 开发新功能

1. **规划阶段**：使用 `planner` 进行功能规划
2. **架构设计**：使用 `architect` 进行架构设计
3. **开发实现**：使用语言特定智能体（如 `typescript-dev`）
4. **测试驱动**：使用 `tdd-guide` 遵循 TDD 工作流
5. **代码审查**：使用 `reviewer` 进行代码审查
6. **安全审查**：使用 `security-reviewer` 进行安全审查
7. **文档更新**：使用 `doc-updater` 更新文档

### 架构决策

1. **技术调研**：使用 `researcher` 进行技术调研
2. **架构设计**：使用 `architect` 进行架构设计
3. **风险评估**：使用 `planner` 进行风险评估
4. **实施规划**：制定详细的实施计划

## 🛠️ 技能引用

每个智能体都引用相关的技能，确保：

- **Rules 层**：定义要求和约束
- **Skills 层**：提供详细的实现模式
- **Agents 层**：定义专家角色和工作流

## 📖 详细文档

- [规划与设计智能体](planning/) - 规划、架构、调研专家
- [开发与编码智能体](development/) - 语言特定开发专家
- [测试与质量智能体](testing/) - 测试和质量保证专家
- [安全与审查智能体](security/) - 安全和审查专家
- [DevOps 与部署智能体](devops/) - DevOps 和部署专家
- [代码质量智能体](quality/) - 代码质量和文档专家
- [工具与实用程序智能体](utilities/) - 工具和实用程序专家

---

**架构理念**：MCP 管"连接"，Rules 管"边界"，Skills 管"动作"，Agent 管"决策与执行"。它们从底层到高层，共同构成了一个完整的智能系统。
