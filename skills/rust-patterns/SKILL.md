---
name: rust-patterns
description: Rust 惯用模式、所有权系统、生命周期、错误处理和并发安全最佳实践。适用于所有 Rust 项目。
---

# Rust 开发模式

用于构建安全、高效和可维护应用程序的惯用 Rust 模式与最佳实践。

## 何时激活

- 编写新的 Rust 代码
- 审查 Rust 代码
- 重构现有 Rust 代码
- 设计 Rust 模块/crate

## 技术栈版本

| 技术          | 最低版本 | 推荐版本 |
| ------------- | -------- | -------- |
| Rust          | 1.75+    | 1.78+    |
| Cargo         | 最新     | 最新     |
| clippy        | 最新     | 最新     |
| rustfmt       | 最新     | 最新     |
| rust-analyzer | 最新     | 最新     |

## 核心原则

### 1. 所有权是核心

Rust 的所有权系统是其最独特的特性，理解它是编写安全 Rust 代码的关键。

```rust
// 所有权转移 (Move)
let s1 = String::from("hello");
let s2 = s1;  // s1 不再有效
// println!("{}", s1);  // 编译错误！

// 借用 (Borrow)
let s1 = String::from("hello");
let s2 = &s1;  // s1 仍然有效
println!("{} {}", s1, s2);  // 正常工作

// 可变借用
let mut s = String::from("hello");
let s2 = &mut s;
s2.push_str(" world");
```

### 2. 借用规则

- 任意多个不可变借用，或
- 一个可变借用
- 但不能同时存在

```rust
// GOOD: 先不可变借用，后可变借用（不重叠）
let mut s = String::from("hello");
let r1 = &s;
let r2 = &s;
println!("{} {}", r1, r2);  // 不可变借用在此结束

let r3 = &mut s;  // 现在可以可变借用
r3.push_str(" world");

// BAD: 同时存在不可变和可变借用
let mut s = String::from("hello");
let r1 = &s;
let r2 = &mut s;  // 编译错误！
println!("{}", r1);
```

### 3. 错误处理：Result 和 Option

```rust
// 使用 Result 处理可恢复错误
fn read_file(path: &str) -> Result<String, std::io::Error> {
    std::fs::read_to_string(path)
}

// 使用 Option 处理可能缺失的值
fn find_user(id: u32) -> Option<User> {
    users.iter().find(|u| u.id == id).cloned()
}

// ? 操作符传播错误
fn process_file(path: &str) -> Result<Data, Error> {
    let content = read_file(path)?;  // 自动传播错误
    let data = parse_content(&content)?;
    Ok(data)
}
```

## 错误处理模式

### 自定义错误类型

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("User not found: {0}")]
    UserNotFound(u32),

    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Validation failed: {field} - {message}")]
    Validation { field: String, message: String },
}

pub type Result<T> = std::result::Result<T, AppError>;
```

### 错误上下文

```rust
use anyhow::{Context, Result};

fn load_config(path: &str) -> Result<Config> {
    let content = std::fs::read_to_string(path)
        .context(format!("Failed to read config file: {}", path))?;

    let config: Config = toml::from_str(&content)
        .context("Failed to parse config file")?;

    Ok(config)
}
```

## 并发模式

### 使用 Channel 进行消息传递

```rust
use std::sync::mpsc;
use std::thread;

fn worker_pool() {
    let (tx, rx) = mpsc::channel();

    // 启动多个工作线程
    for i in 0..4 {
        let tx_clone = tx.clone();
        thread::spawn(move || {
            let result = process_job(i);
            tx_clone.send(result).unwrap();
        });
    }

    // 收集结果
    drop(tx);  // 丢弃原始发送者
    for result in rx {
        println!("Got result: {:?}", result);
    }
}
```

### 使用 Arc<Mutex> 共享状态

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn shared_counter() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Final count: {}", *counter.lock().unwrap());
}
```

### 使用 Tokio 进行异步编程

```rust
use tokio;
use reqwest;

async fn fetch_urls(urls: Vec<&str>) -> Vec<Result<String, reqwest::Error>> {
    let client = reqwest::Client::new();

    let tasks: Vec<_> = urls
        .into_iter()
        .map(|url| {
            let client = &client;
            async move {
                client.get(url).send().await?.text().await
            }
        })
        .collect();

    futures::future::join_all(tasks).await
}

#[tokio::main]
async fn main() {
    let urls = vec!["https://example.com", "https://rust-lang.org"];
    let results = fetch_urls(urls).await;
}
```

## 结构体设计

### 使用 newtype 模式

```rust
// 类型安全的新类型
#[derive(Debug, Clone)]
struct UserId(u32);

#[derive(Debug, Clone)]
struct Email(String);

impl Email {
    fn new(s: String) -> Result<Self, &'static str> {
        if s.contains('@') {
            Ok(Email(s))
        } else {
            Err("Invalid email format")
        }
    }
}

// 防止混淆不同类型的 ID
fn get_user(id: UserId) -> Option<User> {
    // ...
}
```

### Builder 模式

