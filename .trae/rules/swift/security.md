---
alwaysApply: false
globs:
  - '**/*.swift'
  - '**/Package.swift'
---

# Swift 安全

> Swift 语言特定的安全最佳实践。

## 密钥管理

- 使用 **Keychain Services** 处理敏感数据（令牌、密码、密钥）
- 使用环境变量或 `.xcconfig` 文件来管理构建时的密钥
- 切勿在源代码中硬编码密钥

```swift
let apiKey = ProcessInfo.processInfo.environment["API_KEY"]
guard let apiKey, !apiKey.isEmpty else {
    fatalError("API_KEY not configured")
}
```

## 传输安全

- 默认强制执行 App Transport Security (ATS)
- 对关键端点使用证书锁定
- 验证所有服务器证书

## 输入验证

- 在显示之前清理所有用户输入
- 使用带验证的 `URL(string:)`
- 验证来自外部源的数据

## 相关智能体

- `security-reviewer` - 安全漏洞检测

## 相关技能

- `security-review` - 安全检查清单
- `ios-native-patterns` - iOS 原生模式（包含安全模式）
