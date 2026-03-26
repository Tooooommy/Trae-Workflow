---
name: shopify-app-patterns
description: Shopify 应用（嵌入式应用）开发模式，涵盖架构模式、安全实践、测试驱动开发和项目验证循环。基于官方的 `shopify-app-template-react-router` 模板。**必须激活当**：用户要求构建 Shopify 应用、开发嵌入式应用或集成 Shopify API 时。即使用户没有明确说"Shopify"，当涉及 Shopify 应用或电商集成时也应使用。
---

# Shopify 应用开发模式 (React Router 模板)

基于官方 `shopify-app-template-react-router` 模板、React Router、TypeScript 的完整开发模式。包含 Shopify 应用特有的认证、API 集成、嵌入式 UI 模式、安全要求、测试策略和上架前验证。

## 何时激活

- 使用 **`shopify-app-template-react-router`** 模板初始化新的 Shopify 嵌入式应用（Embedded App）项目时。
- 为现有 Shopify 应用增加新功能模块，需参考架构与安全模式时。
- 需要遵循 **Shopify 平台规范** 和 **App Bridge** 安全要求进行开发时。
- 规划应用的认证、数据库、Webhook 和安装后流程时。
- 准备将应用提交至 Shopify 应用商店，需要通过自动化检查时。

## 技术栈版本

| 技术         | 最低版本 | 推荐版本 |
| ------------ | -------- | -------- |
| Node.js      | 18.0+    | 20.0+    |
| React        | 18.2+    | 18.3+    |
| React Router | 7.0+     | 最新     |
| TypeScript   | 5.0+     | 最新     |
| Shopify API  | 最新     | 最新     |
| Prisma       | 5.0+     | 最新     |
| PostgreSQL   | 14.0+    | 16.0+    |

## 开发模式 (Patterns)

### 项目结构与模板约定

```bash
my-shopify-app/
├── app/ # 核心应用代码 (基于 React Router)
│ ├── routes/ # 文件系统路由
│ │ ├── \_auth/ \*认证相关路由（用于 OAuth 回调）
│ │ │ └── callback.tsx OAuth 回调处理器
│ │ ├── \_index/ 应用主入口点路由组
│ │ │ ├── route.tsx 应用主页
│ │ │ └── additional.tsx 其他页面
│ │ └── api/ API 路由 (处理 Webhook 等)
│ │ └── webhooks.ts Webhook 处理器
│ ├── components/ React 组件
│ │ └── embedded/
│ │ └── layout.tsx 嵌入式应用布局 (使用 App Bridge)
│ ├── lib/ 工具、配置、Shopify 客户端
│ │ ├── session/ 会话存储 (基于数据库)
│ │ ├── shopify/ Shopify API 客户端配置
│ │ └── db/ 数据库客户端 (Prisma)
│ └── root.tsx 应用根组件
├── prisma/ 数据库架构与迁移
│ ├── schema.prisma
│ └── migrations/
├── public/
├── vite.config.ts
└── shopify.app.toml Shopify 应用配置文件
```

### 核心数据流模式 (Loader / Action)

#### Loader: 服务器端会话验证与数据获取

```tsx
// app/routes/\_index.tsx
import { json, type LoaderFunctionArgs } from '@remix-run/node';
import { useLoaderData } from '@remix-run/react';
import { authenticate } from '~/shopify.server';

export async function loader({ request }: LoaderFunctionArgs) {
  // 1. 使用模板提供的 authenticate.admin 完成会话验证和 API 客户端初始化
  const { admin, session } = await authenticate.admin(request);
  const shop = session.shop; // 经过验证的商店域名

  // 2. 使用认证后的 admin 客户端安全调用 Shopify Admin API
  const products = await admin.rest.get({
    path: '/products.json',
    query: { limit: 10 },
  });

  // 3. 也可查询自己的业务数据库
  const appData = await db.order.findMany({
    where: { shop },
  });

  return json({
    shop,
    products: products.data?.products || [],
    appData,
  });
}

export default function AppIndex() {
  const { shop, products, appData } = useLoaderData<typeof loader>();
  return (
    <div>
      <h1>欢迎，{shop}</h1>
      {/ 渲染数据 /}
    </div>
  );
}
```

#### Action: 处理表单提交与数据变更

