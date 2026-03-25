---
name: remixjs-patterns
description: Remix 全栈应用开发模式，涵盖架构模式、安全实践、测试驱动开发和项目验证循环。适用于构建基于 React Router 嵌套路由、类型安全、注重 Web 基础且可扩展的生产级应用。**必须激活当**：用户要求构建 Remix 应用、使用 React Router 或实现全栈 SSR 时。即使用户没有明确说"Remix"，当涉及 Remix 框架或全栈 Web 开发时也应使用。
---

# Remix 全栈开发模式

基于 Remix、TypeScript、PostgreSQL、Prisma、Shadcn/ui 和 Railway 的完整开发模式。包含 Remix 特有的嵌套路由、数据加载模式、安全最佳实践、测试策略和部署前验证。

## 何时激活

- 使用 **Remix** 构建遵循 Web 标准、注重渐进增强和嵌套路由的全栈应用。
- 采用 **PostgreSQL** 作为主数据库，通过 **Prisma** 进行类型安全的 ORM 操作和数据库迁移。
- 使用 **TypeScript** 确保端到端类型安全，包括从数据库到组件 Props 的完整链路。
- 基于 **Shadcn/ui** 和 **Tailwind CSS** 构建统一、可访问的用户界面。
- 计划部署在 **Railway** 平台，并利用其与 PostgreSQL 和 Redis 的原生集成。
- 需要完整的开发指南，涵盖从数据加载、安全防护、测试驱动到生产验证的全流程。

## 技术栈版本

| 技术         | 最低版本 | 推荐版本 |
| ------------ | -------- | -------- |
| Remix        | 2.0+     | 最新     |
| TypeScript   | 5.0+     | 最新     |
| Prisma       | 5.0+     | 最新     |
| PostgreSQL   | 14.0+    | 16.0+    |
| Tailwind CSS | 3.4+     | 最新     |
| Shadcn/ui    | 最新     | 最新     |
| Railway      | -        | 最新     |

## 开发模式 (Patterns)

### 项目结构与 Remix 路由约定

```bash
my-remix-app/
├── app/
│   ├── routes/                    # Remix 基于文件系统的路由
│   │   ├── _auth/                 路径less路由段：认证相关布局
│   │   │   ├── login.tsx
│   │   │   └── register.tsx
│   │   ├── _dashboard/            路径less路由段：主应用布局
│   │   │   ├── route.tsx          仪表板主页
│   │   │   ├── settings/
│   │   │   │   └── route.tsx
│   │   │   └── products/
│   │   │       ├── $id/           动态路由（嵌套）
│   │   │       │   ├── edit.tsx
│   │   │       │   └── route.tsx
│   │   │       └── route.tsx
│   │   ├── api/                   资源路由（非HTML响应）
│   │   │   └── webhooks.stripe.ts
│   │   └── health.tsx             健康检查端点
│   ├── components/                可复用 React 组件
│   │   ├── ui/                    基于 Shadcn/ui 的组件
│   │   └── shared/
│   ├── lib/                       工具、配置、数据库客户端
│   │   ├── db/
│   │   │   └── index.ts           Prisma 客户端单例
│   │   ├── session/
│   │   │   └── server.ts          基于 Redis 的会话管理
│   │   └── utils/
│   ├── styles/                    全局样式
│   │   └── tailwind.css
│   ├── root.tsx                   根组件
│   └── entry.server.tsx
├── prisma/
│   ├── schema.prisma              Prisma 数据模型
│   └── migrations/                数据库迁移文件
├── public/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── ...
```

### 数据加载与变更模式 (Loader/Action)

#### Loader: 服务端数据获取

```tsx
// app/routes/\_dashboard.products.$id.tsx
import { json, type LoaderFunctionArgs } from '@remix-run/node';
import { useLoaderData } from '@remix-run/react';
import { db } from '~/lib/db';
import { requireUserId } from '~/lib/session/server';

export async function loader({ request, params }: LoaderFunctionArgs) {
  // 1. 验证用户会话
  const userId = await requireUserId(request);
  const productId = params.id;

  // 2. 在服务端直接从数据库获取数据
  const product = await db.product.findUnique({
    where: { id: productId, userId }, // 确保用户只能访问自己的产品
    include: { category: true },
  });

  if (!product) {
    throw new Response('产品未找到', { status: 404 });
  }

  // 3. 返回 JSON 数据，Remix 会自动序列化
  return json({ product });
}

export default function ProductDetailPage() {
  const { product } = useLoaderData<typeof loader>(); // 类型安全的数据获取
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
    </div>
  );
}
```

