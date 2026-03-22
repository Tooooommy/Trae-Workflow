---
name: tauri-patterns
description: Tauri 桌面应用开发、Rust 后端、前端集成和安全最佳实践。适用于所有 Tauri 项目。
---

# Tauri 桌面应用模式

用于构建轻量、安全、跨平台桌面应用的 Tauri 模式与最佳实践。

## 何时激活

- 编写新的 Tauri 桌面应用
- 设计 Rust 后端与前端通信
- 实现原生功能
- 优化 Tauri 应用性能

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Tauri | 2.0+ | 最新 |
| Rust | 1.70+ | 最新 |
| TypeScript | 5.0+ | 最新 |
| Vite | 5.0+ | 最新 |
| Vue/React/Svelte | 最新 | 最新 |

## 核心原则

### 1. 项目结构

```
my-tauri-app/
├── src/                    # 前端代码
│   ├── main.ts
│   ├── App.vue
│   └── ...
├── src-tauri/              # Rust 后端
│   ├── src/
│   │   ├── main.rs         # 主入口
│   │   ├── lib.rs          # 库入口
│   │   ├── commands.rs     # Tauri 命令
│   │   └── state.rs        # 应用状态
│   ├── Cargo.toml
│   └── tauri.conf.json
├── package.json
└── vite.config.ts
```

### 2. Tauri 命令

```rust
use tauri::command;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    pub id: String,
    pub name: String,
    pub email: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateUserRequest {
    pub name: String,
    pub email: String,
}

#[command]
pub async fn get_users(state: tauri::State<'_, AppState>) -> Result<Vec<User>, String> {
    let users = state.users.lock().await;
    Ok(users.clone())
}

#[command]
pub async fn get_user(id: String, state: tauri::State<'_, AppState>) -> Result<User, String> {
    let users = state.users.lock().await;
    users
        .iter()
        .find(|u| u.id == id)
        .cloned()
        .ok_or_else(|| "User not found".to_string())
}

#[command]
pub async fn create_user(
    request: CreateUserRequest,
    state: tauri::State<'_, AppState>,
) -> Result<User, String> {
    let mut users = state.users.lock().await;
    
    let user = User {
        id: uuid::Uuid::new_v4().to_string(),
        name: request.name,
        email: request.email,
    };
    
    users.push(user.clone());
    
    Ok(user)
}

#[command]
pub async fn delete_user(id: String, state: tauri::State<'_, AppState>) -> Result<(), String> {
    let mut users = state.users.lock().await;
    let initial_len = users.len();
    
    users.retain(|u| u.id != id);
    
    if users.len() == initial_len {
        Err("User not found".to_string())
    } else {
        Ok(())
    }
}
```

### 3. 应用状态管理

```rust
use std::sync::Arc;
use tokio::sync::Mutex;
use tauri::Manager;

pub struct AppState {
    pub users: Arc<Mutex<Vec<User>>>,
    pub config: Arc<Mutex<AppConfig>>,
    pub db: Arc<Mutex<Database>>,
}

impl AppState {
    pub fn new() -> Self {
        Self {
            users: Arc::new(Mutex::new(Vec::new())),
            config: Arc::new(Mutex::new(AppConfig::default())),
            db: Arc::new(Mutex::new(Database::new())),
        }
    }
}

pub fn setup_app(app: &mut tauri::App) -> Result<(), Box<dyn std::error::Error>> {
    let state = AppState::new();
    app.manage(state);
    Ok(())
}
```

### 4. 主入口

```rust
fn main() {
    tauri::Builder::default()
        .setup(|app| {
            setup_app(app)?;
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            get_users,
            get_user,
            create_user,
            delete_user,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## 前端集成

### TypeScript 类型定义

```typescript
interface User {
  id: string;
  name: string;
  email: string;
}

interface CreateUserRequest {
  name: string;
  email: string;
}

declare global {
  interface Window {
    __TAURI__: {
      tauri: {
        invoke<T>(cmd: string, args?: Record<string, unknown>): Promise<T>;
      };
    };
  }
}
```

### API 封装

```typescript
import { invoke } from '@tauri-apps/api/core';

