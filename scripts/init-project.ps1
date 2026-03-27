# AI Team 项目初始化脚本 (Windows PowerShell)
# 用法: .\init-project.ps1 -ProjectName "my-project"

param(
    [string]$ProjectName = "new-project"
)

$ErrorActionPreference = "Stop"
$Date = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

Write-Host "🚀 正在初始化项目: $ProjectName" -ForegroundColor Cyan
Write-Host ""

# 1. 创建目录结构
Write-Host "📁 创建目录结构..." -ForegroundColor Yellow

$directories = @(
    ".ai-team\orchestrator\decision-registry",
    ".ai-team\experts\product-strategist",
    ".ai-team\experts\tech-architect",
    ".ai-team\experts\ux-engineer",
    ".ai-team\experts\frontend-specialist",
    ".ai-team\experts\backend-specialist",
    ".ai-team\experts\mobile-specialist",
    ".ai-team\experts\devops-engineer",
    ".ai-team\experts\security-auditor",
    ".ai-team\experts\quality-engineer",
    ".ai-team\experts\performance-specialist",
    ".ai-team\experts\docs-engineer",
    ".ai-team\experts\retro-facilitator",
    ".ai-team\shared-context",
    "docs\01-requirements",
    "docs\02-design",
    "docs\03-implementation",
    "docs\04-testing",
    "docs\05-deployment",
    "src",
    "tests",
    ".github\workflows",
    "scripts"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# 2. 初始化 task-board.json
Write-Host "📋 初始化任务看板..." -ForegroundColor Yellow

$taskBoard = @{
    project = @{
        name = $ProjectName
        description = ""
        createdAt = $Date
        updatedAt = $Date
    }
    backlog = @()
    inProgress = @()
    blocked = @()
    completed = @()
}

$taskBoard | ConvertTo-Json -Depth 10 | Out-File -FilePath ".ai-team\orchestrator\task-board.json" -Encoding UTF8

# 3. 初始化工作流日志
Write-Host "📝 初始化工作流日志..." -ForegroundColor Yellow

$workflowLog = @"
# 工作流日志

> 项目: $ProjectName
> 创建时间: $Date

## 日志记录

| 时间 | 专家 | 动作 | 状态 | 备注 |
|------|------|------|------|------|
"@

$workflowLog | Out-File -FilePath ".ai-team\orchestrator\workflow-log.md" -Encoding UTF8

# 4. 初始化项目上下文
Write-Host "🔧 初始化项目上下文..." -ForegroundColor Yellow

$projectContext = @{
    project = @{
        name = $ProjectName
        techStack = @{
            frontend = ""
            backend = ""
            database = ""
            deployment = ""
        }
        constraints = @{
            budget = ""
            timeline = ""
            team = @()
        }
    }
    stakeholders = @()
    milestones = @()
    decisions = @()
}

$projectContext | ConvertTo-Json -Depth 10 | Out-File -FilePath ".ai-team\shared-context\project-context.json" -Encoding UTF8

# 5. 初始化知识图谱
Write-Host "📚 初始化知识图谱..." -ForegroundColor Yellow

$knowledgeGraph = @"
# 知识图谱

> 项目: $ProjectName

## 技术栈

| 层级 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 前端 | - | - | - |
| 后端 | - | - | - |
| 数据库 | - | - | - |
| 部署 | - | - | - |

## 核心概念

_暂无_

## 关键决策

_暂无_

## 经验教训

_暂无_
"@

$knowledgeGraph | Out-File -FilePath ".ai-team\shared-context\knowledge-graph.md" -Encoding UTF8

# 6. 初始化各专家工作区
Write-Host "👥 初始化专家工作区..." -ForegroundColor Yellow

$experts = @(
    "product-strategist",
    "tech-architect",
    "ux-engineer",
    "frontend-specialist",
    "backend-specialist",
    "mobile-specialist",
    "devops-engineer",
    "security-auditor",
    "quality-engineer",
    "performance-specialist",
    "docs-engineer",
    "retro-facilitator"
)

foreach ($expert in $experts) {
    $workspaceContent = @"
# $expert 工作区

> 当前任务：暂无
> 状态：待命

## 工作记录

| 日期 | 任务 | 状态 | 输出 |
|------|------|------|------|

## 待办事项

- [ ] 暂无

## 备注

_暂无_
"@
    $workspaceContent | Out-File -FilePath ".ai-team\experts\$expert\WORKSPACE.md" -Encoding UTF8
}

# 7. 初始化文档目录
Write-Host "📄 初始化文档目录..." -ForegroundColor Yellow

$docsReadme = @{
    "docs\01-requirements\README.md" = @"
# 需求文档目录

## 文档类型

| 文档 | 说明 |
|------|------|
| PRD-*.md | 产品需求文档 |
| user-stories-*.md | 用户故事 |
| mvp-*.md | MVP范围定义 |
| roadmap-*.md | 产品路线图 |

## 当前文档

_暂无文档_
"@
    "docs\02-design\README.md" = @"
# 设计文档目录

## 文档类型

| 文档 | 说明 |
|------|------|
| architecture-*.md | 系统架构设计 |
| tech-selection-*.md | 技术选型报告 |
| data-model-*.md | 数据模型设计 |
| ui-design-*.md | UI设计文档 |
| interaction-*.md | 交互设计规范 |

## 当前文档

_暂无文档_
"@
    "docs\03-implementation\README.md" = @"
# 实现文档目录

## 文档类型

| 文档 | 说明 |
|------|------|
| api-*.md | API文档 |
| component-*.md | 组件文档 |
| page-*.md | 页面文档 |
| mobile-*.md | 移动端文档 |

## 当前文档

_暂无文档_
"@
    "docs\04-testing\README.md" = @"
# 测试文档目录

## 文档类型

| 文档 | 说明 |
|------|------|
| test-report-*.md | 测试报告 |
| quality-report-*.md | 质量报告 |
| security-report-*.md | 安全审计报告 |
| performance-report-*.md | 性能报告 |

## 当前文档

_暂无文档_
"@
    "docs\05-deployment\README.md" = @"
# 部署文档目录

## 文档类型

| 文档 | 说明 |
|------|------|
| deployment-*.md | 部署指南 |
| monitoring-*.md | 监控配置 |
| retrospective-*.md | 复盘报告 |

## 当前文档

_暂无文档_
"@
}

foreach ($file in $docsReadme.Keys) {
    $docsReadme[$file] | Out-File -FilePath $file -Encoding UTF8
}

# 8. 创建决策记录模板
$decisionRegistry = @"
# 决策记录库

## ADR 模板

``````markdown
# ADR-XXX: [决策标题]

## 状态

[提议/已接受/已废弃/已替代]

## 背景

描述背景和问题...

## 决策

描述决策内容...

## 理由

解释为什么做出这个决策...

## 后果

描述决策的影响...
``````

## 决策索引

| 编号 | 标题 | 状态 | 日期 |
|------|------|------|------|

_暂无决策记录_
"@

$decisionRegistry | Out-File -FilePath ".ai-team\orchestrator\decision-registry\README.md" -Encoding UTF8

# 完成
Write-Host ""
Write-Host "✅ 项目 '$ProjectName' 初始化完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📁 目录结构:" -ForegroundColor Cyan
Write-Host "   .ai-team/          # AI团队工作区"
Write-Host "   ├── orchestrator/  # 协调中枢"
Write-Host "   ├── experts/       # 专家工作区"
Write-Host "   └── shared-context/# 共享上下文"
Write-Host "   docs/              # 项目文档"
Write-Host "   src/               # 源代码"
Write-Host "   tests/             # 测试代码"
Write-Host ""
Write-Host "🚀 下一步:" -ForegroundColor Yellow
Write-Host "   1. 编辑 .ai-team\shared-context\project-context.json 配置技术栈"
Write-Host "   2. 开始与 orchestrator-expert 对话启动项目"
