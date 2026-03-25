---
name: analytics-tracking
description: 分析跟踪技能 - 记录 SKILL/Agent 调用、分析使用模式、生成改进建议。**必须激活当**：用户要求分析技能使用情况、跟踪性能指标、生成分析报告或优化工作流程时。即使用户没有明确说"分析"，当涉及使用模式分析、性能监控或改进建议时也应使用。
---

# 分析跟踪技能

用于记录和分析 SKILL/Agent 调用模式，生成改进建议和工作流程优化。

## 何时激活

- 分析技能使用模式
- 跟踪性能指标
- 生成分析报告
- 优化工作流程
- 识别常见问题

## 核心功能

### 1. 调用记录

```typescript
interface SkillCall {
  skillName: string;
  timestamp: Date;
  duration: number;
  success: boolean;
  error?: string;
  context: {
    userId: string;
    sessionId: string;
    taskType: string;
  };
}

function recordSkillCall(call: SkillCall): void {
  console.log(`[Analytics] ${call.skillName} - ${call.duration}ms - ${call.success ? '✓' : '✗'}`);
}
```

### 2. 使用模式分析

```typescript
interface UsagePattern {
  skillName: string;
  totalCalls: number;
  successRate: number;
  avgDuration: number;
  peakHours: string[];
  commonContexts: string[];
}

function analyzePatterns(calls: SkillCall[]): UsagePattern[] {
  const grouped = calls.reduce(
    (acc, call) => {
      acc[call.skillName] = acc[call.skillName] || [];
      acc[call.skillName].push(call);
      return acc;
    },
    {} as Record<string, SkillCall[]>
  );

  return Object.entries(grouped).map(([skillName, skillCalls]) => ({
    skillName,
    totalCalls: skillCalls.length,
    successRate: skillCalls.filter((c) => c.success).length / skillCalls.length,
    avgDuration: skillCalls.reduce((sum, c) => sum + c.duration, 0) / skillCalls.length,
    peakHours: analyzePeakHours(skillCalls),
    commonContexts: analyzeCommonContexts(skillCalls),
  }));
}
```

### 3. 改进建议生成

```typescript
interface Improvement {
  type: 'optimization' | 'fix' | 'enhancement';
  priority: 'high' | 'medium' | 'low';
  description: string;
  potentialImpact: string;
}

function generateImprovements(patterns: UsagePattern[]): Improvement[] {
  return patterns
    .filter((p) => p.successRate < 0.8)
    .map((p) => ({
      type: 'fix' as const,
      priority: 'high' as const,
      description: `${p.skillName} 成功率低于 80%`,
      potentialImpact: '提高任务完成效率',
    }));
}
```

## 分析报告格式

```markdown
## 分析报告

### 概览

- 总调用次数：X
- 成功率：X%
- 平均响应时间：Xms

### 技能使用排行

| 技能 | 调用次数 | 成功率 |
| ---- | -------- | ------ |
| xxx  | X        | X%     |

### 改进建议

1. [高优先级] xxx
2. [中优先级] xxx
```

## 集成方式

```typescript
class AnalyticsTracker {
  private calls: SkillCall[] = [];

  track(call: Omit<SkillCall, 'timestamp'>) {
    this.calls.push({ ...call, timestamp: new Date() });
  }

  getReport(): string {
    const patterns = analyzePatterns(this.calls);
    return generateReport(patterns);
  }
}
```
