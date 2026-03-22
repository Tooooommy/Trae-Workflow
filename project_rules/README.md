# 规则

> 此目录包含语言特定扩展规则。项目配置请参考 `user_rules/`。

---

## 规则层级

```
user_rules/           ← 最高优先级（项目配置）
    ↓
project_rules/<lang>/ ← 语言特定扩展
```

---

## 目录结构

```
project_rules/
├── typescript/          # TypeScript/JavaScript 扩展
│   ├── coding-style.md  # 编码风格
│   ├── testing.md       # 测试规范
│   ├── security.md      # 安全规范
│   ├── patterns.md      # 设计模式
│   ├── hooks.md         # Hooks 配置
│   ├── nextjs.md        # Next.js 技术栈
│   ├── react.md         # React 技术栈
│   ├── nestjs.md        # NestJS 技术栈
│   ├── shopify.md       # Shopify 技术栈
│   ├── expo.md          # Expo 技术栈
│   ├── react-native.md  # React Native CLI 技术栈
│   ├── weixin.md        # 微信小程序
│   ├── taro.md          # Taro 跨平台
│   └── uniapp.md        # uni-app 跨平台
├── python/              # Python 扩展
│   ├── coding-style.md
│   ├── testing.md
│   ├── security.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── fastapi.md       # FastAPI 技术栈
│   ├── django.md        # Django 技术栈
│   └── flask.md         # Flask 技术栈
├── golang/              # Go 扩展
│   ├── coding-style.md
│   ├── testing.md
│   ├── security.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── gin.md           # Gin 技术栈
│   ├── echo.md          # Echo 技术栈
│   └── fiber.md         # Fiber 技术栈
├── swift/               # Swift 扩展
│   ├── coding-style.md
│   ├── testing.md
│   ├── security.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── vapor.md         # Vapor 技术栈
│   └── swiftui.md       # SwiftUI 技术栈
├── rust/                # Rust 扩展
│   ├── coding-style.md
│   ├── testing.md
│   ├── security.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── actix.md         # Actix-web 技术栈
│   └── axum.md          # Axum 技术栈
├── java/                # Java 扩展
│   ├── coding-style.md
│   ├── testing.md
│   ├── security.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── spring.md        # Spring Boot 技术栈
│   └── quarkus.md       # Quarkus 技术栈
└── kotlin/              # Kotlin 扩展
    ├── coding-style.md
    ├── testing.md
    ├── security.md
    ├── patterns.md
    ├── hooks.md
    ├── ktor.md          # Ktor 技术栈
    └── spring.md        # Spring Boot 技术栈
```

---

## 文件说明

### 通用文件（每个语言目录）

| 文件            | 说明                     |
| --------------- | ------------------------ |
| coding-style.md | 语言特定的编码风格和约定 |
| testing.md      | 语言特定的测试框架和策略 |
| security.md     | 语言特定的安全最佳实践   |
| patterns.md     | 语言特定的设计模式       |
| hooks.md        | 语言特定的 Hooks 配置    |

### 技术栈文件

每个语言目录下的技术栈文件包含：

- 技术栈概述
- 项目结构
- 关键规则
- 代码示例
- 环境配置

---

## 规则优先级

当规则冲突时：

1. **user_rules/** - 项目配置（最高优先级）
2. **project_rules/<lang>/** - 语言特定扩展
