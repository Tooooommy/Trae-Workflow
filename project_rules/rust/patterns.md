# Rust 架构模式

> Rust 项目架构设计模式

## 项目结构

```
src/
├── main.rs          # 二进制入口
├── lib.rs           # 库入口
├── config.rs        # 配置模块
├── models/          # 数据模型
│   └── mod.rs
├── services/        # 业务逻辑
│   └── mod.rs
├── handlers/        # 请求处理
│   └── mod.rs
├── db/              # 数据库层
│   └── mod.rs
└── error.rs        # 错误定义
```

## 分层架构

```
handlers/    → HTTP 请求处理
services/    → 业务逻辑
repositories/ → 数据访问
models/      → 数据模型
```

## 常用 Crate

| 用途 | Crate |
|------|-------|
| Web 框架 | actix-web, axum, rocket |
| 异步运行时 | tokio |
| 数据库 | sqlx, diesel, sea-orm |
| 序列化 | serde, serde_json |
| 错误处理 | thiserror, anyhow |
