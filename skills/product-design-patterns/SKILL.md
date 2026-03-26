---
name: product-design-patterns
description: 产品与设计模式。涵盖产品需求分析（PRD、用户故事、MVP）、UI/UX 设计（色彩、排版、布局、组件）、原型设计。**必须激活当**：用户要求编写产品需求文档、设计新页面、创建 UI 组件、选择配色方案时。
---

# 产品与设计模式

用于产品需求分析与 UI 设计。

## 何时激活

当用户要求以下任一操作时激活：

**产品需求**

- 编写产品需求文档（PRD）
- 编写用户故事（User Story）
- 需求分析与分解
- 定义 MVP（最小可行产品）
- 制定产品路线图
- 需求优先级评估

**UI/UX 设计**

- 设计新页面（Landing Page、Dashboard、Admin、移动端 App）
- 创建或重构 UI 组件（按钮、表单、卡片、表格）
- 选择配色方案、字体系统、间距标准
- 审查 UI 代码的可访问性或视觉一致性
- 实现导航结构、动画或响应式行为

## 标准输出格式

调用本 Skill 时，输出以下文档：

| #   | 文档名称                  | 说明                                           | 时间戳     |
| --- | ------------------------- | ---------------------------------------------- | ---------- |
| 1   | 结构化产品需求文档（PRD） | 概述、用户分析、功能需求、非功能需求、验收标准 | YYYY-MM-DD |
| 2   | 用户故事地图              | 用户角色、用户故事、功能分解                   | YYYY-MM-DD |
| 3   | 可交互原型链接            | Figma/Protopie 等原型链接                      | YYYY-MM-DD |
| 4   | 高保真设计稿              | Sketch/Figma 设计文件                          | YYYY-MM-DD |

### 文档命名规范

```
[文档类型]_[项目名称]_[版本]_[日期]
示例：
PRD_用户登录模块_v1.0_2026-03-26
原型_仪表盘功能_v2.1_2026-03-26
设计稿_移动端首页_v1.0_2026-03-26
```

---

## 产品需求篇

### 产品需求文档（PRD）

| 章节       | 内容                 |
| ---------- | -------------------- |
| 概述       | 产品目标、背景、范围 |
| 用户分析   | 目标用户、用户痛点   |
| 功能需求   | 功能列表、优先级     |
| 非功能需求 | 性能、安全、可用性   |
| 验收标准   | 可测试的验收条件     |

### 用户故事格式

```
作为 [角色]
我想要 [功能]
以便 [收益]
```

### 需求优先级

| 级别 | 说明     | 决策依据             |
| ---- | -------- | -------------------- |
| P0   | 必须有   | 无此功能产品无法上线 |
| P1   | 应该有   | 重要但可延迟         |
| P2   | 可以有   | 锦上添花的功能       |
| P3   | 以后再说 | 未来可能需要         |

### PRD 模板

```markdown
## 1. 概述

### 1.1 产品目标

[一句话描述产品要解决的核心问题]

### 1.2 背景

[为什么现在要做这件事]

### 1.3 范围

- **包含**：功能 A、功能 B
- **不包含**：功能 C（将在 V2 实现）

## 2. 用户分析

### 2.1 目标用户

[用户画像描述]

### 2.2 用户痛点

1. 痛点 A
2. 痛点 B

## 3. 功能需求

### 3.1 功能列表

| 功能 | 描述 | 优先级 | 负责人 |
| ---- | ---- | ------ | ------ |
| F1   | xxx  | P0     | @xxx   |

### 3.2 功能详细说明

#### F1: [功能名称]

**描述**：[功能详细描述]

**用户流程**：

1. 用户进入页面
2. 用户点击按钮
3. 系统返回结果

**验收标准**：

- [ ] 标准 1
- [ ] 标准 2

## 4. 非功能需求

| 类型   | 要求           |
| ------ | -------------- |
| 性能   | 页面加载 < 2s  |
| 可用性 | 可用性 ≥ 99.9% |
| 安全   | 符合安全规范   |

## 5. 风险评估

| 风险       | 影响 | 缓解策略     |
| ---------- | ---- | ------------ |
| 技术难度高 | 中   | 提前技术验证 |
| 依赖第三方 | 高   | 准备备选方案 |
```

### MVP 定义

```markdown
## MVP（最小可行产品）

### 核心功能（P0）

1. [功能 1]
2. [功能 2]
3. [功能 3]

### 排除功能

- [功能 A] - V2
- [功能 B] - V3

### 成功指标

- 日活跃用户 ≥ 1000
- 核心功能使用率 ≥ 80%
```

### 产品路线图

