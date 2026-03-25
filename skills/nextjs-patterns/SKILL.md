---
name: nextjs-patterns
description: Next.js + Supabase 全栈开发模式，涵盖架构模式、安全实践、测试驱动开发和项目验证循环。适用于构建可扩展、类型安全、生产就绪的现代Web应用。**必须激活当**：用户要求构建 Next.js 应用、使用 Supabase、实现 SSR/SSG 或处理身份验证时。即使用户没有明确说"Next.js"，当涉及 React 框架、全栈开发或现代 Web 应用时也应使用。
---

# Next.js + Supabase 全栈开发模式

基于 Next.js (App Router)、TypeScript、Shadcn/ui、Tailwind CSS、Supabase 和 Vercel 的完整开发模式。包含架构设计、安全最佳实践、测试策略和项目验证流程。

## 何时激活

- 使用 **Next.js (App Router)** 构建全栈应用
- 采用 **Supabase** 作为后端即服务 (BaaS)，管理数据库、认证、存储
- 需要端到端的 **TypeScript** 类型安全
- 基于 **Shadcn/ui** 和 **Tailwind CSS** 构建现代化UI
- 计划部署在 **Vercel** 平台
- 需要完整的开发流程指导，从架构到测试、安全到部署验证

## 技术栈版本

| 技术         | 最低版本 | 推荐版本 |
| ------------ | -------- | -------- |
| Next.js      | 14.0+    | 15.0+    |
| TypeScript   | 5.0+     | 最新     |
| Supabase     | 2.0+     | 最新     |
| Tailwind CSS | 3.4+     | 最新     |
| Shadcn/ui    | 最新     | 最新     |
| Vercel       | -        | 最新     |

## 开发模式 (Patterns)

### 项目结构与组织

```bash
my-app/
├── src/
│ ├── app/ # Next.js App Router
│ │ ├── (auth)/ 路由组：认证相关
│ │ ├── (dashboard)/ 路由组：主应用
│ │ ├── api/ App Router API 路由
│ │ ├── layout.tsx 根布局
│ │ └── page.tsx 首页
│ ├── components/ React 组件
│ │ ├── ui/ Shadcn/ui 组件
│ │ ├── shared/ 共享组件
│ │ └── features/ 功能组件
│ ├── lib/ 工具与配置
│ │ ├── supabase/ Supabase 客户端
│ │ ├── utils/ 工具函数
│ │ └── validation/ Zod 验证模式
│ └── styles/ 样式文件
├── public/
├── tests/
│ ├── unit/
│ ├── integration/
│ └── e2e/
└── ...
```

### 数据获取模式

#### 服务器组件数据获取

```tsx
// src/app/(dashboard)/page.tsx
import { createClient } from '@/lib/supabase/server';

export default async function DashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // 服务器端获取数据
  const { data: products } = await supabase
    .from('products')
    .select('\*')
    .eq('user_id', user?.id)
    .order('created_at', { ascending: false });

  return <ProductList initialProducts={products} />;
}
```

#### 服务器操作 (Server Actions)

```ts
// src/app/actions/product.ts
'use server';
import { createClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const CreateProductSchema = z.object({
  name: z.string().min(1, '名称不能为空'),
  price: z.number().positive('价格必须为正数'),
});

export async function createProduct(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { success: false, message: '未授权' };
  }

  const validation = CreateProductSchema.safeParse({
    name: formData.get('name'),
    price: parseFloat(formData.get('price') as string),
  });

  if (!validation.success) {
    return {
      success: false,
      errors: validation.error.flatten().fieldErrors,
    };
  }

  await supabase.from('products').insert({
    ...validation.data,
    user_id: user.id,
  });

  revalidatePath('/dashboard');
  return { success: true };
}
```

### 实时数据模式

```tsx
// src/components/realtime/products-list.tsx
'use client';
import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export function RealtimeProductsList() {
  const [products, setProducts] = useState([]);
  const supabase = createClient();

  useEffect(() => {
    const channel = supabase
      .channel('realtime:products')
      .on('postgres_changes', { event: '\*', schema: 'public', table: 'products' }, (payload) => {
        // 实时更新状态
        if (payload.eventType === 'INSERT') {
          setProducts((current) => [payload.new, ...current]);
        }
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase]);

  return <ProductList products={products} />;
}
```

## 安全实践 (Security)

### 认证与授权模式

#### 服务器端会话保护

```ts
// src/lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

export async function createClient() {
  const cookieStore = await cookies();
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => cookieStore.set(name, value, options));
        },
      },
    }
  );
}
```

#### 路由保护中间件

```ts
// src/middleware.ts
import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          / ... /;
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();
  const isProtectedRoute = request.nextUrl.pathname.startsWith('/dashboard');
  const isAuthRoute = ['/login', '/register'].includes(request.nextUrl.pathname);

  // 重定向逻辑
  if (isProtectedRoute && !user) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (isAuthRoute && user) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  return NextResponse.next();
}
```

### 行级安全 (RLS) 策略

