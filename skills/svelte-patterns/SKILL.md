---
name: svelte-patterns
description: Svelte 响应式模式、Store 状态管理、组件设计和性能优化最佳实践。适用于所有 Svelte 项目。
---

# Svelte 开发模式

用于构建简洁、高性能 Web 应用的 Svelte 模式与最佳实践。

## 何时激活

- 编写新的 Svelte 组件
- 设计 Svelte 应用架构
- 使用 Svelte Store 状态管理
- 优化 Svelte 应用性能

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Svelte | 4.0+ | 5.0+ |
| SvelteKit | 2.0+ | 最新 |
| TypeScript | 5.0+ | 最新 |
| Vite | 5.0+ | 最新 |
| Svelte Store | 内置 | 内置 |

## 核心原则

### 1. 响应式声明

```svelte
<script>
  let count = 0;
  $: doubled = count * 2;
  $: {
    console.log(`count is ${count}`);
    console.log(`doubled is ${doubled}`);
  }

  function increment() {
    count += 1;
  }
</script>

<button on:click={increment}>
  Count: {count} (doubled: {doubled})
</button>
```

### 2. Props 和事件

```svelte
<!-- Child.svelte -->
<script>
  export let name = 'World';
  export let items = [];

  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();

  function handleClick(item) {
    dispatch('select', { item });
  }
</script>

<div>
  <h1>Hello, {name}!</h1>
  <ul>
    {#each items as item (item.id)}
      <li on:click={() => handleClick(item)}>
        {item.name}
      </li>
    {/each}
  </ul>
</div>

<!-- Parent.svelte -->
<script>
  import Child from './Child.svelte';

  function handleSelect(event) {
    console.log('Selected:', event.detail.item);
  }
</script>

<Child name="Svelte" {items} on:select={handleSelect} />
```

### 3. 双向绑定

```svelte
<!-- Input.svelte -->
<script>
  export let value = '';
</script>

<input bind:value />

<!-- Parent.svelte -->
<script>
  import Input from './Input.svelte';
  let text = '';
</script>

<Input bind:value={text} />
<p>You typed: {text}</p>
```

## Store 模式

### Writable Store

```javascript
import { writable } from 'svelte/store';

export const todos = writable([]);

export function addTodo(text) {
  todos.update(items => [...items, {
    id: Date.now(),
    text,
    completed: false,
  }]);
}

export function removeTodo(id) {
  todos.update(items => items.filter(t => t.id !== id));
}

export function toggleTodo(id) {
  todos.update(items =>
    items.map(t => t.id === id ? { ...t, completed: !t.completed } : t)
  );
}
```

### Readable Store

```javascript
import { readable } from 'svelte/store';

export const time = readable(new Date(), function start(set) {
  const interval = setInterval(() => {
    set(new Date());
  }, 1000);

  return function stop() {
    clearInterval(interval);
  };
});
```

### Derived Store

```javascript
import { derived } from 'svelte/store';
import { todos } from './todos';

export const completedTodos = derived(
  todos,
  $todos => $todos.filter(t => t.completed)
);

export const pendingTodos = derived(
  todos,
  $todos => $todos.filter(t => !t.completed)
);

export const todoStats = derived(
  [completedTodos, pendingTodos],
  ([$completed, $pending]) => ({
    completed: $completed.length,
    pending: $pending.length,
    total: $completed.length + $pending.length,
  })
);
```

### Custom Store

```javascript
import { writable } from 'svelte/store';

function createCounter() {
  const { subscribe, set, update } = writable(0);

  return {
    subscribe,
    increment: () => update(n => n + 1),
    decrement: () => update(n => n - 1),
    reset: () => set(0),
  };
}

export const counter = createCounter();
```

## 组件模式

### 插槽

```svelte
<!-- Card.svelte -->
<div class="card">
  <header class="card-header">
    <slot name="header">
      <h2>Default Title</h2>
    </slot>
  </header>
  
  <main class="card-body">
    <slot>No content</slot>
  </main>
  
  <footer class="card-footer">
    <slot name="footer"></slot>
  </footer>
</div>

<!-- 使用 -->
<Card>
  <h1 slot="header">Custom Title</h1>
  <p>Main content here</p>
  <button slot="footer">Action</button>
</Card>
```

### 插槽 Props

