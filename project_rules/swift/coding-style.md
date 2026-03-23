---
alwaysApply: false
globs:
  - '**/*.swift'
  - '**/Package.swift'
---

# Swift 编码风格

> Swift 语言特定的编码规范。

## 格式化

- **SwiftFormat** 用于自动格式化，**SwiftLint** 用于风格检查
- `swift-format` 已作为替代方案捆绑在 Xcode 16+ 中

## 不变性

- 优先使用 `let` 而非 `var` — 将所有内容定义为 `let`，仅在编译器要求时才改为 `var`
- 默认使用具有值语义的 `struct`；仅在需要标识或引用语义时才使用 `class`

## 命名

遵循 [Apple API 设计指南](https://www.swift.org/documentation/api-design-guidelines/)：

- 在使用时保持清晰 — 省略不必要的词语
- 根据方法和属性的作用而非类型来命名
- 对于常量，使用 `static let` 而非全局常量

## 相关智能体

- `code-reviewer` - 代码质量和规范检查

## 相关技能

- `coding-standards` - 通用编码标准
