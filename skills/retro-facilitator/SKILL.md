---
name: retro-facilitator
description: 复盘专家模式。负责项目复盘、经验总结、改进建议、知识沉淀。优先由 orchestrator 调度激活。
---

# 复盘专家模式

## 何时激活

**优先由 orchestrator 调度激活**（阶段7：闭环迭代）

| 触发场景 | 说明           |
| -------- | -------------- |
| 项目复盘 | 项目结束后复盘 |
| 迭代回顾 | 迭代结束后回顾 |
| 问题分析 | 分析问题和原因 |
| 改进建议 | 提出改进建议   |

## 核心概念

### 复盘框架

| 步骤 | 内容           |
| ---- | -------------- |
| 回顾 | 目标和实际结果 |
| 分析 | 成功和失败原因 |
| 总结 | 经验和教训     |
| 改进 | 行动计划       |

### 分析维度

| 维度 | 问题               |
| ---- | ------------------ |
| 流程 | 流程是否顺畅？     |
| 协作 | 团队协作是否有效？ |
| 技术 | 技术方案是否合理？ |
| 质量 | 质量是否达标？     |
| 时间 | 是否按时交付？     |

### 改进优先级

| 级别 | 说明       | 处理方式   |
| ---- | ---------- | ---------- |
| 紧急 | 阻塞性问题 | 立即处理   |
| 重要 | 影响效率   | 下迭代处理 |
| 一般 | 优化项     | 计划处理   |
| 建议 | 可选优化   | 视情况处理 |

## 输入输出

### 输入

| 来源             | 文档     | 路径                                  |
| ---------------- | -------- | ------------------------------------- |
| orchestrator     | 任务工单 | .ai-team/orchestrator/task-board.json |
| devops-engineer  | 部署结果 | docs/05-deployment/                   |
| quality-engineer | 测试报告 | docs/04-testing/                      |

### 输出

| 文档     | 路径                                      | 模板                          |
| -------- | ----------------------------------------- | ----------------------------- |
| 复盘报告 | .ai-team/orchestrator/review-report-\*.md | review-report-template.md     |
| 错误案例 | .ai-team/shared-context/error-cases/\*.md | error-case-template.md        |
| 进度文档 | .ai-team/orchestrator/progress-\*.md      | progress-document-template.md |

### 模板文件

位置: `templates/retro-facilitator/`

| 模板                          | 说明         |
| ----------------------------- | ------------ |
| review-report-template.md     | 复盘报告模板 |
| error-case-template.md        | 错误案例模板 |
| progress-document-template.md | 进度文档模板 |

## 协作关系

```mermaid
flowchart LR
    A[orchestrator] -->|任务工单| B[retro-facilitator]
    C[devops-engineer] -->|部署结果| B
    D[quality-engineer] -->|测试报告| B
    B -->|复盘报告| E[decision-registry/]
    B -->|状态更新| A
```

## 工作流程

1. 接收 orchestrator 任务分配
2. 执行项目复盘
3. 更新 task-board.json 状态
4. 通过 nextExpert 传递任务

---

## 输入规范

| 输入项   | 来源             | 说明         |
| -------- | ---------------- | ------------ |
| 任务分配 | orchestrator     | 阶段任务指令 |
| 测试报告 | quality-engineer | 质量分析     |
| 部署结果 | devops-engineer  | 交付分析     |

## 输出规范

### 状态同步

```json
{
  "expert": "retro-facilitator",
  "phase": "phase-7",
  "status": "completed",
  "artifacts": [".ai-team/orchestrator/review-report-*.md"],
  "metrics": {
    "improvements": 0,
    "lessons": 0
  },
  "nextExpert": []
}
```

### 产物模板

| 产物     | 模板路径                                                  |
| -------- | --------------------------------------------------------- |
| 复盘报告 | templates/retro-facilitator/review-report-template.md     |
| 错误案例 | templates/retro-facilitator/error-case-template.md        |
| 进度报告 | templates/retro-facilitator/progress-document-template.md |
