---
name: react-native-ignite-stack
description: React Native 移动应用开发模式，涵盖基于 Ignite 脚手架的项目架构、Tamagui 高性能 UI 开发、安全实践、测试驱动开发和发布前验证循环。适用于构建高质量、跨平台的移动应用。
---

# React Native 开发模式 (Ignite + Tamagui)

基于 Ignite 脚手架和 Tamagui UI 框架的 React Native 移动应用开发模式。包含现代化项目结构、高性能跨平台 UI 开发、移动端安全考量、测试策略和商店发布验证。

## 何时激活

- 使用 **Ignite** 脚手架初始化新的 React Native 项目时。
- 采用 **Tamagui** 构建高性能、类型安全且可主题化的跨平台 UI 组件。
- 需要遵循 React Native 社区最佳实践和项目结构。
- 构建需要支持 iOS 和 Android 的生产级移动应用。
- 需要完整的移动开发指南，涵盖从项目搭建、状态管理、导航、测试到应用商店上架的全流程。

## 开发模式 (Patterns)

### 项目结构与 Ignite 约定

```bash
YourApp/
├── app/ # 应用核心代码 (Ignite 约定)
│ ├── components/ 可复用 UI 组件
│ │ ├── ui/ 基于 Tamagui 的基础组件
│ │ │ ├── button.tsx
│ │ │ └── text.tsx
│ │ └── shared/ 共享业务组件
│ ├── i18n/ 国际化
│ ├── models/ 数据模型 (Mobx-State-Tree 或其它)
│ ├── navigators/ 路由导航配置
│ ├── screens/ 应用屏幕 (页面)
│ │ ├── welcome/
│ │ │ └── screen.tsx
│ │ ├── demo/
│ │ │ └── screen.tsx
│ │ └── error/
│ │ └── boundary.tsx
│ ├── services/ 业务服务与 API 客户端
│ │ ├── api/ API 调用层
│ │ ├── storage/ 本地存储 (MMKV/AsyncStorage)
│ │ └── push-notifications/ 推送服务
│ ├── theme/ Tamagui 主题与样式定义
│ │ ├── index.ts
│ │ └── tokens.ts
│ ├── utils/ 工具函数
│ └── app.tsx 应用根组件
├── assets/ 静态资源 (图片、字体)
├── e2e/ 端到端测试
├── test/ 单元与集成测试
├── .env 环境变量
├── app.json Expo/React Native 配置
├── metro.config.js Metro 打包配置
├── tamagui.config.ts Tamagui 主题与配置
└── package.json
```

### 使用 Ignite CLI 初始化项目

```bash
#1. 安装 Ignite CLI (如果尚未安装)
npm install -g ignite-cli

#2. 使用 Ignite 创建新项目，选择你喜欢的选项
#例如，使用默认的 "Ignite Bowser" 模板，它包含许多开箱即用的最佳实践
ignite new YourAppName

#在初始化过程中，CLI 会询问一系列问题来配置项目：

#- 使用哪种导航库？(React Navigation)

#- 使用哪种状态管理库？(MobX-State-Tree, 或选择其他如 Zustand/Redux Toolkit)

#- 是否使用 Expo？(根据项目需求选择 Bare Workflow 或 Expo)

#- 选择 UI 框架？(此时可选择 Tamagui)

#3. 导航到项目目录并安装 Tamagui

cd YourAppName
npm install tamagui
#或使用你选择的包管理器

#4. 运行初始配置 (Tamagui 提供了 CLI 工具帮助设置)
npx tamagui init
#这将会创建 tamagui.config.ts 并更新 babel/metro 配置。

#5. 启动应用
npm run ios # 或 npm run android
#如果使用 Expo: npx expo start
```

### Tamagui UI 开发模式

#### 1. 定义设计与主题 Token

