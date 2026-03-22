---
name: analytics-tracking
description: 分析跟踪技能 - 记录 SKILL/Agent 调用、分析使用模式、生成改进建议
---

# 分析跟踪技能

> 记录 SKILL 和 Agent 调用、分析使用模式、生成持续改进建议

## 何时激活

- 项目复盘时
- 需要优化工作流时
- 分析团队使用模式时
- 生成改进报告时

## 技术栈版本

| 技术     | 最低版本 | 推荐版本 |
| -------- | -------- | -------- |
| Node.js  | 18.0+    | 20.0+    |
| SQLite   | 3.0+     | 最新     |
| Chart.js | 4.0+     | 最新     |

## 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                    跟踪分析架构                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │ 调用记录器   │────>│ 数据存储     │────>│ 分析引擎    │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│         │                   │                   │          │
│         ▼                   ▼                   ▼          │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │ SKILL 调用  │     │ Agent 调用  │     │ 改进建议    │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 调用记录格式

### SKILL 调用记录

```json
{
  "type": "skill_invocation",
  "timestamp": "2024-01-15T10:30:00Z",
  "skill_name": "authentication-patterns",
  "context": {
    "project_type": "nextjs",
    "task_description": "实现 OAuth2 登录",
    "user_intent": "添加第三方登录"
  },
  "outcome": {
    "success": true,
    "duration_ms": 45000,
    "files_modified": 5,
    "tests_added": 3
  },
  "feedback": {
    "helpful": true,
    "rating": 4,
    "comments": "很好的指导"
  }
}
```

### Agent 调用记录

```json
{
  "type": "agent_invocation",
  "timestamp": "2024-01-15T10:35:00Z",
  "agent_name": "security-reviewer",
  "trigger": "code-reviewer 委托",
  "context": {
    "files_reviewed": ["auth.ts", "login.tsx"],
    "issues_found": 2,
    "severity": "medium"
  },
  "outcome": {
    "success": true,
    "duration_ms": 30000,
    "recommendations": 3,
    "accepted": 2
  }
}
```

## 数据存储 Schema

```sql
CREATE TABLE skill_invocations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  skill_name TEXT NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  project_type TEXT,
  task_description TEXT,
  success BOOLEAN,
  duration_ms INTEGER,
  files_modified INTEGER,
  tests_added INTEGER,
  rating INTEGER,
  comments TEXT
);

CREATE TABLE agent_invocations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  agent_name TEXT NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  trigger TEXT,
  success BOOLEAN,
  duration_ms INTEGER,
  issues_found INTEGER,
  recommendations INTEGER,
  accepted INTEGER
);

CREATE TABLE improvement_suggestions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  source_type TEXT,
  source_name TEXT,
  suggestion TEXT,
  priority TEXT,
  status TEXT DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  resolved_at DATETIME,
  resolution TEXT
);
```

## 分析脚本

