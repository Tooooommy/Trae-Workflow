---
name: react-native-patterns
description: React Native 跨平台开发、状态管理、原生模块集成和性能优化最佳实践。适用于所有 React Native 项目。
---

# React Native 开发模式

用于构建高性能、跨平台移动应用的 React Native 模式与最佳实践。

## 何时激活

- 编写新的 React Native 应用
- 设计跨平台组件架构
- 集成原生模块
- 优化 React Native 性能

## 技术栈版本

| 技术             | 最低版本 | 推荐版本 |
| ---------------- | -------- | -------- |
| React Native     | 0.73+    | 0.75+    |
| React            | 18.2+    | 18.3+    |
| TypeScript       | 5.0+     | 最新     |
| React Navigation | 6.0+     | 最新     |
| Hermes           | 内置     | 启用     |

## 核心原则

### 1. 跨平台优先

```typescript
// 使用跨平台组件
import { View, Text, StyleSheet, Platform } from 'react-native';

// 平台特定代码
const styles = StyleSheet.create({
  container: {
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 4,
      },
      android: {
        elevation: 5,
      },
    }),
  },
});

// 平台特定文件
// Button.ios.tsx
// Button.android.tsx
// Button.tsx (默认)
```

### 2. 组件设计

```typescript
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  disabled = false,
}) => {
  return (
    <TouchableOpacity
      style={[styles.button, styles[variant], disabled && styles.disabled]}
      onPress={onPress}
      disabled={disabled}
      activeOpacity={0.7}
    >
      <Text style={[styles.text, styles[`${variant}Text`]]}>
        {title}
      </Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primary: {
    backgroundColor: '#007AFF',
  },
  secondary: {
    backgroundColor: '#E5E5EA',
  },
  disabled: {
    opacity: 0.5,
  },
  text: {
    fontSize: 16,
    fontWeight: '600',
  },
  primaryText: {
    color: '#FFFFFF',
  },
  secondaryText: {
    color: '#000000',
  },
});
```

### 3. Hooks 模式

```typescript
import { useState, useEffect, useCallback } from 'react';
import { Dimensions, Keyboard, AppState } from 'react-native';

// 屏幕尺寸 Hook
export function useWindowDimensions() {
  const [dimensions, setDimensions] = useState(Dimensions.get('window'));

  useEffect(() => {
    const subscription = Dimensions.addEventListener('change', ({ window }) => {
      setDimensions(window);
    });

    return () => subscription.remove();
  }, []);

  return dimensions;
}

// 键盘状态 Hook
export function useKeyboard() {
  const [keyboardHeight, setKeyboardHeight] = useState(0);
  const [isKeyboardVisible, setIsKeyboardVisible] = useState(false);

  useEffect(() => {
    const showSubscription = Keyboard.addListener('keyboardDidShow', (e) => {
      setKeyboardHeight(e.endCoordinates.height);
      setIsKeyboardVisible(true);
    });

    const hideSubscription = Keyboard.addListener('keyboardDidHide', () => {
      setKeyboardHeight(0);
      setIsKeyboardVisible(false);
    });

    return () => {
      showSubscription.remove();
      hideSubscription.remove();
    };
  }, []);

  return { keyboardHeight, isKeyboardVisible };
}

// 应用状态 Hook
export function useAppState() {
  const [appState, setAppState] = useState(AppState.currentState);

  useEffect(() => {
    const subscription = AppState.addEventListener('change', setAppState);
    return () => subscription.remove();
  }, []);

  return appState;
}
```

## 导航模式

### React Navigation

