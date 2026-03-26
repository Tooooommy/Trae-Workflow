---
name: design-patterns
description: 设计团队模式。负责交互设计、视觉设计、品牌视觉、设计系统。当需要进行 UI 设计、交互设计、原型设计、设计系统维护时使用此 Skill。
---

# 设计团队模式

用于创建专业、高质量用户界面的设计模式和最佳实践。

## 何时激活

当用户要求以下任一操作时激活：

- 设计新页面（Landing Page、Dashboard、Admin、移动端 App）
- 创建或重构 UI 组件（按钮、表单、卡片、表格）
- 选择配色方案、字体系统、间距标准
- 审查 UI 代码的可访问性或视觉一致性
- 实现导航结构、动画或响应式行为

## 标准输出格式

调用本 Skill 时，输出以下文档：

| # | 文档名称 | 说明 | 时间戳 |
|---|---------|------|--------|
| 3 | 可交互原型链接 | Figma/Protopie 等原型链接 | YYYY-MM-DD |
| 4 | 高保真设计稿 | Sketch/Figma 设计文件 | YYYY-MM-DD |

### 文档命名规范

```
[文档类型]_[项目名称]_[版本]_[日期]
示例：
原型_仪表盘功能_v2.1_2026-03-26
设计稿_移动端首页_v1.0_2026-03-26
```

## 设计原则优先级

| 优先级 | 类别 | 影响 | 检查项 |
| ------ | ---- | ---- | ------ |
| 1 | 可访问性 | CRITICAL | 对比度 4.5:1、ARIA 标签、键盘导航 |
| 2 | 触摸友好 | CRITICAL | 最小 44×44px、间距 8px+ |
| 3 | 性能 | HIGH | WebP/AVIF、懒加载、无 CLS |
| 4 | 响应式 | HIGH | 移动端优先断点 |
| 5 | 一致性 | HIGH | 色彩令牌、间距系统 |

## 可访问性

### 核心检查

```
- 颜色对比度：正常文本 ≥ 4.5:1，大文本 ≥ 3:1
- focus-states：可见焦点环 2-4px
- alt-text：图片有描述性 Alt
- aria-labels：图标按钮有标签
- keyboard-nav：Tab 顺序匹配视觉顺序
- form-labels：label 配合 for 属性
- reduced-motion：尊重 prefers-reduced-motion
```

### 反模式

```
✗ 移除焦点环
✗ 图标按钮无标签
✗ 仅依赖悬停交互
✗ 即时状态变化（0ms）
```

## 色彩系统

### CSS 变量定义

```css
:root {
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-text-primary: #111827;
  --color-text-secondary: #6b7280;
  --color-bg-primary: #ffffff;
  --color-bg-secondary: #f9fafb;
  --color-border: #e5e7eb;
}
```

### 暗色模式

```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-text-primary: #f9fafb;
    --color-text-secondary: #9ca3af;
    --color-bg-primary: #111827;
    --color-bg-secondary: #1f2937;
    --color-border: #374151;
  }
}
```

## 字体与间距

### 字体系统

```css
:root {
  --font-family: system-ui, -apple-system, sans-serif;
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-size-2xl: 1.5rem;
  --line-height-normal: 1.5;
}
```

### 间距系统

```css
:root {
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-3: 0.75rem;
  --spacing-4: 1rem;
  --spacing-6: 1.5rem;
  --spacing-8: 2rem;
}
```

## 组件模式

### 按钮

```css
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-2) var(--spacing-4);
  font-size: var(--font-size-sm);
  font-weight: 500;
  border-radius: 0.375rem;
  min-height: 44px;
  min-width: 44px;
  transition: all 150ms ease;
}

.btn-primary {
  background-color: var(--color-primary);
  color: white;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
```

### 输入框

```css
.input {
  width: 100%;
  padding: var(--spacing-2) var(--spacing-3);
  font-size: var(--font-size-base);
  border: 1px solid var(--color-border);
  border-radius: 0.375rem;
  min-height: 44px;
}

.input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}
```

### 卡片

```css
.card {
  background: var(--color-bg-primary);
  border-radius: 0.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: var(--spacing-6);
}

.card-interactive:hover {
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}
```

## 布局模式

### 响应式断点

```css
/* 移动端默认 */
.container {
  padding: var(--spacing-4);
}

/* 平板 */
@media (min-width: 640px) {
  .container {
    padding: var(--spacing-6);
    max-width: 640px;
  }
}

/* 桌面 */
@media (min-width: 768px) {
  .container {
    padding: var(--spacing-8);
    max-width: 768px;
  }
}
```

### 常用布局

```css
.center-h {
  display: flex;
  justify-content: center;
}

.center-both {
  display: flex;
  justify-content: center;
  align-items: center;
}

.justify-between {
  display: flex;
  justify-content: space-between;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: var(--spacing-6);
}
```

## 移动端导航

### 底部导航

```css
.bottom-nav {
  display: flex;
  justify-content: space-around;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: var(--color-bg-primary);
  padding: var(--spacing-2) 0;
  padding-bottom: calc(var(--spacing-2) + env(safe-area-inset-bottom));
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 64px;
  min-height: 44px;
  color: var(--color-text-secondary);
}

.nav-item-active {
  color: var(--color-primary);
}
```

## 动画原则

```css
.transition-fast {
  transition-duration: 150ms;
}

.transition-normal {
  transition-duration: 200ms;
}

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## 性能优化

### 图片

```html
<img src="image.webp" loading="lazy" alt="描述" />

<picture>
  <source srcset="image.avif" type="image/avif" />
  <source srcset="image.webp" type="image/webp" />
  <img src="image.jpg" alt="描述" />
</picture>
```

### 骨架屏

```css
.skeleton {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
}

@keyframes loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}
```

## 表单设计

### 结构

```html
<div class="form-group">
  <label for="email" class="form-label">
    邮箱地址 <span class="required">*</span>
  </label>
  <input
    type="email"
    id="email"
    class="input"
    placeholder="请输入邮箱"
    aria-describedby="email-helper"
  />
  <p id="email-helper" class="form-helper">我们不会向第三方分享您的邮箱</p>
</div>
```

### 错误提示

```html
<div class="form-group has-error">
  <label for="password" class="form-label">密码</label>
  <input
    type="password"
    id="password"
    class="input input-error"
    aria-invalid="true"
    aria-describedby="password-error"
  />
  <p id="password-error" class="form-error">密码至少需要 8 个字符</p>
</div>
```

## 上线检查清单

### 可访问性

```
[ ] 颜色对比度 ≥ 4.5:1
[ ] 所有图片有 Alt 文本
[ ] 表单有标签
[ ] 支持键盘导航
[ ] 支持 reduced-motion
```

### 触摸友好

```
[ ] 触摸目标 ≥ 44×44px
[ ] 元素间间距 ≥ 8px
[ ] 有加载反馈
[ ] 错误提示明确
```

### 性能

```
[ ] 图片使用 WebP/AVIF
[ ] 开启懒加载
[ ] 无布局抖动（CLS < 0.1）
```

### 响应式

```
[ ] 移动端优先
[ ] 无水平滚动
[ ] 文字不截断
```

## 快速参考

| 元素 | 规范 |
| ---- | ---- |
| 触摸目标 | ≥ 44×44px |
| 间距基准 | 8px |
| 过渡时间 | 150-300ms |
| 字体基准 | 16px |
| 对比度 | ≥ 4.5:1 |
