---
name: monorepo-patterns
description: Monorepo 管理模式 - 多包管理、共享代码、构建优化最佳实践。**必须激活当**：用户要求设置 Monorepo、管理多包项目、配置构建管道或优化共享代码时。即使用户没有明确说"monorepo"，当涉及 pnpm workspace、Turborepo、Nx 或多包管理时也应使用。
---

# Monorepo 管理模式

> 多包管理、共享代码、构建优化的最佳实践

## 何时激活

- 多包项目管理
- 共享代码库
- 统一版本管理
- 构建优化
- 团队协作

## 技术栈版本

| 技术       | 最低版本 | 推荐版本 |
| ---------- | -------- | -------- |
| pnpm       | 8.0+     | 最新     |
| Turborepo  | 1.10+    | 最新     |
| Nx         | 17.0+    | 最新     |
| Changesets | 2.0+     | 最新     |

## 目录结构

```
monorepo/
├── apps/
│   ├── web/
│   │   ├── package.json
│   │   └── src/
│   └── api/
│       ├── package.json
│       └── src/
├── packages/
│   ├── ui/
│   │   ├── package.json
│   │   └── src/
│   ├── utils/
│   └── config/
├── package.json
├── pnpm-workspace.yaml
├── turbo.json
└── tsconfig.json
```

## pnpm Workspace

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

## Turborepo 配置

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "lint": {
      "outputs": []
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

## 共享包配置

```json
{
  "name": "@repo/ui",
  "version": "1.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js"
    },
    "./button": {
      "import": "./dist/button.mjs",
      "require": "./dist/button.js"
    }
  },
  "scripts": {
    "build": "tsup src/index.ts --format cjs,esm --dts",
    "dev": "tsup src/index.ts --format cjs,esm --watch"
  }
}
```

## 引用共享包

```json
{
  "name": "@repo/web",
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  }
}
```

## Changesets 发布

```json
{
  "name": "@repo/web",
  "version": "1.0.0",
  "scripts": {
    "changeset": "changeset",
    "version": "changeset version",
    "release": "changeset publish"
  }
}
```

## 快速参考

```bash
# 安装依赖
pnpm install

# 运行构建
turbo run build

# 运行测试
turbo run test

# 开发模式
turbo run dev

# 添加 changeset
pnpm changeset

# 发布版本
pnpm release
```

## 参考

- [Turborepo Docs](https://turbo.build/repo/docs)
- [pnpm Workspace](https://pnpm.io/workspaces)
- [Nx Docs](https://nx.dev/)
- [Changesets](https://github.com/changesets/changesets)
