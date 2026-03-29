# [Feature Name] Implementation Plan

> **执行要求**: 按照本计划逐条执行，每个任务使用 checkbox (`- [ ]`) 跟踪进度。

**Goal:** [一句话描述要实现的功能]

**Architecture:** [2-3句话描述技术方案]

**Tech Stack:** [关键技术/库版本]

---

## 文件结构

| 文件                                  | 操作   | 说明          |
| ------------------------------------- | ------ | ------------- |
| `src/components/[Component].tsx`      | Create | [组件说明]    |
| `src/components/[Component].test.tsx` | Create | [测试说明]    |
| `src/api/[api].ts`                    | Modify | [API修改说明] |

---

## 任务分解

### Task 1: [组件/功能名称]

**Files:**

- Create: `src/components/[Component].tsx`
- Modify: `src/pages/[Page].tsx:[line-range]`
- Test: `src/components/[Component].test.tsx`

- [ ] **Step 1: 编写失败的测试**

```typescript
// src/components/[Component].test.tsx
import { render, screen } from '@testing-library/react';
import { [Component] } from './[Component]';

test('renders [Component] with [expected]', () => {
  render(<[Component] prop="value" />);
  expect(screen.getByText('expected')).toBeInTheDocument();
});
```

- [ ] **Step 2: 运行测试确认失败**

Run: `npm test -- [Component].test.tsx`
Expected: FAIL with "[Component] not defined"

- [ ] **Step 3: 编写最小实现**

```typescript
// src/components/[Component].tsx
export function [Component]({ prop }: { prop: string }) {
  return <div>{prop}</div>;
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `npm test -- [Component].test.tsx`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add src/components/[Component].tsx src/components/[Component].test.tsx
git commit -m "feat: add [Component] component with tests"
```

---

### Task 2: [下一个组件/功能]

**Files:**

- Create: `src/[path]/[file].ts`
- Modify: `src/[path]/[existing].ts:[line-range]`
- Test: `src/[path]/[file].test.ts`

- [ ] **Step 1: 编写失败的测试**

```typescript
// 完整的测试代码
```

- [ ] **Step 2: 运行测试确认失败**

Run: `npm test -- [file].test.ts`
Expected: FAIL with "..."

- [ ] **Step 3: 编写最小实现**

```typescript
// 完整的实现代码（仅满足测试）
```

- [ ] **Step 4: 运行测试确认通过**

Run: `npm test -- [file].test.ts`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add src/[path]/[file].ts src/[path]/[file].test.ts
git commit -m "feat: add [feature description]"
```
