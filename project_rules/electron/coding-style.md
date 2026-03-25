---
alwaysApply: false
globs:
  - '**/package.json'
---

# Electron 编码风格

> Electron 桌面应用编码规范。

## 不可变性

渲染进程使用不可变数据更新：

```typescript
// CORRECT
const newState = { ...state, count: state.count + 1 };
```

## 主进程安全

- 禁用 nodeIntegration
- 启用 contextIsolation
- 使用 contextBridge 暴露 API

## 进程通信

- 使用 ipcMain/ipcRenderer
- 避免暴露原生 API