```tsx
// app/routes/\_index.create-product.tsx
import { json, type ActionFunctionArgs } from '@remix-run/node';
import { authenticate } from '~/shopify.server';
import { z } from 'zod';

const CreateProductSchema = z.object({
  title: z.string().min(1),
  price: z.coerce.number().positive(),
});

export async function action({ request }: ActionFunctionArgs) {
  const { admin } = await authenticate.admin(request);
  const formData = await request.formData();
  const rawData = Object.fromEntries(formData);

  // 1. 验证输入
  const validation = CreateProductSchema.safeParse(rawData);
  if (!validation.success) {
    return json({ errors: validation.error.flatten().fieldErrors }, { status: 400 });
  }

  // 2. 调用 Shopify API 创建产品
  try {
    const response = await admin.rest.post({
      path: '/products.json',
      data: {
        product: {
          title: validation.data.title,
          variants: [{ price: validation.data.price }],
        },
      },
    });
    return json({ product: response.data?.product });
  } catch (error) {
    console.error('创建产品失败:', error);
    return json({ error: '创建失败' }, { status: 500 });
  }
}
```

### 嵌入式 UI 与 App Bridge

```tsx
// app/components/embedded/layout.tsx
import { useEffect } from 'react';
import { useLocation } from '@remix-run/react';
import { NavigationMenu, TitleBar } from '@shopify/app-bridge-react';
import { useAppBridge } from '@shopify/app-bridge-react';
import { getSessionToken } from '@shopify/app-bridge-utils';

export function EmbeddedLayout({ children }: { children: React.ReactNode }) {
const app = useAppBridge();
const location = useLocation();

// 1. 自动为 fetch 请求注入必要的认证头
useEffect(() => {
const fetchWithAuth = async (url: string, init?: RequestInit) => {
const token = await getSessionToken(app);
const headers = new Headers(init?.headers);
headers.set('Authorization', Bearer ${token});
return fetch(url, { ...init, headers });
};
// 可以替换全局 fetch 或通过 context 提供
}, [app]);

return (
<>
{/ 2. 使用 App Bridge 提供的导航和标题栏，与 Shopify Admin 保持一致 /}
<TitleBar title="我的应用" />
<NavigationMenu
navigationLinks={[
{
label: '概览',
destination: '/app',
},
{
label: '设置',
destination: '/app/settings',
},
]}
/>

<main>{children}</main>
</>
);
}
```

### Webhook 处理

```ts
// app/routes/api.webhooks.ts
import { type ActionFunctionArgs, json } from '@remix-run/node';
import { authenticate } from '~/shopify.server';

export async function action({ request }: ActionFunctionArgs) {
  // 1. 验证 Webhook 请求的 HMAC 签名
  const { topic, shop, payload, webhookId } = await authenticate.webhook(request);

  // 2. 根据 topic 处理不同事件
  switch (topic) {
    case 'ORDERS_CREATE':
      await handleOrderCreated(payload, shop);
      break;
    case 'APP_UNINSTALLED':
      await cleanupShopData(shop); // 清理该店铺数据
      break;
  }

  return json({ success: true });
}

async function handleOrderCreated(order: any, shop: string) {
  // 将订单数据同步到自己的数据库
  await db.order.create({
    data: {
      shop,
      shopifyOrderId: order.id,
      totalPrice: order.total_price,
      // ... 其他字段
    },
  });
}
```

## 安全实践 (Security)

### 认证与 OAuth 流程

模板已内置完整 OAuth 流程。核心安全要点：

1.  **会话存储**：模板默认使用 **Prisma + PostgreSQL** 存储 OAuth 会话。确保生产环境使用强密码，并定期轮换。
2.  **API 访问范围**：在 `shopify.app.toml` 中精确申请所需权限，遵循最小权限原则。

    ```toml

    # shopify.app.toml
    [access_scopes]

    # 使用手选模式，明确列出所需权限
    scopes = "read_products, write_products, read_orders"
    ```

3.  **前台 API 令牌**：永远不要在客户端组件或浏览器中直接使用 `ACCESS_TOKEN`。所有 Shopify API 调用必须通过你自己的后端（在 Loader/Action 中）进行，或使用 `getSessionToken` 获取短期令牌。

### 防止嵌入攻击

Shopify 嵌入式应用运行在 iframe 中，需配置 `Content-Security-Policy` 防止点击劫持等攻击。

```ts
// 在入口文件或服务器配置中添加响应头
// 例如，在 Vercel 的 vercel.json 或 Railway 的 railway.json 中
{
  "headers": [
    {
      "source": "/(._)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "frame-ancestors https://_.myshopify.com https://admin.shopify.com;"
        },
        { "key": "X-Frame-Options", "value": "ALLOW-FROM https://admin.shopify.com" }
      ]
    }
  ]
}
```

### 安全清单