```markdown
## 产品路线图 [年份]

### Q1 - 基础能力

- [ ] 功能 1
- [ ] 功能 2

### Q2 - 增长能力

- [ ] 功能 3
- [ ] 功能 4

### Q3 - 生态扩展

- [ ] 功能 5
- [ ] 功能 6

### Q4 - 商业化

- [ ] 功能 7
- [ ] 功能 8
```

### 需求分解技巧

**从目标倒推**

```
最终目标：用户完成订单
    ↓
子目标 1：用户浏览商品
    ↓
子目标 2：用户加入购物车
    ↓
子目标 3：用户结算
```

**按用户流程分解**

```
用户登录 → 用户搜索 → 用户浏览 → 用户下单 → 用户支付 → 订单完成
```

**按层次分解**
| 层次 | 示例 |
| ---- | ---- |
| Epic | 完整的电商系统 |
| Feature | 用户下单功能 |
| Story | 作为用户，我想快速下单 |
| Task | 实现购物车组件 |

---

## UI 设计篇

### 设计原则优先级

| 优先级 | 类别     | 影响     | 检查项                            |
| ------ | -------- | -------- | --------------------------------- |
| 1      | 可访问性 | CRITICAL | 对比度 4.5:1、ARIA 标签、键盘导航 |
| 2      | 触摸友好 | CRITICAL | 最小 44×44px、间距 8px+           |
| 3      | 性能     | HIGH     | WebP/AVIF、懒加载、无 CLS         |
| 4      | 响应式   | HIGH     | 移动端优先断点                    |
| 5      | 一致性   | HIGH     | 色彩令牌、间距系统                |

### 可访问性

**核心检查**

```
- 颜色对比度：正常文本 ≥ 4.5:1，大文本 ≥ 3:1
- focus-states：可见焦点环 2-4px
- alt-text：图片有描述性 Alt
- aria-labels：图标按钮有标签
- keyboard-nav：Tab 顺序匹配视觉顺序
- form-labels：label 配合 for 属性
- reduced-motion：尊重 prefers-reduced-motion
```

**反模式**

```
✗ 移除焦点环
✗ 图标按钮无标签
✗ 仅依赖悬停交互
✗ 即时状态变化（0ms）
```

### 色彩系统

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

### 字体与间距

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
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-4: 1rem;
  --spacing-6: 1.5rem;
  --spacing-8: 2rem;
}
```

### 组件模式

**按钮**

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
```

**输入框**

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

**卡片**

```css
.card {
  background: var(--color-bg-primary);
  border-radius: 0.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: var(--spacing-6);
}
```

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

### 动画原则

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

### 性能优化

```html
<img src="image.webp" loading="lazy" alt="描述" />

<picture>
  <source srcset="image.avif" type="image/avif" />
  <source srcset="image.webp" type="image/webp" />
  <img src="image.jpg" alt="描述" />
</picture>
```

### 表单设计

```html
<div class="form-group">
  <label for="email" class="form-label">邮箱地址 <span class="required">*</span></label>
  <input
    type="email"
    id="email"
    class="input"
    placeholder="请输入邮箱"
    aria-describedby="email-helper"
  />
  <p id="email-helper" class="form-helper">我们不会向第三方分享您的邮箱</p>
</div>

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

### 上线检查清单

**可访问性**

```
[ ] 颜色对比度 ≥ 4.5:1
[ ] 所有图片有 Alt 文本
[ ] 表单有标签
[ ] 支持键盘导航
[ ] 支持 reduced-motion
```

**触摸友好**

```
[ ] 触摸目标 ≥ 44×44px
[ ] 元素间间距 ≥ 8px
[ ] 有加载反馈
[ ] 错误提示明确
```

**性能**

```
[ ] 图片使用 WebP/AVIF
[ ] 开启懒加载
[ ] 无布局抖动（CLS < 0.1）
```

**响应式**

```
[ ] 移动端优先
[ ] 无水平滚动
[ ] 文字不截断
```

### 快速参考

| 元素     | 规范      |
| -------- | --------- |
| 触摸目标 | ≥ 44×44px |
| 间距基准 | 8px       |
| 过渡时间 | 150-300ms |
| 字体基准 | 16px      |
| 对比度   | ≥ 4.5:1   |

---

## 协作说明

| 阶段     | 协同部门     | 输出       |
| -------- | ------------ | ---------- |
| 需求收集 | 产品与设计部 | 原始需求   |
| 需求分析 | 产品与设计部 | PRD 初稿   |
| 原型设计 | 产品与设计部 | 交互原型   |
| 技术评审 | 工程技术部   | 技术可行性 |
| 需求确认 | 全员         | PRD 定稿   |
