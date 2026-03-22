---
name: prisma-patterns
description: Prisma ORM 模式 - 类型安全查询、迁移、关系映射最佳实践
---

# Prisma ORM 模式

> 类型安全查询、数据库迁移、关系映射的最佳实践

## 何时激活

- 数据库建模
- 类型安全查询
- 数据库迁移
- 关系查询
- 事务处理

## 技术栈版本

| 技术       | 最低版本 | 推荐版本 |
| ---------- | -------- | -------- |
| Prisma     | 5.0+     | 最新     |
| Node.js    | 18.0+    | 20.0+    |
| PostgreSQL | 14.0+    | 16.0+    |
| TypeScript | 5.0+     | 最新     |

## Schema 定义

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String    @id @default(cuid())
  email     String    @unique
  name      String?
  posts     Post[]
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  authorId  String
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
}
```

## CRUD 操作

```typescript
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// 创建
const user = await prisma.user.create({
  data: { email: 'user@example.com', name: 'John' },
});

// 查询
const user = await prisma.user.findUnique({
  where: { id: 'user-id' },
  include: { posts: true },
});

// 更新
await prisma.user.update({
  where: { id: 'user-id' },
  data: { name: 'Jane' },
});

// 删除
await prisma.user.delete({ where: { id: 'user-id' } });
```

## 关系查询

```typescript
const postsWithAuthor = await prisma.post.findMany({
  include: {
    author: { select: { id: true, name: true } },
  },
});

const userWithCount = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    _count: { select: { posts: true } },
  },
});
```

## 事务

```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { email, name } });
  await tx.post.create({ data: { title, authorId: user.id } });
});
```

## 快速参考

```bash
# 生成客户端
npx prisma generate

# 创建迁移
npx prisma migrate dev --name init

# 打开 Studio
npx prisma studio
```

## 参考

- [Prisma Docs](https://www.prisma.io/docs)
- [Prisma Client API](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference)