```typescript
import Database from 'better-sqlite3';

const db = new Database('analytics.db');

function analyzeSkillUsage(days: number = 30) {
  const skills = db
    .prepare(
      `
    SELECT 
      skill_name,
      COUNT(*) as total_calls,
      AVG(duration_ms) as avg_duration,
      SUM(CASE WHEN success THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as success_rate,
      AVG(rating) as avg_rating
    FROM skill_invocations
    WHERE timestamp > datetime('now', '-${days} days')
    GROUP BY skill_name
    ORDER BY total_calls DESC
  `
    )
    .all();

  return skills;
}

function analyzeAgentPerformance(days: number = 30) {
  const agents = db
    .prepare(
      `
    SELECT 
      agent_name,
      COUNT(*) as total_calls,
      AVG(duration_ms) as avg_duration,
      SUM(CASE WHEN success THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as success_rate,
      AVG(issues_found) as avg_issues,
      AVG(recommendations) as avg_recommendations,
      AVG(accepted) * 100.0 / NULLIF(AVG(recommendations), 0) as acceptance_rate
    FROM agent_invocations
    WHERE timestamp > datetime('now', '-${days} days')
    GROUP BY agent_name
    ORDER BY total_calls DESC
  `
    )
    .all();

  return agents;
}

function generateImprovementSuggestions() {
  const suggestions = [];

  const lowRatedSkills = db
    .prepare(
      `
    SELECT skill_name, AVG(rating) as avg_rating
    FROM skill_invocations
    GROUP BY skill_name
    HAVING avg_rating < 3.5
  `
    )
    .all();

  lowRatedSkills.forEach((skill) => {
    suggestions.push({
      source_type: 'skill',
      source_name: skill.skill_name,
      suggestion: `考虑优化 ${skill.skill_name} 技能，当前评分 ${skill.avg_rating.toFixed(1)}`,
      priority: 'high',
    });
  });

  const lowAcceptanceAgents = db
    .prepare(
      `
    SELECT agent_name, 
           AVG(accepted) * 100.0 / NULLIF(AVG(recommendations), 0) as acceptance_rate
    FROM agent_invocations
    GROUP BY agent_name
    HAVING acceptance_rate < 50
  `
    )
    .all();

  lowAcceptanceAgents.forEach((agent) => {
    suggestions.push({
      source_type: 'agent',
      source_name: agent.agent_name,
      suggestion: `${agent.agent_name} 建议接受率低，检查建议质量`,
      priority: 'medium',
    });
  });

  return suggestions;
}
```

## 报告生成

```typescript
interface AnalyticsReport {
  period: { start: Date; end: Date };
  summary: {
    totalSkillCalls: number;
    totalAgentCalls: number;
    avgSuccessRate: number;
    avgRating: number;
  };
  topSkills: Array<{ name: string; calls: number }>;
  topAgents: Array<{ name: string; calls: number }>;
  improvements: Array<{
    source: string;
    suggestion: string;
    priority: string;
  }>;
}

function generateReport(days: number = 30): AnalyticsReport {
  return {
    period: {
      start: new Date(Date.now() - days * 24 * 60 * 60 * 1000),
      end: new Date(),
    },
    summary: {
      totalSkillCalls: getTotalCalls('skill', days),
      totalAgentCalls: getTotalCalls('agent', days),
      avgSuccessRate: getAvgSuccessRate(days),
      avgRating: getAvgRating(days),
    },
    topSkills: getTopItems('skill', 5, days),
    topAgents: getTopItems('agent', 5, days),
    improvements: generateImprovementSuggestions(),
  };
}
```

## 使用模式分析

### 识别高频场景

```typescript
function identifyPatterns() {
  const patterns = db
    .prepare(
      `
    SELECT 
      s.skill_name,
      a.agent_name,
      COUNT(*) as co_occurrence
    FROM skill_invocations s
    JOIN agent_invocations a 
      ON DATE(s.timestamp) = DATE(a.timestamp)
    GROUP BY s.skill_name, a.agent_name
    HAVING co_occurrence > 3
    ORDER BY co_occurrence DESC
  `
    )
    .all();

  return patterns.map((p) => ({
    pattern: `${p.skill_name} + ${p.agent_name}`,
    frequency: p.co_occurrence,
    recommendation: `考虑创建组合工作流：${p.skill_name} → ${p.agent_name}`,
  }));
}
```

### 识别缺失技能

```typescript
function identifyMissingSkills() {
  const taskKeywords = db
    .prepare(
      `
    SELECT task_description
    FROM skill_invocations
    WHERE rating < 3 OR comments LIKE '%缺少%'
  `
    )
    .all();

  const keywordAnalysis = analyzeKeywords(taskKeywords);

  return keywordAnalysis.map((k) => ({
    keyword: k.word,
    frequency: k.count,
    suggestion: `考虑创建针对 "${k.word}" 的技能`,
  }));
}
```

## 快速参考

```bash
# 初始化数据库
npx ts-node scripts/init-analytics.ts

# 生成报告
npx ts-node scripts/generate-report.ts --days 30

# 导出数据
npx ts-node scripts/export-analytics.ts --format json

# 清理旧数据
npx ts-node scripts/cleanup-analytics.ts --days 90
```

## 参考

- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [better-sqlite3](https://github.com/WiseLibs/better-sqlite3)
- [Chart.js](https://www.chartjs.org/)
