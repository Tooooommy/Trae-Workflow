---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/build.gradle.kts'
---

# Kotlin 测试规范

> Kotlin 语言特定的测试框架和策略。

## Kotest 测试

```kotlin
import io.kotest.core.spec.style.DescribeSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe

class UserServiceTest : DescribeSpec({
    describe("UserService") {
        val service = UserService(userRepository)

        describe("create") {
            it("should create user successfully") {
                val request = CreateUserRequest("test@example.com", "password")
                val user = service.create(request)

                user.id shouldNotBe null
                user.email shouldBe "test@example.com"
            }

            it("should throw exception for duplicate email") {
                shouldThrow<DuplicateEmailException> {
                    service.create(existingEmailRequest)
                }
            }
        }
    }
})
```

## JUnit 5 测试

```kotlin
import org.junit.jupiter.api.*
import org.junit.jupiter.api.Assertions.*

class UserRepositoryTest {

    @Test
    fun `should find user by email`() {
        val user = userRepository.findByEmail("test@example.com")

        assertTrue(user.isPresent)
        assertEquals("test@example.com", user.get().email)
    }

    @Test
    fun `should return empty for non-existent email`() {
        val user = userRepository.findByEmail("nonexistent@example.com")

        assertTrue(user.isEmpty)
    }
}
```

## 测试覆盖率

```bash
./gradlew test                    # 运行测试
./gradlew jacocoTestReport        # 生成覆盖率报告
```
