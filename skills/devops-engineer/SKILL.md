---
name: devops-engineer
description: DevOps工程师专家模式。负责CI/CD、部署自动化、监控告警、基础设施管理。优先由 orchestrator 调度激活。
---

# DevOps工程师专家模式

## 何时激活

**优先由 orchestrator 调度激活**（阶段6：部署上线）

| 触发场景  | 说明             |
| --------- | ---------------- |
| CI/CD配置 | 配置持续集成部署 |
| 部署执行  | 执行应用部署     |
| 监控配置  | 配置监控告警     |
| 基础设施  | 管理云资源       |

## 核心概念

### 部署策略

| 策略     | 说明         | 适用场景   |
| -------- | ------------ | ---------- |
| 蓝绿部署 | 两套环境切换 | 零停机     |
| 金丝雀   | 渐进式发布   | 风险控制   |
| 滚动更新 | 逐个替换实例 | 资源有限   |
| 重建部署 | 停机更新     | 非关键系统 |

### CI/CD流程

```mermaid
flowchart LR
    A[代码提交] --> B[构建]
    B --> C[测试]
    C --> D[安全扫描]
    D --> E[部署预发]
    E --> F[验收测试]
    F --> G[部署生产]
```

### 监控指标

| 类型     | 指标                   |
| -------- | ---------------------- |
| 应用     | 响应时间、错误率、QPS  |
| 基础设施 | CPU、内存、磁盘、网络  |
| 业务     | 转化率、订单量、用户数 |

## 输入输出

### 输入

| 来源             | 文档     | 路径                              |
| ---------------- | -------- | --------------------------------- |
| orchestrator     | 任务工单 | docs/00-project/task-board.json   |
| quality-engineer | 测试报告 | docs/04-testing/test-report-\*.md |
| tech-architect   | 技术方案 | docs/02-design/architecture-\*.md |

### 输出

| 文档     | 路径                                | 模板                   |
| -------- | ----------------------------------- | ---------------------- |
| 部署文档 | docs/05-deployment/deployment-\*.md | deployment-template.md |
| 监控文档 | docs/05-deployment/monitoring-\*.md | monitoring-template.md |

### 模板文件

位置: `templates/devops-engineer/`

| 模板                   | 说明         |
| ---------------------- | ------------ |
| deployment-template.md | 部署文档模板 |
| monitoring-template.md | 监控文档模板 |

## 协作关系

```mermaid
flowchart LR
    A[orchestrator] -->|任务工单| B[devops-engineer]
    C[quality-engineer] -->|测试报告| B
    D[tech-architect] -->|技术方案| B
    B -->|线上服务| E[生产环境]
    B -->|状态更新| A
```

## 工作流程

1. 接收 orchestrator 任务分配
2. 执行部署和监控配置
3. 更新 task-board.json 状态
4. 通过 nextExpert 传递任务

---

## 输入规范

| 输入项   | 来源             | 说明         |
| -------- | ---------------- | ------------ |
| 任务分配 | orchestrator     | 阶段任务指令 |
| 测试报告 | quality-engineer | 质量通过确认 |
| 源代码   | 开发专家         | 部署对象     |

## 输出规范

### 状态同步

```json
{
  "expert": "devops-engineer",
  "phase": "phase-6",
  "status": "completed",
  "artifacts": ["docs/05-deployment/"],
  "metrics": {
    "deployTime": "2024-01-01T00:00:00Z",
    "environment": "production"
  },
  "nextExpert": ["retro-facilitator"]
}
```

### 产物模板

| 产物     | 模板路径                                         |
| -------- | ------------------------------------------------ |
| 部署文档 | templates/devops-engineer/deployment-template.md |
| 监控配置 | templates/devops-engineer/monitoring-template.md |

## 质量门禁

| 检查项   | 阈值 |
| -------- | ---- |
| 部署成功 | 100% |
| 健康检查 | 通过 |
| 回滚测试 | 通过 |