class UserApi {
  async getAll(): Promise<User[]> {
    return invoke<User[]>('get_users');
  }

  async getById(id: string): Promise<User> {
    return invoke<User>('get_user', { id });
  }

  async create(request: CreateUserRequest): Promise<User> {
    return invoke<User>('create_user', { request });
  }

  async delete(id: string): Promise<void> {
    return invoke('delete_user', { id });
  }
}

export const userApi = new UserApi();
```

### Vue 组件示例

```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { userApi } from './api/user';

const users = ref<User[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);

const loadUsers = async () => {
  loading.value = true;
  error.value = null;
  
  try {
    users.value = await userApi.getAll();
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Unknown error';
  } finally {
    loading.value = false;
  }
};

onMounted(loadUsers);
</script>

<template>
  <div class="user-list">
    <div v-if="loading">Loading...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <ul v-else>
      <li v-for="user in users" :key="user.id">
        {{ user.name }} - {{ user.email }}
      </li>
    </ul>
  </div>
</template>
```

## 事件系统

### Rust 发送事件

```rust
use tauri::{Manager, Window, Emitter};

#[command]
pub async fn process_file(
    path: String,
    window: Window,
) -> Result<(), String> {
    window.emit("processing-started", &path).ok();
    
    for i in 0..100 {
        tokio::time::sleep(tokio::time::Duration::from_millis(50)).await;
        window.emit("processing-progress", ProgressPayload {
            current: i,
            total: 100,
        }).ok();
    }
    
    window.emit("processing-completed", &path).ok();
    
    Ok(())
}

#[derive(Clone, Serialize)]
struct ProgressPayload {
    current: u32,
    total: u32,
}
```

### 前端监听事件

```typescript
import { listen, UnlistenFn } from '@tauri-apps/api/event';

interface ProgressPayload {
  current: number;
  total: number;
}

const setupEventListeners = async () => {
  const unlisteners: UnlistenFn[] = [];

  unlisteners.push(
    await listen<string>('processing-started', (event) => {
      console.log('Started processing:', event.payload);
    })
  );

  unlisteners.push(
    await listen<ProgressPayload>('processing-progress', (event) => {
      const { current, total } = event.payload;
      const percent = Math.round((current / total) * 100);
      console.log(`Progress: ${percent}%`);
    })
  );

  unlisteners.push(
    await listen<string>('processing-completed', (event) => {
      console.log('Completed:', event.payload);
    })
  );

  return () => unlisteners.forEach((unlisten) => unlisten());
};
```

## 文件系统

### 安全文件操作

```rust
use tauri::api::path::{app_data_dir, app_config_dir};
use std::fs;
use std::path::PathBuf;

pub struct FileManager {
    base_path: PathBuf,
}

impl FileManager {
    pub fn new(app_handle: &tauri::AppHandle) -> Result<Self, String> {
        let base_path = app_data_dir(&app_handle.config())
            .ok_or_else(|| "Cannot determine app data directory".to_string())?;
        
        fs::create_dir_all(&base_path)
            .map_err(|e| e.to_string())?;
        
        Ok(Self { base_path })
    }

    pub fn read_file(&self, name: &str) -> Result<Vec<u8>, String> {
        let path = self.base_path.join(name);
        
        if !path.starts_with(&self.base_path) {
            return Err("Path traversal detected".to_string());
        }
        
        fs::read(&path).map_err(|e| e.to_string())
    }

    pub fn write_file(&self, name: &str, data: &[u8]) -> Result<(), String> {
        let path = self.base_path.join(name);
        
        if !path.starts_with(&self.base_path) {
            return Err("Path traversal detected".to_string());
        }
        
        fs::write(&path, data).map_err(|e| e.to_string())
    }

    pub fn list_files(&self) -> Result<Vec<String>, String> {
        let entries = fs::read_dir(&self.base_path)
            .map_err(|e| e.to_string())?;
        
        let files: Vec<String> = entries
            .filter_map(|e| e.ok())
            .filter_map(|e| e.file_name().to_str().map(|s| s.to_string()))
            .collect();
        
        Ok(files)
    }
}
```

### 文件对话框

```rust
use tauri::api::dialog::blocking::FileDialogBuilder;

