# Electron 桌面应用

> Electron 桌面应用开发规范

## 概述

Electron 是基于 Node.js 和 Chromium 的跨平台桌面应用框架。

## 项目结构

```
electron/
├── src/
│   ├── main/              # 主进程
│   │   ├── index.ts
│   │   ├── ipc.ts
│   │   └── window.ts
│   ├── preload/           # 预加载脚本
│   │   └── index.ts
│   └── renderer/          # 渲染进程
│       ├── App.tsx
│       └── main.tsx
├── electron-builder.json
└── package.json
```

## 核心原则

### 安全配置

```typescript
const mainWindow = new BrowserWindow({
  webPreferences: {
    nodeIntegration: false,
    contextIsolation: true,
    sandbox: true,
    preload: path.join(__dirname, 'preload.js'),
  },
});
```

### IPC 通信

- 使用 `contextBridge` 暴露安全 API
- 验证 IPC 通道
- 避免直接暴露 Node.js API

## 常用包

| 用途     | 包               |
| -------- | ---------------- |
| 打包     | electron-builder |
| 自动更新 | electron-updater |
| 状态存储 | electron-store   |

## 命令

```bash
# 开发
npm run electron:dev

# 构建
npm run electron:build
```