```svelte
<!-- List.svelte -->
<script>
  export let items = [];
</script>

<ul>
  {#each items as item, i (item.id)}
    <li>
      <slot {item} {i} />
    </li>
  {/each}
</ul>

<!-- 使用 -->
<List {items} let:item let:i>
  <span>{i + 1}. {item.name}</span>
</List>
```

### 递归组件

```svelte
<!-- TreeNode.svelte -->
<script>
  export let node;
  export let depth = 0;
</script>

<div class="node" style="padding-left: {depth * 20}px">
  <span>{node.label}</span>
  
  {#if node.children}
    {#each node.children as child (child.id)}
      <svelte:self node={child} depth={depth + 1} />
    {/each}
  {/if}
</div>
```

### 组件类

```svelte
<script>
  export let className = '';
  export let variant = 'primary';
</script>

<button class="btn btn-{variant} {className}">
  <slot />
</button>

<style>
  .btn {
    padding: 0.5rem 1rem;
    border-radius: 4px;
  }
  .btn-primary {
    background: blue;
    color: white;
  }
  .btn-secondary {
    background: gray;
    color: white;
  }
</style>
```

## 高级模式

### 动作 (Actions)

```javascript
export function clickOutside(node, callback) {
  function handleClick(event) {
    if (node && !node.contains(event.target) && !event.defaultPrevented) {
      callback();
    }
  }

  document.addEventListener('click', handleClick, true);

  return {
    destroy() {
      document.removeEventListener('click', handleClick, true);
    },
  };
}

// 使用
<script>
  import { clickOutside } from './actions';
  
  let show = false;
</script>

{#if show}
  <div use:clickOutside={() => show = false}>
    Dropdown content
  </div>
{/if}
```

### 过渡动画

```svelte
<script>
  import { fade, slide, fly } from 'svelte/transition';
  import { quintOut } from 'svelte/easing';

  let visible = true;
</script>

<button on:click={() => visible = !visible}>
  Toggle
</button>

{#if visible}
  <div
    in:fly={{ y: 20, duration: 300 }}
    out:fade={{ duration: 200 }}
  >
    Animated content
  </div>
{/if}
```

### 上下文 API

```javascript
import { setContext, getContext } from 'svelte';

// 父组件设置
const theme = writable('light');
setContext('theme', theme);

// 子组件获取
const theme = getContext('theme');
```

### 模块上下文

```svelte
<script context="module">
  export const preload = async ({ params }) => {
    const res = await fetch(`/api/users/${params.id}`);
    return { user: await res.json() };
  };
</script>

<script>
  export let user;
</script>

<h1>{user.name}</h1>
```

## 表单处理

### 表单绑定

```svelte
<script>
  let form = {
    name: '',
    email: '',
    role: 'user',
    notifications: true,
    tags: [],
  };

  function handleSubmit() {
    console.log('Form submitted:', form);
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <input type="text" bind:value={form.name} placeholder="Name" />
  
  <input type="email" bind:value={form.email} placeholder="Email" />
  
  <select bind:value={form.role}>
    <option value="user">User</option>
    <option value="admin">Admin</option>
  </select>
  
  <label>
    <input type="checkbox" bind:checked={form.notifications} />
    Enable notifications
  </label>
  
  <button type="submit">Submit</button>
</form>
```

### 表单验证

```svelte
<script>
  import { derived } from 'svelte/store';
  import { writable } from 'svelte/store';

  const form = writable({
    email: '',
    password: '',
  });

  const errors = derived(form, $form => ({
    email: !$form.email ? 'Email is required' :
           !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test($form.email) ? 'Invalid email' : null,
    password: !$form.password ? 'Password is required' :
              $form.password.length < 8 ? 'Password too short' : null,
  }));

  const isValid = derived(errors, $errors => 
    Object.values($errors).every(e => e === null)
  );

  function handleSubmit() {
    if ($isValid) {
      console.log('Submit:', $form);
    }
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <input type="email" bind:value={$form.email} />
  {#if $errors.email}
    <span class="error">{$errors.email}</span>
  {/if}
  
  <input type="password" bind:value={$form.password} />
  {#if $errors.password}
    <span class="error">{$errors.password}</span>
  {/if}
  
  <button type="submit" disabled={!$isValid}>Submit</button>
</form>
```

