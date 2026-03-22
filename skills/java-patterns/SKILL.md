---
name: java-patterns
description: Java 惯用模式、Spring Boot 最佳实践、并发安全和性能优化。适用于所有 Java 项目。
---

# Java 开发模式

用于构建健壮、高效和可维护应用程序的惯用 Java 模式与最佳实践。

## 何时激活

- 编写新的 Java 代码
- 审查 Java 代码
- 重构现有 Java 代码
- 设计 Java 模块/服务

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Java | 17+ | 21+ |
| Spring Boot | 3.2+ | 3.3+ |
| Maven | 3.9+ | 最新 |
| Gradle | 8.5+ | 最新 |
| Lombok | 1.18+ | 最新 |

## 核心原则

### 1. 面向对象设计

```java
// GOOD: 封装和单一职责
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;
    
    public UserService(UserRepository repository, EmailService emailService) {
        this.repository = repository;
        this.emailService = emailService;
    }
    
    public User createUser(CreateUserRequest request) {
        validateRequest(request);
        User user = new User(request);
        User saved = repository.save(user);
        emailService.sendWelcomeEmail(saved);
        return saved;
    }
}
```

### 2. 不可变性优先

```java
// GOOD: 不可变类
public final class User {
    private final String id;
    private final String name;
    private final String email;
    
    public User(String id, String name, String email) {
        this.id = Objects.requireNonNull(id);
        this.name = Objects.requireNonNull(name);
        this.email = Objects.requireNonNull(email);
    }
    
    // 只有 getter，没有 setter
    public String getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    
    // 返回新实例而非修改
    public User withName(String newName) {
        return new User(this.id, newName, this.email);
    }
}
```

### 3. 使用 Java 17+ 特性

```java
// Records (Java 16+)
public record UserDTO(String id, String name, String email) {}

// Pattern Matching (Java 17+)
public String process(Object obj) {
    return switch (obj) {
        case String s -> "String: " + s;
        case Integer i -> "Integer: " + i;
        case null -> "null";
        default -> "Unknown";
    };
}

// Text Blocks (Java 15+)
String json = """
    {
        "name": "%s",
        "email": "%s"
    }
    """.formatted(name, email);
```

## 错误处理模式

### 自定义异常层次

```java
// 基础异常
public abstract class AppException extends RuntimeException {
    private final ErrorCode errorCode;
    
    protected AppException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }
    
    protected AppException(ErrorCode errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }
    
    public ErrorCode getErrorCode() { return errorCode; }
}

// 具体异常
public class UserNotFoundException extends AppException {
    public UserNotFoundException(String userId) {
        super(ErrorCode.USER_NOT_FOUND, "User not found: " + userId);
    }
}

public class ValidationException extends AppException {
    private final List<FieldError> errors;
    
    public ValidationException(List<FieldError> errors) {
        super(ErrorCode.VALIDATION_ERROR, "Validation failed");
        this.errors = errors;
    }
}
```

### 全局异常处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(UserNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(e.getErrorCode(), e.getMessage()));
    }
    
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(ValidationException e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(new ErrorResponse(e.getErrorCode(), e.getErrors()));
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception e) {
        log.error("Unexpected error", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse(ErrorCode.INTERNAL_ERROR, "An error occurred"));
    }
}
```

## Spring Boot 最佳实践

### 依赖注入

```java
// GOOD: 构造器注入（推荐）
@Service
@RequiredArgsConstructor  // Lombok
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    // 自动生成构造器
}

