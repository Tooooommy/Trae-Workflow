---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/*.kts'
---

# Kotlin 编码风格

> Kotlin 语言特定的编码规范。

## 格式化

- 使用 **ktlint** 进行代码格式化和风格检查
- 推荐使用 IntelliJ IDEA 或 Android Studio 的默认格式化

## 不变性

- 优先使用 `val` 而非 `var`
- 默认使用数据类 `data class` 代替普通类存储数据
- 使用不可变集合 (`listOf`, `setOf`, `mapOf`)

## 命名

遵循 [Kotlin 官方编码约定](https://kotlinlang.org/docs/coding-conventions.html)：

- 使用 PascalCase 命名类和接口
- 使用 camelCase 命名函数和变量
- 对于常量，使用 `companion object` 或顶级 `const val`

## 相关智能体

- `code-reviewer` - 代码质量和规范检查

## 相关技能

- `coding-standards` - 通用编码标准
- `android-native-patterns` - Android 开发模式