#[command]
pub async fn select_file() -> Result<Option<String>, String> {
    let path = FileDialogBuilder::new()
        .add_filter("Text", &["txt", "md"])
        .add_filter("All", &["*"])
        .pick_file();
    
    Ok(path.map(|p| p.to_string_lossy().to_string()))
}

#[command]
pub async fn save_file(default_name: Option<String>) -> Result<Option<String>, String> {
    let mut builder = FileDialogBuilder::new();
    
    if let Some(name) = default_name {
        builder = builder.set_file_name(&name);
    }
    
    let path = builder.save_file();
    
    Ok(path.map(|p| p.to_string_lossy().to_string()))
}
```

## 数据库集成

### SQLite

```rust
use rusqlite::{Connection, params};
use std::sync::Mutex;

pub struct Database {
    conn: Mutex<Connection>,
}

impl Database {
    pub fn new(app_handle: &tauri::AppHandle) -> Result<Self, String> {
        let data_dir = app_data_dir(&app_handle.config())
            .ok_or_else(|| "Cannot determine app data directory".to_string())?;
        
        std::fs::create_dir_all(&data_dir)
            .map_err(|e| e.to_string())?;
        
        let db_path = data_dir.join("data.db");
        let conn = Connection::open(db_path)
            .map_err(|e| e.to_string())?;
        
        conn.execute(
            "CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                email TEXT NOT NULL,
                created_at INTEGER NOT NULL
            )",
            [],
        )
        .map_err(|e| e.to_string())?;
        
        Ok(Self {
            conn: Mutex::new(conn),
        })
    }

    pub fn get_users(&self) -> Result<Vec<User>, String> {
        let conn = self.conn.lock().map_err(|e| e.to_string())?;
        
        let mut stmt = conn
            .prepare("SELECT id, name, email FROM users ORDER BY created_at DESC")
            .map_err(|e| e.to_string())?;
        
        let users = stmt
            .query_map([], |row| {
                Ok(User {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    email: row.get(2)?,
                })
            })
            .map_err(|e| e.to_string())?
            .collect::<Result<Vec<_>, _>>()
            .map_err(|e| e.to_string())?;
        
        Ok(users)
    }

    pub fn insert_user(&self, user: &User) -> Result<(), String> {
        let conn = self.conn.lock().map_err(|e| e.to_string())?;
        
        conn.execute(
            "INSERT INTO users (id, name, email, created_at) VALUES (?1, ?2, ?3, ?4)",
            params![user.id, user.name, user.email, chrono::Utc::now().timestamp()],
        )
        .map_err(|e| e.to_string())?;
        
        Ok(())
    }
}
```

## 系统托盘

```rust
use tauri::{
    CustomMenuItem, Manager, SystemTray, SystemTrayEvent, SystemTrayMenu, SystemTrayMenuItem,
    WindowEvent,
};

fn create_system_tray() -> SystemTray {
    let quit = CustomMenuItem::new("quit".to_string(), "Quit");
    let show = CustomMenuItem::new("show".to_string(), "Show Window");
    let hide = CustomMenuItem::new("hide".to_string(), "Hide Window");
    
    let tray_menu = SystemTrayMenu::new()
        .add_item(show)
        .add_item(hide)
        .add_native_item(SystemTrayMenuItem::Separator)
        .add_item(quit);
    
    SystemTray::new().with_menu(tray_menu)
}

fn handle_tray_event(app: &tauri::AppHandle, event: SystemTrayEvent) {
    match event {
        SystemTrayEvent::LeftClick { .. } => {
            let window = app.get_window("main").unwrap();
            window.show().unwrap();
            window.set_focus().unwrap();
        }
        SystemTrayEvent::MenuItemClick { id, .. } => match id.as_str() {
            "quit" => {
                app.exit(0);
            }
            "show" => {
                let window = app.get_window("main").unwrap();
                window.show().unwrap();
                window.set_focus().unwrap();
            }
            "hide" => {
                let window = app.get_window("main").unwrap();
                window.hide().unwrap();
            }
            _ => {}
        },
        _ => {}
    }
}

