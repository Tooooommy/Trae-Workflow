# 项目规则

语言特定的项目规则扩展。

## 📁 目录结构

```
project_rules/
├── README.md           # 本文件
├── typescript/         # TypeScript/JavaScript 规则
├── python/             # Python 规则
├── golang/             # Go 规则
├── ios-native/         # iOS/Swift 规则
├── android-native/     # Android/Kotlin 规则
├── electron/           # Electron 规则
└── tauri/             # Tauri 规则
```

## 🔄 规则层级

```
user_rules/           ← 最高优先级（项目配置）
    ↓
project_rules/<lang>/ ← 语言特定扩展
```

当规则冲突时，`user_rules/` 中的规则优先级更高。

## 📋 语言规则

### 核心语言

| 目录           | 描述                       | 对应智能体     | 框架规则                 |
| -------------- | -------------------------- | -------------- | ------------------------ |
| typescript     | TypeScript/JavaScript 规则 | typescript-dev | react, nextjs, nestjs 等 |
| python         | Python 规则                | python-dev     | django, fastapi, flask   |
| golang         | Go 规则                    | go-dev         | gin, fiber               |
| ios-native     | iOS/Swift 规则             | ios-native     | swiftui                  |
| android-native | Android/Kotlin 规则        | android-native | android                  |
| electron       | Electron 规则              | -              | -                        |
| tauri          | Tauri 规则                 | -              | -                        |

### 框架规则

每个语言目录下包含特定框架的规则：

| 语言           | 框架规则                                     |
| -------------- | -------------------------------------------- |
| typescript     | react, nextjs, nestjs, react-native, expo 等 |
| python         | django, fastapi, flask                       |
| golang         | gin, fiber                                   |
| ios-native     | swiftui                                      |
| android-native | android                                      |
| electron       | 桌面应用                                     |
| tauri          | 桌面应用                                     |

## 📝 规则文件格式

每个语言目录包含以下文件：

| 文件            | 描述         |
| --------------- | ------------ |
| coding-style.md | 代码风格规范 |
| patterns.md     | 设计模式     |
| testing.md      | 测试规范     |
| security.md     | 安全规范     |
| hooks.md        | 钩子配置     |

框架特定规则文件（如 `react.md`、`django.md`）包含框架特定的最佳实践。

## 🛠️ 使用方法

### 1. 自动初始化

```bash
# 使用 CLI 初始化项目规则
traew init ./my-project
```

### 2. 手动选择

根据项目技术栈，复制相应的规则目录到项目：

```bash
# 例如：Next.js 项目
cp -r project_rules/typescript .trae/rules/
```

### 3. 规则组合

一个项目可以组合多个规则：

```
my-project/
├── .trae/
│   └── rules/
│       └── typescript/    # 语言规则（包含框架规则）
```

## � 与智能体对应

| 智能体           | 推荐规则目录    |
| ---------------- | --------------- |
| typescript-dev   | typescript/     |
| python-dev       | python/         |
| go-dev           | golang/         |
| ios-native       | ios-native/     |
| react-native-dev | typescript/     |
| android-native   | android-native/ |

## 🔗 与技能对应

| 规则目录       | 相关技能                              |
| -------------- | ------------------------------------- |
| typescript     | react-modern-stack, frontend-patterns |
| python         | python-patterns, python-testing       |
| golang         | golang-patterns, golang-testing       |
| ios-native     | ios-native-patterns                   |
| android-native | android-native-patterns               |

---

**设计理念**：语言特定规则作为通用规则的扩展，提供更精确的指导。