```sql
-- 在 Supabase 中为 products 表启用 RLS
CREATE POLICY "用户只能管理自己的产品"
ON products
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 允许公开读取已发布的产品
CREATE POLICY "任何人都可以查看已发布的产品"
ON products
FOR SELECT
USING (is_published = true OR auth.uid() = user_id);
```

### 安全清单

- \[ ] **环境变量**：敏感密钥存储在 `.env.local`，不提交到仓库
- \[ ] **CORS 配置**：在 Supabase 中正确配置允许的来源
- \[ ] **输入验证**：使用 Zod 验证所有用户输入
- \[ ] **SQL 注入防护**：使用 Supabase 客户端，避免原始 SQL
- \[ ] **XSS 防护**：对用户内容进行清理，使用 `DOMPurify`
- \[ ] **CSRF 保护**：使用 SameSite cookies 和 CSRF tokens
- \[ ] **速率限制**：在 API 路由和 Server Actions 中实现
- \[ ] **安全头**：配置 `next.config.js` 中的安全头

## 测试驱动开发 (TDD)

### 测试策略

#### 1. 先写测试

```ts
// tests/unit/services/product-service.test.ts
import { describe, expect, it, vi } from 'vitest';
import { createProduct, getProductsByUser } from '@/app/actions/product';
import { createClient } from '@/lib/supabase/server';

// 模拟 Supabase 客户端
vi.mock('@/lib/supabase/server', () => ({
  createClient: vi.fn(() => ({
    auth: {
      getUser: vi.fn().mockResolvedValue({
        data: { user: { id: 'user-123' } },
      }),
    },
    from: vi.fn(() => ({
      insert: vi.fn().mockResolvedValue({ error: null }),
      select: vi.fn(() => ({
        eq: vi.fn().mockResolvedValue({
          data: [{ id: 1, name: 'Test Product' }],
          error: null,
        }),
      })),
    })),
  })),
}));

describe('Product Service', () => {
  describe('createProduct', () => {
    it('验证输入失败时返回错误', async () => {
      const formData = new FormData();
      formData.append('name', ''); // 空名称
      formData.append('price', '-10'); // 负价格

      const result = await createProduct(formData);

      expect(result.success).toBe(false);
      expect(result.errors).toHaveProperty('name');
      expect(result.errors).toHaveProperty('price');
    });

    it('验证输入成功时创建产品', async () => {
      const formData = new FormData();
      formData.append('name', 'Test Product');
      formData.append('price', '29.99');

      const result = await createProduct(formData);

      expect(result.success).toBe(true);
    });
  });
});
```

#### 2. 实现最小代码

```ts
// src/app/actions/product.ts
export async function createProduct(formData: FormData) {
  // 实现验证逻辑...
  // 实现数据库操作...
  return { success: true };
}
```

#### 3. 重构与优化

```tsx
// 重构：提取验证逻辑
import { z } from 'zod';

const CreateProductSchema = z.object({
  name: z.string().min(1, '名称不能为空'),
  price: z.coerce.number().positive('价格必须为正数'),
});

function validateProductInput(formData: FormData) {
  const rawData = Object.fromEntries(formData);
  return CreateProductSchema.safeParse(rawData);
}
```

### 测试类型

#### 单元测试 (Vitest + React Testing Library)

```tsx
// tests/unit/components/ui/button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '@/components/ui/button';
import { describe, expect, it, vi } from 'vitest';

describe('Button', () => {
  it('渲染子内容', () => {
    render(<Button>点击我</Button>);
    expect(screen.getByText('点击我')).toBeInTheDocument();
  });

  it('点击时调用回调', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>点击</Button>);
    fireEvent.click(screen.getByText('点击'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('禁用时不响应点击', () => {
    const handleClick = vi.fn();
    render(
      <Button onClick={handleClick} disabled>
        禁用按钮
      </Button>
    );
    fireEvent.click(screen.getByText('禁用按钮'));
    expect(handleClick).not.toHaveBeenCalled();
  });
});
```

#### 集成测试

```tsx
// tests/integration/dashboard.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import DashboardPage from '@/app/(dashboard)/page';
import { createClient } from '@/lib/supabase/server';

vi.mock('@/lib/supabase/server', () => ({
  createClient: vi.fn(() => ({
    auth: {
      getUser: vi.fn().mockResolvedValue({
        data: { user: { id: 'user-123', email: 'test@example.com' } },
      }),
    },
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          order: vi.fn(() => ({
            limit: vi.fn().mockResolvedValue({
              data: [
                { id: 1, name: '产品1', price: 100 },
                { id: 2, name: '产品2', price: 200 },
              ],
              error: null,
            }),
          })),
        })),
      })),
    })),
  })),
}));

describe('Dashboard Page', () => {
  it('显示用户的产品列表', async () => {
    render(await DashboardPage());

    await waitFor(() => {
      expect(screen.getByText('产品1')).toBeInTheDocument();
      expect(screen.getByText('$100')).toBeInTheDocument();
    });
  });
});
```

#### E2E 测试 (Playwright)

