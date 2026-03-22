---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/build.gradle.kts'
---

# Kotlin 编码风格

> Kotlin 语言特定的编码风格和约定。

## 命名约定

| 类型    | 约定                 | 示例              |
| ------- | -------------------- | ----------------- |
| 类/接口 | PascalCase           | `UserService`     |
| 函数    | camelCase            | `createUser`      |
| 变量    | camelCase            | `userName`        |
| 常量    | SCREAMING_SNAKE_CASE | `MAX_CONNECTIONS` |

## 代码风格

```kotlin
// 使用 data class
data class User(
    val id: Long?,
    val name: String,
    val email: String
)

// 使用 when 表达式
fun getStatus(status: Int): String = when (status) {
    0 -> "PENDING"
    1 -> "ACTIVE"
    else -> "UNKNOWN"
}

// 使用扩展函数
fun String.isEmail(): Boolean {
    return this.contains("@")
}

// 使用作用域函数
val user = User(name = "John", email = "john@example.com").apply {
    id = 1L
}

// 使用空安全
val name: String? = user?.name
val length = name?.length ?: 0
```

## 协程

```kotlin
suspend fun fetchUser(id: Long): User? {
    return withContext(Dispatchers.IO) {
        userRepository.findById(id)
    }
}

// Flow
fun observeUsers(): Flow<User> = userRepository.observeAll()
```

## 错误处理

```kotlin
// 使用 Result
fun createUser(request: CreateUserRequest): Result<User> = runCatching {
    userRepository.save(request.toEntity())
}

// 使用密封类
sealed class ApiResult<out T> {
    data class Success<T>(val data: T) : ApiResult<T>()
    data class Error(val message: String) : ApiResult<Nothing>()
}
```
