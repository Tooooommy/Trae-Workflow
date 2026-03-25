---
alwaysApply: false
globs:
  - '**/package.json'
---

# Electron 测试规范

> Electron 桌面应用测试规范。

## 测试类型

| 类型 | 工具 |
|------|------|
| 单元测试 | Vitest + @vitest/ui |
| E2E 测试 | Playwright |
| 组件测试 | Testing Library |

## 测试配置

```typescript
// vitest.config.ts
export default defineConfig({
  environment: 'node',
  include: ['src/**/*.{test,spec}.ts'],
});
```

## E2E 测试

```typescript
// main.test.ts
import { test, expect } from '@playwright/test';

test('window loads', async ({ electronApp }) => {
  const window = await electronApp.firstWindow();
  await expect(window).toHaveTitle('My App');
});
```
