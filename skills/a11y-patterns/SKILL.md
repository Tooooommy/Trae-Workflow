---
name: a11y-patterns
description: 无障碍设计模式 - WCAG 合规、屏幕阅读器、键盘导航最佳实践。在实现无障碍设计、满足 WCAG 标准或支持屏幕阅读器时激活。
---

# 无障碍设计模式

> WCAG 合规、屏幕阅读器、键盘导航的最佳实践

## 何时激活

- 用户要求实现无障碍设计
- 需要满足 WCAG 标准
- 需要支持屏幕阅读器
- 涉及键盘导航优化
- 色彩对比度检查
- 表单无障碍实现

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|----------|----------|
| WCAG | 2.1 | 2.2 |
| axe-core | 4.0+ | 最新 |
| @testing-library/jest-dom | 6.0+ | 最新 |
| eslint-plugin-jsx-a11y | 6.0+ | 最新 |

---

## WCAG 原则

### 四大原则 (POUR)

| 原则 | 说明 | 关键词 |
|------|------|--------|
| **可感知 (Perceivable)** | 信息必须可被用户感知 | 文本替代、时基媒体、适应性 |
| **可操作 (Operable)** | 用户界面组件必须可操作 | 键盘可访问、充足时间、可导航 |
| **可理解 (Understandable)** | 信息和操作必须可理解 | 可读性、可预测性、输入帮助 |
| **健壮 (Robust)** | 内容必须被各种辅助技术解释 | 兼容性、辅助技术 |

### 合规级别

| 级别 | 说明 | 目标 |
|------|------|------|
| A | 最低级 | 必须满足 |
| AA | 中级 | 推荐满足 (通常要求) |
| AAA | 最高级 | 尽量满足 |

---

## 语义化 HTML

> 优先使用原生语义化标签，而非 ARIA

### 页面结构

```tsx
function PageLayout() {
  return (
    <div>
      <header>
        <nav aria-label="Main navigation">
          <logo />
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/about">About</a></li>
          </ul>
        </nav>
      </header>

      <main id="main-content" tabIndex={-1}>
        <article>
          <header>
            <h1>Article Title</h1>
            <p>By <address rel="author">Author Name</address></p>
          </header>
          <section>{/* content */}</section>
          <footer>
            <nav aria-label="Article navigation">
              <a href="/prev">Previous</a>
              <a href="/next">Next</a>
            </nav>
          </footer>
        </article>
      </main>

      <footer>
        <nav aria-label="Footer navigation">{/* links */}</nav>
      </footer>
    </div>
  );
}
```

### 常用语义标签

| 标签 | 用途 | 无障碍意义 |
|------|------|-----------|
| `<article>` | 独立内容块 | 辅助技术可识别为独立单元 |
| `<nav>` | 导航区域 | 快速跳转导航链接 |
| `<main>` | 主内容区 | 跳过导航直接到主内容 |
| `<aside>` | 侧边栏 | 识别为次要内容 |
| `<header>/<footer>` | 页面头部/底部 | 结构化页面布局 |
| `<button>` | 按钮 | 自动键盘可访问 |
| `<a href>` | 链接 | 可聚焦、可跳转 |

---

## ARIA 属性

> 规则：优先使用语义化 HTML，次选 ARIA

### ARIA 角色

```tsx
// 对话框
<div role="dialog" aria-modal="true" aria-labelledby="title">
  <h2 id="title">Dialog Title</h2>
  {/* content */}
</div>

// 警告
<div role="alert" aria-live="assertive">
  Error: Please check your input
</div>

// 状态
<div role="status" aria-live="polite">
  Changes saved successfully
</div>

// 列表
<ul role="list">
  <li role="listitem">Item 1</li>
  <li role="listitem">Item 2</li>
</ul>
```

### ARIA 状态属性

```tsx
// 展开/折叠
<button aria-expanded={isOpen} aria-controls="content">
  {isOpen ? 'Collapse' : 'Expand'}
</button>
<div id="content" hidden={!isOpen}>

// 选择
<div role="listbox" aria-label="Options">
  <div role="option" aria-selected={selected === 'a'}>Option A</div>
  <div role="option" aria-selected={selected === 'b'}>Option B</div>
</div>

// 进度
<div role="progressbar" aria-valuenow={60} aria-valuemin={0} aria-valuemax={100}>

// 要求
<input aria-required="true" aria-invalid={hasError}>
```

---

## 键盘导航

### 焦点管理

```tsx
function Modal({ isOpen, onClose }) {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousFocus = useRef<HTMLElement>();

  useEffect(() => {
    if (isOpen) {
      previousFocus.current = document.activeElement as HTMLElement;
      modalRef.current?.focus();
    } else {
      previousFocus.current?.focus();
    }
  }, [isOpen]);

  return isOpen ? (
    <div ref={modalRef} tabIndex={-1} role="dialog" aria-modal="true">
      <button onClick={onClose}>Close</button>
    </div>
  ) : null;
}
```

### 下拉菜单