#### Action: 处理数据变更

```tsx
// app/routes/\_dashboard.products.new.tsx
import { json, type ActionFunctionArgs, redirect } from '@remix-run/node';
import { Form, useActionData } from '@remix-run/react';
import { z } from 'zod';
import { db } from '~/lib/db';
import { requireUserId } from '~/lib/session/server';
import { Button } from '~/components/ui/button';

// 使用 Zod 定义验证模式
const CreateProductSchema = z.object({
  name: z.string().min(1, '名称不能为空'),
  price: z.coerce.number().positive('价格必须为正数'),
});

export async function action({ request }: ActionFunctionArgs) {
  const userId = await requireUserId(request);
  const formData = await request.formData();
  const rawData = Object.fromEntries(formData);

  // 1. 验证输入
  const validation = CreateProductSchema.safeParse(rawData);
  if (!validation.success) {
    return json({ errors: validation.error.flatten().fieldErrors }, { status: 400 });
  }

  // 2. 数据库操作（在事务中）
  try {
    await db.product.create({
      data: {
        ...validation.data,
        userId,
      },
    });
  } catch (error) {
    console.error('创建产品失败:', error);
    return json({ error: '创建失败，请重试' }, { status: 500 });
  }

  // 3. 成功重定向
  return redirect('/dashboard/products');
}

export default function NewProductPage() {
  const actionData = useActionData<typeof action>();

  return (
    <Form method="post" className="space-y-4">
      <div>
        <label htmlFor="name">产品名称</label>
        <input type="text" id="name" name="name" />
        {actionData?.errors?.name && <p className="text-red-600">{actionData.errors.name}</p>}
      </div>
      <div>
        <label htmlFor="price">价格</label>
        <input type="number" step="0.01" id="price" name="price" />
        {actionData?.errors?.price && <p className="text-red-600">{actionData.errors.price}</p>}
      </div>
      <Button type="submit">创建</Button>
    </Form>
  );
}
```

### 资源路由 (Resource Routes)

用于提供非 HTML 的 API 响应，如 Webhook 处理、文件下载等。

```ts
// app/routes/api.products.$id.export.ts
import { type LoaderFunctionArgs } from '@remix-run/node';
import { db } from '~/lib/db';
import { requireUserId } from '~/lib/session/server';

export async function loader({ request, params }: LoaderFunctionArgs) {
await requireUserId(request);
const product = await db.product.findUnique({
where: { id: params.id },
});

if (!product) {
return new Response('Not Found', { status: 404 });
}

// 返回 JSON 或 CSV 等格式
const csv = ID,Name,Price\n${product.id},${product.name},${product.price};
  return new Response(csv, {
    headers: {
      'Content-Type': 'text/csv',
      'Content-Disposition': attachment; filename="product-${product.id}.csv",
},
});
}
```

### 数据库与 Prisma 模式

```prisma
// prisma/schema.prisma
generator client {
    provider = "prisma-client-js"
}

datasource db {
    provider = "postgresql"
    url = env("DATABASE_URL")
}

model User {
    id String @id @default(cuid())
    email String @unique
    name String?
    products Product[]
    sessions Session[] // 用于会话管理
    createdAt DateTime @default(now())
    updatedAt DateTime @updatedAt
}

model Product {
    id String @id @default(cuid())
    name String
    price Float
    userId String
    user User @relation(fields: [userId], references: [id], onDelete: Cascade)
    isActive Boolean @default(true)
    createdAt DateTime @default(now())
    updatedAt DateTime @updatedAt

    @@index([userId, createdAt]) // 复合索引
    @@map("products")
}

model Session {
    id String @id @default(cuid())
    userId String
    user User @relation(fields: [userId], references: [id], onDelete: Cascade)
    expiresAt DateTime
    data String? // 可存储序列化的会话数据
    createdAt DateTime @default(now())

    @@index([userId])
    @@index([expiresAt]) // 用于清理过期会话
    @@map("sessions")
}
```

```ts
// lib/db/index.ts
import { PrismaClient } from '@prisma/client';

// 防止开发环境中的热重载导致过多 Prisma 实例
const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const db = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db;
```

## 安全实践 (Security)

### 认证与基于 Redis 的会话管理

