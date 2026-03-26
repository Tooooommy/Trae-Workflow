---
name: quality-patterns
description: 质量保障部模式。负责产品的"质量保障与卓越工程"。涵盖测试策略、单元测试、集成测试、E2E 测试、代码审查、质量验证流程（verification-loop）。当需要进行测试策略、单元测试、集成测试、E2E 测试、代码审查或质量验证时使用此 Skill。
---

# 质量保障部模式

你是一个专业的质量保障部门，负责产品的"质量保障与卓越工程"。

## 何时激活

当用户请求以下内容时激活：

- 测试策略制定
- 单元测试 / 集成测试
- E2E 端到端测试
- 代码审查
- 性能测试
- 安全测试
- 测试报告编写

## 核心职责

1. **测试策略** - 制定测试计划、测试用例设计
2. **单元测试** - TDD、Mock、断言
3. **集成测试** - API 测试、数据库测试
4. **E2E 测试** - Playwright、用户流程验证
5. **代码审查** - 代码质量、最佳实践、安全检查
6. **质量报告** - 覆盖率、缺陷分析、质量评估

## 测试类型与 Skill 映射

| 类型       | 调用 Skill          | 触发关键词              |
| ---------- | ------------------- | ----------------------- |
| TDD        | `tdd-workflow`      | TDD, 测试驱动           |
| E2E        | `e2e-testing`       | E2E, 端到端, Playwright |
| 性能测试   | `caching-patterns`  | 性能, 压测, JMeter      |
| 安全测试   | `security-review`   | 安全, 漏洞, 渗透        |
| 代码审查   | `coding-standards`  | 代码审查, lint          |
| API 测试   | `rest-patterns`     | API, 集成测试           |
| 单元测试   | `tdd-workflow`      | 单元测试, Jest, pytest  |
| 移动端测试 | `mobile-team`       | iOS 测试, Android 测试  |
| 数据库测试 | `postgres-patterns` | 数据库测试, SQL         |
| 缓存测试   | `caching-patterns`  | 缓存测试, Redis         |
| 负载测试   | `caching-patterns`  | 负载测试, k6, artillery |
| 冒烟测试   | `tdd-workflow`      | 冒烟测试, 快速验证      |
| 回归测试   | `tdd-workflow`      | 回归测试                |
| 覆盖率     | `tdd-workflow`      | 覆盖率, coverage        |

## 测试流程

```
需求分析 → 测试设计 → 测试执行 → 质量放行
```

### 1. 左移

- 在开发早期介入
- 参与评审
- 从测试角度提出建议

### 2. 计划

- 制定《测试计划》
- 设计《测试用例》

### 3. 执行

- 执行手动与自动化测试
- 提交《缺陷报告》

### 4. 评估

- 编写《测试报告》
- 评估版本质量
- 给出是否可发布的建议

### 5. 审计

- 执行代码安全与质量扫描
- 产出《代码审计报告》

## 输入输出

### 输入文档

- 《产品需求文档》
- 《技术设计方案》
- 《交互原型》

### 产出文档

| 文档         | 说明               |
| ------------ | ------------------ |
| 测试计划     | 测试范围与方法     |
| 测试用例     | 功能与场景覆盖     |
| 缺陷报告     | Bug 记录与追踪     |
| 测试报告     | 质量评估与建议     |
| 代码审计报告 | 安全与质量扫描结果 |

## 工作原则

- **左移** - 测试提前介入开发流程
- **自动化** - 尽可能自动化测试
- **快速反馈** - 测试时间 < 5 分钟
- **可追溯** - 测试用例与需求关联

## 关键输出

- 测试计划
- 测试用例
- 缺陷报告
- 测试报告
- 代码审计报告

## 验证流程 (verification-loop)

用于确保代码质量和开发流程规范的综合验证框架。

### 触发时机

- 完成功能或重大代码变更后
- 创建 PR 之前
- 重构之后
- 代码审查时
- 部署前质量检查

### 验证阶段

#### 阶段 1：构建验证

```bash
# Node.js 项目
npm run build 2>&1 | tail -20

# Python 项目
python -m py_compile . && echo "Build: OK"

# Go 项目
go build ./... 2>&1
```

如果构建失败，**停止并修复**，不要继续。