- [ ] **环境变量**：`SHOPIFY_API_KEY`, `SHOPIFY_API_SECRET`, `SCOPES`, `DATABASE_URL` 等通过环境变量管理。**绝对不要**提交到代码仓库。
- [ ] **`shopify.app.toml` 配置**：
  - 正确配置 `app_url` 和 `auth.callback_path`。
  - 使用 `read_` 和 `write_` 前缀精确声明所需权限。
  - 正确配置 **App 级别的 Webhook** 订阅和终结点。
- [ ] **数据库安全**：
  - 为会话表（`Session`）建立索引并设置合理的清理任务。
  - 使用 Prisma 参数化查询，防止 SQL 注入。
- [ ] **输入验证**：对所有来自前端和 Webhook 的输入数据使用 **Zod** 进行验证和类型转换。
- [ ] **错误处理**：在生产环境中，不要将详细的数据库错误或堆栈跟踪返回给客户端。记录到日志服务。
- [ ] **依赖安全**：定期运行 `npm audit` 和更新 `@shopify/app-bridge-*` 等相关依赖。

## 测试驱动开发 (TDD)

### 测试策略

- **单元测试 (Vitest)**：测试工具函数、数据转换逻辑、自定义 hooks。
- **集成测试 (Vitest + @remix-run/testing)**：模拟 Shopify API 响应，测试 Loader 和 Action 的逻辑。
- **E2E 测试 (Playwright)**：模拟完整的用户安装、授权和应用内操作流程。

### 模拟 Shopify 环境

```ts
// tests/shopify-mocks.ts
import { vi } from 'vitest';

export const mockAuthenticateAdmin = vi.fn().mockResolvedValue({
  admin: {
    rest: {
      get: vi.fn().mockResolvedValue({ data: { products: [] } }),
      post: vi.fn().mockResolvedValue({ data: { product: { id: 1 } } }),
    },
    graphql: vi.fn().mockResolvedValue({ data: {} }),
  },
  session: {
    shop: 'test-shop.myshopify.com',
    accessToken: 'fake-token',
  },
});

export const mockAuthenticateWebhook = vi.fn().mockResolvedValue({
  topic: 'ORDERS_CREATE',
  shop: 'test-shop.myshopify.com',
  payload: { id: 123 },
  webhookId: 'webhook_123',
});
```

### Loader 集成测试示例

```tsx
// tests/integration/routes/\_index.test.tsx
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { createRequest } from '@remix-run/node';
import { loader } from '~/routes/\_index';
import { authenticate } from '~/shopify.server';
import { db } from '~/lib/db';

vi.mock('~/shopify.server');
vi.mock('~/lib/db');

describe('应用主页 Loader', () => {
  beforeEach(() => {
    vi.resetAllMocks();
  });

  it('成功获取商店数据和产品列表', async () => {
    // 模拟认证成功
    vi.mocked(authenticate.admin).mockResolvedValue({
      admin: {
        rest: {
          get: vi.fn().mockResolvedValue({
            data: { products: [{ id: 1, title: '测试产品' }] },
          }),
        },
      },
      session: { shop: 'test-shop.myshopify.com' },
    });
    // 模拟数据库查询
    vi.mocked(db.order.findMany).mockResolvedValue([]);

    const request = createRequest('http://localhost/app');
    const response = await loader({ request, params: {}, context: {} });

    // 验证响应状态和数据
    expect(response.status).toBe(200);
    const data = await response.json();
    expect(data.shop).toBe('test-shop.myshopify.com');
    expect(data.products).toHaveLength(1);
    expect(authenticate.admin).toHaveBeenCalledWith(request);
  });

  it('认证失败时抛出重定向', async () => {
    vi.mocked(authenticate.admin).mockRejectedValue(
      new Response(null, { status: 401, headers: { Location: '/auth' } })
    );

    const request = createRequest('http://localhost/app');
    await expect(loader({ request, params: {}, context: {} })).rejects.toThrow();
  });
});
```

### Action 测试示例

```tsx
// tests/integration/routes/\_index.create-product.test.tsx
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { createRequest } from '@remix-run/node';
import { action } from '~/routes/\_index.create-product';

describe('创建产品 Action', () => {
  it('验证失败时返回 400 及错误信息', async () => {
    const formData = new FormData();
    formData.append('title', ''); // 无效的标题
    formData.append('price', '-10'); // 无效的价格

    const request = createRequest('http://localhost/app/create-product', {
      method: 'POST',
      body: formData,
    });

    const response = await action({ request, params: {}, context: {} });
    expect(response.status).toBe(400);
    const data = await response.json();
    expect(data.errors).toHaveProperty('title');
    expect(data.errors).toHaveProperty('price');
  });
});
```

### E2E 测试 (Playwright) - 模拟 OAuth 流程片段