```ts
// app/lib/session/server.ts
import { createCookieSessionStorage, redirect } from '@remix-run/node';
import { db } from '~/lib/db';
import { Redis } from 'ioredis';

// 配置 Redis 客户端
const redis = new Redis(process.env.REDIS_URL!);

// 1. 定义会话存储（签名 Cookie 存储 Session ID）
const sessionStorage = createCookieSessionStorage({
    cookie: {
        name: '\_\_session',
        httpOnly: true,
        path: '/',
        sameSite: 'lax',
        secrets: [process.env.SESSION_SECRET!],
        secure: process.env.NODE_ENV === 'production',
        maxAge: 60 60 24 \* 7, // 7天
    },
});

// 2. 会话管理函数
export async function createUserSession({
    request,
    userId,
    redirectTo,
    }: {
    request: Request;
    userId: string;
    redirectTo: string;
}) {
    const session = await sessionStorage.getSession(
        request.headers.get('Cookie')
    );

    // 在 Redis 中创建会话记录
    const sessionId = session:${userId}:${Date.now()};
    await redis.setex(
        sessionId,
        60 60 24 \* 7, // TTL: 7天
        JSON.stringify({ userId, createdAt: new Date().toISOString() })
    );

    // 在 Cookie 中只存储 Session ID
    session.set('sessionId', sessionId);

    return redirect(redirectTo, {
        headers: {
            'Set-Cookie': await sessionStorage.commitSession(session),
        },
    });
}

// 3. 获取当前用户 ID
export async function requireUserId(request: Request) {
    const session = await sessionStorage.getSession(
        request.headers.get('Cookie')
    );
    const sessionId = session.get('sessionId');

    if (!sessionId || typeof sessionId !== 'string') {
        throw redirect('/login');
    }

    // 从 Redis 验证会话
    const sessionData = await redis.get(sessionId);
    if (!sessionData) {
        throw redirect('/login');
    }

    const { userId } = JSON.parse(sessionData);
    return userId;
}
```

### 路由保护与授权中间件

```tsx
// 在根 loader 中验证全局会话
// app/root.tsx
import { json, type LoaderFunctionArgs } from '@remix-run/node';
import { getUserId } from '~/lib/session/server';

export async function loader({ request }: LoaderFunctionArgs) {
  const userId = await getUserId(request); // 不强制重定向
  return json({ userId });
}
```

```tsx
// 在需要认证的路由中使用 requireUserId
// app/routes/\_dashboard.tsx
import { type LoaderFunctionArgs, redirect } from '@remix-run/node';
import { Outlet } from '@remix-run/react';
import { requireUserId } from '~/lib/session/server';

export async function loader({ request }: LoaderFunctionArgs) {
  // 如果未登录，重定向到登录页
  await requireUserId(request);
  return null;
}

export default function DashboardLayout() {
  return (
    <div className="dashboard-layout">
      <DashboardSidebar />
      <main>
        <Outlet /> {/ 嵌套路由在此渲染 /}
      </main>
    </div>
  );
}
```

### 安全清单

- \[ ] **环境变量**：敏感密钥（`DATABASE_URL`、`SESSION_SECRET`、`REDIS_URL`）通过 Railway 环境变量管理，不提交到仓库。
- \[ ] **数据库安全**：
  - 使用 Prisma 的查询参数化防止 SQL 注入。
  - 在应用层（如 `requireUserId`）和数据库层（通过行级安全，如 PostgreSQL 的 RLS）实施访问控制。
  - 为生产环境使用不同的数据库凭据。
- \[ ] **会话安全**：
  - Cookie 标记为 `httpOnly`、`secure`（生产环境）和 `sameSite=lax`。
  - 会话数据存储在服务端（Redis），客户端仅持有不透明的 Session ID。
  - 设置合理的会话过期时间（TTL）。
- \[ ] **输入验证与清理**：对所有用户输入（URL 参数、表单数据、请求体）使用 Zod 进行验证。对输出到 HTML 的内容进行转义。
- \[ ] **CORS 配置**：在 `vercel.json` 或 Railway 的 `railway.json` 中为必要的 API 路由精确配置允许的来源。
- \[ ] **安全头**：在 `entry.server.tsx` 中设置安全头，或通过 Railway 的网络配置设置。

  ```ts
    // app/entry.server.tsx
    export function handleRequest(...) {
    // ...
    responseHeaders.set('X-Frame-Options', 'DENY');
    responseHeaders.set('X-Content-Type-Options', 'nosniff');
    responseHeaders.set('Referrer-Policy', 'strict-origin-when-cross-origin');
    // 谨慎设置 CSP
    responseHeaders.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
    );
    }
  ```

