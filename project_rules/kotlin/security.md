---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/*.kts'
---

# Kotlin 安全

> Kotlin 语言特定的安全最佳实践。

## 密钥管理

- 使用 **Android Keystore** 处理敏感数据（令牌、密码、密钥）
- 使用环境变量或 BuildConfig 管理密钥
- 切勿在源代码中硬编码密钥

```kotlin
val apiKey = BuildConfig.API_KEY
if (apiKey.isEmpty()) {
    throw IllegalStateException("API_KEY not configured")
}
```

## 传输安全

- 使用 HTTPS 进行所有网络通信
- 对关键端点使用证书锁定
- 验证所有服务器证书

## 数据存储

- 使用 EncryptedSharedPreferences 存储敏感数据
- 避免在日志中打印敏感信息
- 使用安全的随机数生成器

## 相关智能体

- `security-reviewer` - 安全审查

## 相关技能

- `security-review` - 安全最佳实践
- `android-native-patterns` - Android 开发模式
