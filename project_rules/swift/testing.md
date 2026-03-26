---
alwaysApply: false
globs:
  - '**/*.swift'
  - '**/Package.swift'
---

# Swift 测试

> Swift 语言特定的测试框架和策略。

## 测试框架

对于新测试，使用 **Swift Testing** (`import Testing`)。使用 `@Test` 和 `#expect`：

```swift
@Test("User creation validates email")
func userCreationValidatesEmail() throws {
    #expect(throws: ValidationError.invalidEmail) {
        try User(email: "not-an-email")
    }
}
```

## 参数化测试

```swift
@Test("Validates formats", arguments: ["json", "xml", "csv"])
func validatesFormat(format: String) throws {
    let parser = try Parser(format: format)
    #expect(parser.isValid)
}
```

## 覆盖率

```bash
swift test --enable-code-coverage
```

## 相关智能体

- `testing-expert` - TDD 工作流和测试策略

## 相关技能

- `ios-native-patterns` - iOS 开发模式，包含协议依赖注入测试
- `tdd-patterns` - 测试驱动开发
