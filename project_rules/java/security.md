---
alwaysApply: false
globs:
  - '**/*.java'
  - '**/pom.xml'
  - '**/build.gradle'
---

# Java 安全规范

> Java 语言特定的安全最佳实践。

## 输入验证

```java
import jakarta.validation.constraints.*;

public class CreateUserRequest {
    @Email
    @NotBlank
    private String email;

    @Size(min = 8, max = 100)
    private String password;

    @Pattern(regexp = "^[a-zA-Z ]+$")
    private String name;
}
```

## 密码处理

```java
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Service
public class AuthService {

    private final BCryptPasswordEncoder passwordEncoder;

    public User register(CreateUserRequest request) {
        String hashedPassword = passwordEncoder.encode(request.getPassword());
        // ...
    }
}
```

## SQL 注入防护

```java
// 使用 JPA/Hibernate 参数化查询
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);

// 使用 JdbcTemplate
jdbcTemplate.queryForObject(
    "SELECT * FROM users WHERE id = ?",
    userRowMapper,
    id
);
```

## 敏感数据保护

- 使用 `@JsonIgnore` 排除敏感字段
- 使用环境变量存储配置
- 使用 Spring Cloud Config 管理配置

## 相关智能体

- `security-reviewer` - 安全漏洞检测

## 相关技能

- `security-review` - 安全检查清单
- `java-patterns` - Java 模式（包含安全模式）