```rust
pub struct Server {
    host: String,
    port: u16,
    timeout: Duration,
    max_connections: usize,
}

pub struct ServerBuilder {
    host: Option<String>,
    port: Option<u16>,
    timeout: Option<Duration>,
    max_connections: Option<usize>,
}

impl ServerBuilder {
    pub fn new() -> Self {
        Self {
            host: None,
            port: None,
            timeout: None,
            max_connections: None,
        }
    }

    pub fn host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }

    pub fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }

    pub fn timeout(mut self, timeout: Duration) -> Self {
        self.timeout = Some(timeout);
        self
    }

    pub fn build(self) -> Result<Server, &'static str> {
        Ok(Server {
            host: self.host.ok_or("host is required")?,
            port: self.port.unwrap_or(8080),
            timeout: self.timeout.unwrap_or(Duration::from_secs(30)),
            max_connections: self.max_connections.unwrap_or(100),
        })
    }
}

// 使用
let server = ServerBuilder::new()
    .host("localhost")
    .port(3000)
    .build()?;
```

## Trait 设计

### Trait 作为参数

```rust
// 使用 impl Trait 语法
fn process(item: impl Display + Debug) {
    println!("{}", item);
}

// 使用泛型约束（更灵活）
fn process<T: Display + Debug>(item: T) {
    println!("{}", item);
}

// 使用 where 子句（更清晰）
fn process<T>(item: T)
where
    T: Display + Debug,
{
    println!("{}", item);
}
```

### Trait 对象

```rust
// 动态分发
fn process(items: Vec<Box<dyn Draw>>) {
    for item in items {
        item.draw();
    }
}

// 静态分发（更高效）
fn process<T: Draw>(items: Vec<T>) {
    for item in items {
        item.draw();
    }
}
```

## 项目组织

### 标准项目布局

```
myproject/
├── Cargo.toml
├── Cargo.lock
├── src/
│   ├── main.rs          # 二进制入口
│   ├── lib.rs           # 库入口
│   ├── config.rs        # 配置模块
│   ├── models/
│   │   ├── mod.rs
│   │   └── user.rs
│   └── api/
│       ├── mod.rs
│       └── handlers.rs
├── tests/               # 集成测试
├── benches/             # 性能测试
└── examples/            # 示例代码
```

### 模块可见性

```rust
// lib.rs
mod private_module;      // 私有模块
pub mod public_module;   // 公开模块

pub(crate) fn internal_fn() {}  // crate 内可见
pub fn public_fn() {}           // 公开
fn private_fn() {}              // 私有
```

## 性能优化

### 避免不必要的克隆

```rust
// BAD: 不必要的克隆
fn process(s: String) -> String {
    let _ = s.clone();  // 不需要
    s.to_uppercase()
}

// GOOD: 使用引用
fn process(s: &str) -> String {
    s.to_uppercase()
}
```

### 使用迭代器

```rust
// GOOD: 惰性迭代器链
let sum: i32 = (1..=100)
    .filter(|x| x % 2 == 0)
    .map(|x| x * x)
    .sum();

// GOOD: 收集到特定类型
let vec: Vec<i32> = (1..=10).collect();
let map: HashMap<i32, i32> = (1..=10).map(|i| (i, i * 2)).collect();
```

### 内存预分配

```rust
// GOOD: 预分配容量
let mut vec = Vec::with_capacity(1000);
let mut map = HashMap::with_capacity(100);
let mut string = String::with_capacity(100);
```

## 工具集成

### 基本命令

```bash
# 构建
cargo build
cargo build --release

# 运行
cargo run
cargo run --release

# 测试
cargo test
cargo test -- --nocapture  # 显示输出

# 文档
cargo doc --open

# 格式化
cargo fmt
cargo clippy

# 审计
cargo audit
```

### Cargo.toml 配置

```toml
[package]
name = "myproject"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
anyhow = "1"
thiserror = "1"

[dev-dependencies]
tokio-test = "0.4"

[profile.release]
opt-level = 3
lto = true
```

## 快速参考

| 惯用法     | 描述               |
| ---------- | ------------------ |
| 所有权     | 每个值有唯一所有者 |
| 借用       | 不可变或可变引用   |
| 生命周期   | 引用的有效范围     |
| Result     | 可恢复错误处理     |
| Option     | 可能缺失的值       |
| ? 操作符   | 错误传播           |
| impl Trait | 静态分发           |
| dyn Trait  | 动态分发           |
| Arc        | 原子引用计数       |
| Mutex      | 互斥锁             |

## 应避免的反模式

```rust
// BAD: 过度使用 unwrap()
let value = option.unwrap();

// GOOD: 正确处理
let value = option.ok_or(Error::NotFound)?;

// BAD: 忽略错误
let _ = file.write(&data);

// GOOD: 处理或传播错误
file.write(&data).context("Failed to write data")?;

// BAD: 循环中克隆
for item in items.iter().cloned() {
    process(item);
}

// GOOD: 使用引用
for item in &items {
    process(item);
}
```

**记住**：Rust 的学习曲线陡峭，但一旦掌握，它能帮助你编写无数据竞争的安全代码。编译器是你的朋友，认真对待每一个警告。
