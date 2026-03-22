---
alwaysApply: false
globs:
  - "**/components/**"
  - "**/*.tsx"
---

# React 项目规范与指南

> 基于 React 18+ 的前端应用开发规范。

## 项目总览

* 技术栈: React 18+, TypeScript, 状态管理 (Zustand/Jotai/Redux)
* 架构: 组件化、函数式组件、Hooks

## 关键规则

### 组件结构

```typescript
// 组件定义
interface ButtonProps {
  variant?: 'primary' | 'secondary'
  children: React.ReactNode
  onClick?: () => void
}

export function Button({ variant = 'primary', children, onClick }: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant}`}
      onClick={onClick}
    >
      {children}
    </button>
  )
}
```

### Hooks 使用

```typescript
// 自定义 Hook
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key)
    return stored ? JSON.parse(stored) : initialValue
  })

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value))
  }, [key, value])

  return [value, setValue] as const
}
```

### 状态管理

```typescript
// Zustand Store
import { create } from 'zustand'

interface UserStore {
  user: User | null
  setUser: (user: User) => void
  logout: () => void
}

export const useUserStore = create<UserStore>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
}))
```

### 文件组织

```
src/
├── components/
│   ├── ui/              # 基础 UI 组件
│   │   ├── Button.tsx
│   │   └── Input.tsx
│   └── features/        # 功能组件
│       └── UserProfile/
│           ├── index.tsx
│           ├── useProfile.ts
│           └── ProfileForm.tsx
├── hooks/               # 自定义 Hooks
├── stores/              # 状态管理
├── utils/               # 工具函数
└── types/               # 类型定义
```

## 性能优化

- 使用 `React.memo` 避免不必要的重渲染
- 使用 `useMemo` 和 `useCallback` 缓存计算结果
- 使用 `React.lazy` 和 `Suspense` 进行代码分割
