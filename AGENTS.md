# 智能体调用关系图

本文档定义了各智能体之间的调用链和协作关系，确保任务能够高效、有序地完成。

## 智能体分类

### 🎯 协调层（Coordination Layer）

| 智能体         | 职责       | 调用时机               |
| -------------- | ---------- | ---------------------- |
| `orchestrator` | 中央协调器 | 复杂任务、多智能体协作 |
| `planner`      | 实施规划   | 功能实现、架构变更     |

### 🏗️ 架构层（Architecture Layer）

| 智能体            | 职责         | 调用时机             |
| ----------------- | ------------ | -------------------- |
| `architect`       | 系统架构设计 | 新功能设计、架构决策 |
| `cloud-architect` | 云架构设计   | 云服务选型、成本优化 |

### 🔍 审查层（Review Layer）

| 智能体              | 职责            | 调用时机                       |
| ------------------- | --------------- | ------------------------------ |
| `code-reviewer`     | TS/JS 代码审查  | TypeScript/JavaScript 代码变更 |
| `python-reviewer`   | Python 代码审查 | Python 代码变更                |
| `go-reviewer`       | Go 代码审查     | Go 代码变更                    |
| `rust-reviewer`     | Rust 代码审查   | Rust 代码变更                  |
| `swift-reviewer`    | Swift 代码审查  | Swift/iOS 代码变更             |
| `java-reviewer`     | Java 代码审查   | Java 代码变更                  |
| `kotlin-reviewer`   | Kotlin 代码审查 | Kotlin 代码变更                |
| `security-reviewer` | 安全审查        | 用户输入、认证、敏感数据       |
| `database-reviewer` | 数据库审查      | SQL、迁移、模式设计            |

### 🔧 修复层（Fix Layer）

| 智能体                 | 职责         | 调用时机           |
| ---------------------- | ------------ | ------------------ |
| `build-error-resolver` | 构建错误修复 | TS/JS 构建失败     |
| `go-build-resolver`    | Go 构建修复  | Go 构建失败        |
| `refactor-cleaner`     | 代码清理     | 死代码、重复项清理 |

### 🧪 测试层（Testing Layer）

| 智能体        | 职责         | 调用时机              |
| ------------- | ------------ | --------------------- |
| `tdd-guide`   | TDD 开发指导 | 新功能、Bug修复、重构 |
| `qa-engineer` | 测试策略     | 测试计划、质量保证    |
| `e2e-runner`  | E2E 测试     | 关键用户流程测试      |

### 🚀 部署层（Deployment Layer）

| 智能体            | 职责         | 调用时机           |
| ----------------- | ------------ | ------------------ |
| `devops-engineer` | CI/CD 和部署 | 部署配置、基础设施 |

### 🎨 专业层（Specialist Layer）

| 智能体                  | 职责     | 调用时机             |
| ----------------------- | -------- | -------------------- |
| `performance-optimizer` | 性能优化 | 性能瓶颈分析         |
| `ml-engineer`           | 机器学习 | 模型训练、MLOps      |
| `mobile-developer`      | 移动开发 | React Native/Flutter |
| `data-engineer`         | 数据工程 | 数据管道、ETL        |
| `ux-designer`           | UX 设计  | 用户体验、交互设计   |

### 📚 支持层（Support Layer）

| 智能体             | 职责     | 调用时机              |
| ------------------ | -------- | --------------------- |
| `doc-updater`      | 文档更新 | 代码映射、README 更新 |
| `feedback-analyst` | 反馈分析 | 使用分析、改进建议    |

### 🔄 版本控制层（Version Control Layer）

| 智能体         | 职责         | 调用时机                     |
| -------------- | ------------ | ---------------------------- |
| `git-workflow` | Git 版本控制 | 分支策略、合并冲突、版本发布 |

---

## 标准调用链

### 1. 功能开发流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      功能开发标准流程                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  用户请求 ──→ orchestrator ──→ planner                          │
│                                │                                │
│                                ▼                                │
│                           architect (如需架构设计)               │
│                                │                                │
│                                ▼                                │
│                            tdd-guide                            │
│                                │                                │
│                                ▼                                │
│                         [实现代码]                               │
│                                │                                │
│                                ▼                                │
│                    ┌─── 根据语言选择 reviewer ───┐               │
│                    │                            │               │
│                    ▼                            ▼               │
│              code-reviewer              python-reviewer         │
│              go-reviewer                rust-reviewer           │
│              java-reviewer              swift-reviewer          │
│              kotlin-reviewer                                    │
│                    │                                            │
│                    ▼                                            │
│           security-reviewer (如涉及安全)                         │
│                    │                                            │
│                    ▼                                            │
│           database-reviewer (如涉及数据库)                       │
│                    │                                            │
│                    ▼                                            │
│              e2e-runner (关键流程)                               │
│                    │                                            │
│                    ▼                                            │
│              doc-updater                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Bug 修复流程

