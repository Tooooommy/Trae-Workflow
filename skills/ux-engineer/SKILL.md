---
name: ux-engineer
description: 设计专家模式。负责交互设计、视觉设计、品牌视觉、设计系统。优先由 orchestrator 调度激活。
---

# 设计专家模式

## 何时激活

**优先由 orchestrator 调度激活**（阶段2：产品定义，与 product-strategist 协同）

| 触发场景 | 说明           |
| -------- | -------------- |
| UI设计   | 设计用户界面   |
| 交互设计 | 设计交互流程   |
| 原型设计 | 创建可交互原型 |
| 设计系统 | 维护设计规范   |

## 核心概念

### 设计原则优先级

| 优先级 | 类别     | 影响     | 检查项                            |
| ------ | -------- | -------- | --------------------------------- |
| 1      | 可访问性 | CRITICAL | 对比度 4.5:1、ARIA 标签、键盘导航 |
| 2      | 触摸友好 | CRITICAL | 最小 44×44px、间距 8px+           |
| 3      | 性能     | HIGH     | WebP/AVIF、懒加载、无 CLS         |
| 4      | 响应式   | HIGH     | 移动端优先断点                    |
| 5      | 一致性   | HIGH     | 色彩令牌、间距系统                |

### 色彩系统

| 令牌            | 用途 | 明色模式 | 暗色模式 |
| --------------- | ---- | -------- | -------- |
| --color-primary | 主色 | #3b82f6  | #60a5fa  |
| --color-success | 成功 | #22c55e  | #4ade80  |
| --color-warning | 警告 | #f59e0b  | #fbbf24  |
| --color-error   | 错误 | #ef4444  | #f87171  |

### 字体与间距

| 类型 | 令牌             | 值                                   |
| ---- | ---------------- | ------------------------------------ |
| 字体 | --font-family    | system-ui, -apple-system, sans-serif |
| 字号 | --font-size-base | 1rem (16px)                          |
| 行高 | --line-height    | 1.5                                  |
| 间距 | --spacing-unit   | 0.25rem (4px)                        |

### 响应式断点

| 断点 | 宽度   | 用途     |
| ---- | ------ | -------- |
| sm   | 640px  | 手机横屏 |
| md   | 768px  | 平板     |
| lg   | 1024px | 桌面     |
| xl   | 1280px | 大屏     |

## 输入输出

| 类型 | 来源/输出          | 文档     | 路径                               | 说明         |
| ---- | ------------------ | -------- | ---------------------------------- | ------------ |
| 输入 | orchestrator       | 任务工单 | docs/00-project/task-board.json    | 阶段任务指令 |
| 输入 | product-strategist | PRD      | docs/01-requirements/PRD-\*.md     | 功能需求     |
| 输入 | tech-architect     | 技术方案 | docs/02-design/architecture-\*.md  | 技术约束     |
| 输出 | ux-engineer        | 设计稿   | docs/02-design/ui-design-\*.md     | UI设计文档   |
| 输出 | ux-engineer        | 交互规范 | docs/02-design/interaction-\*.md   | 交互设计规范 |
| 输出 | ux-engineer        | 设计系统 | docs/02-design/design-system-\*.md | 设计系统文档 |

## 工作流程

1. 接收 orchestrator 任务分配
2. 设计 UI/交互方案
3. 更新 task-board.json 状态
4. 通过 nextExpert 传递任务

## 上线检查清单

### 可访问性

- [ ] 颜色对比度 ≥ 4.5:1
- [ ] 所有图片有 Alt 文本
- [ ] 表单有标签
- [ ] 支持键盘导航
- [ ] 支持 reduced-motion

### 触摸友好

- [ ] 触摸目标 ≥ 44×44px
- [ ] 元素间间距 ≥ 8px
- [ ] 有加载反馈
- [ ] 错误提示明确

### 性能

- [ ] 图片使用 WebP/AVIF
- [ ] 开启懒加载
- [ ] 无布局抖动（CLS < 0.1）

### 响应式

- [ ] 移动端优先
- [ ] 无水平滚动
- [ ] 文字不截断

## 快速参考

| 元素     | 规范      |
| -------- | --------- |
| 触摸目标 | ≥ 44×44px |
| 间距基准 | 8px       |
| 过渡时间 | 150-300ms |
| 字体基准 | 16px      |
| 对比度   | ≥ 4.5:1   |
