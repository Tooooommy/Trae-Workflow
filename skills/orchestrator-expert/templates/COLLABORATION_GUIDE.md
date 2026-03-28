# AI专家团队智能协作指南

## 协作架构

```mermaid
flowchart TB
    subgraph 调度层
        O[orchestrator-expert<br/>协调中枢]
    end
    
    subgraph 产品层
        P[product-strategist<br/>产品专家]
        UX[ux-engineer<br/>设计专家]
    end
    
    subgraph 架构层
        TA[tech-architect<br/>架构专家]
        SA[security-auditor<br/>安全专家]
    end
    
    subgraph 开发层
        FE[frontend-specialist<br/>前端专家]
        BE[backend-specialist<br/>后端专家]
        MO[mobile-specialist<br/>移动端专家]
    end
    
    subgraph 质量层
        QE[quality-engineer<br/>质量专家]
        DO[docs-engineer<br/>文档专家]
    end
    
    subgraph 运维层
        DE[devops-engineer<br/>运维专家]
        RF[retro-facilitator<br/>复盘专家]
    end
    
    subgraph 共享层
        CTX[shared-context<br/>共享上下文]
        TB[task-board<br/>任务看板]
    end
    
    O --> P & UX
    P & UX --> TA
    TA --> SA
    TA --> FE & BE & MO
    FE & BE & MO --> QE
    QE --> DO
    DO --> DE
    DE --> RF
    
    O <--> CTX
    O <--> TB
    P & UX & TA & FE & BE & MO & QE & SA & DO & DE & RF <--> CTX
    P & UX & TA & FE & BE & MO & QE & SA & DO & DE & RF <--> TB
```

---

## 智能调度机制

### 任务智能路由

```mermaid
flowchart TD
    A[用户需求] --> B{orchestrator 解析}
    B --> C{复杂度评估}
    
    C -->|高复杂度| D[完整7阶段流程]
    C -->|中复杂度| E[快速修复流程]
    C -->|低复杂度| F[快速通道]
    C -->|紧急| G[紧急流程]
    
    D --> H{并行需求?}
    H -->|是| I[多专家并行调度]
    H -->|否| J[串行调度]
    
    I --> K[结果聚合]
    J --> K
    E --> K
    F --> K
    G --> K
    
    K --> L{质量门禁}
    L -->|通过| M[自动流转]
    L -->|失败| N[智能回退]
    N --> B
```

### 智能决策引擎

| 决策点 | 条件 | 动作 |
|--------|------|------|
| 任务类型 | 包含"开发"/"实现" | 完整流程 |
| 任务类型 | 包含"修复"/"Bug" | 快速修复 |
| 任务类型 | 包含"更新"/"修改" | 快速通道 |
| 任务类型 | 包含"紧急"/"生产" | 紧急流程 |
| 并行需求 | 前后端都有 | 并行调度 |
| 质量门禁 | 测试覆盖率 < 80% | 返回开发 |
| 质量门禁 | 安全漏洞 > 0 | 返回开发 |
| 部署失败 | 重试次数 < 3 | 自动重试 |
| 部署失败 | 重试次数 >= 3 | 人工介入 |

---

## 专家协作协议

### 消息传递

```typescript
interface ExpertMessage {
  id: string;
  timestamp: string;
  type: 'request' | 'response' | 'notification' | 'error';
  priority: 'critical' | 'high' | 'medium' | 'low';
  
  sender: {
    expert: string;
    phase: string;
    status: 'available' | 'busy' | 'blocked' | 'completed';
  };
  
  receiver: {
    expert: string;
    action: 'start' | 'continue' | 'pause' | 'complete' | 'error';
  };
  
  payload: {
    taskId: string;
    input: ExpertInput;
    output: ExpertOutput;
    context: ProjectContext;
  };
}
```

### 状态同步

每个专家完成后必须：

1. **更新任务看板** → `task-board.json`
2. **同步共享上下文** → `shared-context/project-context.json`
3. **通知协调中枢** → 发送消息给 `orchestrator-expert`

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

---

## 智能协作模式

### 模式1：并行开发

**触发条件**：前后端都需要开发

