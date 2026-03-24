# 智能体系统

Trae Workflow 提供了一套精简高效的智能体系统，专为个人开发者设计。

## 🎯 设计理念

- **精简高效**：从 27 个智能体精简为 17 个核心智能体
- **功能整合**：合并相似功能，减少切换成本
- **语言全覆盖**：保留所有主流语言的开发智能体
- **易于使用**：清晰的职责划分，快速找到合适的智能体

## 📊 智能体分类

### 🎯 规划与设计

| 智能体    | 描述                                 | 触发场景                       |
| --------- | ------------------------------------ | ------------------------------ |
| planner   | 功能规划专家，负责需求分析、任务分解 | 新功能开发、架构变更、复杂重构 |
| architect | 软件架构专家，负责系统设计、技术选型 | 规划新功能、重构大型系统       |

### 💻 开发与编码

| 智能体           | 描述                           | 触发场景              |
| ---------------- | ------------------------------ | --------------------- |
| typescript-dev   | TypeScript/JavaScript 开发专家 | TS/JS/React/Node.js   |
| python-dev       | Python 开发专家                | Python/FastAPI/Django |
| golang-dev       | Go 开发专家                    | Go 语言开发           |
| ios-native       | iOS 开发专家                   | iOS/macOS             |
| react-native-dev | React Native 开发专家          | React Native 跨平台   |
| android-native   | Android 开发专家               | Android/Compose       |

### 🧪 测试与质量

| 智能体         | 描述                              | 触发场景          |
| -------------- | --------------------------------- | ----------------- |
| testing-expert | 测试专家，整合 TDD、E2E、代码质量 | TDD、E2E 测试     |
| tdd-guide      | TDD 工作流专家，引导红-绿-重构    | TDD 流程、覆盖率  |
| code-reviewer  | 代码审查专家                      | PR 审查、代码质量 |

### 🔧 错误解决

| 智能体               | 描述                                 | 触发场景           |
| -------------------- | ------------------------------------ | ------------------ |
| build-error-resolver | 构建错误解决专家，分析编译/依赖错误  | 构建失败、编译错误 |
| security-reviewer    | 安全漏洞检测专家                     | 安全审查、漏洞检测 |
| devops-expert        | DevOps 专家，整合 CI/CD、Git、Docker | CI/CD、部署、监控  |

### 🎨 专家智能体

| 智能体          | 描述                                | 触发场景            |
| --------------- | ----------------------------------- | ------------------- |
| backend-expert  | 后端专家，整合 API 设计、数据库优化 | API 设计、数据库    |
| frontend-expert | 前端专家                            | React/Vue、状态管理 |
| doc-expert      | 文档专家                            | 文档编写、API 文档  |
| analytics-agent | 数据分析专家，追踪使用数据生成报告  | 数据分析、使用追踪  |

## 🔄 标准工作流

### 开发新功能

1. **规划阶段**：使用 `planner` 进行功能规划
2. **架构设计**：使用 `architect` 进行架构设计
3. **TDD 实现**：使用 `tdd-guide` 引导测试驱动开发
4. **开发实现**：使用语言特定智能体（如 `typescript-dev`）
5. **代码审查**：使用 `code-reviewer` 审查代码
6. **构建验证**：使用 `build-error-resolver` 解决构建问题
7. **安全审查**：使用 `security-reviewer` 进行安全审查
8. **部署上线**：使用 `devops-expert` 部署

### Bug 修复流程

1. **复现问题**：确认 Bug 可复现
2. **TDD 修复**：使用 `tdd-guide` 先写测试再修复
3. **代码审查**：使用 `code-reviewer` 审查修复
4. **构建验证**：使用 `build-error-resolver` 确保构建成功

### DevOps 流程

1. **CI/CD 配置**：使用 `devops-expert` 配置流水线
2. **自动化部署**：使用 `devops-expert` 实现部署
3. **监控告警**：使用 `devops-expert` 配置监控

## 📋 智能体协作关系

所有智能体遵循统一的协作模式：

| 任务     | 委托目标               |
| -------- | ---------------------- |
| 功能规划 | `planner`              |
| 架构设计 | `architect`            |
| TDD 流程 | `tdd-guide`            |
| 测试策略 | `testing-expert`       |
| 代码审查 | `code-reviewer`        |
| 构建错误 | `build-error-resolver` |
| 安全审查 | `security-reviewer`    |
| DevOps   | `devops-expert`        |

## 🛠️ 智能体与技能对应

每个智能体引用相关的技能及调用时机：

| 智能体               | 核心技能                                   | 调用时机       |
| -------------------- | ------------------------------------------ | -------------- |
| planner              | clean-architecture, tdd-workflow           | 需求分析时     |
| architect            | clean-architecture, ddd-patterns           | 系统设计时     |
| tdd-guide            | tdd-workflow                               | TDD 开发时     |
| build-error-resolver | coding-standards                           | 构建失败时     |
| typescript-dev       | frontend-patterns, coding-standards        | TS/JS 开发时   |
| python-dev           | python-patterns, django-patterns           | Python 开发时  |
| golang-dev           | golang-patterns                            | Go 开发时      |
| ios-native           | ios-native-patterns                        | iOS 开发时     |
| react-native-dev     | react-native-patterns, frontend-patterns   | RN 开发时      |
| android-native       | android-native-patterns, frontend-patterns | Android 开发时 |
| testing-expert       | tdd-workflow, e2e-testing                  | 测试策略时     |
| code-reviewer        | coding-standards, clean-architecture       | 代码审查时     |
| security-reviewer    | security-review                            | 安全审查时     |
| devops-expert        | deployment-patterns, docker-patterns       | 部署运维时     |
| backend-expert       | rest-patterns, postgres-patterns           | 后端开发时     |
| frontend-expert      | frontend-patterns, vue-patterns            | 前端开发时     |
| doc-expert           | -                                          | 文档编写时     |
| analytics-agent      | analytics-tracking, logging-observability  | 数据分析时     |

---

**设计理念**：精简、高效、易用。专为个人开发者设计，减少学习成本，提高开发效率。
