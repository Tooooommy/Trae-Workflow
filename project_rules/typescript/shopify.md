---
alwaysApply: false
globs:
  - '**/shopify.app.toml'
  - '**/*.server.ts'
  - '**/*.server.tsx'
---

# Shopify App 项目规范与指南

> 基于 Shopify App Template (React Router) 的官方最佳实践开发规范。

## 项目总览

- 技术栈: Shopify CLI, React Router 7, Remix, TypeScript, Prisma
- 架构: Server-Side Rendering, OAuth 认证, Shopify Admin API

## 关键规则

### 项目结构

```
app/
├── routes/              # React Router 路由
│   ├── _index.tsx       # 首页
│   ├── app._index.tsx   # 应用首页
│   ├── app.products.tsx # 产品页面
│   └── auth.$.tsx       # OAuth 回调
├── components/          # 组件
│   ├── AppProvider.tsx  # Shopify Provider
│   └── Navigation.tsx   # 导航组件
├── models/              # Prisma 模型
│   └── server.ts        # 数据库配置
├── services/            # 服务层
│   └── shopify.server.ts
└── entry.server.tsx     # 服务端入口
prisma/
└── schema.prisma        # 数据库 Schema
shopify.app.toml         # Shopify 配置
vite.config.ts           # Vite 配置
```

### 应用配置

```toml
# shopify.app.toml
name = "my-shopify-app"
client_id = "your-client-id"
application_url = "https://your-app-url.com"
embedded = true

[access_scopes]
scopes = "write_products,read_products"

[auth]
redirect_urls = [
  "https://your-app-url.com/auth/callback"
]

[webhooks]
api_version = "2024-01"

[app_proxy]
url = "https://your-app-url.com/proxy"
subpath = "my-proxy"
```

### 路由定义

```tsx
// app/routes/app._index.tsx
import { json, type LoaderFunctionArgs } from '@shopify/remix-oxygen';
import { useLoaderData } from '@remix-run/react';
import { authenticate } from '../shopify.server';

export async function loader({ request }: LoaderFunctionArgs) {
  const { session, admin } = await authenticate.admin(request);

  const response = await admin.graphql(
    `#graphql
    query {
      products(first: 10) {
        edges {
          node {
            id
            title
            handle
          }
        }
      }
    }`
  );

  const { data } = await response.json();
  return json({ products: data.products.edges, shop: session.shop });
}

export default function AppIndex() {
  const { products, shop } = useLoaderData<typeof loader>();

  return (
    <ui-title-bar title={`Welcome to ${shop}`}>
      <button variant="primary" onClick={() => console.log('Action')}>
        Add Product
      </button>
    </ui-title-bar>
  );
}
```

### Shopify Provider

```tsx
// app/components/AppProvider.tsx
import { PolarismdProvider } from '@shopify/polaris';
import { AppProvider as ShopifyAppProvider } from '@shopify/shopify-app-remix/react';
import enTranslations from '@shopify/polaris/locales/en.json';

interface AppProviderProps {
  children: React.ReactNode;
  apiKey: string;
}

export function AppProvider({ children, apiKey }: AppProviderProps) {
  return (
    <ShopifyAppProvider isEmbeddedApp apiKey={apiKey}>
      <PolarismdProvider i18n={enTranslations}>{children}</PolarismdProvider>
    </ShopifyAppProvider>
  );
}
```

### GraphQL 查询

```tsx
// app/services/products.server.ts
import { type AdminApiContext } from '@shopify/shopify-app-remix/server';

export async function getProducts(admin: AdminApiContext) {
  const response = await admin.graphql(
    `#graphql
    query GetProducts($first: Int!) {
      products(first: $first) {
        edges {
          node {
            id
            title
            status
            variants(first: 1) {
              edges {
                node {
                  price
                  sku
                }
              }
            }
          }
        }
      }
    }`,
    { variables: { first: 50 } }
  );

  const { data } = await response.json();
  return data.products.edges.map((edge: any) => edge.node);
}

export async function createProduct(admin: AdminApiContext, product: any) {
  const response = await admin.graphql(
    `#graphql
    mutation CreateProduct($input: ProductInput!) {
      productCreate(input: $input) {
        product {
          id
          title
        }
        userErrors {
          field
          message
        }
      }
    }`,
    { variables: { input: product } }
  );

  return response.json();
}
```

### Webhook 处理

```tsx
// app/routes/webhooks.products.create.tsx
import { json, type ActionFunctionArgs } from '@shopify/remix-oxygen';
import { authenticate } from '../shopify.server';

export async function action({ request }: ActionFunctionArgs) {
  const { payload, session, topic, shop } = await authenticate.webhook(request);

  console.log(`Received ${topic} webhook for ${shop}`);

  // 处理产品创建事件
  const productId = payload.id;

  return json({ success: true });
}
```

### Prisma Schema

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Session {
  id          String   @id
  shop        String
  state       String
  isOnline    Boolean  @default(false)
  scope       String?
  expires     DateTime?
  accessToken String
  userId      String?

  @@index([shop])
}

model ProductSetting {
  id        String   @id @default(cuid())
  productId String   @unique
  enabled   Boolean  @default(true)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## 环境变量

```bash
# .env
DATABASE_URL="postgresql://user:password@localhost:5432/shopify_app"
SHOPIFY_API_KEY="your-api-key"
SHOPIFY_API_SECRET="your-api-secret"
SCOPES="write_products,read_products"
HOST="https://your-app-url.com"
```

## 开发命令

```bash
npm run dev              # 开发服务器
npm run build            # 生产构建
npm run start            # 生产服务器
npm run prisma:migrate   # 数据库迁移
npm run prisma:studio    # Prisma Studio
shopify app deploy       # 部署到 Shopify
shopify app config validate  # 验证配置
```
