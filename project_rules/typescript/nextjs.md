---
alwaysApply: false
globs:
  - '**/next.config.*'
  - '**/app/**'
  - '**/pages/**'
---

# Next.js 项目规范与指南

> 基于 Next.js 14+ (App Router) 的全栈 Web 应用开发规范。

## 项目总览

- 技术栈: Next.js 14+, React 18+, TypeScript, Tailwind CSS
- 架构: App Router, Server Components, Server Actions

## 关键规则

### 路由约定

```
app/
├── layout.tsx          # 根布局
├── page.tsx            # 首页
├── (auth)/             # 路由组
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
├── dashboard/
│   ├── layout.tsx      # 嵌套布局
│   └── page.tsx
└── api/
    └── users/
        └── route.ts    # API 路由
```

### Server Components

```typescript
// 默认为 Server Component
async function UserProfile({ id }: { id: string }) {
  const user = await fetchUser(id)
  return <div>{user.name}</div>
}

// 使用 'use client' 标记 Client Component
'use client'
function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

### Server Actions

```typescript
// actions/user.ts
'use server';
export async function createUser(formData: FormData) {
  const name = formData.get('name');
  await db.user.create({ data: { name } });
  revalidatePath('/users');
}
```

### 数据获取

```typescript
// Server Component 中直接获取数据
async function UsersPage() {
  const users = await db.user.findMany()
  return <UserList users={users} />
}

// 使用 SWR 在 Client Component 中获取数据
import useSWR from 'swr'
function UserList() {
  const { data, error } = useSWR('/api/users', fetcher)
  if (error) return <div>Failed to load</div>
  if (!data) return <div>Loading...</div>
  return <ul>{data.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}
```

## 环境变量

```bash
# .env.local
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="your-secret"
NEXTAUTH_URL="http://localhost:3000"
```

## 开发命令

```bash
npm run dev       # 开发服务器
npm run build     # 生产构建
npm run start     # 生产服务器
npm run lint      # 代码检查
```
