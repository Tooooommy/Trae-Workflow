---
alwaysApply: false
globs:
  - '**/*.ts'
  - '**/*.tsx'
  - '**/*.js'
  - '**/*.jsx'
---

# TypeScript/JavaScript 测试

> TypeScript/JavaScript 语言特定的测试框架和策略。

## 测试框架

| 类型     | 推荐框架        |
| -------- | --------------- |
| 单元测试 | Vitest          |
| E2E 测试 | Playwright      |
| 组件测试 | Testing Library |

## 覆盖率

```bash
vitest run --coverage
```

## 测试组织

```typescript
// __tests__/user.test.ts
describe('User', () => {
  it('should create user', () => {
    const user = createUser({ name: 'Test' });
    expect(user.name).toBe('Test');
  });
});
```

## 相关智能体

- `testing-expert` - TDD 工作流和测试策略

## 相关技能

- `tdd-patterns` - 测试驱动开发
- `e2e-testing` - Playwright E2E 测试
