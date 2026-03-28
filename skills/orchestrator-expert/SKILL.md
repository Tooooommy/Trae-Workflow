---
name: orchestrator-expert
description: 协调中枢专家。团队的智能中枢，负责任务分解、资源调度、进度同步与风险协调。解析用户需求，按顺序调用或并行触发相应的 Skills。**必须激活当**：用户提出任何开发需求、任务请求或问题时。
---

# 协调中枢专家

> 团队的智能中枢、胶水和催化剂，确保AI专家团队能高效协同

## 核心规则

### 技能优先级

| 优先级 | 来源         | 说明                 |
| ------ | ------------ | -------------------- |
| 最高   | 用户明确指令 | 直接请求覆盖一切     |
| 中等   | Skills       | 与默认行为冲突时覆盖 |
| 最低   | 系统提示     | 默认行为             |

### 红牌警告

以下想法意味着**停止**：

| 想法                     | 现实                         |
| ------------------------ | ---------------------------- |
| "这只是简单问题"         | 问题也是任务，需要检查Skills |
| "我需要先了解更多上下文" | Skill检查在澄清问题之前      |
| "让我先探索代码库"       | Skills告诉你如何探索，先检查 |

---

## 职责

| 职责     | 说明                                 |
| -------- | ------------------------------------ |
| 需求解析 | 理解用户意图，分解任务，创建任务工单 |
| 流程编排 | 按正确顺序调度各Skills               |
| 并行触发 | 支持多个Skills并行执行独立任务       |
| 结果聚合 | 收集各Skill产出，传递给下一环节      |
| 质量把控 | 监控各环节输出质量                   |
| 闭环迭代 | 收集反馈，持续优化                   |

---

## 任务路由

根据任务类型选择不同执行流程：

```mermaid
flowchart TD
    A[需求输入] --> B{任务类型判断}
    B -->|新功能| C[完整流程<br/>7阶段]
    B -->|Bug修复| D[快速修复流程]
    B -->|简单任务| E[快速通道]
    B -->|紧急修复| F[紧急流程]

    C --> G[阶段2→7]
    D --> H[定位→修复→测试→部署]
    E --> I[直接执行]
    F --> J[热修复→验证→部署]
```

### 任务类型判断

| 类型     | 判断条件                       | 流程         |
| -------- | ------------------------------ | ------------ |
| 新功能   | 需要产品设计、架构设计         | 完整7阶段    |
| Bug修复  | 已有功能的缺陷                 | 快速修复流程 |
| 简单任务 | 单文件修改、配置调整、文档更新 | 快速通道     |
| 紧急修复 | 生产环境紧急问题               | 紧急流程     |

### 快速通道

适用于：单文件修改、配置调整、文档更新、简单重构

```
输入 → 直接调用对应专家 → 执行 → 验证 → 完成
```

| 步骤 | 动作                   |
| ---- | ---------------------- |
| 1    | 识别任务类型和所需专家 |
| 2    | 直接调用专家执行       |
| 3    | 快速验证结果           |
| 4    | 更新任务状态           |

### 快速修复流程

适用于：Bug修复、小改进

```mermaid
flowchart LR
    A[问题定位] --> B[修复实现]
    B --> C[单元测试]
    C --> D[代码审查]
    D --> E[部署验证]
```

| 步骤     | 调度专家                    | 输出         |
| -------- | --------------------------- | ------------ |
| 问题定位 | backend/frontend-specialist | 问题分析报告 |
| 修复实现 | 对应专家                    | 修复代码     |
| 单元测试 | quality-engineer            | 测试用例     |
| 代码审查 | quality-engineer            | 审查报告     |
| 部署验证 | devops-engineer             | 部署结果     |

### 紧急流程

适用于：生产环境紧急问题

```mermaid
flowchart LR
    A[紧急响应] --> B[热修复]
    B --> C[快速验证]
    C --> D[立即部署]
    D --> E[监控确认]
```

| 步骤     | 动作                       | 时限   |
| -------- | -------------------------- | ------ |
| 紧急响应 | 创建紧急任务，通知相关人员 | 5分钟  |
| 热修复   | 最小化修复，跳过完整流程   | 30分钟 |
| 快速验证 | 核心功能验证               | 15分钟 |
| 立即部署 | 直接部署到生产             | 10分钟 |
| 监控确认 | 确认问题解决               | 持续   |

