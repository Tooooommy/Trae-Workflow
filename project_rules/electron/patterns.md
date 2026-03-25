---
alwaysApply: false
globs:
  - '**/package.json'
---

# Electron 项目规范

> 基于 Electron 的桌面应用开发规范。

## 项目总览

- 技术栈: Electron, TypeScript, React/Vue
- 架构: 主进程 + 渲染进程

## 项目结构

```
src/
├── main/                    # 主进程
│   ├── index.ts
│   ├── ipc.ts
│   └── window.ts
├── preload/                 # 预加载脚本
│   └── index.ts
├── renderer/                # 渲染进程
│   ├── App.tsx
│   └── main.tsx
├── package.json
└── electron-builder.json
```

## 关键规则

### 主进程

- 使用 contextBridge 暴露 API
- 禁用 nodeIntegration
- 启用 sandbox

### 打包配置

- 使用 electron-builder
- 配置签名
- 自动更新