```ts
// app/theme/tokens.ts
import { createTokens } from 'tamagui'

export const tokens = createTokens({
// 设计系统的核心 Token
size: {
0: 0,
1: 4,
2: 8,
3: 12,
4: 16,
5: 20,
// ... 定义完整的尺寸阶梯
true: 16, // 默认尺寸
},
space: { ... }, // 通常复用 size 的值
radius: {
0: 0,
1: 3,
2: 5,
3: 7,
4: 9,
},
zIndex: {
0: 0,
1: 100,
2: 200,
},
color: {
// 语义化颜色名称
background: '#ffffff',
backgroundHover: '#f6f6f6',
text: '#050505',
textSubtle: '#6b6b6b',
border: '#ededed',
// 品牌色
primary: '#007AFF',
primaryAccent: '#0056CC',
success: '#34C759',
warning: '#FF9500',
danger: '#FF3B30',
},
})

```

```ts
// app/theme/index.ts
import { createTamagui } from 'tamagui';
import { tokens } from './tokens';

// 创建完整的 Tamagui 配置
export const config = createTamagui({
  tokens,
  themes: {
    // 定义主题 (如 light, dark)
    light: {
      background: tokens.color.background,
      backgroundHover: tokens.color.backgroundHover,
      text: tokens.color.text,
      textSubtle: tokens.color.textSubtle,
      border: tokens.color.border,
      primary: tokens.color.primary,
    },
    dark: {
      background: '#000000',
      backgroundHover: '#1c1c1e',
      text: '#ffffff',
      textSubtle: '#8e8e93',
      border: '#38383a',
      primary: '#0a84ff',
    },
  },
  // 可以在此处添加自定义字体、动画等
});

export type AppConfig = typeof config;
// 为 Tamagui 的样式属性提供类型支持
declare module 'tamagui' {
  interface TamaguiCustomConfig extends AppConfig {}
}
```

#### 2. 构建可复用的 Tamagui 组件

```tsx
// app/components/ui/button.tsx
import { styled, YStack, Text, GetProps } from 'tamagui';
import { TouchableOpacity } from 'react-native';

// 使用 styled 创建高性能的样式化组件
export const ButtonFrame = styled(YStack, {
  name: 'Button', // 有助于调试
  tag: 'button', // 在 Web 上渲染为 <button>，在 Native 上使用 TouchableOpacity
  backgroundColor: '$primary',
  borderRadius: '$4',
  paddingHorizontal: '$4',
  paddingVertical: '$3',
  alignItems: 'center',
  justifyContent: 'center',
  cursor: 'pointer',
  hoverStyle: {
    backgroundColor: '$primaryAccent',
  },
  pressStyle: {
    opacity: 0.8,
  },
  variants: {
    size: {
      small: {
        paddingHorizontal: '$3',
        paddingVertical: '$2',
      },
      large: {
        paddingHorizontal: '$5',
        paddingVertical: '$4',
      },
    },
    variant: {
      outlined: {
        backgroundColor: 'transparent',
        borderWidth: 1,
        borderColor: '$primary',
      },
      ghost: {
        backgroundColor: 'transparent',
      },
    },
    disabled: {
      true: {
        opacity: 0.5,
        cursor: 'not-allowed',
      },
    },
  } as const,
});

// 导出组件的 Props 类型，便于在其他地方使用
export type ButtonFrameProps = GetProps<typeof ButtonFrame>;

// 组合组件
export const Button = ButtonFrame.styleable<
  ButtonFrameProps & {
    title?: string;
    onPress?: () => void;
  }
>((props, ref) => {
  const { title, children, ...rest } = props;
  return (
    <ButtonFrame ref={ref} {...rest}>
      {title ? (
        <Text color="$background" fontWeight="600">
          {title}
        </Text>
      ) : (
        children
      )}
    </ButtonFrame>
  );
});
```

#### 3. 在屏幕中使用

