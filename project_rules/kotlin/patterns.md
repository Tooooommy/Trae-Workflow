---
alwaysApply: false
globs:
  - "**/*.kt"
  - "**/build.gradle.kts"
---

# Kotlin 设计模式

> Kotlin 语言特定的设计模式。

## Builder 模式 (DSL 风格)

```kotlin
data class User(
    val id: Long?,
    val name: String,
    val email: String
)

fun user(block: UserBuilder.() -> Unit): User {
    return UserBuilder().apply(block).build()
}

class UserBuilder {
    var id: Long? = null
    var name: String = ""
    var email: String = ""

    fun build() = User(id, name, email)
}

// 使用
val user = user {
    id = 1L
    name = "John"
    email = "john@example.com"
}
```

## Repository 模式

```kotlin
interface UserRepository {
    suspend fun findById(id: Long): User?
    suspend fun findByEmail(email: String): User?
    suspend fun save(user: User): User
    suspend fun delete(id: Long)
}

class UserRepositoryImpl(
    private val db: Database
) : UserRepository {
    override suspend fun findById(id: Long): User? = db.query {
        Users.select { Users.id eq id }
            .map { it.toUser() }
            .singleOrNull()
    }
}
```

## Sealed Class 模式

```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String, val code: Int) : Result<Nothing>()
}

fun <T> Result<T>.onSuccess(block: (T) -> Unit): Result<T> {
    if (this is Result.Success) block(data)
    return this
}

fun <T> Result<T>.onError(block: (String, Int) -> Unit): Result<T> {
    if (this is Result.Error) block(message, code)
    return this
}
```
