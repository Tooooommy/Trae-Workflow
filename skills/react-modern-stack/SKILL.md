---
name: react-modern-stack
description: 现代 React SPA 应用开发模式，涵盖基于 Vite 的项目架构、TypeScript 类型安全、状态管理、API 集成、组件开发、安全实践、测试驱动开发和发布前验证循环。适用于构建高性能、可维护的企业级单页应用。
---

# 现代 React 应用开发模式 (Vite + TypeScript)

基于 Vite、React 18+、TypeScript、React Router、Zustand、React Query、Shadcn/ui 和 Tailwind CSS 的完整开发模式。包含现代化项目结构、状态管理策略、API 集成、组件开发、安全最佳实践、测试策略和发布验证。

## 何时激活

- 使用 **Vite** 构建高性能的现代 React 单页应用 (SPA)。
- 采用 **TypeScript** 严格模式确保端到端类型安全。
- 使用 **React Router** 进行客户端路由管理。
- 需要 **Zustand** 进行客户端状态管理，**React Query** 进行服务器状态管理。
- 基于 **Shadcn/ui** 和 **Radix UI** 构建无障碍、可定制的组件库。
- 使用 **Tailwind CSS** 实现实用优先的样式开发。
- 需要完整的 SPA 开发指南，涵盖从项目搭建、状态管理、路由、测试到生产部署的全流程。

## 技术栈版本

| 技术         | 最低版本 | 推荐版本 |
| ------------ | -------- | -------- |
| React        | 18.2+    | 18.3+    |
| Vite         | 5.0+     | 最新     |
| TypeScript   | 5.0+     | 最新     |
| React Router | 6.20+    | 最新     |
| Zustand      | 4.4+     | 最新     |
| React Query  | 5.0+     | 最新     |
| Tailwind CSS | 3.4+     | 最新     |

## 开发模式 (Patterns)

### 项目结构

```bash
my-react-app/
├── src/
│ ├── api/ API 客户端与接口定义
│ │ ├── client.ts Axios/Fetch 客户端配置
│ │ ├── endpoints/ API 端点定义
│ │ │ ├── auth.ts
│ │ │ └── products.ts
│ │ └── types/ API 响应类型
│ ├── components/ React 组件
│ │ ├── ui/ 基于 Shadcn/ui 的基础组件
│ │ │ ├── button.tsx
│ │ │ ├── card.tsx
│ │ │ └── ...
│ │ ├── shared/ 共享组件
│ │ │ ├── layout/
│ │ │ │ ├── header.tsx
│ │ │ │ └── sidebar.tsx
│ │ │ └── forms/
│ │ │ └── product-form.tsx
│ │ └── features/ 功能组件 (按功能域组织)
│ │ ├── auth/
│ │ │ ├── login-form.tsx
│ │ │ └── register-form.tsx
│ │ └── products/
│ │ ├── product-list.tsx
│ │ └── product-card.tsx
│ ├── hooks/ 自定义 React Hooks
│ │ ├── use-auth.ts
│ │ ├── use-products.ts
│ │ └── use-debounce.ts
│ ├── lib/ 工具函数、配置
│ │ ├── utils.ts
│ │ ├── constants.ts
│ │ └── validators.ts Zod 验证模式
│ ├── pages/ 页面组件 (路由级)
│ │ ├── home/
│ │ │ └── page.tsx
│ │ ├── login/
│ │ │ └── page.tsx
│ │ ├── dashboard/
│ │ │ ├── page.tsx
│ │ │ └── products/
│ │ │ └── page.tsx
│ │ └── 404.tsx
│ ├── providers/ 上下文提供者
│ │ ├── query-client-provider.tsx
│ │ ├── theme-provider.tsx
│ │ └── auth-provider.tsx
│ ├── router/ 路由配置
│ │ ├── index.tsx
│ │ ├── routes.tsx
│ │ └── protected-route.tsx
│ ├── stores/ Zustand 状态存储
│ │ ├── auth.store.ts
│ │ ├── ui.store.ts
│ │ └── cart.store.ts
│ ├── styles/ 全局样式
│ │ └── globals.css
│ ├── types/ 全局类型定义
│ │ ├── index.ts
│ │ ├── api.ts
│ │ └── components.ts
│ ├── App.tsx
│ └── main.tsx
├── public/
├── tests/
│ ├── unit/
│ ├── integration/
│ └── e2e/
├── .env
├── .env.example
├── index.html
├── vite.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

### 状态管理策略

#### 客户端状态管理 (Zustand)

```tsx
// src/stores/auth.store.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { AuthUser, LoginCredentials } from '@/types/auth';