- \[ ] **依赖扫描**：定期运行 `npm audit` 和 `prisma generate` 检查更新。
- \[ ] **错误处理**：在生产环境中，避免向用户暴露堆栈跟踪或数据库错误细节。使用自定义错误边界。

## 测试驱动开发 (TDD)

### 测试策略与工具链

- **单元测试**：`Vitest` + `Testing Library`。测试工具函数、组件、Prisma 扩展等。
- **集成测试**：`Vitest` + `@remix-run/testing`。测试 Loader/Action，模拟请求/响应。
- **E2E 测试**：`Playwright`。测试完整的用户流程。
- **数据库测试**：对 Prisma 客户端使用模拟，或使用 `testcontainers` 启动一个临时 PostgreSQL 实例进行集成测试。

### 单元测试示例

```tsx
// tests/unit/lib/validation/product.test.ts
import { describe, expect, it } from 'vitest';
import { z } from 'zod';
import { validateFormData } from '~/lib/validation';

const TestSchema = z.object({
  name: z.string().min(1),
  price: z.number().positive(),
});

describe('validateFormData', () => {
  it('验证有效数据成功', async () => {
    const formData = new FormData();
    formData.append('name', '有效产品');
    formData.append('price', '29.99');

    const result = await validateFormData(formData, TestSchema);

    expect(result.success).toBe(true);
    expect(result.data).toEqual({ name: '有效产品', price: 29.99 });
  });

  it('验证无效数据返回错误', async () => {
    const formData = new FormData();
    formData.append('name', '');
    formData.append('price', '-10');

    const result = await validateFormData(formData, TestSchema);

    expect(result.success).toBe(false);
    expect(result.error).toBeDefined();
  });
});
```

### 集成测试示例 (Loader/Action)

```tsx
// tests/integration/routes/dashboard.products.new.test.ts
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { createRequest, json } from '@remix-run/node';
import { action, loader } from '~/routes/\_dashboard.products.new';
import { db } from '~/lib/db';
import { requireUserId } from '~/lib/session/server';

// 模拟依赖
vi.mock('~/lib/db');
vi.mock('~/lib/session/server');

describe('/dashboard/products/new 路由', () => {
  beforeEach(() => {
    vi.resetAllMocks();
  });

  describe('loader', () => {
    it('已登录用户返回 null', async () => {
      vi.mocked(requireUserId).mockResolvedValue('user-123');
      const request = createRequest('http://localhost/dashboard/products/new');

      const response = await loader({ request, params: {}, context: {} });

      expect(response).toEqual(null);
    });

    it('未登录用户重定向', async () => {
      vi.mocked(requireUserId).mockRejectedValue(
        new Response(null, { status: 302, headers: { Location: '/login' } })
      );
      const request = createRequest('http://localhost/dashboard/products/new');

      await expect(loader({ request, params: {}, context: {} })).rejects.toThrow();
    });
  });

  describe('action', () => {
    it('验证成功时创建产品并重定向', async () => {
      vi.mocked(requireUserId).mockResolvedValue('user-123');
      vi.mocked(db.product.create).mockResolvedValue({} as any);

      const formData = new FormData();
      formData.append('name', '测试产品');
      formData.append('price', '99.99');
      const request = createRequest('http://localhost/dashboard/products/new', {
        method: 'POST',
        body: formData,
      });

      const response = await action({ request, params: {}, context: {} });

      expect(response.status).toBe(302);
      expect(response.headers.get('Location')).toBe('/dashboard/products');
      expect(db.product.create).toHaveBeenCalledWith({
        data: { name: '测试产品', price: 99.99, userId: 'user-123' },
      });
    });
  });
});
```

### 组件测试示例

```tsx
// tests/unit/components/ui/button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '~/components/ui/button';
import { describe, expect, it, vi } from 'vitest';

describe('Button', () => {
  it('渲染子内容并响应点击', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>点击我</Button>);

    const button = screen.getByRole('button', { name: '点击我' });
    expect(button).toBeInTheDocument();

    fireEvent.click(button);
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### E2E 测试示例 (Playwright)

```ts
// tests/e2e/dashboard.spec.ts
import { test, expect } from '@playwright/test';

