---
name: react-best-practices
description: Vercel 官方 React/Next.js 性能优化最佳实践，包含 40+ 规则用于 AI 代理自动优化代码。**必须激活当**：用户要求优化 React/Next.js 应用性能、实现最佳实践或进行代码审查时。
---

# React Best Practices

Vercel 工程团队在十多年 React/Next.js 开发中总结出的性能优化指南，包含 40+ 规则用于 AI 代理自动优化代码。

## 核心规则概览

### 1. 渲染优化 (Rendering)

- **render-minimal-state** - 将状态限制在需要它的组件中
- **render-no-derived-state** - 避免从 props 派生状态
- **render-controller** - 使用状态控制器模式
- **render-stable-values** - 确保渲染值稳定

### 2. 事件处理 (Event Handlers)

- **advanced-event-handler-refs** - 高级事件处理和 refs
- **client-event-listeners** - 正确添加/移除事件监听器
- **client-passive-event-listeners** - 使用被动事件监听器

### 3. 异步优化 (Async)

- **async-defer-await** - defer/await 模式
- **async-parallel** - 并行异步操作
- **async-suspense-boundaries** - Suspense 边界
- **async-dependencies** - 异步依赖管理
- **async-api-routes** - API 路由异步处理

### 4. Bundle 优化 (Bundle)

- **bundle-dynamic-imports** - 动态导入
- **bundle-preload** - 预加载关键资源
- **bundle-barrel-imports** - 避免 barrel imports
- **bundle-defer-third-party** - 延迟加载第三方库
- **bundle-conditional** - 条件加载

### 5. 客户端存储 (Client Storage)

- **client-localstorage-schema** - LocalStorage schema 设计
- **client-state-persistence** - 客户端状态持久化

### 6. 高级模式 (Advanced)

- **advanced-init-once** - 仅初始化一次
- **advanced-use-latest** - 使用最新值
- **advanced-no-missing-deps** - 完整的依赖数组

### 7. CSS 优化 (CSS)

- **css-tailwind** - 使用 Tailwind CSS
- **css-no-global-styles** - 避免全局样式
- **css-nested-components** - 嵌套组件样式

### 8. 图片优化 (Images)

- **image-external-images** - 外部图片配置
- **image-size-images** - 为图片指定尺寸
- **image-prefer-srcset** - 使用 srcset

### 9. 字体优化 (Fonts)

- **font-next-font** - 使用 next/font
- **font-display** - 字体 display 属性

### 10. 元数据 (Metadata)

- **metadata-missing-metadata** - 完整的 metadata
- **metadata-opengraph** - OpenGraph 配置

### 11. SEO

- **seo-robots-txt** - robots.txt 配置
- **seo-sitemap** - sitemap 配置

## 详细规则

### 渲染优化

#### render-minimal-state

将状态限制在需要它的组件中，避免不必要的全局状态。

```tsx
// ❌ 错误: 状态提升过早
function Parent() {
  const [count, setCount] = useState(0);
  return <Child count={count} onIncrement={() => setCount((c) => c + 1)} />;
}

// ✅ 正确: 在需要它的组件中管理状态
function Parent() {
  return <Child />;
}

function Child() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount((c) => c + 1)}>{count}</button>;
}
```

#### render-no-derived-state

避免从 props 派生状态，这会导致同步问题。

```tsx
// ❌ 错误: 派生状态
function Component({ user }) {
  const [name, setName] = useState(user.name);
  // 这会导致状态不同步
}

// ✅ 正确: 直接使用 props 或 memo
function Component({ user }) {
  return <div>{user.name}</div>;
}
```

### 事件处理

#### client-event-listeners

正确添加和移除事件监听器。

```tsx
// ❌ 错误: 不清理事件监听器
function Component() {
  useEffect(() => {
    window.addEventListener('resize', handleResize);
  }, []);
  // 缺少 cleanup
}

// ✅ 正确: 清理事件监听器
function Component() {
  useEffect(() => {
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);
}
```

#### client-passive-event-listeners

对滚动和触摸事件使用被动监听器。

```tsx
// ✅ 正确: 使用 passive 提高性能
useEffect(() => {
  element.addEventListener('scroll', handler, { passive: true });
}, []);
```

### 异步优化

#### async-defer-await

使用 defer 关键字延迟非关键依赖。

```tsx
// ✅ 使用 defer 延迟加载
import { defer, useLoaderData } from 'react-router-dom';

function loader() {
  return defer({
    critical: await fetchCriticalData(),
    deferred: deferLazyData(),
  });
}
```

#### async-suspense-boundaries

正确使用 Suspense 边界。

```tsx
// ✅ 正确的 Suspense 边界
function Page() {
  return (
    <Suspense fallback={<Skeleton />}>
      <Comments />
    </Suspense>
  );
}
```

### Bundle 优化

#### bundle-dynamic-imports

使用动态导入分割代码。

```tsx
// ✅ 动态导入
const Modal = dynamic(() => import('./Modal'));

function Page() {
  return <Modal />;
}
```

#### bundle-barrel-imports

避免 barrel imports (index.ts 导出)。

```tsx
// ❌ 错误: barrel import
import { Button, Card, Modal } from './components';

// ✅ 正确: 直接导入
import Button from './components/Button';
import Card from './components/Card';
```

### 图片优化

#### image-size-images

始终为图片指定尺寸。

```tsx
// ✅ 正确: 指定尺寸
<Image src="/hero.png" width={1200} height={600} alt="Hero" />

// ❌ 错误: 缺少尺寸
<Image src="/hero.png" alt="Hero" />
```

### 字体优化

#### font-next-font

使用 next/font 优化字体加载。

```tsx
import { Inter } from 'next/font/google';

const inter = Inter({ subsets: ['latin'] });

export default function Layout({ children }) {
  return (
    <html className={inter.className}>
      <body>{children}</body>
    </html>
  );
}
```

### 性能指标目标

| 指标 | 目标值  | 优化方法              |
| ---- | ------- | --------------------- |
| LCP  | < 2.5s  | 图片优化、CDN、预加载 |
| FID  | < 100ms | 代码分割、减少 JS     |
| CLS  | < 0.1   | 字体优化、图片尺寸    |

## 相关技能

| 技能                  | 说明                |
| --------------------- | ------------------- |
| nextjs-dev            | Next.js 全栈方案    |
| composition-patterns  | React 组合模式      |
| react-native-dev      | React Native 移动端 |
| web-design-guidelines | Web 设计规范        |

---

_基于 Vercel 官方最佳实践（致谢：Vercel Labs）_
