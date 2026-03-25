---
name: feature-flags
description: 功能开关模式 - 特性开关、A/B测试、渐进发布最佳实践。**必须激活当**：用户要求实现功能开关、配置 A/B 测试或进行渐进发布时。即使用户没有明确说"功能开关"，当涉及特性开关或 A/B 测试时也应使用。
---

# 功能开关模式

> 特性开关、A/B测试、渐进发布的最佳实践

## 何时激活

- 渐进式功能发布
- A/B 测试
- 紧急功能关闭
- 环境差异化配置
- 金丝雀发布

## 技术栈版本

| 技术             | 最低版本 | 推荐版本 |
| ---------------- | -------- | -------- |
| LaunchDarkly SDK | 7.0+     | 最新     |
| Unleash          | 5.0+     | 最新     |
| Flagsmith        | 4.0+     | 最新     |
| Optimizely       | 4.0+     | 最新     |

## 开关类型

| 类型     | 生命周期 | 用途     |
| -------- | -------- | -------- |
| 发布开关 | 短期     | 渐进发布 |
| 实验开关 | 中期     | A/B 测试 |
| 运维开关 | 长期     | 紧急关闭 |
| 权限开关 | 长期     | 用户权限 |

## 基础实现

```typescript
interface FeatureFlag {
  name: string;
  enabled: boolean;
  conditions?: FlagCondition[];
}

interface FlagCondition {
  type: 'user' | 'percentage' | 'environment' | 'time';
  value: any;
}

class FeatureFlagService {
  private flags = new Map<string, FeatureFlag>();

  constructor(flags: FeatureFlag[]) {
    flags.forEach((flag) => this.flags.set(flag.name, flag));
  }

  isEnabled(name: string, context: FlagContext = {}): boolean {
    const flag = this.flags.get(name);
    if (!flag) return false;

    if (!flag.enabled) return false;

    if (!flag.conditions || flag.conditions.length === 0) {
      return true;
    }

    return flag.conditions.every((condition) => this.evaluate(condition, context));
  }

  private evaluate(condition: FlagCondition, context: FlagContext): boolean {
    switch (condition.type) {
      case 'user':
        return condition.value.includes(context.userId);
      case 'percentage':
        return this.hashPercentage(context.userId || 'anonymous') < condition.value;
      case 'environment':
        return condition.value.includes(context.environment);
      case 'time':
        return new Date() >= new Date(condition.value);
      default:
        return false;
    }
  }

  private hashPercentage(key: string): number {
    let hash = 0;
    for (let i = 0; i < key.length; i++) {
      hash = (hash << 5) - hash + key.charCodeAt(i);
      hash = hash & hash;
    }
    return Math.abs(hash) % 100;
  }
}

interface FlagContext {
  userId?: string;
  environment?: string;
  attributes?: Record<string, any>;
}
```

## LaunchDarkly 集成

```typescript
import LaunchDarkly from 'launchdarkly-node-server-sdk';

const client = LaunchDarkly.init(process.env.LAUNCHDARKLY_SDK_KEY!);

await client.waitForInitialization();

async function checkFeature(
  flagKey: string,
  userId: string,
  defaultValue: boolean = false
): Promise<boolean> {
  const user = { key: userId };
  return client.variation(flagKey, user, defaultValue);
}

async function checkFeatureWithDetails<T>(
  flagKey: string,
  userId: string,
  defaultValue: T
): Promise<T> {
  const user = { key: userId };
  return client.variation(flagKey, user, defaultValue);
}

app.get('/api/feature', async (req, res) => {
  const userId = req.user?.id || 'anonymous';

  const newFeatureEnabled = await checkFeature('new-dashboard', userId);
  const maxItems = await checkFeatureWithDetails('max-items', userId, 10);

  res.json({
    newDashboard: newFeatureEnabled,
    maxItems,
  });
});
```

## Unleash 集成

```typescript
import { UnleashClient } from 'unleash-client';

const unleash = new UnleashClient({
  url: process.env.UNLEASH_URL!,
  appName: 'my-app',
  environment: process.env.NODE_ENV,
  customHeaders: {
    Authorization: process.env.UNLEASH_API_KEY!,
  },
});

unleash.start();

function isFeatureEnabled(name: string, context: any = {}): boolean {
  return unleash.isEnabled(name, context);
}

function getVariant(name: string, context: any = {}): any {
  return unleash.getVariant(name, context);
}

app.get('/api/check', (req, res) => {
  const context = {
    userId: req.user?.id,
    properties: {
      plan: req.user?.plan,
      region: req.headers['x-region'],
    },
  };

  res.json({
    darkMode: isFeatureEnabled('dark-mode', context),
    variant: getVariant('checkout-flow', context),
  });
});
```