```mermaid
sequenceDiagram
    participant O as orchestrator
    participant FE as frontend
    participant BE as backend
    participant CTX as shared-context
    
    O->>BE: 启动后端开发
    O->>FE: 启动前端开发（Mock数据）
    
    BE->>CTX: 更新API文档
    FE->>CTX: 读取API文档
    
    BE->>O: 后端完成
    FE->>O: 前端完成
    
    O->>FE: 集成真实API
    FE->>O: 集成完成
```

### 模式2：串行依赖

**触发条件**：后端API需要先完成

```mermaid
sequenceDiagram
    participant O as orchestrator
    participant BE as backend
    participant FE as frontend
    participant CTX as shared-context
    
    O->>BE: 启动后端开发
    BE->>CTX: 更新API文档
    BE->>O: 后端完成
    
    O->>FE: 启动前端开发
    FE->>CTX: 读取API文档
    FE->>O: 前端完成
```

### 模式3：迭代反馈

**触发条件**：质量门禁未通过

```mermaid
sequenceDiagram
    participant O as orchestrator
    participant QE as quality
    participant DEV as 开发专家
    participant CTX as shared-context
    
    O->>QE: 质量检查
    QE->>CTX: 记录问题
    QE->>O: 测试失败
    
    O->>DEV: 返回修复
    DEV->>CTX: 读取问题
    DEV->>O: 修复完成
    
    O->>QE: 重新检查
    QE->>O: 测试通过
```

---

## 质量门禁链

```mermaid
flowchart LR
    A[代码提交] --> B{Lint检查}
    B -->|失败| C[自动修复]
    C --> B
    B -->|通过| D{类型检查}
    D -->|失败| E[返回开发]
    D -->|通过| F{单元测试}
    F -->|失败| E
    F -->|通过| G{覆盖率检查}
    G -->|失败| E
    G -->|通过| H{安全扫描}
    H -->|失败| E
    H -->|通过| I{集成测试}
    I -->|失败| E
    I -->|通过| J[质量通过]
```

### 门禁配置

| 门禁 | 命令 | 阈值 | 自动处理 |
|------|------|------|----------|
| Lint | `npm run lint` | 0 errors | 自动修复 |
| 类型 | `npm run typecheck` | 0 errors | 返回开发 |
| 单元测试 | `npm run test` | 100% pass | 返回开发 |
| 覆盖率 | `npm run coverage` | ≥ 80% | 返回开发 |
| 安全 | `npm audit` | 0 high | 返回开发 |
| 集成测试 | `npm run test:integration` | 100% pass | 返回开发 |

---

## 异常处理

### 自动恢复

| 异常 | 检测方式 | 自动恢复 |
|------|----------|----------|
| Lint错误 | 构建失败 | 自动修复后重试 |
| 测试失败 | 测试报告 | 返回开发阶段 |
| 部署失败 | 健康检查 | 自动回滚 |
| 依赖缺失 | 启动错误 | 自动安装 |

### 升级机制

| 级别 | 条件 | 处理 |
|------|------|------|
| 自动处理 | 重试次数 < 3 | 自动重试 |
| 人工介入 | 重试次数 >= 3 | 通知用户 |
| 紧急停止 | 阻塞 > 30分钟 | 暂停流程 |

---

## 知识沉淀

### 自动记录

每个阶段完成后自动记录：

1. **决策记录** → `.ai-team/orchestrator/decision-registry/ADR-*.md`
2. **工作日志** → `.ai-team/orchestrator/workflow-log.md`
3. **经验沉淀** → `.ai-team/shared-context/knowledge-graph.md`

### 反馈闭环

```mermaid
flowchart LR
    A[项目完成] --> B[retro-facilitator]
    B --> C[复盘分析]
    C --> D[经验沉淀]
    D --> E[知识库更新]
    E --> F[下次项目优化]
```

---

## 最佳实践

### 1. 渐进式自动化

```
手动确认 → 半自动 → 全自动
```

| 阶段 | 人工介入点 | 自动化程度 |
|------|------------|------------|
| 初期 | PRD、架构确认 | 30% |
| 中期 | 关键决策 | 60% |
| 成熟 | 异常处理 | 90% |

### 2. 上下文传递

每个专家接收任务时自动获取：

- 项目背景和目标
- 前序阶段产出
- 技术决策记录
- 已知约束和风险

### 3. 智能重试

```
失败 → 分析原因 → 智能修复 → 重试 → 成功
```

### 4. 并行优化

- 独立任务并行执行
- 依赖任务智能排序
- 资源冲突自动协调