```tsx
function DropdownMenu({ items }) {
  const [isOpen, setIsOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(-1);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setActiveIndex(prev => Math.min(prev + 1, items.length - 1));
        break;
      case 'ArrowUp':
        e.preventDefault();
        setActiveIndex(prev => Math.max(prev - 1, 0));
        break;
      case 'Enter':
      case ' ':
        e.preventDefault();
        if (activeIndex >= 0) items[activeIndex].onClick();
        break;
      case 'Escape':
        setIsOpen(false);
        break;
    }
  };

  return (
    <div role="menu" onKeyDown={handleKeyDown}>
      {items.map((item, index) => (
        <div
          key={item.id}
          role="menuitem"
          tabIndex={isOpen && index === activeIndex ? 0 : -1}
          aria-haspopup={item.children ? 'true' : undefined}
        >
          {item.label}
        </div>
      ))}
    </div>
  );
}
```

### 快捷键

```tsx
function KeyboardShortcut() {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Alt + S: 提交
      if (e.altKey && e.key === 's') {
        e.preventDefault();
        handleSubmit();
      }
      // Escape: 取消
      if (e.key === 'Escape') {
        handleCancel();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  return <button aria-label="Submit (Alt+S)">Submit</button>;
}
```

---

## 表单无障碍

### 标签关联

```tsx
function FormField({ label, hint, error, required }) {
  const id = useId();

  return (
    <div>
      <label htmlFor={id}>
        {label}
        {required && <span aria-hidden="true"> *</span>}
      </label>

      <input
        id={id}
        type="text"
        aria-required={required}
        aria-invalid={!!error}
        aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
      />

      {hint && <small id={`${id}-hint`}>{hint}</small>}
      {error && (
        <span role="alert" id={`${id}-error`}>
          {error}
        </span>
      )}
    </div>
  );
}
```

### 分组

```tsx
function FormGroups() {
  return (
    <form>
      <fieldset>
        <legend>Contact Information</legend>
        <FormField label="Email" type="email" required />
        <FormField label="Phone" type="tel" />
      </fieldset>

      <fieldset>
        <legend>Preferences</legend>
        <label>
          <input type="checkbox" name="newsletter" />
          Subscribe to newsletter
        </label>
        <label>
          <input type="checkbox" name="notifications" />
          Enable notifications
        </label>
      </fieldset>
    </form>
  );
}
```

---

## 跳过链接

```tsx
function SkipLinks() {
  return (
    <a
      href="#main-content"
      className="skip-link"
      style={{
        position: 'absolute',
        left: '-9999px',
        '&:focus': { left: 0 }
      }}
    >
      Skip to main content
    </a>
  );
}

function App() {
  return (
    <>
      <SkipLinks />
      <header>{/* nav */}</header>
      <main id="main-content" tabIndex={-1}>
        {/* main content */}
      </main>
    </>
  );
}
```

---

## 实时区域

> 用于动态内容更新的无障碍通知

```tsx
function StatusUpdates() {
  const [message, setMessage] = useState('');

  return (
    <>
      <button onClick={() => setMessage('Loading...')}>
        Load Data
      </button>

      {/* 礼貌通知 */}
      <div role="status" aria-live="polite" aria-atomic="true">
        {message}
      </div>

      {/* 紧急通知 */}
      <div role="alert" aria-live="assertive">
        {error && <span>Error: {error.message}</span>}
      </div>
    </>
  );
}
```

---

## 测试

### Jest + axe

```typescript
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

describe('Accessibility', () => {
  it('should have no accessibility violations', async () => {
    const { container } = render(<AccessibleComponent />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

### React Testing Library

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('Form accessibility', () => {
  it('should associate label with input', () => {
    render(<FormField label="Email" />);
    expect(screen.getByLabelText('Email')).toBeInTheDocument();
  });

  it('should announce errors to screen readers', () => {
    render(<FormField label="Email" error="Invalid email" />);
    expect(screen.getByRole('alert')).toHaveTextContent('Invalid email');
  });

  it('should trap focus in modal', async () => {
    const user = userEvent.setup();
    render(<Modal isOpen />);

    const modal = screen.getByRole('dialog');
    expect(modal).toHaveFocus();
  });
});
```

---

## 快速检查清单

### 必检项 (A级)

- [ ] 所有图片有 alt 属性
- [ ] 表单有标签
- [ ] 链接/按钮可键盘聚焦
- [ ] 颜色不是唯一信息载体
- [ ] 页面有标题
- [ ] 语言属性设置

### 推荐项 (AA级)

- [ ] 对比度 ≥ 4.5:1
- [ ] 焦点可见
- [ ] 跳过导航链接
- [ ] 焦点顺序合理
- [ ] 错误有文字提示
- [ ] 可缩放至 200%

### 增强项 (AAA级)

- [ ] 对比度 ≥ 7:1
- [ ] 音频有控制
- [ ] 手势有替代方案
- [ ] 翻译标注语言变化

---

## 参考

- [WCAG 2.2 官方指南](https://www.w3.org/WAI/WCAG22/quickref/)
- [WAI-ARIA 实践](https://www.w3.org/WAI/ARIA/apg/)
- [axe-core](https://github.com/dequelabs/axe-core)
- [React 无障碍](https://react.dev/learn/accessibility)
- [WebAIM 对比度检查](https://webaim.org/resources/contrastchecker/)
