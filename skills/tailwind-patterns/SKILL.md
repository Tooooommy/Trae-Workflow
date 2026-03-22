---
name: tailwind-patterns
description: Tailwind CSS 模式 - 原子化 CSS、响应式设计、组件模式最佳实践
---

# Tailwind CSS 模式

> 原子化 CSS、响应式设计、组件模式的最佳实践

## 何时激活

- 快速 UI 开发
- 响应式设计
- 设计系统实现
- 组件样式
- 暗色模式

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Tailwind CSS | 3.4+ | 最新 |
| PostCSS | 8.0+ | 最新 |
| tailwind-merge | 2.0+ | 最新 |
| clsx | 2.0+ | 最新 |

## 配置

```typescript
import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: { 50: '#f0f9ff', 500: '#3b82f6', 900: '#1e3a8a' },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
};

export default config;
```

## 组件模式

```tsx
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

function Button({ variant = 'primary', size = 'md', className, children }: ButtonProps) {
  const baseStyles = 'rounded-lg font-medium transition-colors';
  
  const variants = {
    primary: 'bg-primary-500 text-white hover:bg-primary-600',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
    outline: 'border border-gray-300 hover:bg-gray-50',
  };
  
  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };
  
  return (
    <button className={cn(baseStyles, variants[variant], sizes[size], className)}>
      {children}
    </button>
  );
}
```

## 响应式设计

```tsx
function ResponsiveGrid() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {items.map((item) => (
        <div key={item.id} className="p-4 bg-white rounded-lg shadow">
          {item.name}
        </div>
      ))}
    </div>
  );
}
```

## 暗色模式

```tsx
function Card() {
  return (
    <div className="bg-white dark:bg-gray-800 text-gray-900 dark:text-white p-6 rounded-lg shadow-lg">
      <h2 className="text-xl font-bold mb-2">Title</h2>
      <p className="text-gray-600 dark:text-gray-300">Content</p>
    </div>
  );
}
```

## 快速参考

```css
/* 间距 */
p-4 m-2 gap-4

/* 布局 */
flex items-center justify-between grid grid-cols-3

/* 响应式 */
sm:text-lg md:flex lg:grid-cols-4

/* 状态 */
hover:bg-blue-500 focus:ring-2 active:scale-95

/* 暗色 */
dark:bg-gray-800
```

## 参考

- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Tailwind UI](https://tailwindui.com/)
- [Headless UI](https://headlessui.com/)
