---
name: vue-patterns
description: Vue 3 组合式 API、Pinia 状态管理、组件设计和性能优化最佳实践。适用于所有 Vue 项目。
---

# Vue 3 开发模式

用于构建可维护、高性能 Vue 应用的组合式 API 模式与最佳实践。

## 何时激活

- 编写新的 Vue 组件
- 设计 Vue 应用架构
- 重构 Vue 2 到 Vue 3
- 优化 Vue 应用性能

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Vue | 3.4+ | 3.5+ |
| Pinia | 2.1+ | 最新 |
| Vue Router | 4.2+ | 最新 |
| Vite | 5.0+ | 最新 |
| TypeScript | 5.0+ | 最新 |

## 核心原则

### 1. 组合式 API 优先

```vue
<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'

interface Props {
  userId: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  update: [user: User]
}>()

const user = ref<User | null>(null)
const loading = ref(false)
const error = ref<string | null>(null)

const displayName = computed(() => 
  user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
)

async function fetchUser() {
  loading.value = true
  error.value = null
  try {
    user.value = await userService.getUser(props.userId)
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

watch(() => props.userId, fetchUser, { immediate: true })

onMounted(() => {
  console.log('Component mounted')
})
</script>

<template>
  <div v-if="loading">Loading...</div>
  <div v-else-if="error">{{ error }}</div>
  <div v-else>
    <h1>{{ displayName }}</h1>
  </div>
</template>
```

### 2. 单向数据流

```vue
<script setup lang="ts">
interface Props {
  modelValue: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

function handleInput(event: Event) {
  emit('update:modelValue', (event.target as HTMLInputElement).value)
}
</script>

<template>
  <input
    :value="modelValue"
    @input="handleInput"
  />
</template>
```

## 组合式函数 (Composables)

### 数据获取

```typescript
import { ref, watch, type Ref } from 'vue'

interface UseFetchOptions<T> {
  immediate?: boolean
  initialData?: T
}

export function useFetch<T>(
  url: Ref<string> | string,
  options: UseFetchOptions<T> = {}
) {
  const data = ref<T | undefined>(options.initialData) as Ref<T | undefined>
  const error = ref<Error | null>(null)
  const loading = ref(false)

  async function execute() {
    loading.value = true
    error.value = null
    try {
      const response = await fetch(typeof url === 'string' ? url : url.value)
      if (!response.ok) throw new Error(response.statusText)
      data.value = await response.json()
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  if (options.immediate !== false) {
    execute()
  }

  if (typeof url !== 'string') {
    watch(url, execute)
  }

  return { data, error, loading, execute }
}
```

### 表单处理

```typescript
import { ref, computed, type Ref } from 'vue'

interface ValidationRule<T> {
  validate: (value: T) => boolean
  message: string
}

export function useForm<T extends Record<string, any>>(
  initialValues: T,
  validationRules: Partial<{ [K in keyof T]: ValidationRule<T[K]>[] }> = {}
) {
  const values = ref<T>({ ...initialValues }) as Ref<T>
  const touched = ref<Set<keyof T>>(new Set())
  const errors = ref<Partial<{ [K in keyof T]: string[] }>>({})

  function validate(): boolean {
    const newErrors: Partial<{ [K in keyof T]: string[] }> = {}
    let isValid = true

    for (const field in validationRules) {
      const rules = validationRules[field]
      if (rules) {
        const fieldErrors: string[] = []
        for (const rule of rules) {
          if (!rule.validate(values.value[field])) {
            fieldErrors.push(rule.message)
            isValid = false
          }
        }
        if (fieldErrors.length > 0) {
          newErrors[field] = fieldErrors
        }
      }
    }

    errors.value = newErrors
    return isValid
  }

  function setFieldTouched(field: keyof T) {
    touched.value.add(field)
  }

  function reset() {
    values.value = { ...initialValues }
    touched.value.clear()
    errors.value = {}
  }

  const isValid = computed(() => Object.keys(errors.value).length === 0)

  return {
    values,
    touched,
    errors,
    isValid,
    validate,
    setFieldTouched,
    reset,
  }
}
```

### 事件总线