```tsx
// app/screens/welcome/screen.tsx
import { SafeAreaView, ScrollView } from 'react-native';
import { Button, Text, YStack, XStack } from 'tamagui';
import { useNavigation } from '@react-navigation/native';

export function WelcomeScreen() {
  const navigation = useNavigation();

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <ScrollView>
        <YStack flex={1} padding="4" space="4">
          <Text fontSize="$8" fontWeight="bold">
            欢迎使用
          </Text>
          <Text color="$textSubtle">
            这是一个使用 Ignite 和 Tamagui 构建的高性能 React Native 应用示例。
          </Text>

          <YStack space="3" marginTop="6">
            <Button title="主要操作" onPress={() => navigation.navigate('Demo' as never)} />
            <Button title="次要操作" variant="outlined" onPress={() => console.log('Pressed')} />
            <Button
              title="禁用按钮"
              disabled
              onPress={() => {}} // 不会被触发
            />
          </YStack>

          {/ 响应式布局示例 /}
          <XStack
            flexWrap="wrap"
            gap="$2"
            $gtSm={{
              flexDirection: 'row',
              justifyContent: 'space-between',
            }}
          >
            <YStack
              backgroundColor="$backgroundHover"
              padding="$4"
              borderRadius="$4"
              flex={1}
              minWidth={150}
            >
              <Text fontWeight="600">特性 1</Text>
              <Text fontSize="2" color="textSubtle" marginTop="$2">
                高性能 UI
              </Text>
            </YStack>
            {/ 更多卡片... /}
          </XStack>
        </YStack>
      </ScrollView>
    </SafeAreaView>
  );
}
```

### 状态管理 (以 MobX-State-Tree 为例，Ignite 常用)

```ts
// app/models/root-store.ts
import { Instance, types } from 'mobx-state-tree';
import { withEnvironment } from './extensions/with-environment';
import { withRootStore } from './extensions/with-root-store';
import { UserModel, User } from './user';

export const RootStoreModel = types
  .model('RootStore')
  .props({
    user: types.optional(UserModel, {} as User),
    sessionToken: types.maybe(types.string),
  })
  .extend(withEnvironment) // 提供 API 客户端等环境依赖
  .extend(withRootStore) // 提供访问根 store 的方法
  .actions((self) => ({
    setSessionToken(token: string | undefined) {
      self.sessionToken = token;
    },
    reset() {
      self.sessionToken = undefined;
      self.user = {} as User;
    },
  }));

export interface RootStore extends Instance<typeof RootStoreModel> {}
```

### 服务层与 API 集成

```ts
// app/services/api/api-problem.ts
// 定义统一的 API 错误处理
export type ApiResponse<D = any> =
  | {
      kind: 'ok';
      data: D;
    }
  | {
      kind: 'bad-data';
      data: any;
      message?: string;
    }
  | {
      kind: 'timeout';
    }
  | {
      kind: 'cannot-connect';
    }
  | {
      kind: 'forbidden';
    }
  | {
      kind: 'not-found';
    }
  | {
      kind: 'rejected';
    }
  | {
      kind: 'unknown';
      temporary: boolean;
    }
  | {
      kind: 'unauthorized';
    };
```

```ts
// app/services/api/api.ts
import { ApisauceInstance, create } from 'apisauce'
import { ApiConfig, DEFAULT_API_CONFIG } from './api-config'

export class Api {
apisauce: ApisauceInstance
config: ApiConfig

constructor(config: ApiConfig = DEFAULT_API_CONFIG) {
this.config = config
this.apisauce = create({
baseURL: this.config.url,
timeout: this.config.timeout,
headers: {
Accept: 'application/json',
},
})

    // 请求拦截器：添加认证 Token
    this.apisauce.addRequestTransform((request) => {
      const token = rootStore.sessionToken // 从状态管理获取
      if (token) {
        request.headers.Authorization = Bearer ${token}
      }
    })

    // 响应拦截器：统一错误处理
    this.apisauce.addResponseTransform((response) => {
      // 可以在此处根据 HTTP 状态码转换响应为 ApiResponse
    })

}

async login(email: string, password: string): Promise<ApiResponse<{ token: string }>> {
const response = await this.apisauce.post('/auth/login', { email, password })
if (!response.ok) {
return { kind: 'bad-data', data: response.data }
}
return { kind: 'ok', data: response.data }
}
}
```