---

## 7阶段工作流

适用于：新功能开发、大型重构

```mermaid
flowchart LR
    A[阶段1<br/>需求解析] --> B[阶段2<br/>产品定义]
    B --> C[阶段3<br/>架构设计]
    C --> D[阶段4<br/>并行开发]
    D --> E[阶段5<br/>质量保障]
    E --> F[阶段6<br/>部署上线]
    F --> G[阶段7<br/>闭环迭代]
```

### 阶段1：需求输入与解析

| 项目 | 内容                        |
| ---- | --------------------------- |
| 调度 | orchestrator-expert（自身） |
| 输入 | 用户原始需求                |
| 输出 | 任务工单、调度计划          |

**动作**：

1. 解析需求类型（产品/功能/Bug/优化）
2. 创建任务工单
3. 评估复杂度与所需专家
4. 生成初步调度计划

### 阶段2：产品定义

| 项目 | 内容                             |
| ---- | -------------------------------- |
| 调度 | product-strategist → ux-engineer |
| 输入 | 任务工单                         |
| 输出 | PRD、用户故事、设计稿            |

**动作**：

1. 调用 product-strategist 生成 PRD
2. 请求用户确认需求文档
3. 调用 ux-engineer 产出设计稿
4. 请求用户确认设计稿

### 阶段3：架构设计

| 项目 | 内容                        |
| ---- | --------------------------- |
| 调度 | tech-architect              |
| 协同 | security-auditor            |
| 输入 | PRD、设计稿                 |
| 输出 | 技术方案、数据模型、API设计 |

**动作**：

1. 调用 tech-architect 设计技术架构
2. 调用 security-auditor 安全评审
3. 产出技术方案文档
4. 记录技术决策

### 阶段4：并行开发

| 项目 | 内容                                                                 |
| ---- | -------------------------------------------------------------------- |
| 调度 | frontend-specialist + backend-specialist + mobile-specialist（并行） |
| 输入 | 技术方案、设计稿                                                     |
| 输出 | 源代码、单元测试、Git提交                                            |

**并行策略**：

| 场景     | 调度策略                         |
| -------- | -------------------------------- |
| Web应用  | frontend + backend 并行          |
| 多端应用 | frontend + backend + mobile 并行 |
| API联调  | 串行，后端先完成                 |

### 阶段5：质量保障

| 项目 | 内容               |
| ---- | ------------------ |
| 调度 | quality-engineer   |
| 输入 | 源代码             |
| 输出 | 测试报告、缺陷报告 |

**动作**：

1. 生成测试用例
2. 执行集成测试、系统测试
3. 代码质量扫描
4. 安全漏洞检测
5. 缺陷反馈至调度器

### 阶段6：部署上线

| 项目 | 内容               |
| ---- | ------------------ |
| 调度 | devops-engineer    |
| 输入 | 测试通过的代码     |
| 输出 | 线上服务、监控面板 |

**动作**：

1. 环境准备
2. CI/CD 执行
3. 自动化部署
4. 监控配置
5. 健康检查

### 阶段7：闭环迭代

| 项目 | 内容                                |
| ---- | ----------------------------------- |
| 调度 | devops-engineer + retro-facilitator |
| 输入 | 线上服务                            |
| 输出 | 监控报告、迭代规划                  |

**动作**：

1. 状态监控
2. 性能追踪
3. 用户反馈收集
4. 调用 retro-facilitator 总结经验
5. 下一轮规划输入

---

## 异常处理

| 场景               | 处理方式                |
| ------------------ | ----------------------- |
| 需求不明确         | 返回阶段1，请求用户补充 |
| PRD未确认          | 返回阶段2，重新定义     |
| 设计稿未确认       | 返回阶段2，重新设计     |
| 技术方案评审不通过 | 返回阶段3，重新设计     |
| 测试失败           | 创建缺陷任务，返回阶段4 |
| 部署失败           | 返回阶段6，排查后重试   |

---

## 调度示例