interface AuthState {
  user: AuthUser | null;
  token: string | null;
  isLoading: boolean;
  error: string | null;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
  clearError: () => void;
}

// 创建带有持久化和开发工具的存储
export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isLoading: false,
      error: null,

      login: async (credentials) => {
        set({ isLoading: true, error: null });
        try {
          const response = await api.auth.login(credentials);
          set({
            user: response.user,
            token: response.token,
            isLoading: false,
          });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : '登录失败',
            isLoading: false,
          });
          throw error;
        }
      },

      logout: () => {
        set({ user: null, token: null });
        // 清除 React Query 缓存
        queryClient.clear();
      },

      clearError: () => set({ error: null }),
    }),
    {
      name: 'auth-storage', // localStorage 的 key
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        token: state.token,
      }), // 只持久化 user 和 token
    }
  )
);

// 使用示例
import { useAuthStore } from '@/stores/auth.store';

function LoginForm() {
  const { login, isLoading, error } = useAuthStore();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await login({ email, password });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={(e) => setEmail(e.target.value)} />
      <input value={password} onChange={(e) => setPassword(e.target.value)} />
      <button type="submit" disabled={isLoading}>
        {isLoading ? '登录中...' : '登录'}
      </button>
      {error && <p className="text-red-500">{error}</p>}
    </form>
  );
}
```

#### 服务器状态管理 (React Query)

```ts
// src/api/client.ts
import axios from 'axios';
import { useAuthStore } from '@/stores/auth.store';

// 创建 Axios 实例
export const apiClient = axios.create({
baseURL: import.meta.env.VITE_API_URL,
timeout: 10000,
});

// 请求拦截器：添加认证令牌
apiClient.interceptors.request.use((config) => {
const token = useAuthStore.getState().token;
if (token) {
config.headers.Authorization = Bearer ${token};
}
return config;
});

// 响应拦截器：处理通用错误
apiClient.interceptors.response.use(
(response) => response,
(error) => {
if (error.response?.status === 401) {
useAuthStore.getState().logout();
}
return Promise.reject(error);
}
);
```

```ts
// src/api/endpoints/products.ts
import { apiClient } from '../client';
import { Product, ProductListResponse, CreateProductRequest } from '../types';

export const productApi = {
getProducts: (params?: { page?: number; limit?: number; search?: string }) =>
apiClient.get<ProductListResponse>('/products', { params }),

getProduct: (id: string) =>
apiClient.get<Product>(/products/${id}),

createProduct: (data: CreateProductRequest) =>
apiClient.post<Product>('/products', data),

updateProduct: (id: string, data: Partial<CreateProductRequest>) =>
apiClient.patch<Product>(/products/${id}, data),

deleteProduct: (id: string) =>
apiClient.delete<void>(/products/${id}),
};
```

```ts
// 在组件中使用 React Query
// src/hooks/use-products.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productApi } from '@/api/endpoints/products';
import { queryKeys } from '@/lib/query-keys';

export function useProducts(params?: { page?: number; limit?: number; search?: string }) {
return useQuery({
queryKey: queryKeys.products.list(params),
queryFn: () => productApi.getProducts(params).then(res => res.data),
staleTime: 5 60 1000, // 5分钟
gcTime: 10 60 1000, // 10分钟 (原 cacheTime)
});
}

export function useCreateProduct() {
const queryClient = useQueryClient();

return useMutation({
mutationFn: productApi.createProduct,
onSuccess: () => {
// 使相关查询失效，触发重新获取
queryClient.invalidateQueries({ queryKey: queryKeys.products.all });
},
});
}

export function useUpdateProduct(id: string) {
const queryClient = useQueryClient();

return useMutation({
mutationFn: (data: Partial<CreateProductRequest>) => productApi.updateProduct(id, data),
onSuccess: (updatedProduct) => {
// 更新缓存中的单个产品
queryClient.setQueryData(queryKeys.products.detail(id), updatedProduct.data);
// 使列表失效
queryClient.invalidateQueries({ queryKey: queryKeys.products.all });
},
});
}
```

```tsx
// 在组件中使用
// src/components/features/products/product-list.tsx
import { useProducts, useDeleteProduct } from '@/hooks/use-products';
import { Button } from '@/components/ui/button';
import { ProductCard } from './product-card';
import { Skeleton } from '@/components/ui/skeleton';

