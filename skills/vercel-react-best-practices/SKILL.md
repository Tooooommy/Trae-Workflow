---
name: vercel-react-best-practices
description: Vercel 官方 React/Next.js 性能优化最佳实践，包含超过 40 个性能规则。**必须激活当**：用户要求优化 React/Next.js 应用性能、实现最佳实践或进行代码审查时。即使用户没有明确说"Vercel"，当涉及 React 性能优化或 Next.js 最佳实践时也应使用。
---

## 概述

Vercel React 最佳实践是 Vercel 工程团队在十多年 React/Next.js 开发中总结出的性能优化指南，包含 40+ 规则用于 AI 代理自动优化代码。

## 核心原则

### 1. 组件优化

- 使用 `React.memo` 包装纯展示组件
- 避免不必要的重新渲染
- 使用 `useMemo` 和 `useCallback` 优化计算
- 合理拆分组件，避免单体组件过大

### 2. 渲染优化

```tsx
// ❌ 避免: 内联函数导致子组件重新渲染
function Component() {
  return <Child onClick={() => handleClick()} />;
}

// ✅ 正确: 使用 useCallback 稳定函数引用
function Component() {
  const handleClick = useCallback(() => {
    // ...
  }, []);
  return <Child onClick={handleClick} />;
}
```

### 3. 列表渲染优化

- 使用唯一且稳定的 key
- 实现虚拟列表处理长列表
- 避免在 map 中使用 index 作为 key

```tsx
// ❌ 避免
{
  items.map((item, index) => <Item key={index} />);
}

// ✅ 正确
{
  items.map((item) => <Item key={item.id} />);
}
```

### 4. 图片优化

- 使用 `next/image` 自动优化
- 指定合适的尺寸和格式
- 使用懒加载

```tsx
import Image from 'next/image';

function Hero() {
  return (
    <Image
      src="/hero.png"
      alt="Hero"
      width={1200}
      height={600}
      priority
      placeholder="blur"
      blurDataURL="data:image/..."
    />
  );
}
```

### 5. 字体优化

- 使用 `next/font` 自动优化字体加载
- 避免布局偏移 (CLS)

```tsx
import { Inter } from 'next/font/google';

const inter = Inter({ subsets: ['latin'] });

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={inter.className}>
      <body>{children}</body>
    </html>
  );
}
```

### 6. 脚本优化

- 使用 `next/script` 优化第三方脚本
- 使用 `strategy="afterInteractive"` 或 `strategy="lazyOnload"`

```tsx
import Script from 'next/script';

function Analytics() {
  return <Script src="https://analytics.example.com/script.js" strategy="afterInteractive" />;
}
```

### 7. 数据获取优化

- 使用服务端组件获取数据
- 合理使用缓存策略
- 实现流式渲染

```tsx
// ✅ 使用 React Suspense 和流式渲染
import { Suspense } from 'react';

function Page() {
  return (
    <Suspense fallback={<Skeleton />}>
      <ProductDetails />
    </Suspense>
  );
}
```

### 8. 包体积优化

- 使用动态导入分割代码
- 避免导入整个库
- 使用 `next/bundle-analyzer` 分析包体积

```tsx
// ❌ 避免
import { Button, Card, Modal } from 'ui-library';

// ✅ 正确
import Button from 'ui-library/Button';
import Card from 'ui-library/Card';
import Modal from 'ui-library/Modal';

// ✅ 或使用动态导入
const Modal = dynamic(() => import('ui-library/Modal'));
```

### 9. CSS 优化

- 使用 CSS-in-JS 的服务端渲染支持
- 使用 Tailwind CSS 等原子化 CSS
- 避免运行时 CSS-in-JS

```tsx
// ❌ 避免: 运行时样式计算
const styles = {
  container: {
    display: 'flex',
    flexDirection: props.vertical ? 'column' : 'row',
  },
};

// ✅ 正确: 使用 Tailwind 或静态 CSS
<div className={`flex ${isVertical ? 'flex-col' : 'flex-row'}`}>
```

### 10. SEO 优化

- 使用语义化 HTML
- 正确配置元数据
- 生成结构化数据

```tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Product Page',
  description: 'Best products at great prices',
  openGraph: {
    title: 'Product Page',
    description: 'Best products at great prices',
    images: ['/og-image.jpg'],
  },
};
```

## 性能指标目标

| 指标 | 目标值  | 优化方法              |
| ---- | ------- | --------------------- |
| LCP  | < 2.5s  | 图片优化、CDN、预加载 |
| FID  | < 100ms | 代码分割、减少 JS     |
| CLS  | < 0.1   | 字体优化、图片尺寸    |
| TTI  | < 3.8s  | 代码分割、懒加载      |

## 自动化工具

### 1. @next/bundle-analyzer

```bash
npm install @next/bundle-analyzer
```

```js
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer({});
```

### 2. next lint

```bash
npx next lint
```

### 3. Lighthouse CI

```bash
npm install -D @lhci/cli
```

## 常见性能反模式

1. **客户端组件滥用** - 过度使用 `use client`
2. **缺少预加载** - 未使用 `Link` 的预加载功能
3. **大图片** - 未压缩或未使用现代格式
4. **阻塞渲染** - 服务端组件中同步操作
5. **过度订阅** - 不必要的实时数据订阅

## 相关技能

| 技能              | 说明                |
| ----------------- | ------------------- |
| nextjs-dev        | Next.js 全栈方案    |
| frontend-expert   | React/Vue 前端模式  |
| react-native-dev  | React Native 移动端 |
| tailwind-patterns | Tailwind CSS 模式   |

---

_基于 Vercel 官方最佳实践（致谢：Vercel Labs）_