## 安全实践 (Security)

### 移动端安全清单

- \[ ] **安全存储**：
  - 永远不要将敏感信息（API 密钥、令牌）硬编码在源代码中。使用环境变量（通过 `react-native-config`）或安全的云配置服务。
  - 使用 **React Native Keychain** (iOS) 和 **SecureStore** (Android/Expo) 或 **MMKV** 的加密存储来安全存储认证令牌、生物特征信息等。
  - 避免使用 `AsyncStorage` 存储敏感数据，因为它未加密。

    ```bash
    npm install react-native-keychain

    # 或 (Expo)

    npx expo install expo-secure-store
    ```

    ```ts
    import \* as SecureStore from 'expo-secure-store';
    // 或 import Keychain from 'react-native-keychain';

    async function saveToken(token: string) {
        await SecureStore.setItemAsync('user_token', token, {
            keychainAccessible: SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY, // iOS 特定选项
        });
    }
    ```

- \[ ] **网络通信安全**：
  - 确保所有 API 通信都使用 **HTTPS**，禁用明文 HTTP（在 `Info.plist` 和 `AndroidManifest.xml` 中配置）。
  - 实施 **证书锁定 (Certificate Pinning)** 以防止中间人攻击（使用 `react-native-cert-pinner`）。
  - 验证服务器证书，不忽略 SSL 错误（切勿在开发后保留 `android:usesCleartextTraffic="true"`）。

- \[ ] **代码保护**：
  - 启用 **ProGuard** (Android) 和 **代码混淆** 以增加逆向工程难度。
  - 考虑使用商业解决方案（如 **Jscrambler**, **Promon SHIELD**）进行高级运行时保护。
  - 避免在日志中输出敏感信息，并在生产构建中移除 `console.log`（使用 Babel 插件如 `babel-plugin-transform-remove-console`）。

- \[ ] **本地数据安全**：
  - 使用 **SQLCipher** 对本地 SQLite 数据库进行加密（如果应用存储大量结构化敏感数据）。
  - 定期清理缓存和临时文件。

- \[ ] **生物识别与设备认证**：
  - 使用 `expo-local-authentication` 或 `react-native-biometrics` 安全地集成指纹/面部识别，用于敏感操作。

- \[ ] **依赖安全**：
  - 定期运行 `npm audit` 和 `snyk test` 检查依赖漏洞。
  - 锁定依赖版本（使用 `package-lock.json` 或 `yarn.lock`）并定期更新。

- \[ ] **深度链接 (Deep Link) 安全**：
  - 验证深度链接 URL 的来源和完整性，防止通过恶意链接进行未授权操作。

- \[ ] **发布配置**：
  - 为 iOS 和 Android 使用不同的发布证书和密钥库。
  - 在 Google Play Console 中启用 **应用签名** (Play App Signing)。
  - 在 Firebase 控制台（如果使用）中正确配置你的 Android 应用 SHA-1/SHA-256 证书指纹。

## 测试驱动开发 (TDD)

### 测试策略

- **单元测试 (Jest)**：测试工具函数、转换逻辑、MobX-State-Tree 的 action 和 computed 属性、Tamagui 工具函数。
- **组件测试 (React Native Testing Library)**：测试 UI 组件的渲染和交互逻辑。
- **集成测试 (Detox 或 Maestro)**：测试跨多个模块的用户流程（如登录、导航）。
- **E2E 测试 (Detox 或 Appium)**：在模拟器/真机上测试完整的用户旅程（速度较慢，用于关键路径）。

### 单元测试示例 (Jest)