```ts
// tests/e2e/dashboard.spec.ts
import { test, expect } from '@playwright/test';

test('用户登录并查看仪表板', async ({ page }) => {
  // 1. 导航到登录页
  await page.goto('/login');

  // 2. 填写登录表单
  await page.fill('input[name="email"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');
  await page.click('button[type="submit"]');

  // 3. 验证重定向到仪表板
  await expect(page).toHaveURL('/dashboard');
  await expect(page.getByRole('heading', { name: '仪表板' })).toBeVisible();

  // 4. 创建新产品
  await page.click('text=新建产品');
  await page.fill('input[name="name"]', 'Playwright测试产品');
  await page.fill('input[name="price"]', '99.99');
  await page.click('button[type="submit"]');

  // 5. 验证产品创建成功
  await expect(page.getByText('Playwright测试产品')).toBeVisible();
});
```

### 测试数据构建器

```ts
// tests/factories/product-factory.ts
import { faker } from '@faker-js/faker';

export interface ProductData {
  id?: number;
  name: string;
  description?: string;
  price: number;
  is_published?: boolean;
  user_id?: string;
}

export function createProductData(overrides: Partial<ProductData> = {}): ProductData {
  return {
    name: faker.commerce.productName(),
    description: faker.commerce.productDescription(),
    price: parseFloat(faker.commerce.price({ min: 10, max: 1000 })),
    is_published: true,
    user_id: 'user-123',
    ...overrides,
  };
}
```

## 验证循环 (Verification)

### 阶段 1：构建与类型检查

```bash

#清理并构建
npm run build

#TypeScript 类型检查
npm run type-check

#如果没有 type-check 脚本，可以添加
"type-check": "tsc --noEmit"

```

### 阶段 2：静态分析与代码质量

```bash
#ESLint 检查
npm run lint

#如果有更严格的 lint
npm run lint:strict

#检查 Tailwind CSS 类
npx @tailwindcss/oxide check src//\*.{ts,tsx}
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

**覆盖率要求**：

- 语句覆盖率 ≥ 80%
- 分支覆盖率 ≥ 70%
- 函数覆盖率 ≥ 80%
- 行覆盖率 ≥ 80%

### 阶段 4：安全扫描

```bash
#依赖漏洞检查
npm audit

#如果有高级安全扫描
npm run security:scan

#检查敏感信息
npx secret-scan

#检查 Supabase RLS 策略
#确保所有表都有适当的 RLS 策略
```

### 阶段 5：性能与优化

```bash
#检查包大小
npm run analyze

#Lighthouse 检查
npx lighthouse https://your-staging-url.com --view

#检查 Core Web Vitals
npm run vitals
```

### 阶段 6：差异审查

```bash
#查看更改的文件
git status

#查看具体更改
git diff

#检查是否有调试代码
grep -r "console.log\debugger\ TODO\ FIXME" src/ --include=".ts" --include=".tsx" grep -v "test"
grep -v ".test.ts"
```

### 验证报告模板

```markdown
# NEXT.JS + SUPABASE 验证报告

项目: [项目名称]
环境: [development/staging]
时间: [时间戳]

构建状态: [✅ PASS / ❌ FAIL]
类型检查: [✅ PASS / ❌ FAIL] (错误数: X)
Lint 检查: [✅ PASS / ❌ FAIL] (警告数: Y, 错误数: Z)
测试结果: [✅ PASS / ❌ FAIL]
单元测试: X/Y 通过
集成测试: A/B 通过
E2E测试: M/N 通过
覆盖率: 行: P%, 分支: Q%, 函数: R%
安全检查: [✅ PASS / ❌ FAIL] (漏洞数: V)
性能检查: [✅ PASS / ❌ FAIL] (Lighthouse 分数: S)
包大小: [X.X MB] (gzipped)

关键问题:

1. [问题描述] - 优先级: [高/中/低]
2. [问题描述] - 优先级: [高/中/低]

部署就绪: [✅ 是 / ❌ 否]
```

## CI/CD 配置示例

```yaml
.github/workflows/ci.yml

name: CI

on:
push:
branches: [main]
pull_request:
branches: [main]

jobs:
verify:
runs-on: ubuntu-latest
env:
NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}

    steps:
      ◦ uses: actions/checkout@v4


      ◦ name: Setup Node.js

        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      ◦ name: Install dependencies

        run: npm ci

      ◦ name: Type check

        run: npm run type-check

      ◦ name: Lint

        run: npm run lint

      ◦ name: Run tests

        run: npm test

      ◦ name: Run e2e tests

        run: npm run test:e2e

      ◦ name: Build

        run: npm run build

      ◦ name: Security audit

        run: npm audit --audit-level=high
```

## 核心原则

1. **类型安全优先**：充分利用 TypeScript 严格模式，确保端到端类型安全。
2. **测试驱动开发**：先写测试，后写实现，保持高测试覆盖率。
3. **安全默认**：所有数据默认私有，通过 RLS 和中间件保护。
4. **性能感知**：优化 Core Web Vitals，使用正确的渲染策略。
5. **自动化验证**：通过 CI/CD 自动化所有验证步骤，确保每次提交都符合质量标准。

记住：良好的架构、全面的测试和严格的安全措施是构建可维护、可扩展和可靠应用的基础。在快速迭代的同时，始终保持代码质量。