```typescript
import { ref, onUnmounted } from 'vue'

type EventHandler<T = any> = (payload: T) => void

export function useEventBus<T extends Record<string, any>>() {
  const listeners = new Map<keyof T, Set<EventHandler>>()

  function on<K extends keyof T>(event: K, handler: EventHandler<T[K]>) {
    if (!listeners.has(event)) {
      listeners.set(event, new Set())
    }
    listeners.get(event)!.add(handler)

    onUnmounted(() => off(event, handler))
  }

  function off<K extends keyof T>(event: K, handler: EventHandler<T[K]>) {
    listeners.get(event)?.delete(handler)
  }

  function emit<K extends keyof T>(event: K, payload: T[K]) {
    listeners.get(event)?.forEach(handler => handler(payload))
  }

  return { on, off, emit }
}
```

## 状态管理 (Pinia)

### Store 定义

```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('token'))

  const isAuthenticated = computed(() => !!token.value)
  const userName = computed(() => user.value?.name ?? 'Guest')

  async function login(credentials: Credentials) {
    const response = await authApi.login(credentials)
    token.value = response.token
    user.value = response.user
    localStorage.setItem('token', response.token)
  }

  function logout() {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
  }

  async function fetchUser() {
    if (!token.value) return
    user.value = await authApi.getProfile()
  }

  return {
    user,
    token,
    isAuthenticated,
    userName,
    login,
    logout,
    fetchUser,
  }
})
```

### 组合式 Store

```typescript
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([])

  const userStore = useUserStore()

  const totalItems = computed(() => 
    items.value.reduce((sum, item) => sum + item.quantity, 0)
  )

  const totalPrice = computed(() =>
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  )

  function addItem(product: Product) {
    const existing = items.value.find(i => i.productId === product.id)
    if (existing) {
      existing.quantity++
    } else {
      items.value.push({
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
      })
    }
  }

  function removeItem(productId: string) {
    const index = items.value.findIndex(i => i.productId === productId)
    if (index > -1) {
      items.value.splice(index, 1)
    }
  }

  async function checkout() {
    if (!userStore.isAuthenticated) {
      throw new Error('User not authenticated')
    }
    await orderApi.create({
      userId: userStore.user!.id,
      items: items.value,
    })
    items.value = []
  }

  return {
    items,
    totalItems,
    totalPrice,
    addItem,
    removeItem,
    checkout,
  }
})
```

## 组件模式

### 高阶组件

```typescript
import { defineComponent, h, type Component } from 'vue'

export function withLoading<T extends Component>(
  WrappedComponent: T,
  LoadingComponent: Component
) {
  return defineComponent({
    props: {
      loading: Boolean,
      ...WrappedComponent.props,
    },
    setup(props, { slots, attrs }) {
      return () => 
        props.loading
          ? h(LoadingComponent)
          : h(WrappedComponent, { ...props, ...attrs }, slots)
    },
  })
}
```

### 插槽模式

```vue
<script setup lang="ts">
interface Props {
  items: T[]
}

defineProps<Props>()
</script>

<template>
  <ul class="list">
    <li v-for="(item, index) in items" :key="index">
      <slot name="item" :item="item" :index="index">
        {{ item }}
      </slot>
    </li>
  </ul>
</template>

<!-- 使用 -->
<List :items="users">
  <template #item="{ item, index }">
    <div class="user-item">
      <span>{{ index + 1 }}.</span>
      <span>{{ item.name }}</span>
    </div>
  </template>
</List>
```

### 递归组件

```vue
<script setup lang="ts">
import type { TreeNode } from '@/types'

interface Props {
  node: TreeNode
  depth?: number
}

const props = withDefaults(defineProps<Props>(), {
  depth: 0,
})
</script>

<template>
  <div class="tree-node" :style="{ paddingLeft: `${depth * 20}px` }">
    <span class="label">{{ node.label }}</span>
    <template v-if="node.children?.length">
      <TreeNode
        v-for="child in node.children"
        :key="child.id"
        :node="child"
        :depth="depth + 1"
      />
    </template>
  </div>
</template>
```

## 性能优化

### 懒加载组件

```typescript
import { defineAsyncComponent } from 'vue'

const AsyncModal = defineAsyncComponent(() =>
  import('@/components/Modal.vue')
)

const AsyncChart = defineAsyncComponent({
  loader: () => import('@/components/Chart.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorComponent,
  delay: 200,
  timeout: 10000,
})
```

### 虚拟列表

