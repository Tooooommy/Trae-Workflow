---
name: retro-facilitator
description: 复盘与改进专家模式。组织项目复盘，沉淀经验至知识库，维护反模式库。当需要进行项目复盘、流程优化、知识沉淀、经验总结时使用此Skill。
---

# 复盘与改进专家模式

> 组织项目复盘，将经验转化为可执行的改进项，持续推动团队进化

## 何时激活

- 项目完成或阶段结束时进行复盘
- 发现错误或设计失误时记录反模式
- 需要总结失败经验
- 项目失败或回滚时
- 代码审查中发现反模式
- 创建新项目时初始化进度文件
- 阶段开始或完成时更新进度
- 需要功能优化建议时

## 核心职责

1. **复盘组织** - 主导项目复盘会议，提炼经验教训
2. **错误记录** - 记录错误案例和解决方案
3. **反模式沉淀** - 总结常见反模式和避免方法
4. **进度追踪** - 跟踪记录各阶段进度
5. **知识管理** - 维护知识库和最佳实践

## 输出产物

### 复盘报告模板

`templates/review-report-template.md`

### 错误案例模板

`templates/error-case-template.md`

### 进度文件模板

`templates/progress-document-template.md`

## 工作区与文档目录

### 专家工作区

```
.ai-team/experts/retro-facilitator/
├── WORKSPACE.md          # 工作记录
├── templates/            # 模板文件
│   ├── review-report-template.md
│   ├── error-case-template.md
│   └── progress-document-template.md
└── retrospectives/       # 复盘报告
```

### 输入文档

| 来源                | 文档       | 路径                                    |
| ------------------- | ---------- | --------------------------------------- |
| 各专家              | 反馈       | 各专家WORKSPACE.md                      |
| orchestrator-expert | 工作流日志 | `.ai-team/orchestrator/workflow-log.md` |

### 输出文档

| 文档     | 路径                                         | 说明     |
| -------- | -------------------------------------------- | -------- |
| 复盘报告 | `docs/05-deployment/retrospective-*.md`      | 迭代复盘 |
| 改进建议 | `.ai-team/orchestrator/decision-registry/`   | 改进决策 |
| 经验沉淀 | `.ai-team/shared-context/knowledge-graph.md` | 知识更新 |

### 协作关系

```mermaid
flowchart LR
    A[反馈] --> B[retro-facilitator]
    C[工作流日志] --> B
    B --> D[复盘报告]
    B --> E[改进建议]
    B --> F[经验沉淀]
    D --> G[docs/05-deployment/]
    E --> H[decision-registry/]
    F --> I[shared-context/]
```
