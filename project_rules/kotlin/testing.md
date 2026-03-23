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
    }
}
```

## 测试覆盖率

```bash
./gradlew test                    # 运行测试
./gradlew jacocoTestReport        # 生成覆盖率报告
```

## 相关智能体

- `testing-expert` - TDD 工作流和测试策略

## 相关技能

- `kotlin-patterns` - Kotlin 模式（包含测试模式）
- `tdd-workflow` - 测试驱动开发
