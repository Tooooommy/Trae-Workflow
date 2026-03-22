---
alwaysApply: false
globs:
  - "**/manifest.json"
  - "**/pages.json"
---

# uni-app 项目规范与指南

> 基于 uni-app 的多端开发规范。

## 项目总览

* 技术栈: Vue 3, TypeScript, uni-app
* 架构: 多端统一，条件编译

## 关键规则

### 项目结构

```
src/
├── manifest.json           # 应用配置
├── pages.json              # 页面配置
├── main.ts                 # 入口文件
├── App.vue                 # 应用入口
├── uni.scss                # 全局样式变量
├── pages/
│   ├── index/
│   │   └── index.vue
│   └── user/
│       └── user.vue
├── components/
│   └── UserCard.vue
├── api/
│   └── user.ts
├── store/
│   └── index.ts
├── utils/
│   └── request.ts
├── static/
│   └── images/
└── subpackages/            # 分包
    └── packageA/
```

### 页面定义

```vue
<template>
  <view class="container">
    <view v-for="item in list" :key="item.id" class="item">
      <text>{{ item.name }}</text>
    </view>
    <view v-if="loading" class="loading">加载中...</view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onPullDownRefresh, onReachBottom } from '@dcloudio/uni-app'

const list = ref<any[]>([])
const loading = ref(false)

const loadData = async () => {
  loading.value = true
  try {
    const data = await api.getList()
    list.value = data
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
})

onPullDownRefresh(() => {
  loadData().finally(() => {
    uni.stopPullDownRefresh()
  })
})

onReachBottom(() => {
  loadMore()
})
</script>

<style lang="scss" scoped>
.container {
  padding: 20rpx;
}
</style>
```

### 组件定义

```vue
<template>
  <view class="user-card" @click="handleClick">
    <image :src="avatar" class="avatar" />
    <text class="name">{{ name }}</text>
  </view>
</template>

<script setup lang="ts">
interface Props {
  name: string
  avatar?: string
}

const props = withDefaults(defineProps<Props>(), {
  avatar: '/static/default-avatar.png'
})

const emit = defineEmits<{
  click: [value: { name: string }]
}>()

const handleClick = () => {
  emit('click', { name: props.name })
}
</script>

<style lang="scss" scoped>
.user-card {
  display: flex;
  align-items: center;
  padding: 20rpx;
}
</style>
```

### 全局配置

```json
// pages.json
{
  "pages": [
    { "path": "pages/index/index", "style": { "navigationBarTitleText": "首页" } },
    { "path": "pages/user/user", "style": { "navigationBarTitleText": "我的" } }
  ],
  "globalStyle": {
    "navigationBarTextStyle": "black",
    "navigationBarTitleText": "uni-app",
    "navigationBarBackgroundColor": "#ffffff",
    "backgroundColor": "#f5f5f5"
  },
  "tabBar": {
    "color": "#999",
    "selectedColor": "#007aff",
    "list": [
      { "pagePath": "pages/index/index", "text": "首页", "iconPath": "static/icons/home.png", "selectedIconPath": "static/icons/home-active.png" },
      { "pagePath": "pages/user/user", "text": "我的", "iconPath": "static/icons/user.png", "selectedIconPath": "static/icons/user-active.png" }
    ]
  },
  "subPackages": [
    { "root": "subpackages/packageA", "pages": [{ "path": "detail/detail" }] }
  ]
}
```

### 条件编译

```vue
<template>
  <view>
    <!-- #ifdef MP-WEIXIN -->
    <button open-type="getPhoneNumber" @getphonenumber="getPhoneNumber">
      获取手机号
    </button>
    <!-- #endif -->

    <!-- #ifdef H5 -->
    <button @click="getPhoneH5">获取手机号</button>
    <!-- #endif -->

    <!-- #ifdef MP-ALIPAY -->
    <button @click="getPhoneAlipay">获取手机号</button>
    <!-- #endif -->
  </view>
</template>

<script setup lang="ts">
// #ifdef MP-WEIXIN
const getPhoneNumber = (e: any) => {
  console.log(e.detail.code)
}
// #endif

// #ifdef H5
const getPhoneH5 = () => {
  // H5 逻辑
}
// #endif
</script>
```

## 开发命令

```bash
npm run dev:mp-weixin     # 微信小程序开发
npm run dev:mp-alipay     # 支付宝小程序开发
npm run dev:h5            # H5 开发
npm run build:mp-weixin   # 微信小程序构建
npm run build:h5          # H5 构建
```
