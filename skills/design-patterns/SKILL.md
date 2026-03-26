---
name: design-patterns
description: UI/UX 设计模式。涵盖 Web 和移动端应用设计，包含样式选择、色彩搭配、排版、布局、交互模式等。适用于页面设计、组件设计、用户体验优化场景。
---

# UI/UX 设计模式

用于创建专业、高质量用户界面的设计模式和最佳实践。

## 何时激活

- 设计新页面（Landing Page、Dashboard、Admin、SaaS、移动端 App）
- 创建或重构 UI 组件（按钮、模态框、表单、表格、图表等）
- 选择配色方案、字体系统、间距标准或布局系统
- 审查 UI 代码的用户体验、可访问性或视觉一致性
- 实现导航结构、动画或响应式行为
- 做出产品级设计决策（风格、信息层级、品牌表达）
- 提升界面的感知质量、清晰度或可用性

## 设计原则

### 优先级表

| 优先级 | 类别         | 影响     | 关键检查                                    |
| ------ | ------------ | -------- | ------------------------------------------- |
| 1      | 可访问性     | CRITICAL | 对比度 4.5:1、Alt 文本、键盘导航、ARIA 标签 |
| 2      | 触摸与交互   | CRITICAL | 最小尺寸 44×44px、间距 8px+、加载反馈       |
| 3      | 性能         | HIGH     | WebP/AVIF、懒加载、CLS < 0.1                |
| 4      | 样式选择     | HIGH     | 匹配产品类型、一致性、SVG 图标              |
| 5      | 布局与响应式 | HIGH     | 移动端优先断点、Viewport meta、无水平滚动   |
| 6      | 排版与色彩   | MEDIUM   | 基准 16px、行高 1.5、语义色彩令牌           |
| 7      | 动画         | MEDIUM   | 持续时间 150-300ms、减少动画支持            |
| 8      | 表单与反馈   | MEDIUM   | 可见标签、错误提示、渐进式披露              |
| 9      | 导航模式     | HIGH     | 可预测返回、底部导航 ≤5、深链接             |
| 10     | 图表与数据   | LOW      | 图例、工具提示、无障碍色彩                  |

## 可访问性（必须检查）

### 核心检查项

```markdown
- color-contrast: 正常文本最小 4.5:1（大型文本 3:1）
- focus-states: 交互元素可见焦点环（2-4px）
- alt-text: 有意义图片的描述性 Alt 文本
- aria-labels: 图标按钮的 aria-label
- keyboard-nav: Tab 顺序匹配视觉顺序
- form-labels: 使用 label 配合 for 属性
- skip-links: 跳转到主要内容
- heading-hierarchy: 顺序 h1→h6，不跳过层级
- color-not-only: 不单独用颜色传达信息
- reduced-motion: 尊重 prefers-reduced-motion
```

### 反模式（避免）

- 移除焦点环
- 图标按钮无标签
- 仅依赖悬停的交互
- 即时状态变化（0ms）
- 系统缩放时截断文本

## 触摸与交互（移动端关键）

### 核心检查项

```markdown
- touch-target-size: 最小 44×44pt（Apple）/ 48×48dp（Material）
- touch-spacing: 触摸目标间最小 8px/8dp 间距
- hover-vs-tap: 使用点击/触摸作为主要交互
- loading-buttons: 异步操作期间禁用按钮，显示加载指示
- error-feedback: 错误提示靠近问题区域
```

### 反模式（避免）

- 触摸目标过小
- 仅依赖悬停的交互
- 无加载反馈
- 错误信息远离输入框

## 性能

### 图片优化

```markdown
- 使用 WebP/AVIF 格式
- 懒加载图片
- 预留图片空间（防止 CLS）
- 使用 CDN + 合适尺寸
```

```html
<!-- WebP + 懒加载 -->
<img src="image.webp" loading="lazy" alt="描述" />

<!-- 响应式图片 -->
<img
  srcset="small.jpg 480w, medium.jpg 800w, large.jpg 1200w"
  sizes="(max-width: 600px) 480px, (max-width: 900px) 800px, 1200px"
  src="medium.jpg"
  alt="描述"
/>
```

### 布局稳定性

```css
/* 避免布局抖动 */
img {
  width: 100%;
  aspect-ratio: 16/9;
  object-fit: cover;
}

/* 预留空间 */
.skeleton {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
}
```

## 样式与品牌

### 色彩系统

```css
:root {
  /* 主色 */
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-primary-active: #1d4ed8;

  /* 语义色 */
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-info: #06b6d4;

  /* 中性色 */
  --color-text-primary: #111827;
  --color-text-secondary: #6b7280;
  --color-text-disabled: #9ca3af;
  --color-bg-primary: #ffffff;
  --color-bg-secondary: #f9fafb;
  --color-border: #e5e7eb;
}
```

### 字体系统

```css
:root {
  --font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-size-xs: 0.75rem; /* 12px */
  --font-size-sm: 0.875rem; /* 14px */
  --font-size-base: 1rem; /* 16px */
  --font-size-lg: 1.125rem; /* 18px */
  --font-size-xl: 1.25rem; /* 20px */
  --font-size-2xl: 1.5rem; /* 24px */
  --font-size-3xl: 1.875rem; /* 30px */

  --line-height-tight: 1.25;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;
}
```

