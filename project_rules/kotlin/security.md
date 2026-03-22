---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/build.gradle.kts'
---

# Kotlin 安全规范

> Kotlin 语言特定的安全最佳实践。

## 输入验证

```kotlin
import jakarta.validation.constraints.*

data class CreateUserRequest(
    @field:Email
    @field:NotBlank
    val email: String,

    @field:Size(min = 8, max = 100)
    val password: String,

    @field:Pattern(regexp = "^[a-zA-Z ]+$")
    val name: String
)
```

## 密码处理

```kotlin
import org.springframework.security.crypto.password.PasswordEncoder

@Service
class AuthService(
    private val passwordEncoder: PasswordEncoder,
    private val userRepository: UserRepository
) {
    fun register(request: CreateUserRequest): User {
        val hashedPassword = passwordEncoder.encode(request.password)
        return userRepository.save(
            User(
                email = request.email,
                password = hashedPassword,
                name = request.name
            )
        )
    }
}
```

## SQL 注入防护

```kotlin
// 使用 Exposed DSL
Users.select { Users.email eq email }.singleOrNull()

// 使用 JPA
@Query("SELECT u FROM User u WHERE u.email = :email")
fun findByEmail(@Param("email") email: String): User?
```

## 敏感数据保护

- 使用 `@JsonIgnore` 排除敏感字段
- 使用环境变量存储配置
- 使用 Kotlin 的 `internal` 可见性限制访问