```
┌─────────────────────────────────────────────────────────────────┐
│                       Bug 修复标准流程                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Bug 报告 ──→ tdd-guide ──→ [编写失败测试]                      │
│                  │                                              │
│                  ▼                                              │
│             [修复代码]                                           │
│                  │                                              │
│                  ▼                                              │
│         根据语言选择 reviewer                                    │
│                  │                                              │
│                  ▼                                              │
│         security-reviewer (如涉及安全)                           │
│                  │                                              │
│                  ▼                                              │
│         [验证修复]                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3. 构建失败流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      构建失败修复流程                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  构建失败 ──→ 根据语言选择 ──┬── build-error-resolver (TS/JS)   │
│                              ├── go-build-resolver (Go)         │
│                              └── build-error-resolver (其他)    │
│                                        │                        │
│                                        ▼                        │
│                                  [修复错误]                      │
│                                        │                        │
│                                        ▼                        │
│                                  [验证构建]                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4. 代码审查流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      代码审查标准流程                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  代码变更 ──→ 根据语言选择 reviewer                              │
│                  │                                              │
│                  ├─────────────────────────────────┐            │
│                  │                                 │            │
│                  ▼                                 ▼            │
│         是否涉及安全？                      是否涉及数据库？      │
│                  │                                 │            │
│          ┌───────┴───────┐                ┌───────┴───────┐    │
│          ▼               ▼                ▼               ▼    │
│         是              否               是              否     │
│          │               │                │               │    │
│          ▼               │                ▼               │    │
│  security-reviewer       │       database-reviewer       │    │
│          │               │                │               │    │
│          └───────────────┴────────────────┴───────────────┘    │
│                                  │                              │
│                                  ▼                              │
│                            审查报告                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5. 性能优化流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      性能优化标准流程                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  性能问题 ──→ performance-optimizer ──→ 分析瓶颈                │
│                      │                                          │
│                      ▼                                          │
│              问题类型判断                                         │
│                      │                                          │
│         ┌────────────┼────────────┐                             │
│         ▼            ▼            ▼                             │
│     代码问题     数据库问题    架构问题                           │
│         │            │            │                             │
│         ▼            ▼            ▼                             │
│  code-reviewer  database-   architect                          │
│     (按语言)     reviewer                                        │
│         │            │            │                             │
│         └────────────┼────────────┘                             │
│                      ▼                                          │
│              [实施优化]                                          │
│                      │                                          │
│                      ▼                                          │
│              [验证效果]                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 协作规则

### 优先级规则

```
安全 > 功能 > 性能 > 样式
```

当多个智能体提供冲突建议时：

1. **安全相关** — 最高优先级，必须解决
2. **功能相关** — 次高优先级，影响用户
3. **性能相关** — 中等优先级，可后续优化
4. **样式相关** — 最低优先级，可选改进

### 语言选择规则

| 语言                  | 代码审查          | 构建修复               | 测试框架     |
| --------------------- | ----------------- | ---------------------- | ------------ |
| TypeScript/JavaScript | `code-reviewer`   | `build-error-resolver` | Jest, Vitest |
| Python                | `python-reviewer` | `build-error-resolver` | pytest       |
| Go                    | `go-reviewer`     | `go-build-resolver`    | go test      |
| Rust                  | `rust-reviewer`   | `build-error-resolver` | cargo test   |
| Swift                 | `swift-reviewer`  | `build-error-resolver` | XCTest       |
| Java                  | `java-reviewer`   | `build-error-resolver` | JUnit        |
| Kotlin                | `kotlin-reviewer` | `build-error-resolver` | JUnit        |

### 条件调用规则

| 条件             | 触发智能体              |
| ---------------- | ----------------------- |
| 涉及用户输入     | `security-reviewer`     |
| 涉及认证/授权    | `security-reviewer`     |
| 涉及敏感数据     | `security-reviewer`     |
| 涉及 SQL/数据库  | `database-reviewer`     |
| 涉及 API 端点    | `security-reviewer`     |
| 涉及文件上传     | `security-reviewer`     |
| 涉及支付功能     | `security-reviewer`     |
| 涉及关键用户流程 | `e2e-runner`            |
| 涉及性能问题     | `performance-optimizer` |
| 涉及 CI/CD       | `devops-engineer`       |
| 涉及云服务       | `cloud-architect`       |
| 涉及分支管理     | `git-workflow`          |
| 涉及合并冲突     | `git-workflow`          |
| 涉及版本发布     | `git-workflow`          |

---

## 智能体依赖关系图

```
                    ┌─────────────────┐
                    │   orchestrator  │
                    │   (中央协调器)   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
        ┌─────────┐   ┌───────────┐   ┌─────────┐
        │ planner │   │ architect │   │  tdd-   │
        │ (规划)  │   │  (架构)   │   │ guide   │
        └────┬────┘   └─────┬─────┘   └────┬────┘
             │              │              │
             │              │              │
             └──────────────┼──────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │      实现代码           │
              └────────────┬────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
         ▼                 ▼                 ▼
   ┌───────────┐    ┌───────────┐    ┌───────────┐
   │  Review   │    │  Review   │    │  Review   │
   │  (按语言) │    │ (安全)    │    │ (数据库)  │
   └─────┬─────┘    └─────┬─────┘    └─────┬─────┘
         │                 │                 │
         └─────────────────┼─────────────────┘
                           │
                           ▼
              ┌─────────────────────────┐
              │       e2e-runner        │
              │     (关键流程测试)       │
              └────────────┬────────────┘
                           │
                           ▼
              ┌─────────────────────────┐
              │      doc-updater        │
              │       (文档更新)         │
              └─────────────────────────┘
