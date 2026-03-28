# 设计系统文档

## 项目概述

| 项目 | 内容 |
|------|------|
| 项目名称 | {PROJECT_NAME} |
| 版本 | v1.0 |
| 日期 | {DATE} |
| 设计师 | ux-engineer |

## 1. 设计原则

| 原则 | 说明 |
|------|------|
| 一致性 | 统一的视觉语言 |
| 可扩展 | 易于添加新组件 |
| 可维护 | 清晰的命名规范 |
| 可访问 | 符合 WCAG 标准 |

## 2. 设计令牌

### 2.1 色彩

#### 品牌色

| 令牌 | 色值 | 用途 |
|------|------|------|
| --color-brand-primary | | 主品牌色 |
| --color-brand-secondary | | 辅助品牌色 |
| --color-brand-accent | | 强调色 |

#### 语义色

| 令牌 | 色值 | 用途 |
|------|------|------|
| --color-semantic-success | #22c55e | 成功状态 |
| --color-semantic-warning | #f59e0b | 警告状态 |
| --color-semantic-error | #ef4444 | 错误状态 |
| --color-semantic-info | #3b82f6 | 信息状态 |

#### 中性色

| 令牌 | 色值 | 用途 |
|------|------|------|
| --color-neutral-50 | | 最浅背景 |
| --color-neutral-100 | | 浅背景 |
| --color-neutral-500 | | 边框 |
| --color-neutral-900 | | 最深文字 |

### 2.2 字体

#### 字体家族

| 令牌 | 值 | 用途 |
|------|-----|------|
| --font-family-sans | system-ui, -apple-system, sans-serif | 无衬线 |
| --font-family-mono | ui-monospace, monospace | 等宽 |

#### 字号

| 令牌 | 值 | 用途 |
|------|-----|------|
| --font-size-xs | 0.75rem (12px) | 辅助文字 |
| --font-size-sm | 0.875rem (14px) | 小号文字 |
| --font-size-base | 1rem (16px) | 正文 |
| --font-size-lg | 1.125rem (18px) | 大号文字 |
| --font-size-xl | 1.25rem (20px) | 标题 |
| --font-size-2xl | 1.5rem (24px) | 大标题 |
| --font-size-3xl | 2rem (32px) | 页面标题 |

#### 字重

| 令牌 | 值 | 用途 |
|------|-----|------|
| --font-weight-normal | 400 | 正文 |
| --font-weight-medium | 500 | 强调 |
| --font-weight-bold | 700 | 标题 |

### 2.3 间距

| 令牌 | 值 | 用途 |
|------|-----|------|
| --spacing-0 | 0 | 无间距 |
| --spacing-1 | 0.25rem (4px) | 最小间距 |
| --spacing-2 | 0.5rem (8px) | 紧凑间距 |
| --spacing-3 | 0.75rem (12px) | 小间距 |
| --spacing-4 | 1rem (16px) | 标准间距 |
| --spacing-6 | 1.5rem (24px) | 大间距 |
| --spacing-8 | 2rem (32px) | 区块间距 |
| --spacing-12 | 3rem (48px) | 大区块间距 |

### 2.4 圆角

| 令牌 | 值 | 用途 |
|------|-----|------|
| --radius-none | 0 | 无圆角 |
| --radius-sm | 0.125rem (2px) | 小圆角 |
| --radius-md | 0.375rem (6px) | 标准圆角 |
| --radius-lg | 0.5rem (8px) | 大圆角 |
| --radius-full | 9999px | 圆形 |

### 2.5 阴影

| 令牌 | 值 | 用途 |
|------|-----|------|
| --shadow-sm | 0 1px 2px rgba(0,0,0,0.05) | 微阴影 |
| --shadow-md | 0 4px 6px rgba(0,0,0,0.1) | 标准阴影 |
| --shadow-lg | 0 10px 15px rgba(0,0,0,0.1) | 大阴影 |

### 2.6 动效

| 令牌 | 值 | 用途 |
|------|-----|------|
| --duration-fast | 150ms | 快速动效 |
| --duration-normal | 200ms | 标准动效 |
| --duration-slow | 300ms | 慢速动效 |
| --easing-default | ease-out | 默认缓动 |

## 3. 组件库

### 3.1 基础组件

| 组件 | 说明 | 状态 |
|------|------|------|
| Button | 按钮 | |
| Input | 输入框 | |
| Select | 选择器 | |
| Checkbox | 复选框 | |
| Radio | 单选框 | |
| Switch | 开关 | |
| Textarea | 文本域 | |

### 3.2 布局组件

| 组件 | 说明 | 状态 |
|------|------|------|
| Container | 容器 | |
| Grid | 栅格 | |
| Stack | 堆叠 | |
| Flex | 弹性布局 | |
| Divider | 分割线 | |

### 3.3 展示组件

| 组件 | 说明 | 状态 |
|------|------|------|
| Card | 卡片 | |
| Table | 表格 | |
| List | 列表 | |
| Badge | 徽标 | |
| Avatar | 头像 | |
| Image | 图片 | |
| Icon | 图标 | |

### 3.4 反馈组件

| 组件 | 说明 | 状态 |
|------|------|------|
| Alert | 警告提示 | |
| Toast | 轻提示 | |
| Modal | 弹窗 | |
| Drawer | 抽屉 | |
| Progress | 进度条 | |
| Skeleton | 骨架屏 | |

### 3.5 导航组件

| 组件 | 说明 | 状态 |
|------|------|------|
| Navbar | 导航栏 | |
| Tabs | 标签页 | |
| Breadcrumb | 面包屑 | |
| Pagination | 分页 | |
| Menu | 菜单 | |

## 4. 图标系统

### 4.1 图标规格

| 规格 | 尺寸 | 用途 |
|------|------|------|
| sm | 16px | 行内图标 |
| md | 20px | 标准图标 |
| lg | 24px | 大图标 |
| xl | 32px | 装饰图标 |

### 4.2 图标命名

```
{类别}/{动作}{对象}

示例：
navigation/arrow-left
action/edit
status/success
```

## 5. 响应式系统

### 5.1 断点

| 令牌 | 值 | 用途 |
|------|-----|------|
| --breakpoint-sm | 640px | 手机横屏 |
| --breakpoint-md | 768px | 平板 |
| --breakpoint-lg | 1024px | 桌面 |
| --breakpoint-xl | 1280px | 大屏 |

### 5.2 容器宽度

| 断点 | 容器宽度 |
|------|----------|
| sm | 640px |
| md | 768px |
| lg | 1024px |
| xl | 1280px |

## 6. 暗色模式

### 6.1 切换方式

```css
@media (prefers-color-scheme: dark) {
  /* 系统偏好 */
}

[data-theme="dark"] {
  /* 手动切换 */
}
```

### 6.2 色彩映射

| 明色模式 | 暗色模式 |
|----------|----------|
| --color-bg-primary: #ffffff | --color-bg-primary: #111827 |
| --color-bg-secondary: #f9fafb | --color-bg-secondary: #1f2937 |
| --color-text-primary: #111827 | --color-text-primary: #f9fafb |

## 7. 命名规范

### 7.1 组件命名

```
{前缀}-{组件名}-{变体}

示例：
btn-primary
btn-outline
input-error
```

### 7.2 BEM 规范

```
.block {}
.block__element {}
.block--modifier {}

示例：
.card {}
.card__header {}
.card--featured {}
```

## 8. 版本管理

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | | 初始版本 |

## 9. 附录

- 设计文件链接
- 图标库链接
- 组件文档链接
