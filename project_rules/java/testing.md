---
alwaysApply: false
globs:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle"
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

    @Test
    @DisplayName("Should throw exception when user not found")
    void shouldThrowExceptionWhenUserNotFound() {
        assertThrows(UserNotFoundException.class, () -> {
            userService.findById(999L);
        });
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

    @Test
    void shouldSaveAndFindUser() {
        var user = new User("test@example.com", "Test User");
        var saved = userRepository.save(user);

        var found = userRepository.findById(saved.getId());
        assertTrue(found.isPresent());
    }
}
```

## 测试覆盖率

```bash
mvn jacoco:report    # Maven
gradle jacocoTestReport  # Gradle
```