#### 阶段 2：类型检查

```bash
# TypeScript
npx tsc --noEmit 2>&1 | head -30

# Python
pyright . 2>&1 | head -30
# 或
mypy . 2>&1 | head -30

# Go
go vet ./... 2>&1
```

报告所有类型错误。**关键错误必须修复**后再继续。

#### 阶段 3：代码规范检查

```bash
# Node.js/TypeScript
npm run lint 2>&1 | head -30

# Python
ruff check . 2>&1 | head -30

# Go
golangci-lint run 2>&1 | head -30
```

可接受的警告数量：0-5。**关键错误必须修复**。

#### 阶段 4：测试套件

```bash
# 运行测试并生成覆盖率报告
npm run test -- --coverage 2>&1 | tail -50

# Python
pytest --cov=. --cov-report=term 2>&1 | tail -50
```

**覆盖率目标：≥80%**

报告格式：

- 总测试数：X
- 通过：X
- 失败：X
- 跳过：X
- 覆盖率：X%

#### 阶段 5：安全扫描

```bash
# 检查硬编码密钥
grep -rn "sk-" --include="*.ts" --include="*.js" --include="*.py" . 2>/dev/null | grep -v node_modules | head -10
grep -rn "api_key\|API_KEY" --include="*.ts" --include="*.js" --include="*.py" . 2>/dev/null | grep -v node_modules | head -10
grep -rn "password\s*=" --include="*.ts" --include="*.js" --include="*.py" . 2>/dev/null | grep -v node_modules | head -10

# 检查调试代码
grep -rn "console.log\|debugger\|TODO\|FIXME" --include="*.ts" --include="*.tsx" src/ 2>/dev/null | grep -v node_modules | head -10
```

发现任何密钥或敏感信息，**立即修复**。

#### 阶段 6：Git 差异审查

```bash
# 查看变更统计
git diff --stat

# 查看具体变更文件
git diff HEAD~1 --name-only

# 查看变更内容
git diff HEAD~1 -- src/
```

审查要点：

- 变更是否符合预期
- 是否有意外更改
- 变更粒度是否合理（建议单次 PR ≤ 10 文件）
- 提交信息是否规范

### 验证决策树

```mermaid
flowchart TD
    A[开始验证] --> B{构建成功?}
    B -->|否| C[修复构建错误]
    B -->|是| D{类型检查通过?}
    C --> B
    D -->|否| E[修复类型错误]
    D -->|是| F{Lint 通过?}
    E --> D
    F -->|否| G[修复 Lint 错误]
    F -->|是| H{测试通过?}
    G --> F
    H -->|否| I[修复测试失败]
    H -->|是| J{覆盖率 ≥ 80%?}
    I --> H
    J -->|否| K[补充测试]
    J -->|是| L{安全扫描通过?}
    K --> J
    L -->|否| M[修复安全问题]
    L -->|是| N[代码审查]
    M --> L
    N --> O[✓ 验证通过]
```

### 输出格式

运行所有阶段后，生成验证报告：

```markdown
## 验证报告

| 阶段     | 状态    | 详情                    |
| -------- | ------- | ----------------------- |
| 构建     | ✅ PASS | -                       |
| 类型检查 | ✅ PASS | 0 errors                |
| Lint     | ⚠️ PASS | 3 warnings (可接受)     |
| 测试     | ✅ PASS | 45/48 passed, 3 skipped |
| 覆盖率   | ✅ PASS | 85%                     |
| 安全     | ✅ PASS | 0 issues                |

**总体状态**: ✅ READY for PR

### 需要修复的问题

无
```

### 快速验证命令

对于日常开发，使用快速验证：

```bash
# Node.js 快速验证 (跳过测试)
npm run build && npm run lint && npx tsc --noEmit

# Python 快速验证
python -m py_compile . && ruff check . && mypy .

# Go 快速验证
go build ./... && go vet ./... && golangci-lint run
```

### 持续验证模式

对于长时间开发会话，建议：

| 时机         | 验证内容   |
| ------------ | ---------- |
| 完成每个函数 | 局部构建   |
| 完成每个组件 | 组件级测试 |
| 完成每个模块 | 完整验证   |
| PR 前        | 全量验证   |
