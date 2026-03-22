---
alwaysApply: false
globs:
  - "**/config/index.ts"
  - "**/src/app.config.ts"
---

# Taro 项目规范与指南

> 基于 Taro 的多端小程序开发规范。

## 项目总览

* 技术栈: Taro 3+, React/Vue, TypeScript
* 架构: 多端统一，一套代码多端运行

## 关键规则

### 项目结构

```
src/
├── app.config.ts           # 全局配置
├── app.tsx                 # 入口文件
├── app.scss                # 全局样式
├── index.html              # H5 入口
├── pages/
│   ├── index/
│   │   ├── index.tsx
│   │   ├── index.config.ts
│   │   └── index.scss
│   └── user/
├── components/
│   └── UserCard/
│       ├── index.tsx
│       └── index.scss
├── services/
│   └── api.ts
├── store/
│   ├── index.ts
│   └── modules/
│       └── user.ts
├── utils/
│   └── request.ts
└── types/
    └── index.d.ts
config/
├── index.ts                # 开发配置
├── dev.ts
└── prod.ts
```

### 页面定义

```tsx
import { View, Text } from '@tarojs/components'
import { useReady, useDidShow, useDidHide } from '@tarojs/taro'
import { useState, useEffect } from 'react'
import './index.scss'

export default function Index() {
  const [list, setList] = useState([])

  useReady(() => {
    console.log('Page ready')
  })

  useDidShow(() => {
    loadData()
  })

  useDidHide(() => {
    console.log('Page hide')
  })

  const loadData = async () => {
    const data = await api.getList()
    setList(data)
  }

  return (
    <View className="index">
      {list.map(item => (
        <View key={item.id} className="item">
          <Text>{item.name}</Text>
        </View>
      ))}
    </View>
  )
}

definePageConfig({
  navigationBarTitleText: '首页',
  enablePullDownRefresh: true
})
```

### 组件定义

```tsx
import { View, Text } from '@tarojs/components'
import { FC } from 'react'
import './index.scss'

interface UserCardProps {
  name: string
  avatar?: string
  onClick?: () => void
}

export const UserCard: FC<UserCardProps> = ({ name, avatar, onClick }) => {
  return (
    <View className="user-card" onClick={onClick}>
      <Image src={avatar || defaultAvatar} className="avatar" />
      <Text className="name">{name}</Text>
    </View>
  )
}
```

### 状态管理

```tsx
// store/modules/user.ts
import { createSlice } from '@reduxjs/toolkit'

const userSlice = createSlice({
  name: 'user',
  initialState: {
    info: null,
    token: ''
  },
  reducers: {
    setUserInfo: (state, action) => {
      state.info = action.payload
    },
    setToken: (state, action) => {
      state.token = action.payload
    },
    logout: (state) => {
      state.info = null
      state.token = ''
    }
  }
})

export const { setUserInfo, setToken, logout } = userSlice.actions
export default userSlice.reducer

// 页面使用
import { useSelector, useDispatch } from 'react-redux'
import { setUserInfo } from '@/store/modules/user'

const user = useSelector(state => state.user)
const dispatch = useDispatch()
dispatch(setUserInfo(userData))
```

## 多端配置

```typescript
// config/index.ts
const config = {
  projectName: 'taro-app',
  date: '2024-1-1',
  designWidth: 750,
  deviceRatio: {
    640: 2.34 / 2,
    750: 1,
    828: 1.81 / 2
  },
  sourceRoot: 'src',
  outputRoot: 'dist',
  plugins: [],
  defineConstants: {},
  copy: {
    patterns: [],
    options: {}
  },
  framework: 'react',
  compiler: {
    type: 'webpack5',
    prebundle: { enable: false }
  },
  mini: {
    postcss: {
      pxtransform: { enable: true, config: {} }
    }
  },
  h5: {
    publicPath: '/',
    staticDirectory: 'static',
    postcss: {
      autoprefixer: { enable: true }
    }
  }
}
```

## 开发命令

```bash
npm run dev:weapp      # 微信小程序开发
npm run dev:alipay     # 支付宝小程序开发
npm run dev:h5         # H5 开发
npm run build:weapp    # 微信小程序构建
npm run build:h5       # H5 构建
```
