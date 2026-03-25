# Tauri 桌面应用

> Tauri 桌面应用开发规范

## 概述

Tauri 是使用 Rust 构建的轻量级桌面应用框架，支持前端 Web 技术。

## 项目结构

```
src-tauri/
├── src/
│   ├── main.rs
│   ├── lib.rs
│   └── commands.rs
├── Cargo.toml
└── tauri.conf.json
src/
├── App.tsx
├── main.tsx
└── styles.css
```

## 核心概念

### Rust 后端

```rust
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 前端调用

```typescript
import { invoke } from '@tauri-apps/api/tauri';

const greeting = await invoke<string>('greet', { name: 'World' });
```

## 安全配置

```json
{
  "tauri": {
    "security": {
      "csp": "default-src 'self'"
    }
  }
}
```

## 常用包

| 用途 | 包 |
|------|-----|
| 前端 API | @tauri-apps/api |
| 状态管理 | @tauri-apps/plugin-store |
| Shell | @tauri-apps/plugin-shell |

## 命令

```bash
# 开发
npm run tauri:dev

# 构建
npm run tauri:build
```