### 间距系统

```css
:root {
  --spacing-1: 0.25rem; /* 4px */
  --spacing-2: 0.5rem; /* 8px */
  --spacing-3: 0.75rem; /* 12px */
  --spacing-4: 1rem; /* 16px */
  --spacing-6: 1.5rem; /* 24px */
  --spacing-8: 2rem; /* 32px */
  --spacing-12: 3rem; /* 48px */
  --spacing-16: 4rem; /* 64px */
}
```

## 布局与响应式

### 移动端优先断点

```css
/* 移动端默认样式 */
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

/* 大屏 */
@media (min-width: 1024px) {
  .container {
    max-width: 1024px;
  }
}
```

### 常见布局模式

```css
/* 水平居中 */
.center-horizontal {
  display: flex;
  justify-content: center;
}

/* 垂直居中 */
.center-vertical {
  display: flex;
  align-items: center;
}

/* 水平垂直居中 */
.center-both {
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 两端对齐 */
.justify-between {
  display: flex;
  justify-content: space-between;
}

/* 栅格系统 */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: var(--spacing-6);
}
```

## 组件设计

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
  min-height: 44px; /* 触摸友好 */
  min-width: 44px;
  transition: all 150ms ease;
}

.btn-primary {
  background-color: var(--color-primary);
  color: white;
}

.btn-primary:hover {
  background-color: var(--color-primary-hover);
}

.btn-primary:active {
  background-color: var(--color-primary-active);
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
  transition:
    border-color 150ms ease,
    box-shadow 150ms ease;
}

.input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.input-error {
  border-color: var(--color-error);
}

.input-error:focus {
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}
```

### 卡片

```css
.card {
  background-color: var(--color-bg-primary);
  border-radius: 0.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: var(--spacing-6);
}

.card-hover:hover {
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
  transition: all 200ms ease;
}
```

## 动画与过渡

### 原则

```css
/* 快速响应 */
.transition-fast {
  transition-duration: 150ms;
}

/* 标准过渡 */
.transition-normal {
  transition-duration: 200ms;
}

/* 缓慢过渡 */
.transition-slow {
  transition-duration: 300ms;
}

/* 尊重减少动画偏好 */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### 微交互

```css
/* 按钮点击效果 */
.btn:active {
  transform: scale(0.98);
}

/* 加载状态 */
.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid var(--color-border);
  border-top-color: var(--color-primary);
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
```

## 表单设计

### 标签与提示

```html
<div class="form-group">
  <label for="email" class="form-label">
    邮箱地址
    <span class="required">*</span>
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

### 错误处理

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

## 导航设计

### 底部导航（移动端）

```html
<nav class="bottom-nav" role="navigation" aria-label="主导航">
  <a href="/" class="nav-item nav-item-active">
    <svg class="nav-icon" aria-hidden="true">...</svg>
    <span class="nav-label">首页</span>
  </a>
  <a href="/discover" class="nav-item">
    <svg class="nav-icon" aria-hidden="true">...</svg>
    <span class="nav-label">发现</span>
  </a>
  <a href="/profile" class="nav-item">
    <svg class="nav-icon" aria-hidden="true">...</svg>
    <span class="nav-label">我的</span>
  </a>
</nav>
```

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

.nav-icon {
  width: 24px;
  height: 24px;
}

.nav-label {
  font-size: var(--font-size-xs);
  margin-top: var(--spacing-1);
}
```

## 设计系统检查清单

### 上线前检查

```markdown
## 可访问性

- [ ] 颜色对比度 ≥ 4.5:1
- [ ] 所有图片有 Alt 文本
- [ ] 表单有标签
- [ ] 支持键盘导航
- [ ] 支持屏幕阅读器
- [ ] 支持 reduced-motion

## 触摸友好

- [ ] 触摸目标 ≥ 44×44px
- [ ] 元素间间距 ≥ 8px
- [ ] 有加载反馈
- [ ] 错误提示明确

## 性能

- [ ] 图片使用 WebP/AVIF
- [ ] 开启懒加载
- [ ] 无布局抖动（CLS < 0.1）
- [ ] 首屏内容快速加载

## 响应式

- [ ] 移动端优先
- [ ] 断点合理
- [ ] 无水平滚动
- [ ] 文字不截断

## 视觉

- [ ] 样式一致
- [ ] 间距统一
- [ ] 字体层级清晰
- [ ] 色彩语义化
```

## 快速参考

| 设计元素 | 关键规范              |
| -------- | --------------------- |
| 触摸目标 | ≥ 44×44px             |
| 间距     | 8px 基准              |
| 圆角     | 4px/8px/12px          |
| 阴影     | 0 1px 3px / 0 4px 6px |
| 过渡     | 150-300ms             |
| 字体基准 | 16px                  |
| 行高     | 1.5                   |
| 对比度   | ≥ 4.5:1               |
