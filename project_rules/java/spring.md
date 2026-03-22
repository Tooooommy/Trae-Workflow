---
alwaysApply: false
globs:
  - '**/pom.xml'
  - '**/build.gradle'
  - '**/application.yml'
---

# Spring Boot 项目规范与指南

> 基于 Spring Boot 的企业级 Java 应用开发规范。

## 项目总览

- 技术栈: Java 21+, Spring Boot 3, Spring Data JPA, PostgreSQL
- 架构: 分层架构, 依赖注入

## 关键规则

### 项目结构

```
src/
├── main/
│   ├── java/com/example/
│   │   ├── Application.java
│   │   ├── config/
│   │   │   ├── SecurityConfig.java
│   │   │   └── WebConfig.java
│   │   ├── controller/
│   │   │   ├── UserController.java
│   │   │   └── AuthController.java
│   │   ├── service/
│   │   │   ├── UserService.java
│   │   │   └── AuthService.java
│   │   ├── repository/
│   │   │   └── UserRepository.java
│   │   ├── entity/
│   │   │   └── User.java
│   │   ├── dto/
│   │   │   ├── CreateUserRequest.java
│   │   │   └── UserResponse.java
│   │   └── exception/
│   │       └── GlobalExceptionHandler.java
│   └── resources/
│       └── application.yml
└── test/
    └── java/com/example/
```

### Controller

```java
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse create(@Valid @RequestBody CreateUserRequest request) {
        return userService.create(request);
    }

    @GetMapping("/{id}")
    public UserResponse getById(@PathVariable Long id) {
        return userService.findById(id);
    }

    @GetMapping
    public Page<UserResponse> list(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        return userService.findAll(PageRequest.of(page, size));
    }
}
```

### Service

```java
@Service
@RequiredArgsConstructor
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserResponse create(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException(request.getEmail());
        }

        var user = User.builder()
            .email(request.getEmail())
            .name(request.getName())
            .password(passwordEncoder.encode(request.getPassword()))
            .build();

        return toResponse(userRepository.save(user));
    }
}
```

## 环境变量

```yaml
# application.yml
spring:
  datasource:
    url: ${DATABASE_URL:jdbc:postgresql://localhost:5432/mydb}
    username: ${DB_USER:postgres}
    password: ${DB_PASSWORD:postgres}
  jpa:
    hibernate:
      ddl-auto: validate
jwt:
  secret: ${JWT_SECRET:your-secret-key}
```

## 开发命令

```bash
mvn spring-boot:run           # 开发服务器
mvn clean package             # 构建
mvn test                      # 测试
java -jar target/app.jar      # 生产运行
```