```ts
// test/services/api/api.test.ts
import { Api } from '../../../app/services/api/api';
import { ApiResponseKind } from '../../../app/services/api/api-problem';

describe('Api 服务', () => {
  let api: Api;

  beforeEach(() => {
    api = new Api({ url: 'https://api.example.com', timeout: 5000 });
  });

  describe('login', () => {
    it('使用有效凭据返回 token', async () => {
      // 模拟 apisauce
      const mockPost = jest.fn().mockResolvedValue({
        ok: true,
        data: { token: 'fake-jwt-token' },
      });
      api.apisauce.post = mockPost;

      const result = await api.login('user@example.com', 'password123');

      expect(result.kind).toBe('ok');
      if (result.kind === 'ok') {
        expect(result.data.token).toBe('fake-jwt-token');
      }
      expect(mockPost).toHaveBeenCalledWith('/auth/login', {
        email: 'user@example.com',
        password: 'password123',
      });
    });

    it('使用无效凭据返回错误', async () => {
      const mockPost = jest.fn().mockResolvedValue({
        ok: false,
        data: { error: 'Invalid credentials' },
      });
      api.apisauce.post = mockPost;

      const result = await api.login('wrong@example.com', 'wrong');

      expect(result.kind).toBe('bad-data');
    });
  });
});
```

### 组件测试示例 (React Native Testing Library)

```tsx
// test/components/ui/button.test.tsx
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';
import { Button } from '../../../app/components/ui/button';

describe('Button 组件', () => {
  it('渲染标题文本', () => {
    render(<Button title="点击我" />);
    expect(screen.getByText('点击我')).toBeTruthy();
  });

  it('点击时触发 onPress 回调', () => {
    const onPressMock = jest.fn();
    render(<Button title="点击" onPress={onPressMock} />);

    fireEvent.press(screen.getByText('点击'));

    expect(onPressMock).toHaveBeenCalledTimes(1);
  });

  it('禁用时不触发 onPress', () => {
    const onPressMock = jest.fn();
    render(<Button title="禁用按钮" disabled onPress={onPressMock} />);

    fireEvent.press(screen.getByText('禁用按钮'));

    expect(onPressMock).not.toHaveBeenCalled();
  });
});
```

### 集成/E2E 测试 (Detox 示例)

```javascript
// e2e/firstTest.spec.js
describe('登录流程', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('应该显示欢迎屏幕', async () => {
    await expect(element(by.text('欢迎使用'))).toBeVisible();
  });

  it('登录后应导航到主页', async () => {
    await element(by.id('emailInput')).typeText('user@example.com');
    await element(by.id('passwordInput')).typeText('password123');
    await element(by.text('登录')).tap();

    // 等待导航并断言
    await waitFor(element(by.text('主页')))
      .toBeVisible()
      .withTimeout(5000);
  });
});
```

## 验证循环 (Verification)

### 阶段 1：代码质量与静态分析

```bash

# 1. TypeScript 类型检查
npm run type-check
#或
npx tsc --noEmit

#2. ESLint
npm run lint

#3. 检查未使用的代码/依赖 (可选)
npx depcheck
```

### 阶段 2：测试套件

```bash
#运行单元测试
npm test
#或
npm run test:unit

#生成测试覆盖率报告
npm run test:coverage
```

**覆盖率目标**：

- 工具函数、服务层、状态管理逻辑：≥ 80%
- 组件逻辑（非样式）：≥ 70%
- 整体覆盖率：≥ 75%

### 阶段 3：安全扫描

```bash
#1. 依赖漏洞扫描
npm audit
#或使用更高级的工具
npx snyk test

#2. 检查可能的敏感信息泄露
grep -r "password\secret\ key\ token" . --include=".ts" --include=".tsx" --include="\*.js" --exclude-dir=node_modules --exclude-dir=.git grep -v ".test." grep -v ".spec." grep -v "//"
| true
```

### 阶段 4：构建与打包检查

```bash
#1. 清理并构建 Android 版本
cd android && ./gradlew clean
npm run android -- --mode=release
#或生成 APK/AAB
cd android && ./gradlew bundleRelease

#2. 构建 iOS 版本 (需要在 macOS 上)
cd ios && pod install
npm run ios -- --configuration Release
#或通过 Xcode 进行 Archive

#3. 检查包大小 (使用 react-native-bundle-visualizer 等工具)
npm run analyze-bundle
```

