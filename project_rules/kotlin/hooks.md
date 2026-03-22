---
alwaysApply: false
globs:
  - '**/*.kt'
  - '**/build.gradle.kts'
---

# Kotlin Hooks 配置

> Kotlin 语言特定的 Hooks 配置。

## PreToolUse

- 运行 `./gradlew compileKotlin` 验证语法
- 运行 `./gradlew detekt` 代码检查

## PostToolUse

- 运行 `./gradlew ktlintFormat` 格式化
- 运行 `./gradlew test` 执行测试

## 常用命令

```bash
./gradlew build            # 构建
./gradlew test             # 测试
./gradlew bootRun          # 运行 Spring Boot
./gradlew clean            # 清理
./gradlew detekt           # 静态分析
./gradlew ktlintFormat     # 格式化
```