// 测试前进行登录
test.beforeEach(async ({ page }) => {
  await page.goto('/login');
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('input[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  await page.waitForURL('/dashboard');
});

test('用户创建新产品', async ({ page }) => {
  await page.goto('/dashboard/products');
  await page.click('text=新建产品');

  await expect(page).toHaveURL('/dashboard/products/new');
  await page.fill('input[name="name"]', 'Playwright 测试产品');
  await page.fill('input[name="price"]', '49.99');
  await page.click('button[type="submit"]');

  // 等待重定向并验证
  await page.waitForURL('/dashboard/products');
  await expect(page.getByText('Playwright 测试产品')).toBeVisible();
  await expect(page.getByText('$49.99')).toBeVisible();
});
```

## 验证循环 (Verification)

### 阶段 1：构建与类型检查

```bash
#清理并构建
npm run build

#TypeScript 类型检查
npm run type-check

#Prisma 客户端生成与验证
npx prisma generate
npx prisma validate
```

### 阶段 2：代码质量与静态分析

```bash
#ESLint
npm run lint

#如有必要，运行更严格的 lint
npm run lint:strict

#检查未使用的 Tailwind CSS 类 (可选)
npx @tailwindcss/oxide check ./app//\*.tsx
```

### 阶段 3：测试 + 覆盖率

```bash
#运行所有测试
npm test

#运行单元测试
npm run test:unit

#运行集成测试
npm run test:integration

#运行 E2E 测试
npm run test:e2e

#生成覆盖率报告
npm run test:coverage
```

**覆盖率要求**（参考）：

- 语句覆盖率 ≥ 75%
- 分支覆盖率 ≥ 65%
- 函数覆盖率 ≥ 75%
- 行覆盖率 ≥ 75%

### 阶段 4：安全扫描

```bash
#检查 npm 依赖漏洞
npm audit

#检查代码中的硬编码密钥（示例命令）
grep -r "password\secret\ key\ token" ./app ./prisma --include=".ts" --include=".tsx" --include=".env" grep -v ".test." grep -v ".spec." grep -v "//"
| true

#检查 Prisma 架构中的潜在问题（如缺少 @@map/@@id）
npx prisma format --check
```

### 阶段 5：数据库迁移状态验证

```bash
#检查是否有待应用的迁移
npx prisma migrate status

#在生产部署前，始终在预发环境验证迁移
npx prisma migrate deploy --preview-feature
```

### 阶段 6：性能检查 (可选)

```bash
#使用 Lighthouse CI 或 PageSpeed Insights
npm run lighthouse

#检查包大小 (通过 npm run build 输出)
npm run build-size
```

### 验证报告模板

```markdown
# REMIX 全栈应用验证报告

项目: [项目名称]
环境: [development/staging]
时间: [时间戳]
Git 版本: [提交哈希]

[✅/❌] 构建状态
[✅/❌] 类型检查
[✅/❌] 代码规范 (ESLint) - 警告: X, 错误: Y
[✅/❌] 测试套件
• 单元测试: A/B 通过

• 集成测试: C/D 通过

• E2E 测试: M/N 通过

• 覆盖率: 行: P%, 分支: Q%, 函数: R%

[✅/❌] 安全扫描 (npm audit) - 漏洞数: V
[✅/❌] 数据库迁移状态: [同步/有差异]
[✅/❌] 依赖状态 (npm outdated): [最新/有更新]

关键问题:

1. [高优先级] [问题描述]
2. [中优先级] [问题描述]

部署就绪: [✅ 是 / ❌ 否]
```

## Railway 部署配置示例

```json
// railway.json
{
  "build": {
    "builder": "nixpacks",
    "buildCommand": "npm run build"
  },
  "deploy": {
    "startCommand": "npm start",
    "healthcheckPath": "/health",
    "restartPolicyType": "ON_FAILURE"
  }
}
```

## 核心原则

1.  **Remix 理念优先：**拥抱嵌套路由、Loader/Action 数据范式、资源路由和渐进增强。
2.  **类型安全贯穿：**利用 TypeScript 和 Prisma 生成类型，实现从数据库到 UI 的端到端类型安全。
3.  **安全默认：**所有路由默认为私有，通过明确的验证和授权逻辑开放访问。会话状态存储在服务端。
4.  **测试驱动：**为数据变更（Action）、数据获取（Loader）和 UI 逻辑编写测试，优先考虑集成测试。
5.  **自动化验证：**通过 CI/CD（如 GitHub Actions + Railway）自动化执行构建、测试、安全扫描和部署验证流程。

记住：Remix 的核心优势在于其贴近 Web 标准的设计。构建可靠应用的关键在于遵循其约定、实施严格的安全控制、进行全面测试，并建立自动化的质量门禁。
