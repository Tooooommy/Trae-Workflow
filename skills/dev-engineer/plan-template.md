# [Feature Name] 开发计划

> **目标**: [一句话描述要实现的功能]

**技术栈**: [关键技术/库]

---

## 文件结构

- Create: `src/components/Button.tsx`
- Modify: `src/pages/Home.tsx:45-60`
- Test: `src/components/Button.test.tsx`

---

## 任务分解

### Task 1: [组件名称]

**文件**:
- Create: `src/components/Button.tsx`
- Test: `src/components/Button.test.tsx`

- [ ] **Step 1: 编写失败的测试**

```typescript
// src/components/Button.test.tsx
import { render, screen } from '@testing-library/react';
import { Button } from './Button';

test('renders button with text', () => {
  render(<Button>Click me</Button>);
  expect(screen.getByText('Click me')).toBeInTheDocument();
});
```

- [ ] **Step 2: 运行测试确认失败**

运行: `npm test -- Button.test.tsx`
预期: FAIL - "Button not defined"

- [ ] **Step 3: 编写最小实现**

```typescript
// src/components/Button.tsx
export function Button({ children }: { children: React.ReactNode }) {
  return <button>{children}</button>;
}
```

- [ ] **Step 4: 运行测试确认通过**

运行: `npm test -- Button.test.tsx`
预期: PASS

- [ ] **Step 5: 提交**

```bash
git add src/components/Button.tsx src/components/Button.test.tsx
git commit -m "feat: add Button component"
```

---

## 自检清单

- [ ] 所有任务步骤使用 checkbox (`- [ ]`) 语法
- [ ] 每个任务 2-5 分钟可完成
- [ ] 包含完整的代码示例
- [ ] 包含具体的运行命令和预期输出
- [ ] 无 "TBD", "TODO", "稍后" 等占位符
- [ ] 函数名、类型名在不同任务中保持一致
