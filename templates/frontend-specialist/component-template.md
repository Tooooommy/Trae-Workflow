# 组件文档

## 概述

| 项目 | 内容 |
|------|------|
| 组件名称 | {COMPONENT_NAME} |
| 版本 | v1.0 |
| 日期 | {DATE} |
| 作者 | frontend-specialist |

## 1. 组件说明

> 组件用途和功能描述

## 2. Props

| 属性 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| | | | | |

## 3. 使用示例

### 基础用法

```tsx
import { ComponentName } from '@/components/ComponentName'

function Example() {
  return <ComponentName />
}
```

### 高级用法

```tsx
import { ComponentName } from '@/components/ComponentName'

function Example() {
  return (
    <ComponentName
      prop1="value"
      prop2={123}
    />
  )
}
```

## 4. 类型定义

```typescript
export interface ComponentNameProps {
  className?: string
  children?: React.ReactNode
}
```

## 5. 样式

### CSS 变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| | | |

### Tailwind 类

| 状态 | 类名 |
|------|------|
| 默认 | |
| 悬停 | |
| 聚焦 | |
| 禁用 | |

## 6. 可访问性

| 属性 | 说明 |
|------|------|
| role | |
| aria-label | |
| aria-describedby | |

## 7. 状态

| 状态 | 说明 |
|------|------|
| default | 默认状态 |
| hover | 悬停状态 |
| focus | 聚焦状态 |
| active | 激活状态 |
| disabled | 禁用状态 |
| loading | 加载状态 |
| error | 错误状态 |

## 8. 事件

| 事件 | 类型 | 说明 |
|------|------|------|
| onClick | () => void | 点击事件 |
| onChange | (value: T) => void | 值变化 |

## 9. 测试

### 测试用例

- [ ] 渲染正常
- [ ] Props 传递正确
- [ ] 事件触发正常
- [ ] 状态切换正常
- [ ] 可访问性通过

### 测试覆盖率

| 类型 | 覆盖率 |
|------|--------|
| 语句 | % |
| 分支 | % |
| 函数 | % |
| 行 | % |

## 10. 依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| | | |

## 11. 变更日志

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | | 初始版本 |
