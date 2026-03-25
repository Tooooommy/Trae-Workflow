---
alwaysApply: false
globs:
  - '**/Cargo.toml'
  - '**/tauri.conf.json'
---

# Tauri 安全规范

> Tauri 桌面应用安全规范。

## 安全配置

### tauri.conf.json

```json
{
  "security": {
    "csp": "default-src 'self'",
    "dangerousDisableAssetCspModification": false
  }
}
```

### 权限控制

- 使用 capabilities 配置
- 仅授权必要权限
- 生产禁用 devtools

## 最佳实践

- 不使用 --allowlist
- 使用 invoke 处理命令
- 验证输入数据
