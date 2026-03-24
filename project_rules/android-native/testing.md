---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/*.kts'
---

# Kotlin 测试

> Kotlin 语言特定的测试框架和策略。

## 测试框架

- **JUnit 5** (`junit-jupiter`) - Kotlin/JVM 测试标准
- **Kotest** - Kotlin 原生断言库
- **MockK** - Kotlin 模拟库

```kotlin
import io.kotest.core.spec.style.DescribeSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk

class UserServiceTest : DescribeSpec({
    describe("UserService") {
        val repository = mockk<UserRepository>()
        val service = UserService(repository)

        it("should return user by id") {
            every { repository.findById(1) } returns User(1, "test")

            val result = service.getUser(1)

            result?.name shouldBe "test"
        }
    }
})
```

## 参数化测试

```kotlin
@ParameterizedTest
@ValueSource(strings = ["json", "xml", "csv"])
fun `should validate format`(format: String) {
    val parser = Parser(format)
    parser.isValid shouldBe true
}
```

## 测试覆盖率

```bash
./gradlew test jacocoTestReport
```

## 相关智能体

- `testing-expert` - TDD 工作流和测试策略

## 相关技能

- `android-native-patterns` - Android 开发模式
- `tdd-workflow` - 测试驱动开发