### 阶段 5：手动与自动化验收测试

1.  **在多种设备/模拟器上运行应用**：测试不同屏幕尺寸、操作系统版本。
2.  **测试关键用户流程**：安装、登录、核心功能、推送通知、深度链接、应用状态恢复（前后台切换）。
3.  **性能测试**：使用 React DevTools、Flipper 或 Xcode Instruments/Android Profiler 检查内存泄漏、渲染性能。
4.  **无障碍 (Accessibility) 测试**：确保组件具有正确的 `accessibilityLabel` 和 `accessibilityRole`。

### 阶段 6：应用商店上架前检查清单

- \[ ] **元数据齐全**：应用图标 (多种尺寸)、截图、宣传图、描述、关键词、隐私政策链接、支持链接。
- \[ ] **隐私合规**：
  - 如有数据收集，准备详细的隐私政策。
  - 对于 iOS，在 `Info.plist` 中正确声明所需权限（如相机、相册、位置）及使用描述。
  - 对于 Android，在 `AndroidManifest.xml` 中声明权限，并可能需要在 Google Play 提交隐私政策。
- \[ ] **内容指南**：确保应用内容符合 Apple App Store 和 Google Play 的开发者政策。
- \[ ] **测试账户**：为应用审核提供测试账户（如果需要登录）。
- \[ ] **版本号与构建号**：正确递增版本号 (`versionName`/`CFBundleShortVersionString`) 和构建号 (`versionCode`/`CFBundleVersion`)。

### 验证报告模板

```markdown
# REACT NATIVE 应用验证报告

应用名称: [你的应用名]
平台: iOS / Android
构建版本: [版本号]
构建号: [构建号]
环境: [开发/测试/生产]

[✅/❌] 类型检查通过
[✅/❌] ESLint 检查通过 (警告: X)
[✅/❌] 测试套件通过
◦ 单元测试: A/B 通过

    ◦ 组件测试: C/D 通过

    ◦ 集成/E2E 测试: M/N 通过

    ◦ 覆盖率: 行: P%

[✅/❌] 安全扫描通过 (漏洞数: V)
[✅/❌] Android 生产构建成功 (APK/AAB 大小: Y MB)
[✅/❌] iOS 生产构建成功 (IPA 大小: Z MB)
[✅/❌] 关键用户流程手动测试通过
[✅/❌] 性能分析无关键问题
[✅/❌] 应用商店元数据准备就绪

关键问题:

1. [高优先级] [问题描述，如：发现内存泄漏]
2. [中优先级] [问题描述，如：某屏幕在小尺寸设备上布局错乱]

发布就绪: [✅ 是 / ❌ 否]
```

## 核心原则

1.  **性能为先：**充分利用 Tamagui 的编译时优化，避免不必要的重渲染，对列表使用 FlatList 或 FlashList，对图片使用缓存和优化加载。
2.  **用户体验一致：**通过 Tamagui 的主题系统和响应式工具，确保应用在 iOS 和 Android 上有一致且自适应的体验。
3.  **安全默认：**从项目开始就实施安全存储、安全网络通信和代码保护措施。
4.  **测试保障质量：**为业务逻辑、UI 交互和关键用户旅程编写自动化测试，这是应对复杂移动环境变化和确保应用稳定性的基石。
5.  **自动化发布流程：**利用 CI/CD (如 GitHub Actions, Bitrise) 自动化构建、测试、打包和部署到测试平台 (如 TestFlight, Google Play 内部测试)，实现快速迭代。

记住：移动开发环境复杂，设备和操作系统版本碎片化严重。通过强大的类型系统、彻底的测试、注重性能的 UI 库和严格的安全实践，是构建出能在用户设备上稳定、安全、流畅运行的 React Native 应用的唯一途径。在开发过程中，持续在真实设备上进行测试是必不可少的环节。