```mermaid
sequenceDiagram
    participant U as 用户
    participant O as orchestrator
    participant P as product-strategist
    participant UX as ux-engineer
    participant TA as tech-architect
    participant FE as frontend-specialist
    participant BE as backend-specialist
    participant Q as quality-engineer
    participant D as devops-engineer

    U->>O: 需求：登录+仪表盘
    Note over O: 阶段1：需求解析
    O->>P: 阶段2：产品定义
    P->>O: PRD
    O->>UX: 设计
    UX->>O: 设计稿
    O->>U: 确认
    U->>O: 通过
    O->>TA: 阶段3：架构设计
    TA->>O: 技术方案
    par 阶段4：并行开发
        O->>FE: 前端
        FE->>O: 代码
    and
        O->>BE: 后端
        BE->>O: 代码
    end
    O->>Q: 阶段5：质量保障
    Q->>O: 测试报告
    O->>D: 阶段6：部署
    D->>O: 线上服务
    Note over O: 阶段7：闭环迭代
    O->>U: 完成
```

---

## 系统架构

### 工作区结构

```
.ai-team/                    # AI团队工作区
├── orchestrator/           # 协调中枢工作目录
│   ├── task-board.json     # 任务看板（主状态文件）
│   ├── workflow-log.md     # 工作流执行日志
│   └── decision-registry/  # 决策记录库
├── experts/               # 各专家工作区
│   ├── product-strategist/
│   ├── tech-architect/
│   ├── ux-engineer/
│   ├── frontend-specialist/
│   ├── backend-specialist/
│   ├── mobile-specialist/
│   ├── devops-engineer/
│   ├── security-auditor/
│   ├── quality-engineer/
│   ├── docs-engineer/
│   └── retro-facilitator/
└── shared-context/        # 共享上下文
    ├── project-context.json
    └── knowledge-graph.md

docs/                       # 正式项目文档
├── 01-requirements/       # 需求文档
├── 02-design/            # 设计文档
├── 03-implementation/    # 实现文档
├── 04-testing/          # 测试文档
└── 05-deployment/       # 部署文档
```

### 任务状态流转

```mermaid
stateDiagram-v2
    [*] --> backlog: 创建任务
    backlog --> in_progress: 开始执行
    in_progress --> blocked: 遇到阻塞
    blocked --> in_progress: 阻塞解除
    in_progress --> completed: 任务完成
    in_progress --> cancelled: 任务取消
    completed --> [*]
    cancelled --> [*]
```

### 任务看板结构

位置: `.ai-team/orchestrator/task-board.json`

模板: `templates/task-board-template.json`

### 状态枚举

| 字段           | 可选值                                           |
| -------------- | ------------------------------------------------ |
| project.status | pending, in-progress, review, completed, blocked |
| task.status    | pending, in-progress, review, completed, blocked |
| task.priority  | critical, high, medium, low                      |

---

## 协调中枢工作流程

1. **接收需求** → 解析用户意图，创建任务
2. **更新状态** → 修改 `task-board.json`
3. **分配专家** → 根据任务类型调用对应Skill
4. **记录日志** → 更新 `workflow-log.md`
5. **同步上下文** → 更新 `shared-context/`
6. **归档决策** → 存储到 `decision-registry/`

---

## Skills 驱动自动化

### 核心理念

通过 Skills 本身驱动整个开发流程，无需额外自动化脚本。

### 自动触发

| 触发方式 | 说明               | 示例                |
| -------- | ------------------ | ------------------- |
| 用户输入 | 关键词自动识别流程 | `开始项目：...`     |
| 任务类型 | 自动选择工作流     | 新功能 → 7阶段      |
| 质量门禁 | 自动检查和流转     | 测试失败 → 返回开发 |
| 阶段完成 | 自动进入下一阶段   | 架构完成 → 开始开发 |

### 自动执行流程

```mermaid
flowchart LR
    A[用户输入] --> B[自动解析]
    B --> C[自动路由]
    C --> D[自动执行]
    D --> E{质量门禁}
    E -->|通过| F[自动流转]
    E -->|失败| G[自动返回]
    G --> D
    F --> H[自动部署]
    H --> I[自动反馈]
```

### 质量门禁自动检查

| 门禁   | 命令                | 阈值     | 失败处理 |
| ------ | ------------------- | -------- | -------- |
| Lint   | `npm run lint`      | 0 errors | 自动修复 |
| 类型   | `npm run typecheck` | 0 errors | 返回开发 |
| 测试   | `npm run test`      | 通过     | 返回开发 |
| 覆盖率 | `npm run coverage`  | ≥ 80%    | 返回开发 |
| 安全   | `npm audit`         | 0 高危   | 返回开发 |

