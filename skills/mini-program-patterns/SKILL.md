---
name: mini-program-patterns
description: 微信小程序开发模式、性能优化、原生能力集成和最佳实践。适用于所有微信小程序项目。
---

# 小程序开发模式

用于构建高性能微信小程序的模式与最佳实践。

## 何时激活

- 开发新的微信小程序
- 设计小程序架构
- 集成小程序 API
- 性能优化

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|----------|----------|
| 基础库 | 2.19+ | 2.25+ |
| TypeScript | 4.0+ | 5.0+ |
| 构建工具 | webpack 5 | 最新 |

## 目录结构

```
miniprogram/
├── pages/
│   ├── index/
│   │   ├── index.wxml
│   │   ├── index.wxss
│   │   ├── index.ts
│   │   └── index.json
├── components/
├── utils/
├── api/
├── app.ts
├── app.json
└── app.wxss
```

## 核心模式

### 1. 页面结构

```typescript
// pages/index/index.ts
Page({
  data: {
    message: 'Hello',
    list: [] as Item[],
    loading: false,
  },

  onLoad(options: OnLoadOptions) {
    this.loadData();
  },

  async loadData() {
    this.setData({ loading: true });
    try {
      const res = await api.getList();
      this.setData({ list: res.data, loading: false });
    } catch (err) {
      this.setData({ loading: false });
    }
  },

  onPullDownRefresh() {
    this.loadData().then(() => {
      wx.stopPullDownRefresh();
    });
  },
});
```

### 2. 组件开发

```typescript
// components/card/card.ts
Component({
  properties: {
    title: { type: String, value: '' },
    content: { type: String, value: '' },
  },

  data: {
    localState: 'test',
  },

  methods: {
    onTap() {
      this.triggerEvent('click', { id: 1 });
    },
  },
});
```

```json
{
  "component": true,
  "usingComponents": {}
}
```

### 3. 状态管理

```typescript
// utils/store.ts
class Store {
  private state = {};
  private listeners: Function[] = [];

  subscribe(fn: Function) {
    this.listeners.push(fn);
    return () => {
      this.listeners = this.listeners.filter(l => l !== fn);
    };
  }

  setState(newState: Partial<typeof this.state>) {
    this.state = { ...this.state, ...newState };
    this.listeners.forEach(fn => fn(this.state));
  }

  getState() {
    return this.state;
  }
}

export const store = new Store();
```

### 4. API 封装

```typescript
// utils/request.ts
interface RequestOptions {
  url: string;
  method?: 'GET' | 'POST';
  data?: object;
}

export const request = (options: RequestOptions) => {
  return new Promise((resolve, reject) => {
    wx.request({
      url: `https://api.example.com${options.url}`,
      method: options.method || 'GET',
      data: options.data,
      header: {
        'Content-Type': 'application/json',
      },
      success: (res) => {
        if (res.statusCode === 200) {
          resolve(res.data);
        } else {
          reject(res.data);
        }
      },
      fail: reject,
    });
  });
};
```

## 性能优化

### 1. setData 优化

```typescript
// 避免频繁 setData
// ❌ 错误
this.setData({ count: this.data.count + 1 });

// ✅ 正确 - 合并更新
this.setData({ count: newCount });

// ✅ 正确 - 使用局部数据
this.setData({
  'list[0].name': 'new name',
  'list.length': newLength,
});
```

### 2. 列表渲染

```xml
<!-- 使用 key -->
<block wx:for="{{list}}" wx:key="id">
  <view>{{item.name}}</view>
</block>

<!-- 长列表优化 -->
<recycle-view>
  <recycle-item wx:for="{{longList}}" wx:key="id">
    {{item.name}}
  </recycle-item>
</recycle-view>
```

### 3. 图片优化

```xml
<!-- 使用 CDN + 合适尺寸 -->
<image src="{{item.url}}?w=200&h=200" mode="aspectFill" />

<!-- 懒加载 -->
<image src="{{item.url}}" lazy-load="{{true}}" />
```

## 常用 API

### 路由

```typescript
// 跳转
wx.navigateTo({ url: '/pages/detail/detail?id=1' });
wx.redirectTo({ url: '/pages/detail/detail' });
wx.switchTab({ url: '/pages/index/index' });

// 返回
wx.navigateBack({ delta: 1 });
```

### 存储

```typescript
// 本地存储
wx.setStorageSync('key', value);
const value = wx.getStorageSync('key');
wx.removeStorageSync('key');
```

### 用户信息

```typescript
// 登录
wx.login({
  success: (res) => {
    console.log(res.code);
  },
});

// 获取用户信息
wx.getUserProfile({
  desc: '用于完善资料',
  success: (res) => {
    console.log(res.userInfo);
  },
});
```

## 调试

```typescript
// 开发阶段
console.log('debug info');

// 性能追踪
wx.performance?.createMark('mark1');

// 错误捕获
App({
  onError(err) {
    console.error(err);
  },
});
```

## 快速参考

| 模式 | 用途 |
|------|------|
| setData | 数据绑定 |
| Component | 组件 |
| behaviors | 代码复用 |
| observers | 数据监听 |
| relations | 组件关系 |
| externalClasses | 外部样式 |

**记住**：小程序开发关键在于理解其生命周期，合理使用 setData 优化性能，遵循小程序开发规范。
