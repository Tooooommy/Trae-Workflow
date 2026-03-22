---
alwaysApply: false
globs:
  - "**/index.js"
  - "**/App.tsx"
  - "**/android/**"
  - "**/ios/**"
---

# React Native CLI 项目规范与指南

> 基于 React Native CLI 的原生开发规范。

## 项目总览

* 技术栈: React Native CLI, TypeScript, React Navigation
* 架构: 原生模块集成，自定义原生代码

## 关键规则

### 项目结构

```
project/
├── src/
│   ├── App.tsx            # 应用入口
│   ├── screens/           # 页面
│   │   ├── Home/
│   │   │   ├── index.tsx
│   │   │   └── styles.ts
│   │   └── Profile/
│   ├── components/        # 组件
│   │   ├── common/
│   │   └── features/
│   ├── navigation/        # 导航
│   │   ├── index.tsx
│   │   └── types.ts
│   ├── hooks/
│   ├── services/
│   ├── store/
│   ├── utils/
│   ├── types/
│   └── assets/
├── android/               # Android 原生代码
│   ├── app/
│   │   └── src/main/java/com/myapp/
│   │       ├── MainActivity.kt
│   │       └── MainApplication.kt
│   └── build.gradle
├── ios/                   # iOS 原生代码
│   └── MyApp/
│       ├── AppDelegate.mm
│       └── Info.plist
├── index.js               # 注册入口
├── package.json
├── tsconfig.json
└── metro.config.js
```

### 应用入口

```tsx
// App.tsx
import React from 'react'
import { StatusBar } from 'react-native'
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import { SafeAreaProvider } from 'react-native-safe-area-context'
import { Provider } from 'react-redux'
import { store } from './store'
import { HomeScreen, ProfileScreen, LoginScreen } from './screens'

const Stack = createNativeStackNavigator()

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <SafeAreaProvider>
        <NavigationContainer>
          <StatusBar barStyle="dark-content" />
          <Stack.Navigator initialRouteName="Login">
            <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
            <Stack.Screen name="Home" component={HomeScreen} />
            <Stack.Screen name="Profile" component={ProfileScreen} />
          </Stack.Navigator>
        </NavigationContainer>
      </SafeAreaProvider>
    </Provider>
  )
}

export default App

// index.js
import { AppRegistry } from 'react-native'
import App from './App'
import { name as appName } from './app.json'

AppRegistry.registerComponent(appName, () => App)
```

### 原生模块 (Android)

```kotlin
// android/app/src/main/java/com/myapp/NativeModule.kt
package com.myapp

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

class NativeModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName(): String = "NativeModule"

    @ReactMethod
    fun getDeviceName(promise: Promise) {
        try {
            val deviceName = android.os.Build.MODEL
            promise.resolve(deviceName)
        } catch (e: Exception) {
            promise.reject("ERROR", e.message)
        }
    }
}

// NativeModulePackage.kt
package com.myapp

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.uimanager.ViewManager
import com.facebook.react.bridge.ReactApplicationContext

class NativeModulePackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        return listOf(NativeModule(reactContext))
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return emptyList()
    }
}
```

### 原生模块 (iOS)

```objc
// ios/MyApp/NativeModule.h
#import <React/RCTBridgeModule.h>

@interface NativeModule : NSObject <RCTBridgeModule>
@end

// ios/MyApp/NativeModule.m
#import "NativeModule.h"
#import <UIKit/UIKit.h>

@implementation NativeModule

RCT_EXPORT_MODULE(NativeModule);

RCT_EXPORT_METHOD(getDeviceName:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *deviceName = [[UIDevice currentDevice] name];
    resolve(deviceName);
}

@end
```

### TypeScript 调用

```tsx
// src/native/NativeModule.ts
import { NativeModules } from 'react-native'

interface NativeModuleInterface {
  getDeviceName(): Promise<string>
}

const { NativeModule } = NativeModules

export default NativeModule as NativeModuleInterface

// 使用
import NativeModule from './native/NativeModule'

const getDeviceName = async () => {
  try {
    const name = await NativeModule.getDeviceName()
    console.log('Device name:', name)
  } catch (error) {
    console.error('Error getting device name:', error)
  }
}
```

## 开发命令

```bash
# 开发
npm start                 # 启动 Metro
npm run ios               # iOS 开发
npm run android           # Android 开发

# iOS
cd ios && pod install     # 安装 CocoaPods
npm run ios -- --device   # 真机运行

# Android
npm run android -- --active-arch-only  # 单架构构建

# 构建
cd android && ./gradlew assembleRelease  # Android Release
# iOS 使用 Xcode 构建

# 清理
npm run clean
npx react-native start --reset-cache
```

## 注意事项

- iOS 开发需要 macOS + Xcode
- Android 需要 JDK 17 + Android Studio
- 原生模块需要分别实现 iOS/Android
- 真机调试需要配置签名证书
