---
alwaysApply: false
globs:
  - '**/package.json'
---

# Electron 安全规范

> Electron 桌面应用安全规范。

## 安全配置

### 主进程

```javascript
webPreferences: {
  nodeIntegration: false,
  contextIsolation: true,
  sandbox: true,
  preload: path.join(__dirname, 'preload.js')
}
```

### CSP 配置

```html
<meta http-equiv="Content-Security-Policy" 
  content="default-src 'self'; script-src 'self'">
```

## 最佳实践

- 不加载远程内容
- 验证所有 IPC 消息
- 限制 shell 打开
- 禁用 webSecurity: false