## A/B 测试

```typescript
interface Experiment {
  name: string;
  variants: Variant[];
}

interface Variant {
  name: string;
  weight: number;
  config: Record<string, any>;
}

class ExperimentService {
  private experiments = new Map<string, Experiment>();

  getVariant(experimentName: string, userId: string): Variant {
    const experiment = this.experiments.get(experimentName);
    if (!experiment) throw new Error('Experiment not found');

    const hash = this.hashUserId(userId, experimentName);
    const percentage = hash % 100;

    let cumulative = 0;
    for (const variant of experiment.variants) {
      cumulative += variant.weight;
      if (percentage < cumulative) {
        return variant;
      }
    }

    return experiment.variants[0];
  }

  private hashUserId(userId: string, experimentName: string): number {
    const str = `${userId}-${experimentName}`;
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = (hash << 5) - hash + str.charCodeAt(i);
      hash = hash & hash;
    }
    return Math.abs(hash);
  }
}

const checkoutExperiment: Experiment = {
  name: 'checkout-flow',
  variants: [
    { name: 'control', weight: 50, config: { steps: 3 } },
    { name: 'variant-a', weight: 25, config: { steps: 2 } },
    { name: 'variant-b', weight: 25, config: { steps: 1 } },
  ],
};
```

## 渐进发布

```typescript
class ProgressiveRollout {
  private flagService: FeatureFlagService;

  async getRolloutPercentage(flagName: string): Promise<number> {
    const config = await this.getFlagConfig(flagName);
    return config.rolloutPercentage || 0;
  }

  async incrementRollout(flagName: string, increment: number = 10): Promise<void> {
    const current = await this.getRolloutPercentage(flagName);
    const newPercentage = Math.min(current + increment, 100);

    await this.updateFlag(flagName, {
      rolloutPercentage: newPercentage,
    });
  }

  async shouldShowFeature(flagName: string, userId: string): Promise<boolean> {
    const percentage = await this.getRolloutPercentage(flagName);
    const hash = this.hashUserId(userId, flagName);
    return hash % 100 < percentage;
  }
}
```

## React 集成

```typescript
import { useFlags } from 'launchdarkly-react-client-sdk';

function FeatureComponent() {
  const { 'new-feature': newFeatureEnabled, 'checkout-flow': checkoutVariant } = useFlags();

  if (!newFeatureEnabled) {
    return <OldComponent />;
  }

  return (
    <div>
      {checkoutVariant === 'simplified' ? (
        <SimplifiedCheckout />
      ) : (
        <StandardCheckout />
      )}
    </div>
  );
}
```

## 监控与告警

```typescript
class FeatureFlagMonitor {
  async trackEvaluation(flagName: string, result: boolean, context: any) {
    await this.metrics.increment('feature_flag.evaluation', {
      flag: flagName,
      result: result.toString(),
    });
  }

  async trackError(flagName: string, error: Error) {
    await this.metrics.increment('feature_flag.error', {
      flag: flagName,
      error: error.message,
    });

    await this.alerting.notify({
      type: 'feature_flag_error',
      flag: flagName,
      error: error.message,
    });
  }
}
```

## 最佳实践

| 实践       | 说明                 |
| ---------- | -------------------- |
| 默认值     | 始终提供安全的默认值 |
| 短生命周期 | 发布开关用完即删     |
| 命名规范   | 使用清晰的命名前缀   |
| 监控       | 跟踪开关使用情况     |
| 文档       | 记录开关用途和计划   |

## 快速参考

```typescript
// 检查开关
if (featureFlags.isEnabled('new-feature', { userId })) {
  // 新功能
}

// A/B 测试
const variant = experiment.getVariant('checkout-flow', userId);

// 渐进发布
await rollout.increment('new-feature', 10);

// React 钩子
const flags = useFlags();
```

## 参考

- [LaunchDarkly](https://launchdarkly.com/docs/)
- [Unleash](https://docs.getunleash.io/)
- [Feature Toggles (Martin Fowler)](https://martinfowler.com/articles/feature-toggles.html)
- [Flagsmith](https://docs.flagsmith.com/)