fn main() {
    tauri::Builder::default()
        .system_tray(create_system_tray())
        .on_system_tray_event(handle_tray_event)
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## 自动更新

```rust
use tauri::updater::UpdaterExt;

#[command]
pub async fn check_update(app: tauri::AppHandle) -> Result<UpdateInfo, String> {
    let updater = app.updater().map_err(|e| e.to_string())?;
    
    match updater.check().await {
        Ok(update) => {
            if update.is_update_available() {
                Ok(UpdateInfo {
                    available: true,
                    version: update.latest_version().to_string(),
                    notes: update.body().map(|s| s.to_string()),
                })
            } else {
                Ok(UpdateInfo {
                    available: false,
                    version: String::new(),
                    notes: None,
                })
            }
        }
        Err(e) => Err(e.to_string()),
    }
}

#[command]
pub async fn install_update(app: tauri::AppHandle) -> Result<(), String> {
    let updater = app.updater().map_err(|e| e.to_string())?;
    let update = updater.check().await.map_err(|e| e.to_string())?;
    
    if update.is_update_available() {
        update.download_and_install().await.map_err(|e| e.to_string())?;
    }
    
    Ok(())
}

#[derive(Serialize)]
pub struct UpdateInfo {
    pub available: bool,
    pub version: String,
    pub notes: Option<String>,
}
```

## 配置文件

### tauri.conf.json

```json
{
  "build": {
    "beforeBuildCommand": "pnpm build",
    "beforeDevCommand": "pnpm dev",
    "devPath": "http://localhost:5173",
    "distDir": "../dist"
  },
  "package": {
    "productName": "My App",
    "version": "1.0.0"
  },
  "tauri": {
    "allowlist": {
      "all": false,
      "fs": {
        "all": false,
        "readFile": true,
        "writeFile": true,
        "scope": ["$APPDATA/**"]
      },
      "dialog": {
        "all": false,
        "open": true,
        "save": true
      },
      "shell": {
        "all": false,
        "open": true
      },
      "window": {
        "all": false,
        "close": true,
        "hide": true,
        "show": true,
        "maximize": true,
        "minimize": true,
        "unmaximize": true,
        "unminimize": true,
        "startDragging": true
      }
    },
    "bundle": {
      "active": true,
      "category": "DeveloperTool",
      "copyright": "",
      "deb": {
        "depends": []
      },
      "externalBin": [],
      "icon": [
        "icons/32x32.png",
        "icons/128x128.png",
        "icons/128x128@2x.png",
        "icons/icon.icns",
        "icons/icon.ico"
      ],
      "identifier": "com.example.myapp",
      "longDescription": "",
      "macOS": {
        "entitlements": null,
        "exceptionDomain": "",
        "frameworks": [],
        "providerShortName": null,
        "signingIdentity": null
      },
      "resources": [],
      "shortDescription": "",
      "targets": "all",
      "windows": {
        "certificateThumbprint": null,
        "digestAlgorithm": "sha256",
        "timestampUrl": ""
      }
    },
    "security": {
      "csp": "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'"
    },
    "updater": {
      "active": true,
      "endpoints": ["https://releases.myapp.com/{{target}}/{{arch}}/{{current_version}}"],
      "dialog": true,
      "pubkey": "..."
    },
    "windows": [
      {
        "fullscreen": false,
        "height": 800,
        "resizable": true,
        "title": "My App",
        "width": 1200,
        "minWidth": 800,
        "minHeight": 600
      }
    ]
  }
}
```

## 快速参考

| 模式 | 用途 |
|------|------|
| #[command] | 定义 Tauri 命令 |
| invoke | 前端调用命令 |
| State | 状态管理 |
| Window.emit | 发送事件 |
| listen | 监听事件 |
| SystemTray | 系统托盘 |

**记住**：Tauri 的核心优势是轻量和高安全。使用最小权限原则配置 allowlist，所有文件操作都要验证路径，充分利用 Rust 的类型系统和错误处理。
