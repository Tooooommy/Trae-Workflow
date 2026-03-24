---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/*.kts'
---

# Kotlin 模式

> Kotlin 语言特定的架构模式。

## 数据类

使用 `data class` 定义不可变的数据模型：

```kotlin
data class User(
    val id: Long,
    val name: String,
    val email: String
)
```

## sealed class

使用 `sealed class` 建模不同的状态和结果：

```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String) : Result<Nothing>()
    data object Loading : Result<Nothing>()
}
```

## 协程模式

使用 Kotlin 协程处理异步操作：

```kotlin
suspend fun fetchUser(id: Long): Result<User> = runCatching {
    api.getUser(id)
}
```

## 相关智能体

- `architect` - 架构设计和模式选择

## 相关技能

- `android-native-patterns` - Android 原生模式
- `clean-architecture` - 整洁架构
