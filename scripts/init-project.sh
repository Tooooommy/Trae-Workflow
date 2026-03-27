#!/bin/bash
# AI Team 项目初始化脚本
# 用法: ./init-project.sh <project-name>

set -e

PROJECT_NAME=${1:-"new-project"}
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "🚀 正在初始化项目: $PROJECT_NAME"
echo ""

# 1. 创建目录结构
echo "📁 创建目录结构..."
mkdir -p .ai-team/orchestrator/decision-registry
mkdir -p .ai-team/experts/{product-strategist,tech-architect,ux-engineer,frontend-specialist,backend-specialist,mobile-specialist,devops-engineer,security-auditor,quality-engineer,performance-specialist,docs-engineer,retro-facilitator}
mkdir -p .ai-team/shared-context
mkdir -p docs/{01-requirements,02-design,03-implementation,04-testing,05-deployment}
mkdir -p src tests .github/workflows scripts

# 2. 初始化 task-board.json
echo "📋 初始化任务看板..."
cat > .ai-team/orchestrator/task-board.json << EOF
{
  "project": {
    "name": "$PROJECT_NAME",
    "description": "",
    "createdAt": "$DATE",
    "updatedAt": "$DATE"
  },
  "backlog": [],
  "inProgress": [],
  "blocked": [],
  "completed": []
}
EOF

# 3. 初始化工作流日志
echo "📝 初始化工作流日志..."
cat > .ai-team/orchestrator/workflow-log.md << EOF
# 工作流日志

> 项目: $PROJECT_NAME
> 创建时间: ${DATE}

## 日志记录

| 时间 | 专家 | 动作 | 状态 | 备注 |
|------|------|------|------|------|
EOF

# 4. 初始化项目上下文
echo "🔧 初始化项目上下文..."
cat > .ai-team/shared-context/project-context.json << EOF
{
  "project": {
    "name": "$PROJECT_NAME",
    "techStack": {
      "frontend": "",
      "backend": "",
      "database": "",
      "deployment": ""
    },
    "constraints": {
      "budget": "",
      "timeline": "",
      "team": []
    }
  },
  "stakeholders": [],
  "milestones": [],
  "decisions": []
}
EOF

# 5. 初始化知识图谱
echo "📚 初始化知识图谱..."
cat > .ai-team/shared-context/knowledge-graph.md << EOF
# 知识图谱

> 项目: $PROJECT_NAME

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
EOF

# 6. 初始化各专家工作区
echo "👥 初始化专家工作区..."
for expert in product-strategist tech-architect ux-engineer frontend-specialist backend-specialist mobile-specialist devops-engineer security-auditor quality-engineer performance-specialist docs-engineer retro-facilitator; do
  cat > .ai-team/experts/$expert/WORKSPACE.md << EOF
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
EOF
done

# 7. 初始化文档目录
echo "📄 初始化文档目录..."

cat > docs/01-requirements/README.md << 'EOF'
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
EOF

cat > docs/02-design/README.md << 'EOF'
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
EOF

cat > docs/03-implementation/README.md << 'EOF'
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
EOF

cat > docs/04-testing/README.md << 'EOF'
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
EOF

cat > docs/05-deployment/README.md << 'EOF'
# 部署文档目录

## 文档类型

| 文档 | 说明 |
|------|------|
| deployment-*.md | 部署指南 |
| monitoring-*.md | 监控配置 |
| retrospective-*.md | 复盘报告 |

## 当前文档

_暂无文档_
EOF

# 8. 创建决策记录模板
cat > .ai-team/orchestrator/decision-registry/README.md << 'EOF'
# 决策记录库

## ADR 模板

```markdown
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
```

## 决策索引

| 编号 | 标题 | 状态 | 日期 |
|------|------|------|------|

_暂无决策记录_
EOF

# 完成
echo ""
echo "✅ 项目 '$PROJECT_NAME' 初始化完成！"
echo ""
echo "📁 目录结构:"
echo "   .ai-team/          # AI团队工作区"
echo "   ├── orchestrator/  # 协调中枢"
echo "   ├── experts/       # 专家工作区"
echo "   └── shared-context/# 共享上下文"
echo "   docs/              # 项目文档"
echo "   src/               # 源代码"
echo "   tests/             # 测试代码"
echo ""
echo "🚀 下一步:"
echo "   1. 编辑 .ai-team/shared-context/project-context.json 配置技术栈"
echo "   2. 开始与 orchestrator-expert 对话启动项目"
