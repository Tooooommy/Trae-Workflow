---
name: a11y-patterns
description: 无障碍设计模式 - WCAG 合规、屏幕阅读器、键盘导航最佳实践。**必须激活当**：用户要求实现无障碍设计、满足 WCAG 标准或支持屏幕阅读器时。即使用户没有明确说"无障碍"，当涉及 WCAG、屏幕阅读器或键盘导航时也应使用。
---

# 无障碍设计模式

> WCAG 合规、屏幕阅读器、键盘导航的最佳实践

## 何时激活

- 实现 WCAG 合规
- 屏幕阅读器支持
- 键盘导航优化
- 色彩对比度检查
- 表单无障碍

## 技术栈版本

| 技术                      | 最低版本 | 推荐版本 |
| ------------------------- | -------- | -------- |
| WCAG                      | 2.1      | 2.2      |
| axe-core                  | 4.0+     | 最新     |
| @testing-library/jest-dom | 6.0+     | 最新     |
| eslint-plugin-jsx-a11y    | 6.0+     | 最新     |

## WCAG 原则

```
┌─────────────────────────────────────────────────────────────┐
│                    WCAG 四大原则                             │
├─────────────────┬─────────────────┬─────────────────────────┤
│   可感知 (P)    │   可操作 (O)    │   可理解 (U)   │ 健壮 (R)│
├─────────────────┼─────────────────┼─────────────────────────┤
│ 文本替代        │ 键盘可访问      │ 可读性        │ 兼容性  │
│ 时基媒体        │ 充足时间        │ 可预测性      │ 辅助技术│
│ 适应性          │ 癫痫发作        │ 输入帮助      │         │
│ 可辨别          │ 可导航          │               │         │
│                 │ 输入方式        │               │         │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 语义化 HTML

```tsx
function Article({ title, content, author, date }) {
  return (
    <article>
      <header>
        <h1>{title}</h1>
        <p>
          By <address rel="author">{author}</address>
          on <time dateTime={date}>{formatDate(date)}</time>
        </p>
      </header>
      <main>{content}</main>
      <footer>
        <nav aria-label="Article navigation">
          <a href="/previous">Previous</a>
          <a href="/next">Next</a>
        </nav>
      </footer>
    </article>
  );
}
```

## ARIA 属性

```tsx
function Modal({ isOpen, onClose, title, children }) {
  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      aria-describedby="modal-description"
      hidden={!isOpen}
    >
      <div className="modal-content">
        <h2 id="modal-title">{title}</h2>
        <div id="modal-description">{children}</div>
        <button aria-label="Close modal" onClick={onClose}>
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    </div>
  );
}

function Tabs({ tabs, activeTab, onSelect }) {
  return (
    <div>
      <div role="tablist" aria-label="Content tabs">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            role="tab"
            aria-selected={activeTab === tab.id}
            aria-controls={`panel-${tab.id}`}
            id={`tab-${tab.id}`}
            onClick={() => onSelect(tab.id)}
          >
            {tab.label}
          </button>
        ))}
      </div>
      {tabs.map((tab) => (
        <div
          key={tab.id}
          role="tabpanel"
          id={`panel-${tab.id}`}
          aria-labelledby={`tab-${tab.id}`}
          hidden={activeTab !== tab.id}
        >
          {tab.content}
        </div>
      ))}
    </div>
  );
}
```

## 表单无障碍

```tsx
function Form() {
  return (
    <form>
      <div>
        <label htmlFor="email">Email Address</label>
        <input
          id="email"
          type="email"
          name="email"
          aria-required="true"
          aria-describedby="email-hint"
          aria-invalid={errors.email ? 'true' : 'false'}
        />
        <span id="email-hint">We'll never share your email.</span>
        {errors.email && (
          <span role="alert" id="email-error">
            {errors.email}
          </span>
        )}
      </div>

      <fieldset>
        <legend>Notification Preferences</legend>
        <label>
          <input type="checkbox" name="notifications" value="email" />
          Email notifications
        </label>
        <label>
          <input type="checkbox" name="notifications" value="sms" />
          SMS notifications
        </label>
      </fieldset>

      <button type="submit">Submit</button>
    </form>
  );
}
```

## 键盘导航

```tsx
function Menu({ items }) {
  const [activeIndex, setActiveIndex] = useState(0);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setActiveIndex((prev) => (prev + 1) % items.length);
        break;
      case 'ArrowUp':
        e.preventDefault();
        setActiveIndex((prev) => (prev - 1 + items.length) % items.length);
        break;
      case 'Enter':
      case ' ':
        e.preventDefault();
        items[activeIndex].onClick();
        break;
      case 'Escape':
        onClose();
        break;
    }
  };

  return (
    <ul role="menu" onKeyDown={handleKeyDown}>
      {items.map((item, index) => (
        <li
          key={item.id}
          role="menuitem"
          tabIndex={index === activeIndex ? 0 : -1}
          onClick={item.onClick}
        >
          {item.label}
        </li>
      ))}
    </ul>
  );
}
```

## 跳过链接

```tsx
function SkipLink() {
  return (
    <a
      href="#main-content"
      className="skip-link"
      style={{
        position: 'absolute',
        left: '-9999px',
        top: 'auto',
        width: '1px',
        height: '1px',
        overflow: 'hidden',
      }}
      onFocus={(e) => {
        e.target.style.left = '0';
        e.target.style.width = 'auto';
        e.target.style.height = 'auto';
      }}
      onBlur={(e) => {
        e.target.style.left = '-9999px';
        e.target.style.width = '1px';
        e.target.style.height = '1px';
      }}
    >
      Skip to main content
    </a>
  );
}
```

## 实时区域

```tsx
function LiveRegion() {
  const [message, setMessage] = useState('');

  return (
    <>
      <button onClick={() => setMessage('Action completed successfully')}>Perform Action</button>
      <div role="status" aria-live="polite" aria-atomic="true" className="sr-only">
        {message}
      </div>
    </>
  );
}
```

## 测试

```typescript
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

describe('Accessibility', () => {
  it('should have no accessibility violations', async () => {
    const { container } = render(<Component />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

## 快速参考

```tsx
// 语义化标签
<article>, <nav>, <main>, <header>, <footer>

// ARIA 角色
role="button", role="dialog", role="tablist"

// ARIA 状态
aria-expanded, aria-selected, aria-checked

// ARIA 属性
aria-label, aria-labelledby, aria-describedby

// 实时区域
aria-live="polite", aria-live="assertive"

// 隐藏
aria-hidden="true"
```

## 参考

- [WCAG 2.2 Guidelines](https://www.w3.org/WAI/WCAG22/quickref/)
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [axe-core](https://github.com/dequelabs/axe-core)
- [React Accessibility](https://react.dev/learn/accessibility)