## 性能优化

### 懒加载

```svelte
<script>
  import { onMount } from 'svelte';

  let Component;
  let loading = true;

  onMount(async () => {
    const module = await import('./HeavyComponent.svelte');
    Component = module.default;
    loading = false;
  });
</script>

{#if loading}
  <p>Loading...</p>
{:else}
  <svelte:component this={Component} />
{/if}
```

### 虚拟列表

```svelte
<script>
  export let items = [];
  export let itemHeight = 50;
  export let containerHeight = 400;

  let scrollTop = 0;

  $: visibleCount = Math.ceil(containerHeight / itemHeight) + 2;
  $: startIndex = Math.max(0, Math.floor(scrollTop / itemHeight) - 1);
  $: endIndex = Math.min(items.length, startIndex + visibleCount);
  $: visibleItems = items.slice(startIndex, endIndex);
  $: offsetY = startIndex * itemHeight;

  function handleScroll(event) {
    scrollTop = event.target.scrollTop;
  }
</script>

<div
  class="virtual-list"
  style="height: {containerHeight}px; overflow: auto;"
  on:scroll={handleScroll}
>
  <div
    style="height: {items.length * itemHeight}px; position: relative;"
  >
    {#each visibleItems as item, i (item.id)}
      <div
        style="height: {itemHeight}px; position: absolute; top: {offsetY + i * itemHeight}px; width: 100%;"
      >
        <slot {item} />
      </div>
    {/each}
  </div>
</div>
```

### 响应式优化

```svelte
<script>
  let items = [];
  let filter = '';

  // 使用 reactive 语句缓存过滤结果
  $: filteredItems = filter
    ? items.filter(item => item.name.includes(filter))
    : items;
</script>

<!-- 使用 key 优化列表 -->
{#each filteredItems as item (item.id)}
  <div>{item.name}</div>
{/each}
```

## SvelteKit 集成

### 加载数据

```svelte
<script context="module">
  export async function load({ fetch, params }) {
    const res = await fetch(`/api/users/${params.id}`);
    
    if (res.ok) {
      return {
        props: { user: await res.json() },
      };
    }
    
    return {
      status: res.status,
      error: new Error('User not found'),
    };
  }
</script>

<script>
  export let user;
</script>

<h1>{user.name}</h1>
```

### 表单动作

```svelte
<script context="module">
  export const actions = {
    async default({ request, cookies }) {
      const data = await request.formData();
      const email = data.get('email');
      
      // 处理表单提交
      return { success: true };
    }
  };
</script>

<form method="POST">
  <input name="email" type="email" />
  <button type="submit">Subscribe</button>
</form>
```

## 测试模式

### 组件测试

```javascript
import { render, fireEvent } from '@testing-library/svelte';
import { describe, it, expect } from 'vitest';
import Counter from './Counter.svelte';

describe('Counter', () => {
  it('renders with initial count', () => {
    const { getByText } = render(Counter, { count: 5 });
    expect(getByText('5')).toBeTruthy();
  });

  it('increments on click', async () => {
    const { getByText, component } = render(Counter);
    const button = getByText('Increment');
    
    await fireEvent.click(button);
    
    expect(getByText('1')).toBeTruthy();
  });
});
```

### Store 测试

```javascript
import { get } from 'svelte/store';
import { describe, it, expect } from 'vitest';
import { todos, addTodo, removeTodo } from './todos';

describe('Todos Store', () => {
  it('adds a todo', () => {
    addTodo('Buy milk');
    expect(get(todos)).toContainEqual(
      expect.objectContaining({ text: 'Buy milk' })
    );
  });

  it('removes a todo', () => {
    addTodo('Test');
    const id = get(todos)[0].id;
    removeTodo(id);
    expect(get(todos)).not.toContainEqual(
      expect.objectContaining({ id })
    );
  });
});
```

## 快速参考

| 模式 | 用途 |
|------|------|
| $: 响应式 | 自动追踪依赖 |
| Store | 跨组件状态 |
| bind: | 双向绑定 |
| slot | 内容分发 |
| action | DOM 增强 |
| context | 依赖注入 |

**记住**：Svelte 的编译时优化让运行时更轻量。充分利用响应式声明和 Store 来管理状态，避免手动订阅和取消订阅。
