---
name: kotlin-patterns
description: Kotlin 惯用模式、协程安全、空安全和性能优化。适用于所有 Kotlin 项目。
---

# Kotlin 开发模式

用于构建简洁、安全和可维护应用程序的惯用 Kotlin 模式与最佳实践。

## 何时激活

- 编写新的 Kotlin 代码
- 审查 Kotlin 代码
- 重构现有 Kotlin 代码
- 设计 Kotlin 模块/服务

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Kotlin | 1.9+ | 2.0+ |
| Coroutines | 1.7+ | 最新 |
| Spring Boot | 3.2+ | 3.3+ |
| Gradle | 8.5+ | 最新 |
| ktlint | 1.0+ | 最新 |

## 核心原则

### 1. 空安全优先

```kotlin
// GOOD: 使用安全调用和 Elvis 操作符
val name: String? = user?.profile?.name ?: "Unknown"

// GOOD: 使用 let 处理非空值
user?.let { u ->
    sendEmail(u.email)
}

// GOOD: 使用 when 处理可空类型
when (val result = fetchUser(id)) {
    null -> println("User not found")
    else -> println("Found: ${result.name}")
}

// 避免 !! 操作符
// BAD: val name = user!!.name  // 可能 NPE
// GOOD: val name = requireNotNull(user).name  // 带有清晰的错误信息
```

### 2. 表达式优先

```kotlin
// GOOD: if 是表达式
val max = if (a > b) a else b

// GOOD: when 是表达式
val description = when (status) {
    Status.ACTIVE -> "Active user"
    Status.INACTIVE -> "Inactive user"
    Status.BANNED -> "Banned user"
}

// GOOD: try 是表达式
val result = try {
    parseData(input)
} catch (e: ParseException) {
    null
}
```

### 3. 不可变性优先

```kotlin
// GOOD: 使用 val 而非 var
val users = listOf(User("Alice"), User("Bob"))

// GOOD: 使用不可变集合
val immutableList = listOf(1, 2, 3)
val immutableMap = mapOf("a" to 1, "b" to 2)
val immutableSet = setOf(1, 2, 3)

// 需要修改时转换为可变
val mutableList = immutableList.toMutableList()
```

## 惯用模式

### 数据类

```kotlin
// 自动生成 equals, hashCode, toString, copy
data class User(
    val id: String,
    val name: String,
    val email: String,
    val createdAt: Instant = Instant.now()
)

// 解构声明
val (id, name, email) = user

// copy 函数
val updated = user.copy(name = "New Name")
```

### 密封类

```kotlin
// 表示有限状态集
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String, val code: Int) : Result<Nothing>()
    object Loading : Result<Nothing>()
}

// 穷尽 when
fun handleResult(result: Result<User>) = when (result) {
    is Result.Success -> showUser(result.data)
    is Result.Error -> showError(result.message)
    Result.Loading -> showLoading()
}
```

### 扩展函数

```kotlin
// 为现有类型添加功能
fun String.isEmail(): Boolean = this.contains("@")

fun List<User>.activeUsers(): List<User> = filter { it.isActive }

// 扩展属性
val String.wordCount: Int
    get() = this.split("\\s+".toRegex()).size

// 使用
val email = "test@example.com"
if (email.isEmail()) { /* ... */ }
```

### 作用域函数

```kotlin
// let: 转换值
val length = name?.let { it.length } ?: 0

// run: 执行块并返回结果
val result = user.run {
    "${name} <${email}>"
}

// with: 对对象执行多个操作
with(user) {
    name = "New Name"
    email = "new@example.com"
}

// apply: 配置对象
val user = User().apply {
    name = "Alice"
    email = "alice@example.com"
}

// also: 附加操作（返回原对象）
user.also { logCreation(it) }
```

## 协程模式

### 结构化并发

```kotlin
// GOOD: 使用 coroutineScope
suspend fun fetchAllData(): List<Data> = coroutineScope {
    val deferred1 = async { fetchFromSource1() }
    val deferred2 = async { fetchFromSource2() }
    
    listOf(
        deferred1.await(),
        deferred2.await()
    )
}

// 使用 SupervisorJob 处理独立任务
class MyService : CoroutineScope {
    private val job = SupervisorJob()
    override val coroutineContext = Dispatchers.Default + job
    
    fun cleanup() {
        job.cancel()
    }
}
```

### 错误处理

```kotlin
// 使用 CoroutineExceptionHandler
val handler = CoroutineExceptionHandler { _, exception ->
    logger.error("Coroutine failed", exception)
}

scope.launch(handler) {
    // 协程代码
}

// 使用 Result 包装
suspend fun <T> safeApiCall(block: suspend () -> T): Result<T> = try {
    Result.success(block())
} catch (e: Exception) {
    Result.failure(e)
}
```

### Flow 模式

```kotlin
// 冷流
fun observeUser(id: String): Flow<User> = flow {
    while (true) {
        val user = fetchUser(id)
        emit(user)
        delay(5000)
    }
}

// 操作符链
users
    .filter { it.isActive }
    .map { it.name }
    .distinctUntilChanged()
    .catch { e -> emitAll(flowOf("Error: ${e.message}")) }
    .collect { name -> println(name) }

// StateFlow 用于状态管理
class ViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()
    
    fun loadData() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            _uiState.value = try {
                UiState.Success(repository.fetchData())
            } catch (e: Exception) {
                UiState.Error(e.message)
            }
        }
    }
}
```

## 错误处理

### Result 类型

