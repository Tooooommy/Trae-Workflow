---
alwaysApply: false
globs:
  - "**/build.gradle.kts"
  - "**/Application.kt"
---

# Kotlin Spring Boot 项目规范与指南

> 基于 Spring Boot 的 Kotlin 应用开发规范。

## 项目总览

* 技术栈: Kotlin 1.9+, Spring Boot 3, Spring Data JPA, PostgreSQL
* 架构: 分层架构, 协程支持

## 关键规则

### 项目结构

```
src/
├── main/
│   ├── kotlin/com/example/
│   │   ├── Application.kt
│   │   ├── config/
│   │   │   └── SecurityConfig.kt
│   │   ├── controller/
│   │   │   └── UserController.kt
│   │   ├── service/
│   │   │   └── UserService.kt
│   │   ├── repository/
│   │   │   └── UserRepository.kt
│   │   ├── entity/
│   │   │   └── User.kt
│   │   └── dto/
│   │       └── UserDto.kt
│   └── resources/
│       └── application.yml
└── test/
    └── kotlin/com/example/
```

### Controller

```kotlin
@RestController
@RequestMapping("/api/v1/users")
class UserController(
    private val userService: UserService
) {
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    suspend fun create(@Valid @RequestBody request: CreateUserRequest): UserResponse {
        return userService.create(request)
    }

    @GetMapping("/{id}")
    suspend fun getById(@PathVariable id: Long): UserResponse {
        return userService.findById(id)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
    }

    @GetMapping
    fun list(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): Page<UserResponse> {
        return userService.findAll(PageRequest.of(page, size))
    }
}
```

### Service

```kotlin
@Service
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder
) {
    @Transactional
    suspend fun create(request: CreateUserRequest): UserResponse {
        if (userRepository.existsByEmail(request.email)) {
            throw DuplicateEmailException(request.email)
        }

        val user = User(
            email = request.email,
            name = request.name,
            password = passwordEncoder.encode(request.password)
        )

        return userRepository.save(user).toResponse()
    }
}
```

## 环境变量

```yaml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
jwt:
  secret: ${JWT_SECRET}
```

## 开发命令

```bash
./gradlew bootRun              # 开发服务器
./gradlew build                # 构建
./gradlew test                 # 测试
./gradlew bootJar              # 打包
```