```

---

## 后续委托规则

每个智能体完成任务后，应根据情况委托给下一个智能体：

### 代码审查类

| 完成后       | 委托条件       | 委托目标               |
| ------------ | -------------- | ---------------------- |
| `*-reviewer` | 发现安全问题   | `security-reviewer`    |
| `*-reviewer` | 发现数据库问题 | `database-reviewer`    |
| `*-reviewer` | 发现构建错误   | `build-error-resolver` |
| `*-reviewer` | 需要重构       | `refactor-cleaner`     |

### 开发类

| 完成后      | 委托条件 | 委托目标                |
| ----------- | -------- | ----------------------- |
| `architect` | 需要实施 | `planner` → `tdd-guide` |
| `planner`   | 需要开发 | `tdd-guide`             |
| `tdd-guide` | 代码完成 | 对应语言 `reviewer`     |

### 测试类

| 完成后        | 委托条件 | 委托目标            |
| ------------- | -------- | ------------------- |
| `qa-engineer` | 需要修复 | `tdd-guide`         |
| `e2e-runner`  | 测试失败 | 对应语言 `reviewer` |

### 部署类

| 完成后            | 委托条件     | 委托目标            |
| ----------------- | ------------ | ------------------- |
| `devops-engineer` | 需要安全审查 | `security-reviewer` |
| `devops-engineer` | 需要文档     | `doc-updater`       |

### 专业类

| 完成后                  | 委托条件   | 委托目标                |
| ----------------------- | ---------- | ----------------------- |
| `performance-optimizer` | 代码优化   | 对应语言 `reviewer`     |
| `performance-optimizer` | 数据库优化 | `database-reviewer`     |
| `performance-optimizer` | 架构调整   | `architect`             |
| `ml-engineer`           | API 集成   | `code-reviewer`         |
| `ml-engineer`           | 部署配置   | `devops-engineer`       |
| `mobile-developer`      | API 集成   | `code-reviewer`         |
| `mobile-developer`      | 安全审查   | `security-reviewer`     |
| `data-engineer`         | 性能优化   | `performance-optimizer` |
| `data-engineer`         | 安全审查   | `security-reviewer`     |
| `cloud-architect`       | 安全审查   | `security-reviewer`     |
| `cloud-architect`       | 部署实施   | `devops-engineer`       |
| `ux-designer`           | 前端实现   | `code-reviewer`         |
| `ux-designer`           | 测试验证   | `qa-engineer`           |

### 版本控制类

| 完成后            | 委托条件         | 委托目标                     |
| ----------------- | ---------------- | ---------------------------- |
| `git-workflow`    | 代码需要审查     | 对应语言 `*-reviewer`        |
| `git-workflow`    | 合并后需要测试   | `qa-engineer` / `e2e-runner` |
| `git-workflow`    | 发布需要部署     | `devops-engineer`            |
| `git-workflow`    | 需要更新文档     | `doc-updater`                |
| `*-reviewer`      | 审查通过准备合并 | `git-workflow`               |
| `devops-engineer` | 部署完成准备发布 | `git-workflow`               |

---

## 最佳实践

### 1. 避免循环调用

```
❌ 错误：A → B → A
✅ 正确：A → B → C → 完成
```

### 2. 保持调用链简洁

```
❌ 错误：orchestrator → planner → architect → planner → tdd-guide
✅ 正确：orchestrator → planner → architect → tdd-guide
```

### 3. 条件判断前置

在调用前判断是否需要调用下一个智能体，避免不必要的调用。

### 4. 上下文传递

在智能体之间传递必要的上下文信息，避免重复分析。

### 5. 错误处理

当某个智能体无法完成任务时，应回退到上一个智能体或报告给 `orchestrator`。
