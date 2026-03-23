---
alwaysApply: false
globs:
  - '**/*.java'
  - '**/pom.xml'
  - '**/build.gradle'
---

# Java 测试规范

> Java 语言特定的测试框架和策略。

## JUnit 5 测试

```java
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

@DisplayName("User Service Tests")
class UserServiceTest {

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository);
    }

    @Test
    @DisplayName("Should create user successfully")
    void shouldCreateUser() {
        var request = new CreateUserRequest("test@example.com", "password");
        var user = userService.create(request);

        assertNotNull(user.getId());
        assertEquals("test@example.com", user.getEmail());
    }
}
```

## 集成测试

```java
@SpringBootTest
@Testcontainers
class UserRepositoryIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    @Autowired
    private UserRepository userRepository;
}
```

## 覆盖率

```bash
mvn jacoco:report    # Maven
gradle jacocoTestReport  # Gradle
```

## 相关智能体

- `testing-expert` - TDD 工作流和测试策略

## 相关技能

- `java-patterns` - Java 模式（包含测试模式）
- `tdd-workflow` - 测试驱动开发