```typescript
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

// 类型定义
type RootStackParamList = {
  Home: undefined;
  Details: { id: string };
  Profile: undefined;
};

type TabParamList = {
  HomeTab: undefined;
  SettingsTab: undefined;
};

// Stack Navigator
const Stack = createNativeStackNavigator<RootStackParamList>();

function RootNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: { backgroundColor: '#007AFF' },
        headerTintColor: '#fff',
      }}
    >
      <Stack.Screen
        name="Home"
        component={HomeScreen}
        options={{ title: '首页' }}
      />
      <Stack.Screen
        name="Details"
        component={DetailsScreen}
        options={({ route }) => ({ title: `详情 ${route.params.id}` })}
      />
    </Stack.Navigator>
  );
}

// Tab Navigator
const Tab = createBottomTabNavigator<TabParamList>();

function TabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          const icons: Record<string, string> = {
            HomeTab: 'home',
            SettingsTab: 'settings',
          };
          return <Icon name={icons[route.name]} size={size} color={color} />;
        },
      })}
    >
      <Tab.Screen name="HomeTab" component={HomeScreen} />
      <Tab.Screen name="SettingsTab" component={SettingsScreen} />
    </Tab.Navigator>
  );
}

// 使用导航
function HomeScreen({ navigation }) {
  return (
    <Button
      title="Go to Details"
      onPress={() => navigation.navigate('Details', { id: '123' })}
    />
  );
}
```

### Deep Linking

```typescript
const linking = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: {
    screens: {
      Home: '',
      Details: 'details/:id',
      Profile: 'profile',
    },
  },
};

<NavigationContainer linking={linking}>
  <RootNavigator />
</NavigationContainer>
```

## 状态管理

### Redux Toolkit

```typescript
import { createSlice, configureStore, PayloadAction } from '@reduxjs/toolkit';

interface UserState {
  profile: User | null;
  isAuthenticated: boolean;
  loading: boolean;
}

const userSlice = createSlice({
  name: 'user',
  initialState: {
    profile: null,
    isAuthenticated: false,
    loading: false,
  } as UserState,
  reducers: {
    setProfile: (state, action: PayloadAction<User>) => {
      state.profile = action.payload;
      state.isAuthenticated = true;
    },
    logout: (state) => {
      state.profile = null;
      state.isAuthenticated = false;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.loading = action.payload;
    },
  },
});

export const { setProfile, logout, setLoading } = userSlice.actions;

const store = configureStore({
  reducer: {
    user: userSlice.reducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### Zustand

```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface UserStore {
  profile: User | null;
  isAuthenticated: boolean;
  setProfile: (user: User) => void;
  logout: () => void;
}

export const useUserStore = create<UserStore>()(
  persist(
    (set) => ({
      profile: null,
      isAuthenticated: false,
      setProfile: (user) => set({ profile: user, isAuthenticated: true }),
      logout: () => set({ profile: null, isAuthenticated: false }),
    }),
    {
      name: 'user-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

// 使用
function ProfileScreen() {
  const { profile, logout } = useUserStore();

  return (
    <View>
      <Text>{profile?.name}</Text>
      <Button title="Logout" onPress={logout} />
    </View>
  );
}
```

## 原生模块

### iOS 原生模块

```swift
// MyModule.swift
import React

@objc(MyModule)
class MyModule: NSObject {
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }

  @objc
  func getDeviceName(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    resolve(UIDevice.current.name)
  }

  @objc
  func showAlert(_ title: String, message: String) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
  }
}

// MyModule.m
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(MyModule, NSObject)
RCT_EXTERN_METHOD(getDeviceName:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(showAlert:(NSString *)title message:(NSString *)message)
@end
```

### Android 原生模块

```kotlin
// MyModule.kt
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactMethod

class MyModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName(): String {
        return "MyModule"
    }

    @ReactMethod
    fun getDeviceName(promise: Promise) {
        promise.resolve(android.os.Build.MODEL)
    }

    @ReactMethod
    fun showToast(message: String) {
        val activity = currentActivity
        activity?.runOnUiThread {
            Toast.makeText(reactApplicationContext, message, Toast.LENGTH_SHORT).show()
        }
    }
}

// MyPackage.kt
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.uimanager.ViewManager

class MyPackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        return listOf(MyModule(reactContext))
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return emptyList()
    }
}
```

### TypeScript 接口

```typescript
import { NativeModules, NativeEventEmitter } from 'react-native';

interface MyModuleInterface {
  getDeviceName(): Promise<string>;
  showAlert(title: string, message: string): void;
}

const { MyModule } = NativeModules;

export default MyModule as MyModuleInterface;

