---
alwaysApply: false
globs:
  - '**/Package.swift'
  - '**/Sources/**/*.swift'
---

# Vapor 项目规范与指南

> 基于 Vapor 的 Swift 服务端应用开发规范。

## 项目总览

- 技术栈: Swift 5.10+, Vapor 4, Fluent, PostgreSQL
- 架构: MVC, 异步编程

## 关键规则

### 项目结构

```
project/
├── Sources/
│   ├── App/
│   │   ├── Controllers/
│   │   │   ├── UserController.swift
│   │   │   └── AuthController.swift
│   │   ├── Models/
│   │   │   └── User.swift
│   │   ├── Migrations/
│   │   │   └── CreateUser.swift
│   │   ├── Routes/
│   │   │   └── routes.swift
│   │   └── configure.swift
│   └── Run/
│       └── main.swift
├── Tests/
├── Package.swift
└── docker-compose.yml
```

### Model

```swift
import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}
```

### Controller

```swift
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        users.get(":id", use: show)
    }

    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }

    func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        try await user.save(on: req.db)
        return user
    }

    func show(req: Request) async throws -> User {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user
    }
}
```

## 环境变量

```bash
DATABASE_URL=postgresql://user:password@localhost:5432/vapor_db
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=password
DATABASE_NAME=vapor_db
```

## 开发命令

```bash
vapor run serve          # 开发服务器
vapor run migrate        # 数据库迁移
vapor run revert         # 回滚迁移
vapor test               # 运行测试
swift build              # 构建
```