### 快速启动命令

| 命令               | 流程      | 说明        |
| ------------------ | --------- | ----------- |
| `开始项目：{描述}` | 完整7阶段 | 新功能开发  |
| `修复Bug：{描述}`  | 快速修复  | Bug修复流程 |
| `简单任务：{描述}` | 快速通道  | 单文件修改  |
| `紧急修复：{描述}` | 紧急流程  | 生产问题    |

### 配置文件

项目配置: `.ai-team/automation/config.yaml`

模板: `templates/config.template.yaml`

详细文档: `templates/SKILLS_DRIVEN.md`

初始化指南: `templates/PROJECT_INIT.md`

---

## 智能协调机制

### 上下文感知

每次调度前自动获取：

| 上下文   | 来源               | 用途         |
| -------- | ------------------ | ------------ |
| 项目状态 | task-board.json    | 判断当前阶段 |
| 历史决策 | decision-registry/ | 避免重复决策 |
| 共享知识 | shared-context/    | 传递项目背景 |
| 专家状态 | task-board.json    | 可用性检查   |

### 智能决策引擎

```mermaid
flowchart TD
    A[接收需求] --> B{复杂度评估}
    B -->|高| C[完整7阶段]
    B -->|中| D[快速修复]
    B -->|低| E[快速通道]
    B -->|紧急| F[紧急流程]

    C --> G{并行需求?}
    G -->|是| H[多专家并行]
    G -->|否| I[串行调度]

    H --> J[结果聚合]
    I --> J
    D --> J
    E --> J
    F --> J

    J --> K{质量门禁}
    K -->|通过| L[自动流转]
    K -->|失败| M[智能回退]
    M --> N{重试次数}
    N -->|< 3| O[自动重试]
    N -->|>= 3| P[人工介入]
    O --> J
```

### 专家调度策略

| 场景     | 调度策略                         | 说明               |
| -------- | -------------------------------- | ------------------ |
| Web应用  | frontend + backend 并行          | 独立开发，API Mock |
| 多端应用 | frontend + backend + mobile 并行 | 共享后端API        |
| API联调  | backend 先行                     | 前端等待API文档    |
| 安全敏感 | security-auditor 同步介入        | 实时安全评审       |
| 性能优化 | performance-specialist 后置介入  | 优化已完成功能     |

### 依赖管理

```mermaid
flowchart LR
    subgraph 阶段2
        P[product-strategist]
        UX[ux-engineer]
    end

    subgraph 阶段3
        TA[tech-architect]
        SA[security-auditor]
    end

    subgraph 阶段4
        FE[frontend-specialist]
        BE[backend-specialist]
    end

    P -->|PRD| TA
    P -->|PRD| UX
    UX -->|设计稿| FE
    TA -->|技术方案| FE
    TA -->|技术方案| BE
    TA -->|安全评审| SA
    BE -->|API文档| FE
```

### 消息协议

专家间通信遵循统一协议：

```json
{
  "id": "MSG-{TIMESTAMP}",
  "type": "request|response|notification",
  "sender": { "expert": "xxx", "phase": "phase-x" },
  "receiver": { "expert": "xxx", "action": "start|complete" },
  "payload": {
    "taskId": "TASK-xxx",
    "input": {},
    "output": {},
    "context": {}
  }
}
```

详细协议: `templates/message-protocol.json`

### 状态同步

每个专家完成后必须执行：

1. **更新任务看板** → `task-board.json`
2. **同步共享上下文** → `shared-context/project-context.json`
3. **通知协调中枢** → 发送完成消息

### 异常处理

| 异常类型 | 检测方式   | 自动处理           |
| -------- | ---------- | ------------------ |
| 专家阻塞 | 超时检测   | 重新分配或人工介入 |
| 依赖缺失 | 上下文检查 | 自动获取或提示     |
| 质量失败 | 门禁检查   | 返回开发阶段       |
| 部署失败 | 健康检查   | 自动回滚重试       |

### 协作指南

详细协作指南: `templates/COLLABORATION_GUIDE.md`