```ts
// tests/e2e/app-install.spec.ts
import { test, expect } from '@playwright/test';

// 注意：完全模拟 OAuth 流程较复杂，通常需要测试专用商店和 Token。
// 以下测试假设已有一个已安装应用的测试商店。
test('已安装应用的用户可以访问主页', async ({ page }) => {
// 1. 直接导航到已认证的应用主页（需要预先获取有效的会话）
await page.goto(/app?shop=test-store.myshopify.com&host=abc123);
// 在实际测试中，可能需要先通过 API 为该测试商店创建有效会话

// 2. 验证页面加载并显示商店信息
await expect(page.getByText('欢迎，test-store.myshopify.com')).toBeVisible();
await expect(page.getByRole('link', { name: '概览' })).toBeVisible();
});
```

## 验证循环 (Verification)

### 阶段 1：本地开发验证

```bash
# 1. 使用 Shopify CLI 启动开发服务器
npm run dev
#或
shopify app dev

#2. 检查类型
npm run type-check

#3. 运行 Prisma 迁移
npx prisma migrate dev
```

### 阶段 2：代码质量与安全检查

```bash
#1. Lint
npm run lint

#2. 依赖安全扫描
npm audit

#3. 检查敏感信息（是否意外提交密钥）
grep -r "SHOPIFY_API_SECRET\DATABASE_URL\ secret" . --include=".ts" --include=".toml" --include=".env\*" grep -v ".test." grep -v ".spec." grep -v node_modules
| true

#4. 验证 shopify.app.toml 配置
shopify app config lint
```

### 阶段 3：测试套件

```bash
#运行所有测试
npm test

#生成覆盖率报告
npm run test:coverage
```

**覆盖率目标**：

- Loader/Action 核心逻辑：≥ 80%
- 工具函数：≥ 90%
- 组件逻辑（非UI）：≥ 70%

### 阶段 4：生产环境预检查

```bash
#1. 构建项目
npm run build

#2. 检查 Prisma 生产数据库迁移状态
npx prisma migrate status
#确保状态为 Database schema is up to date

#3. 部署到预发环境，运行完整 E2E 测试流程
```

### 阶段 5：Shopify 合作伙伴仪表板检查

在提交审核前，手动检查：

1.  **应用配置**：`shopify.app.toml` 中的信息（名称、图标、权限、Webhook）与合作伙伴仪表板中一致。
2.  **安装流程**：在开发商店从头安装应用，确保 OAuth、权限请求和重定向流畅。
3.  **嵌入式体验**：应用在 Shopify Admin 内加载正常，无控制台错误，App Bridge 组件工作正常。
4.  **Webhook 交付**：在合作伙伴仪表板中检查关键 Webhook 是否成功送达。

### 验证报告模板

```markdown
# SHOPIFY 应用验证报告

应用名称: [你的应用名]
环境: [开发/预发]
时间: [时间戳]

[✅/❌] 本地开发服务器启动正常
[✅/❌] 类型检查通过
[✅/❌] ESLint 检查通过 (警告: X)
[✅/❌] 测试套件通过
◦ 单元测试: A/B 通过

    ◦ 集成测试: C/D 通过

    ◦ 覆盖率: 行: P%

[✅/❌] 依赖安全扫描通过 (漏洞数: V)
[✅/❌] 生产构建成功
[✅/❌] 数据库迁移状态同步
[✅/❌] Shopify CLI 配置检查通过

关键配置检查:
• 权限范围: [已确认最小化]

• Webhook 终结点: [可公开访问，已验证 HMAC]

• 应用 URL: [正确配置]

部署/提交审核就绪: [✅ 是 / ❌ 否]
```

## 核心原则

1.  **遵循平台规范：**严格遵守 Shopify 的嵌入式应用指南，使用官方模板和库（App Bridge），这是安全、兼容性和良好用户体验的基础。
2.  **服务器端为王：**所有业务逻辑、数据获取（尤其是调用 Shopify API）和敏感操作都必须在 Loader 或 Action 中完成。客户端只负责展示和交互。
3.  **安全是必须项：**OAuth 流程、会话管理、Webhook 验证、CSP 配置，每一项都必须正确实施。安全疏忽将直接导致审核失败或安全事件。
4.  **测试保障交付：**针对认证、API 集成和核心业务逻辑编写充分的测试，是应对 Shopify API 变更和确保应用稳定性的关键。
5.  **自动化验证：**将代码检查、测试和安全扫描集成到 CI/CD 流程中，确保每次提交都符合质量标准，为顺利上架铺平道路。

记住：一个成功的 Shopify 应用不仅是功能实现，更是对平台生态的深度理解和遵守。从开发之初就将安全、测试和验证融入流程，是构建可信赖、可持续应用的唯一途径。
