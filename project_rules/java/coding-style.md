---
alwaysApply: false
globs:
  - '**/*.java'
  - '**/pom.xml'
  - '**/build.gradle'
---

# Java 编码风格

> Java 语言特定的编码风格和约定。

## 命名约定

| 类型    | 约定                 | 示例                  |
| ------- | -------------------- | --------------------- |
| 类/接口 | PascalCase           | `UserService`         |
| 方法    | camelCase            | `createUser`          |
| 变量    | camelCase            | `userName`            |
| 常量    | SCREAMING_SNAKE_CASE | `MAX_CONNECTIONS`     |
| 包名    | 小写                 | `com.example.service` |

## 代码风格

```java
// 使用 Optional 处理可能为空的值
public Optional<User> findById(Long id) {
    return userRepository.findById(id);
}

// 使用 Stream API 处理集合
public List<User> findActiveUsers() {
    return users.stream()
        .filter(User::isActive)
        .collect(Collectors.toList());
}

// 使用 Records (Java 17+)
public record UserDTO(Long id, String name, String email) {}

// 使用 var 进行类型推断
var users = userRepository.findAll();
```

## 异常处理

```java
// 使用自定义异常
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long id) {
        super("User not found with id: " + id);
    }
}

// 使用 try-with-resources
try (var connection = dataSource.getConnection()) {
    // 使用连接
}
```

## Lombok 使用

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private Long id;
    private String name;
    private String email;
}
```