```vue
<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

interface Props {
  items: any[]
  itemHeight: number
  containerHeight: number
}

const props = defineProps<Props>()

const scrollTop = ref(0)
const containerRef = ref<HTMLElement | null>(null)

const visibleCount = computed(() => 
  Math.ceil(props.containerHeight / props.itemHeight) + 2
)

const startIndex = computed(() => 
  Math.max(0, Math.floor(scrollTop.value / props.itemHeight) - 1)
)

const endIndex = computed(() => 
  Math.min(props.items.length, startIndex.value + visibleCount.value)
)

const visibleItems = computed(() => 
  props.items.slice(startIndex.value, endIndex.value)
)

const offsetY = computed(() => 
  startIndex.value * props.itemHeight
)

function handleScroll(event: Event) {
  scrollTop.value = (event.target as HTMLElement).scrollTop
}
</script>

<template>
  <div
    ref="containerRef"
    class="virtual-list"
    :style="{ height: `${containerHeight}px`, overflow: 'auto' }"
    @scroll="handleScroll"
  >
    <div
      class="virtual-list-content"
      :style="{
        height: `${items.length * itemHeight}px`,
        transform: `translateY(${offsetY}px)`,
      }"
    >
      <div
        v-for="item in visibleItems"
        :key="item.id"
        class="virtual-list-item"
        :style="{ height: `${itemHeight}px` }"
      >
        <slot :item="item" />
      </div>
    </div>
  </div>
</template>
```

### 计算属性缓存

```typescript
import { computed, ref } from 'vue'

const expensiveData = ref<Record<string, any>[]>([])

const processedData = computed(() => {
  console.log('Computing...')
  return expensiveData.value.map(item => ({
    ...item,
    processed: heavyTransform(item),
  }))
})

const filteredData = computed(() => 
  processedData.value.filter(item => item.active)
)

const sortedData = computed(() => 
  [...filteredData.value].sort((a, b) => a.name.localeCompare(b.name))
)
```

## 路由模式

### 路由守卫

```typescript
import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/dashboard',
      component: () => import('@/views/Dashboard.vue'),
      meta: { requiresAuth: true },
    },
  ],
})

router.beforeEach(async (to, from) => {
  const authStore = useAuthStore()

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
})

router.afterEach((to) => {
  document.title = to.meta.title ?? 'My App'
})
```

### 动态路由

```typescript
const routes = [
  {
    path: '/user/:id',
    component: UserView,
    props: true,
    beforeEnter: async (to) => {
      const userStore = useUserStore()
      await userStore.fetchUser(to.params.id as string)
    },
  },
]
```

## 测试模式

### 组件测试

```typescript
import { mount } from '@vue/test-utils'
import { describe, it, expect, vi } from 'vitest'
import UserCard from '@/components/UserCard.vue'

describe('UserCard', () => {
  it('renders user name', () => {
    const wrapper = mount(UserCard, {
      props: {
        user: { id: '1', name: 'Alice', email: 'alice@example.com' },
      },
    })

    expect(wrapper.text()).toContain('Alice')
  })

  it('emits edit event', async () => {
    const wrapper = mount(UserCard, {
      props: {
        user: { id: '1', name: 'Alice', email: 'alice@example.com' },
      },
    })

    await wrapper.find('[data-testid="edit-button"]').trigger('click')

    expect(wrapper.emitted('edit')).toBeTruthy()
    expect(wrapper.emitted('edit')![0]).toEqual([{ id: '1' }])
  })
})
```

### Store 测试

```typescript
import { setActivePinia, createPinia } from 'pinia'
import { describe, it, expect, beforeEach } from 'vitest'
import { useUserStore } from '@/stores/user'

describe('User Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('initializes with no user', () => {
    const store = useUserStore()
    expect(store.isAuthenticated).toBe(false)
  })

  it('sets user on login', async () => {
    const store = useUserStore()
    await store.login({ email: 'test@example.com', password: 'password' })
    expect(store.isAuthenticated).toBe(true)
  })
})
```

## 快速参考

| 模式 | 用途 |
|------|------|
| `<script setup>` | 组合式 API 语法糖 |
| Composables | 复用逻辑 |
| Pinia | 状态管理 |
| defineAsyncComponent | 懒加载 |
| v-memo | 列表优化 |
| Suspense | 异步组件 |

**记住**：Vue 3 的组合式 API 让代码更易复用和测试。优先使用 `<script setup>` 语法，将复杂逻辑抽取到 composables 中。
