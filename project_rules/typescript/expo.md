---
alwaysApply: false
globs:
  - '**/app.json'
  - '**/App.tsx'
  - '**/eas.json'
---

# Expo 项目规范与指南

> 基于 Expo 的 React Native 开发规范。

## 项目总览

- 技术栈: Expo SDK 50+, React Native, TypeScript
- 架构: Expo Router 或 React Navigation

## 关键规则

### 项目结构

```
src/
├── app/                   # Expo Router 路由
│   ├── _layout.tsx        # 根布局
│   ├── index.tsx          # 首页
│   ├── (tabs)/            # Tab 路由组
│   │   ├── _layout.tsx
│   │   ├── home.tsx
│   │   └── profile.tsx
│   └── user/
│       └── [id].tsx       # 动态路由
├── components/
│   ├── ui/                # 通用 UI 组件
│   └── features/          # 功能组件
├── hooks/
├── services/
├── store/
├── utils/
├── constants/
│   └── theme.ts
├── types/
└── assets/
    ├── fonts/
    └── images/
app.json                   # Expo 配置
eas.json                   # EAS Build 配置
```

### 应用配置

```json
// app.json
{
  "expo": {
    "name": "MyApp",
    "slug": "my-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.myapp.app"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.myapp.app"
    },
    "plugins": ["expo-router", "expo-secure-store"],
    "scheme": "myapp"
  }
}
```

### 路由布局

```tsx
// app/_layout.tsx
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="auto" />
      <Stack>
        <Stack.Screen name="index" options={{ headerShown: false }} />
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="user/[id]" options={{ title: 'User Details' }} />
      </Stack>
    </>
  );
}

// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen
        name="home"
        options={{
          title: 'Home',
          tabBarIcon: ({ color }) => <Ionicons name="home" color={color} size={24} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color }) => <Ionicons name="person" color={color} size={24} />,
        }}
      />
    </Tabs>
  );
}
```

### 页面定义

```tsx
// app/(tabs)/home.tsx
import { View, Text, FlatList, ActivityIndicator } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { userService } from '@/services/userService';

export default function HomeScreen() {
  const {
    data: users,
    isLoading,
    error,
  } = useQuery({
    queryKey: ['users'],
    queryFn: userService.getUsers,
  });

  if (isLoading) {
    return <ActivityIndicator size="large" />;
  }

  if (error) {
    return <Text>Error loading users</Text>;
  }

  return (
    <View style={{ flex: 1, padding: 16 }}>
      <FlatList
        data={users}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <Text>{item.name}</Text>}
      />
    </View>
  );
}
```

## EAS Build 配置

```json
// eas.json
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
```

## 开发命令

```bash
npx expo start             # 开发服务器
npx expo start --ios       # iOS 开发
npx expo start --android   # Android 开发
npx expo start --web       # Web 开发

npx expo install           # 安装依赖

eas build --platform ios   # iOS 构建
eas build --platform android  # Android 构建
eas submit --platform ios  # 提交 App Store
eas update                 # OTA 更新
```