// 使用
const deviceName = await MyModule.getDeviceName();
MyModule.showAlert('Hello', 'Welcome!');
```

## 性能优化

### FlatList 优化

```typescript
import { FlatList } from 'react-native';

function UserList({ users }: { users: User[] }) {
  const renderItem = useCallback(({ item }: { item: User }) => (
    <UserCard user={item} />
  ), []);

  const keyExtractor = useCallback((item: User) => item.id, []);

  const getItemLayout = useCallback((_: any, index: number) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  }), []);

  return (
    <FlatList
      data={users}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      getItemLayout={getItemLayout}
      initialNumToRender={10}
      maxToRenderPerBatch={10}
      windowSize={5}
      removeClippedSubviews={true}
      ListEmptyComponent={<EmptyState />}
      ListFooterComponent={<LoadingMore />}
      onEndReached={loadMore}
      onEndReachedThreshold={0.5}
    />
  );
}
```

### 图片优化

```typescript
import FastImage from 'react-native-fast-image';

function OptimizedImage({ uri, width, height }: ImageProps) {
  return (
    <FastImage
      source={{
        uri,
        priority: FastImage.priority.normal,
        cache: FastImage.cacheControl.immutable,
      }}
      style={{ width, height }}
      resizeMode={FastImage.resizeMode.cover}
    />
  );
}

// 预加载图片
FastImage.preload([
  { uri: 'https://example.com/image1.jpg' },
  { uri: 'https://example.com/image2.jpg' },
]);
```

### 内存管理

```typescript
import { InteractionManager } from 'react-native';

function MyComponent() {
  useEffect(() => {
    const task = InteractionManager.runAfterInteractions(() => {
      // 在动画和交互完成后执行
      heavyOperation();
    });

    return () => task.cancel();
  }, []);
}
```

## 存储

### AsyncStorage

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

class StorageService {
  async set<T>(key: string, value: T): Promise<void> {
    await AsyncStorage.setItem(key, JSON.stringify(value));
  }

  async get<T>(key: string): Promise<T | null> {
    const value = await AsyncStorage.getItem(key);
    return value ? JSON.parse(value) : null;
  }

  async remove(key: string): Promise<void> {
    await AsyncStorage.removeItem(key);
  }

  async clear(): Promise<void> {
    await AsyncStorage.clear();
  }
}
```

### SQLite

```typescript
import SQLite from 'react-native-quick-sqlite';

const db = SQLite.openDatabase({ name: 'mydb.db' });

async function initDatabase() {
  await db.executeSql(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE
    )
  `);
}

async function saveUser(user: User) {
  await db.executeSql('INSERT OR REPLACE INTO users (id, name, email) VALUES (?, ?, ?)', [
    user.id,
    user.name,
    user.email,
  ]);
}

async function getUsers(): Promise<User[]> {
  const [result] = await db.executeSql('SELECT * FROM users');
  return result.rows._array;
}
```

## 测试

### 组件测试

```typescript
import { render, fireEvent } from '@testing-library/react-native';
import { Button } from './Button';

describe('Button', () => {
  it('renders correctly', () => {
    const { getByText } = render(
      <Button title="Press me" onPress={() => {}} />
    );
    expect(getByText('Press me')).toBeTruthy();
  });

  it('calls onPress when pressed', () => {
    const onPress = jest.fn();
    const { getByText } = render(
      <Button title="Press me" onPress={onPress} />
    );

    fireEvent.press(getByText('Press me'));
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    const onPress = jest.fn();
    const { getByText } = render(
      <Button title="Press me" onPress={onPress} disabled />
    );

    fireEvent.press(getByText('Press me'));
    expect(onPress).not.toHaveBeenCalled();
  });
});
```

## 快速参考

| 模式             | 用途         |
| ---------------- | ------------ |
| StyleSheet       | 样式定义     |
| Platform         | 平台适配     |
| FlatList         | 长列表       |
| React Navigation | 导航         |
| Zustand          | 轻量状态管理 |
| Native Modules   | 原生功能     |
| FastImage        | 图片优化     |

**记住**：React Native 的关键是平衡跨平台代码和平台特定优化。使用 FlatList 的优化属性，合理使用原生模块，注意内存管理。