// 也可以手动写
@Service
public class UserService {
    private final UserRepository userRepository;
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

### 配置管理

```java
@ConfigurationProperties(prefix = "app")
@Validated
public class AppProperties {
    @NotBlank
    private String name;
    
    @Min(1)
    @Max(65535)
    private int port = 8080;
    
    private Duration timeout = Duration.ofSeconds(30);
    
    // getters and setters
}

// application.yml
/*
app:
  name: myapp
  port: 8080
  timeout: 30s
*/
```

### 事务管理

```java
@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;
    private final InventoryService inventoryService;
    private final PaymentService paymentService;
    
    @Transactional
    public Order createOrder(CreateOrderRequest request) {
        // 检查库存
        inventoryService.reserveItems(request.getItems());
        
        // 创建订单
        Order order = new Order(request);
        Order saved = orderRepository.save(order);
        
        // 处理支付
        paymentService.processPayment(saved);
        
        return saved;
    }
    
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void logOrderEvent(OrderEvent event) {
        // 独立事务，不受外层事务影响
    }
}
```

## 并发模式

### 线程安全集合

```java
// GOOD: 使用并发集合
private final ConcurrentHashMap<String, User> userCache = new ConcurrentHashMap<>();
private final BlockingQueue<Task> taskQueue = new LinkedBlockingQueue<>();

// 原子操作
private final AtomicLong counter = new AtomicLong(0);

public long incrementAndGet() {
    return counter.incrementAndGet();
}
```

### 虚拟线程 (Java 21+)

```java
// 使用虚拟线程执行器
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<Future<String>> futures = urls.stream()
        .map(url -> executor.submit(() -> fetchUrl(url)))
        .toList();
    
    for (Future<String> future : futures) {
        System.out.println(future.get());
    }
}

// Spring Boot 3.2+ 配置
/*
spring:
  threads:
    virtual:
      enabled: true
*/
```

### 异步处理

```java
@Service
public class NotificationService {
    
    @Async
    public CompletableFuture<Void> sendNotificationAsync(User user, String message) {
        // 异步执行
        emailService.send(user.getEmail(), message);
        return CompletableFuture.completedFuture(null);
    }
}

// 配置
@Configuration
@EnableAsync
public class AsyncConfig {
    
    @Bean
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}
```

## 性能优化

### JPA 查询优化

```java
// GOOD: 使用 JOIN FETCH 避免 N+1
@Query("SELECT u FROM User u LEFT JOIN FETCH u.orders WHERE u.id = :id")
Optional<User> findByIdWithOrders(@Param("id") String id);

// GOOD: 使用 EntityGraph
@EntityGraph(attributePaths = {"orders", "profile"})
Optional<User> findById(String id);

// GOOD: 批量操作
@Modifying
@Query("UPDATE User u SET u.status = :status WHERE u.id IN :ids")
int updateStatus(@Param("ids") List<String> ids, @Param("status") Status status);
```

### 缓存策略

```java
@Service
public class UserService {
    
    @Cacheable(value = "users", key = "#id")
    public User findById(String id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
    
    @CachePut(value = "users", key = "#user.id")
    public User update(User user) {
        return userRepository.save(user);
    }
    
    @CacheEvict(value = "users", key = "#id")
    public void delete(String id) {
        userRepository.deleteById(id);
    }
}
```

## 项目结构

### 标准项目布局

```
src/main/java/com/example/
├── Application.java           # 主入口
├── config/                    # 配置类
│   ├── SecurityConfig.java
│   └── WebConfig.java
├── controller/                # 控制器
│   └── UserController.java
├── service/                   # 服务层
│   ├── UserService.java
│   └── impl/
│       └── UserServiceImpl.java
├── repository/                # 数据访问层
│   └── UserRepository.java
├── model/                     # 领域模型
│   ├── User.java
│   └── Order.java
├── dto/                       # 数据传输对象
│   ├── CreateUserRequest.java
│   └── UserResponse.java
├── exception/                 # 异常定义
│   └── UserNotFoundException.java
└── util/                      # 工具类
    └── DateUtils.java
```

## 测试模式

### 单元测试

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private EmailService emailService;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void shouldCreateUser() {
        // Given
        CreateUserRequest request = new CreateUserRequest("John", "john@example.com");
        User expected = new User("1", "John", "john@example.com");
        when(userRepository.save(any())).thenReturn(expected);
        
        // When
        User result = userService.createUser(request);
        
        // Then
        assertThat(result).isEqualTo(expected);
        verify(emailService).sendWelcomeEmail(expected);
    }
}
```

### 集成测试

```java
@SpringBootTest
@Testcontainers
class UserControllerIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void shouldCreateUser() throws Exception {
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"John\",\"email\":\"john@example.com\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("John"));
    }
}
```

## 工具集成

### Maven 配置

```xml
<properties>
    <java.version>17</java.version>
    <spring-boot.version>3.2.0</spring-boot.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

### 常用命令

```bash
# 构建
mvn clean package
mvn clean install -DskipTests

# 运行
mvn spring-boot:run

# 测试
mvn test
mvn test -Dtest=UserServiceTest

# 依赖检查
mvn dependency:tree
mvn dependency-check:check
```

## 快速参考

| 模式 | 描述 |
|------|------|
| 构造器注入 | 推荐的依赖注入方式 |
| 不可变对象 | 线程安全，易于理解 |
| Optional | 避免 null 检查 |
| Records | 简洁的数据载体 |
| @Transactional | 声明式事务管理 |
| @Async | 异步方法执行 |
| @Cacheable | 方法结果缓存 |

**记住**：Java 生态系统庞大，选择合适的工具和模式比使用所有功能更重要。保持简单，遵循约定。
