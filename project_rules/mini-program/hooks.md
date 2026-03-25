# 小程序 Hooks

## 常用 Hooks

### useLoad

```typescript
Page({
  onLoad(options) {
    // 页面加载
  },
});
```

### useShow

```typescript
Page({
  onShow() {
    // 页面显示
  },
});
```

### useReady

```typescript
Page({
  onReady() {
    // 页面初次渲染完成
  },
});
```

## 组件 Hooks

- observers: 数据监听
- pageLifetimes: 页面生命周期
- componentLifetimes: 组件生命周期