```kotlin
// 自定义 Result
sealed class ApiResult<out T> {
    data class Success<T>(val data: T) : ApiResult<T>()
    data class Error(val exception: Throwable) : ApiResult<Nothing>()
}

// 使用
suspend fun fetchUser(id: String): ApiResult<User> = try {
    val user = api.getUser(id)
    ApiResult.Success(user)
} catch (e: Exception) {
    ApiResult.Error(e)
}

// 处理
when (val result = fetchUser(id)) {
    is ApiResult.Success -> showUser(result.data)
    is ApiResult.Error -> showError(result.exception)
}
```

### Arrow 库模式

```kotlin
// 使用 Arrow 的 Either
import arrow.core.Either
import arrow.core.left
import arrow.core.right

suspend fun fetchUser(id: String): Either<ApiError, User> = 
    try {
        api.getUser(id).right()
    } catch (e: NotFoundException) {
        ApiError.NotFound(id).left()
    } catch (e: Exception) {
        ApiError.Unknown(e).left()
    }

// 处理
fetchUser(id)
    .mapLeft { it.message }
    .fold(
        ifLeft = { error -> showError(error) },
        ifRight = { user -> showUser(user) }
    )
```

## Spring Boot 集成

### 控制器

```kotlin
@RestController
@RequestMapping("/api/users")
class UserController(
    private val userService: UserService
) {
    @GetMapping("/{id}")
    suspend fun getUser(@PathVariable id: String): ResponseEntity<UserResponse> {
        val user = userService.findById(id)
            ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(user.toResponse())
    }
    
    @PostMapping
    suspend fun createUser(
        @Valid @RequestBody request: CreateUserRequest
    ): ResponseEntity<UserResponse> {
        val user = userService.create(request)
        return ResponseEntity
            .created(URI.create("/api/users/${user.id}"))
            .body(user.toResponse())
    }
}
```

### 服务层

```kotlin
@Service
class UserService(
    private val userRepository: UserRepository,
    private val emailService: EmailService
) {
    @Transactional
    suspend fun create(request: CreateUserRequest): User {
        validateRequest(request)
        val user = User(
            name = request.name,
            email = request.email
        )
        val saved = userRepository.save(user)
        emailService.sendWelcomeEmail(saved)
        return saved
    }
    
    private fun validateRequest(request: CreateUserRequest) {
        require(request.name.isNotBlank()) { "Name cannot be blank" }
        require(request.email.contains("@")) { "Invalid email format" }
    }
}
```

### 配置类

```kotlin
@Configuration
class AppConfig {
    
    @Bean
    fun objectMapper(): ObjectMapper = ObjectMapper()
        .registerModule(JavaTimeModule())
        .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
    
    @Bean
    fun webClient(builder: WebClient.Builder): WebClient =
        builder
            .baseUrl("https://api.example.com")
            .build()
}
```

## 测试模式

### 单元测试

```kotlin
class UserServiceTest {
    private val userRepository = mockk<UserRepository>()
    private val emailService = mockk<EmailService>(relaxed = true)
    private val service = UserService(userRepository, emailService)
    
    @Test
    fun `should create user`() = runTest {
        // Given
        val request = CreateUserRequest("Alice", "alice@example.com")
        val expected = User("1", "Alice", "alice@example.com")
        coEvery { userRepository.save(any()) } returns expected
        
        // When
        val result = service.create(request)
        
        // Then
        assertEquals(expected, result)
        coVerify { emailService.sendWelcomeEmail(expected) }
    }
}
```

### 集成测试

```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserControllerIntegrationTest {
    
    @Autowired
    private lateinit var webTestClient: WebTestClient
    
    @MockBean
    private lateinit var emailService: EmailService
    
    @Test
    fun `should create user`() {
        webTestClient.post()
            .uri("/api/users")
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue("""{"name":"Alice","email":"alice@example.com"}""")
            .exchange()
            .expectStatus().isCreated
            .expectBody()
            .jsonPath("$.name").isEqualTo("Alice")
    }
}
```

## 项目结构

```
src/main/kotlin/com/example/
├── Application.kt              # 主入口
├── config/                     # 配置
│   └── WebConfig.kt
├── controller/                 # 控制器
│   └── UserController.kt
├── service/                    # 服务
│   └── UserService.kt
├── repository/                 # 数据访问
│   └── UserRepository.kt
├── model/                      # 领域模型
│   └── User.kt
├── dto/                        # DTO
│   ├── CreateUserRequest.kt
│   └── UserResponse.kt
└── util/                       # 工具
    └── Extensions.kt
```

## 工具集成

### Gradle 配置

```kotlin
// build.gradle.kts
plugins {
    kotlin("jvm") version "1.9.0"
    kotlin("plugin.spring") version "1.9.0"
    kotlin("plugin.jpa") version "1.9.0"
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
}

tasks.withType<Test> {
    useJUnitPlatform()
}
```

### 常用命令

```bash
# 构建
./gradlew build

# 运行
./gradlew bootRun

# 测试
./gradlew test

# 格式化
./gradlew ktlintFormat
```

## 快速参考

| 惯用法 | 描述 |
|--------|------|
| val 优先 | 优先使用不可变变量 |
| 数据类 | 简洁的数据载体 |
| 密封类 | 有限状态集 |
| 扩展函数 | 为类型添加功能 |
| 协程 | 异步编程 |
| Flow | 响应式流 |
| when | 强大的模式匹配 |

**记住**：Kotlin 的目标是让代码更简洁、更安全。利用语言特性减少样板代码，但不要过度使用技巧性语法。
