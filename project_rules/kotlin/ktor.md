---
alwaysApply: false
globs:
  - '**/build.gradle.kts'
  - '**/Application.kt'
---

# Ktor 项目规范与指南

> 基于 Ktor 的 Kotlin 服务端应用开发规范。

## 项目总览

- 技术栈: Kotlin 1.9+, Ktor 3, Exposed, PostgreSQL
- 架构: 协程优先, 函数式路由

## 关键规则

### 项目结构

```
src/
├── main/
│   ├── kotlin/org/example/
│   │   ├── Application.kt
│   │   ├── config/
│   │   │   └── DatabaseFactory.kt
│   │   ├── routes/
│   │   │   ├── UserRoutes.kt
│   │   │   └── AuthRoutes.kt
│   │   ├── models/
│   │   │   ├── User.kt
│   │   │   └── UserTable.kt
│   │   ├── repositories/
│   │   │   └── UserRepository.kt
│   │   └── services/
│   │       └── UserService.kt
│   └── resources/
│       └── application.conf
└── test/
    └── kotlin/org/example/
```

### Routing

```kotlin
fun Route.userRoutes(userService: UserService) {
    route("/api/v1/users") {
        get {
            val users = userService.findAll()
            call.respond(users)
        }

        get("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: throw BadRequestException("Invalid ID")

            val user = userService.findById(id)
                ?: throw NotFoundException("User not found")

            call.respond(user)
        }

        post {
            val request = call.receive<CreateUserRequest>()
            val user = userService.create(request)
            call.respond(HttpStatusCode.Created, user)
        }
    }
}
```

### Application

```kotlin
fun Application.module() {
    DatabaseFactory.init()

    val userService = UserService(UserRepository())

    install(ContentNegotiation) {
        json()
    }

    install(StatusPages) {
        exception<NotFoundException> {
            call.respond(HttpStatusCode.NotFound, mapOf("error" to it.message))
        }
    }

    routing {
        userRoutes(userService)
    }
}
```

## 环境变量

```hocon
# application.conf
ktor {
    deployment {
        port = 8080
    }
    application {
        modules = [ org.example.ApplicationKt.module ]
    }
}

database {
    url = ${DATABASE_URL}
    user = ${DB_USER}
    password = ${DB_PASSWORD}
}

jwt {
    secret = ${JWT_SECRET}
}
```

## 开发命令

```bash
./gradlew run                  # 开发服务器
./gradlew build                # 构建
./gradlew test                 # 测试
./gradlew shadowJar            # 打包
```