export function ProductList() {
const { data, isLoading, error, isError } = useProducts({ page: 1, limit: 10 });
const deleteMutation = useDeleteProduct();

if (isLoading) {
return (
<div className="space-y-4">
{Array.from({ length: 5 }).map((\_, i) => (
<Skeleton key={i} className="h-24 w-full" />
))}
</div>
);
}

if (isError) {
return <div>错误: {error.message}</div>;
}

return (
<div className="space-y-4">
{data?.products.map((product) => (
<ProductCard
key={product.id}
product={product}
onDelete={() => deleteMutation.mutate(product.id)}
/>
))}
</div>
);
}
```

### 路由配置 (React Router)

```tsx
// src/router/routes.tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { Layout } from '@/components/shared/layout';
import { ProtectedRoute } from './protected-route';

// 懒加载页面组件
const HomePage = lazy(() => import('@/pages/home/page'));
const LoginPage = lazy(() => import('@/pages/login/page'));
const DashboardPage = lazy(() => import('@/pages/dashboard/page'));
const ProductsPage = lazy(() => import('@/pages/dashboard/products/page'));
const ProductDetailPage = lazy(() => import('@/pages/dashboard/products/[id]/page'));
const NotFoundPage = lazy(() => import('@/pages/404'));

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        index: true,
        element: <HomePage />,
      },
      {
        path: 'login',
        element: <LoginPage />,
      },
      {
        path: 'dashboard',
        element: (
          <ProtectedRoute>
            <DashboardPage />
          </ProtectedRoute>
        ),
        children: [
          {
            index: true,
            element: <Navigate to="products" replace />,
          },
          {
            path: 'products',
            children: [
              {
                index: true,
                element: <ProductsPage />,
              },
              {
                path: ':id',
                element: <ProductDetailPage />,
              },
            ],
          },
        ],
      },
      {
        path: '\*',
        element: <NotFoundPage />,
      },
    ],
  },
]);
```

```tsx
// src/router/protected-route.tsx
import { Navigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '@/stores/auth.store';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export function ProtectedRoute({ children }: ProtectedRouteProps) {
  const { user, isLoading } = useAuthStore();
  const location = useLocation();

  if (isLoading) {
    return <div>加载中...</div>;
  }

  if (!user) {
    // 重定向到登录页，并保存当前路径以便登录后返回
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
}
```

### 组件开发 (Shadcn/ui + Radix UI)

```bash
# 安装和配置 Shadcn/ui
npx shadcn@latest init
#按照提示选择样式、颜色、全局 CSS 等

#添加组件

npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add dialog
npx shadcn@latest add form
npx shadcn@latest add input
npx shadcn@latest add label
npx shadcn@latest add select
npx shadcn@latest add table
npx shadcn@latest add toast
```

```tsx
// 使用示例
// src/components/features/products/product-form.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useToast } from '@/hooks/use-toast';

// 定义验证模式
const productFormSchema = z.object({
  name: z.string().min(2, {
    message: '产品名称至少需要2个字符',
  }),
  description: z.string().optional(),
  price: z.coerce.number().positive({
    message: '价格必须是正数',
  }),
  category: z.string({
    required_error: '请选择分类',
  }),
  stock: z.coerce.number().int().nonnegative({
    message: '库存不能为负数',
  }),
});

type ProductFormValues = z.infer<typeof productFormSchema>;

interface ProductFormProps {
  onSubmit: (data: ProductFormValues) => Promise<void>;
  initialData?: Partial<ProductFormValues>;
  isSubmitting?: boolean;
}

export function ProductForm({ onSubmit, initialData, isSubmitting }: ProductFormProps) {
  const { toast } = useToast();

  const form = useForm<ProductFormValues>({
    resolver: zodResolver(productFormSchema),
    defaultValues: initialData || {
      name: '',
      description: '',
      price: 0,
      category: '',
      stock: 0,
    },
  });

  const handleSubmit = async (data: ProductFormValues) => {
    try {
      await onSubmit(data);
      toast({
        title: '成功',
        description: '产品已保存',
      });
    } catch (error) {
      toast({
        title: '错误',
        description: error instanceof Error ? error.message : '保存失败',
        variant: 'destructive',
      });
    }
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-6">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>产品名称</FormLabel>
              <FormControl>
                <Input placeholder="请输入产品名称" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="description"
          render={({ field }) => (
            <FormItem>
              <FormLabel>描述</FormLabel>
              <FormControl>
                <Textarea placeholder="请输入产品描述" className="resize-none" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <FormField
            control={form.control}
            name="price"
            render={({ field }) => (
              <FormItem>
                <FormLabel>价格</FormLabel>
                <FormControl>
                  <Input type="number" step="0.01" placeholder="0.00" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="stock"
            render={(field) => (
              <FormItem>
                <FormLabel>库存</FormLabel>
                <FormControl>
                  <Input type="number" placeholder="0" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
        </div>

        <FormField
          control={form.control}
          name="category"
          render={({ field }) => (
            <FormItem>
              <FormLabel>分类</FormLabel>
              <Select onValueChange={field.onChange} defaultValue={field.value}>
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="选择分类" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectItem value="electronics">电子产品</SelectItem>
                  <SelectItem value="clothing">服装</SelectItem>
                  <SelectItem value="books">图书</SelectItem>
                  <SelectItem value="home">家居</SelectItem>
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />

        <div className="flex justify-end space-x-4">
          <Button
            type="button"
            variant="outline"
            onClick={() => form.reset()}
            disabled={isSubmitting}
          >
            重置
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? '保存中...' : '保存'}
          </Button>
        </div>
      </form>
    </Form>
  );
}
```

## 安全实践 (Security)

### 前端安全清单

- \[ ] **环境变量安全**：
  - 使用 `VITE_` 前缀定义环境变量，通过 `import.meta.env.VITE_API_URL` 访问。
  - 敏感信息（如 API 密钥）只能通过服务器端中转，**绝不**直接暴露在客户端代码中。
  - 创建 `.env.example` 文件作为模板，不提交 `.env` 文件到版本控制。

- \[ ] **认证与令牌安全**：
  - 使用 HTTP-only、Secure、SameSite=Strict 的 Cookie 存储令牌（如果可能）。
  - 将访问令牌存储在内存或 `sessionStorage` 中（针对 SPA），刷新令牌存储在 `httpOnly` Cookie 中。
  - 实现令牌自动刷新机制，防止用户会话意外中断。
  - 页面关闭/刷新时清除敏感的内存数据。

- \[ ] **输入验证与清理**：
  - 使用 **Zod** 在客户端和服务端进行双重验证。
  - 对用户生成的内容（如富文本）使用 **DOMPurify** 进行清理，防止 XSS。
  - 对输出到 DOM 的内容进行适当的转义。

    ```tsx
    import DOMPurify from 'dompurify';

    function UserComment({ comment }: { comment: string }) {
      const cleanHtml = DOMPurify.sanitize(comment);
      return <div dangerouslySetInnerHTML={{ __html: cleanHtml }} />;
    }
    ```

- \[ ] **CORS 配置**：
  - 确保后端 API 正确配置 CORS，只允许信任的来源。
  - 在生产环境中，明确指定 `Access-Control-Allow-Origin`，避免使用通配符 `*`。

- \[ ] **安全头**：
  - 通过服务器或静态托管服务（如 Vercel、Netlify）配置安全头：
    - `Content-Security-Policy` (CSP)：限制资源加载来源
    - `X-Frame-Options`: DENY
    - `X-Content-Type-Options`: nosniff
    - `Referrer-Policy`: strict-origin-when-cross-origin
    - `Permissions-Policy`: 限制浏览器功能访问

- \[ ] **依赖安全**：
  - 定期运行 `npm audit` 和 `npm outdated`，及时更新依赖。
  - 使用 `npm ci` 进行确定性安装，确保依赖版本一致。
  - 考虑使用 Snyk 或 Dependabot 进行自动化安全扫描。

- \[ ] **代码混淆与压缩**：
  - 使用 Vite 的生产构建（`npm run build`）自动进行代码压缩和混淆。
  - 启用 `vite.config.ts` 中的 `minify` 选项。

- \[ ] **错误处理**：
  - 避免在生产环境向用户暴露堆栈跟踪或内部错误详情。
  - 将错误记录到日志服务（如 Sentry），而不是控制台。

- \[ ] **防止点击劫持**：
  - 在 `index.html` 中添加 `<meta>` 标签：

    ```html
    <meta http-equiv="Content-Security-Policy" content="frame-ancestors 'none';" />
    ```

- \[ ] **HTTPS 强制**：
  - 确保生产环境使用 HTTPS。
  - 在开发环境中使用 Vite 的 HTTPS 选项。

### 安全中间件与拦截器

```ts
// src/api/client.ts - 增强的安全配置
import axios from 'axios';

export const apiClient = axios.create({
baseURL: import.meta.env.VITE_API_URL,
timeout: 10000,
headers: {
'Content-Type': 'application/json',
},
// 仅发送凭据到同源请求
withCredentials: import.meta.env.PROD,
});

// CSRF 令牌处理（如果后端使用）
let csrfToken: string | null = null;

if (typeof document !== 'undefined') {
const meta = document.querySelector('meta[name="csrf-token"]');
csrfToken = meta?.getAttribute('content') || null;
}

if (csrfToken) {
apiClient.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}

// 请求拦截器
apiClient.interceptors.request.use(
(config) => {
// 添加时间戳防止缓存
if (config.method?.toUpperCase() === 'GET') {
    config.params = {
        ...config.params,
        \_t: Date.now(),
    };
}
return config;
},
(error) => Promise.reject(error)
);

// 响应拦截器
apiClient.interceptors.response.use(
(response) => response,
(error) => {
// 统一错误处理
if (error.response?.status === 401) {
// 触发登出
window.dispatchEvent(new CustomEvent('unauthorized'));
}

    if (error.response?.status === 403) {
      // 权限不足
      window.dispatchEvent(new CustomEvent('forbidden'));
    }

    // 网络错误
    if (!error.response) {
      window.dispatchEvent(new CustomEvent('network-error'));
    }

    return Promise.reject(error);

}
);
```

## 测试驱动开发 (TDD)

### 测试策略

- **单元测试 (Vitest)**：测试工具函数、自定义 hooks、Zustand stores、表单验证逻辑。
- **组件测试 (Vitest + React Testing Library)**：测试 UI 组件的渲染、交互和状态。
- **集成测试 (Vitest + MSW)**：测试多个组件的交互，模拟 API 请求。
- **E2E 测试 (Playwright/Cypress)**：测试完整的用户流程。

### 测试环境配置

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
plugins: [react()],
test: {
environment: 'jsdom',
globals: true,
setupFiles: ['./tests/setup.ts'],
coverage: {
provider: 'istanbul',
reporter: ['text', 'json', 'html'],
exclude: [
'node_modules/',
'tests/setup.ts',
'/*.d.ts',
'/.config.',
'/index.ts',
],
},
},
resolve: {
alias: {
'@': path.resolve(\_\_dirname, './src'),
},
},
});
```

```ts
// tests/setup.ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

// 在每个测试后清理
afterEach(() => {
  cleanup();
});
```

### 单元测试示例

```tsx
// tests/unit/hooks/use-products.test.tsx
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useProducts } from '@/hooks/use-products';
import { productApi } from '@/api/endpoints/products';

// 模拟 API
vi.mock('@/api/endpoints/products');

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
);

describe('useProducts', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    queryClient.clear();
  });

  it('成功获取产品列表', async () => {
    const mockProducts = [
      { id: 1, name: '产品1', price: 100 },
      { id: 2, name: '产品2', price: 200 },
    ];

    vi.mocked(productApi.getProducts).mockResolvedValue({
      data: { products: mockProducts, total: 2 },
    });

    const { result } = renderHook(() => useProducts(), { wrapper });

    // 初始加载状态
    expect(result.current.isLoading).toBe(true);

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    expect(result.current.data?.products).toHaveLength(2);
    expect(result.current.data?.products[0].name).toBe('产品1');
  });

  it('API 错误时处理错误', async () => {
    vi.mocked(productApi.getProducts).mockRejectedValue(new Error('网络错误'));

    const { result } = renderHook(() => useProducts(), { wrapper });

    await waitFor(() => {
      expect(result.current.isError).toBe(true);
    });

    expect(result.current.error?.message).toBe('网络错误');
  });
});
```

### 组件测试示例

```tsx
// tests/unit/components/features/products/product-card.test.tsx
import { describe, expect, it, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { ProductCard } from '@/components/features/products/product-card';
import { Product } from '@/types';

const mockProduct: Product = {
  id: '1',
  name: '测试产品',
  price: 99.99,
  description: '测试描述',
  category: 'electronics',
  stock: 10,
};

describe('ProductCard', () => {
  it('正确显示产品信息', () => {
    render(<ProductCard product={mockProduct} />);

    expect(screen.getByText('测试产品')).toBeInTheDocument();
    expect(screen.getByText('¥99.99')).toBeInTheDocument();
    expect(screen.getByText('库存: 10')).toBeInTheDocument();
  });

  it('点击删除按钮时调用回调', () => {
    const onDelete = vi.fn();
    render(<ProductCard product={mockProduct} onDelete={onDelete} />);

    const deleteButton = screen.getByRole('button', { name: /删除/i });
    fireEvent.click(deleteButton);

    expect(onDelete).toHaveBeenCalledTimes(1);
  });

  it('禁用时删除按钮不可点击', () => {
    const onDelete = vi.fn();
    render(<ProductCard product={mockProduct} onDelete={onDelete} disabled />);

    const deleteButton = screen.getByRole('button', { name: /删除/i });
    expect(deleteButton).toBeDisabled();

    fireEvent.click(deleteButton);
    expect(onDelete).not.toHaveBeenCalled();
  });
});
```

### 集成测试示例 (使用 MSW 模拟 API)

```tsx
// tests/integration/products/product-list.test.tsx
import { describe, expect, it, beforeAll, afterAll, afterEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ProductList } from '@/components/features/products/product-list';
import { Toaster } from '@/components/ui/toaster';

// 模拟 API 服务器
const server = setupServer(
  http.get('\*/api/products', () => {
    return HttpResponse.json({
      products: [
        { id: 1, name: '产品A', price: 100 },
        { id: 2, name: '产品B', price: 200 },
      ],
      total: 2,
    });
  }),

  http.delete('\*/api/products/1', () => {
    return new HttpResponse(null, { status: 204 });
  })
);

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <QueryClientProvider client={queryClient}>
    {children}
    <Toaster />
  </QueryClientProvider>
);

describe('ProductList 集成测试', () => {
  beforeAll(() => server.listen());
  afterEach(() => {
    server.resetHandlers();
    queryClient.clear();
  });
  afterAll(() => server.close());

  it('加载并显示产品列表', async () => {
    render(<ProductList />, { wrapper });

    // 显示加载状态
    expect(screen.getByText(/加载中/i)).toBeInTheDocument();

    // 等待数据加载
    await waitFor(() => {
      expect(screen.getByText('产品A')).toBeInTheDocument();
      expect(screen.getByText('产品B')).toBeInTheDocument();
    });
  });

  it('删除产品后更新列表', async () => {
    render(<ProductList />, { wrapper });

    // 等待列表加载
    await waitFor(() => {
      expect(screen.getByText('产品A')).toBeInTheDocument();
    });

    // 模拟删除第一个产品
    server.use(
      http.get('*/api/products', () => {
        return HttpResponse.json({
          products: [{ id: 2, name: '产品B', price: 200 }],
          total: 1,
        });
      })
    );

    const deleteButton = screen.getAllByRole('button', { name: /删除/i })[0];
    fireEvent.click(deleteButton);

    // 验证产品A被移除
    await waitFor(() => {
      expect(screen.queryByText('产品A')).not.toBeInTheDocument();
      expect(screen.getByText('产品B')).toBeInTheDocument();
    });
  });
});
```

### E2E 测试示例 (Playwright)

```ts
// tests/e2e/products.spec.ts
import { test, expect } from '@playwright/test';

test.describe('产品管理', () => {
  test.beforeEach(async ({ page }) => {
    // 登录
    await page.goto('/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForURL('/dashboard');
  });

  test('查看产品列表', async ({ page }) => {
    await page.click('text=产品管理');
    await expect(page).toHaveURL('/dashboard/products');

    // 验证列表加载
    await expect(page.locator('text=产品A')).toBeVisible();
    await expect(page.locator('text=产品B')).toBeVisible();
  });

  test('创建新产品', async ({ page }) => {
    await page.goto('/dashboard/products');
    await page.click('text=新建产品');

    // 填写表单
    await page.fill('input[name="name"]', '新产品');
    await page.fill('input[name="price"]', '299.99');
    await page.fill('textarea[name="description"]', '新产品描述');
    await page.selectOption('select[name="category"]', 'electronics');
    await page.fill('input[name="stock"]', '50');

    await page.click('button[type="submit"]');

    // 验证创建成功
    await expect(page.locator('text=产品创建成功')).toBeVisible();
    await expect(page.locator('text=新产品')).toBeVisible();
  });
});
```

## 验证循环 (Verification)

### 阶段 1：代码质量检查

```bash

#1. TypeScript 类型检查
npm run type-check
#或
npx tsc --noEmit

#2. ESLint
npm run lint
#自动修复
npm run lint:fix

#3. 样式检查 (可选)
npx stylelint "/\*.css"

#4. 检查未使用的导出

npx ts-unused-exports tsconfig.json
```

### 阶段 2：测试套件

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

- 语句覆盖率：≥ 80%
- 分支覆盖率：≥ 70%
- 函数覆盖率：≥ 80%
- 行覆盖率：≥ 80%

### 阶段 3：安全与依赖检查

```bash

#1. 依赖漏洞扫描
npm audit
#忽略开发依赖
npm audit --production

#2. 检查过期依赖
npm outdated

#3. 检查许可证
npx license-checker --summary

#4. 检查 bundle 大小
npm run build
#查看 dist 目录大小
du -sh dist/
```

### 阶段 4：构建与性能检查

```bash

#1. 生产构建
npm run build

#2. 预览构建结果
npm run preview

#3. 使用 Lighthouse CI 检查性能
npm run lhci -- collect
npm run lhci -- upload

#4. 分析 bundle 大小
npm run build -- --profile
#然后使用 source-map-explorer 或 @rollup/plugin-visualizer
```

### 阶段 5：手动测试清单

1.  **跨浏览器测试**：Chrome、Firefox、Safari、Edge 最新版本。
2.  **响应式测试**：移动端、平板、桌面不同尺寸。
3.  **无障碍测试**：使用屏幕阅读器（NVDA、VoiceOver）测试键盘导航和 ARIA 标签。
4.  **性能测试**：页面加载速度、交互响应、内存使用。
5.  **离线测试**：验证 Service Worker 和缓存策略（如果使用 PWA）。
6.  **错误边界测试**：验证错误边界是否正常工作。

### 阶段 6：部署前检查

```bash
#1. 检查环境变量
echo "检查环境变量:"
echo "VITE_API_URL: ${VITE_API_URL}"
echo "VITE_ENV: ${VITE_ENV}"

#2. 验证构建产物
find dist/ -name "\*.html" | wc -l
#确保所有静态资源都存在

#3. 运行端到端测试
npm run test:e2e:ci
```

### 验证报告模板

```markdown
# REACT 应用验证报告

项目: [项目名称]
环境: [开发/测试/生产]
构建版本: [版本号]
时间: [时间戳]

[✅/❌] 类型检查通过
[✅/❌] ESLint 检查通过 (警告: X, 错误: Y)
[✅/❌] 测试套件通过
◦ 单元测试: A/B 通过

    ◦ 集成测试: C/D 通过

    ◦ E2E 测试: M/N 通过

    ◦ 覆盖率: 行: P%, 分支: Q%, 函数: R%

[✅/❌] 安全扫描通过 (漏洞数: V)
[✅/❌] 生产构建成功 (Bundle 大小: JS: X KB, CSS: Y KB)
[✅/❌] Lighthouse 性能评分: [性能分数], [可访问性分数]
[✅/❌] 浏览器兼容性检查通过
[✅/❌] 响应式布局检查通过

关键问题:

1. [高优先级] [问题描述]
2. [中优先级] [问题描述]

部署就绪: [✅ 是 / ❌ 否]
```

## 核心原则

1.  **类型安全优先：**充分利用 TypeScript 严格模式，为所有数据定义精确类型，从 API 响应到组件 Props。
2.  **状态管理清晰：**使用 Zustand 管理客户端 UI 状态，使用 React Query 管理服务器状态，明确区分职责。
3.  **组件可组合：**构建小型、专注、可复用的组件，遵循单一职责原则。
4.  **测试驱动开发：**为业务逻辑、组件交互和用户流程编写全面的测试，确保应用稳定性和可维护性。
5.  **性能优化：**代码分割、懒加载、图片优化、虚拟列表、缓存策略（如 React Query），确保应用加载快速、交互流畅。
6.  **安全默认：**输入验证、XSS 防护、CSP 配置、依赖安全，从第一天起就构建安全的应用。
7.  **自动化一切：**通过 CI/CD 自动化测试、检查、构建和部署流程，确保交付质量。

记住：现代 React 开发不仅仅是编写组件，更是构建可维护、可测试、高性能且安全的应用系统。良好的架构、严格的质量门禁和自动化的流程是成功项目的基石。
