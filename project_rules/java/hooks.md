---
alwaysApply: false
globs:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle"
---

# Java Hooks 配置

> Java 语言特定的 Hooks 配置。

## PreToolUse

- 运行 `mvn compile` 或 `gradle compileJava` 验证语法
- 运行 `mvn checkstyle:check` 代码检查

## PostToolUse

- 运行 `mvn spotless:apply` 或 `gradle spotlessApply` 格式化
- 运行 `mvn test` 或 `gradle test` 执行测试

## 常用命令

```bash
# Maven
mvn clean install       # 清理并构建
mvn test               # 测试
mvn package            # 打包
mvn spring-boot:run    # 运行 Spring Boot

# Gradle
gradle clean build     # 清理并构建
gradle test            # 测试
gradle bootRun         # 运行 Spring Boot
```
