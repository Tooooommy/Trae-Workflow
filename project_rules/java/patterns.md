---
alwaysApply: false
globs:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle"
---

# Java 设计模式

> Java 语言特定的设计模式。

## Builder 模式

```java
public class User {
    private final Long id;
    private final String name;
    private final String email;

    private User(Builder builder) {
        this.id = builder.id;
        this.name = builder.name;
        this.email = builder.email;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private Long id;
        private String name;
        private String email;

        public Builder id(Long id) {
            this.id = id;
            return this;
        }

        public Builder name(String name) {
            this.name = name;
            return this;
        }

        public Builder email(String email) {
            this.email = email;
            return this;
        }

        public User build() {
            return new User(this);
        }
    }
}
```

## Repository 模式

```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByActiveTrue();
}

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }
}
```

## Strategy 模式

```java
public interface PaymentStrategy {
    void pay(BigDecimal amount);
}

@Component("creditCard")
public class CreditCardPayment implements PaymentStrategy {
    public void pay(BigDecimal amount) { /* ... */ }
}

@Component("paypal")
public class PayPalPayment implements PaymentStrategy {
    public void pay(BigDecimal amount) { /* ... */ }
}
```
