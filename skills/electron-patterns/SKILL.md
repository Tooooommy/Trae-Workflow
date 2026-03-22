---
name: electron-patterns
description: Electron 桌面应用开发、进程通信、原生集成和性能优化最佳实践。适用于所有 Electron 项目。
---

# Electron 桌面应用模式

用于构建跨平台桌面应用的 Electron 模式与最佳实践。

## 何时激活

- 编写新的 Electron 桌面应用
- 设计主进程与渲染进程架构
- 实现原生功能集成
- 优化 Electron 应用性能

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Electron | 28+ | 32+ |
| Node.js | 18+ | 22+ |
| TypeScript | 5.0+ | 最新 |
| electron-builder | 24+ | 最新 |
| electron-updater | 6.0+ | 最新 |

## 核心原则

### 1. 进程架构

```typescript
import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';

let mainWindow: BrowserWindow | null = null;

const createWindow = () => {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
      sandbox: true,
    },
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 15, y: 15 },
  });

  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:3000');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, 'index.html'));
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
};

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});
```

### 2. 安全预加载脚本

```typescript
import { contextBridge, ipcRenderer } from 'electron';

const validChannels = [
  'get-user-data',
  'save-user-data',
  'select-file',
  'show-notification',
];

contextBridge.exposeInMainWorld('electronAPI', {
  invoke: (channel: string, ...args: unknown[]) => {
    if (validChannels.includes(channel)) {
      return ipcRenderer.invoke(channel, ...args);
    }
    throw new Error(`Invalid channel: ${channel}`);
  },

  on: (channel: string, callback: (...args: unknown[]) => void) => {
    if (validChannels.includes(channel)) {
      const subscription = (_event: Electron.IpcRendererEvent, ...args: unknown[]) => 
        callback(...args);
      ipcRenderer.on(channel, subscription);
      return () => ipcRenderer.removeListener(channel, subscription);
    }
    throw new Error(`Invalid channel: ${channel}`);
  },

  send: (channel: string, ...args: unknown[]) => {
    if (validChannels.includes(channel)) {
      ipcRenderer.send(channel, ...args);
    }
  },
});

declare global {
  interface Window {
    electronAPI: {
      invoke: (channel: string, ...args: unknown[]) => Promise<unknown>;
      on: (channel: string, callback: (...args: unknown[]) => void) => () => void;
      send: (channel: string, ...args: unknown[]) => void;
    };
  }
}
```

### 3. IPC 通信模式

```typescript
import { ipcMain, dialog, Notification, shell } from 'electron';
import fs from 'fs/promises';

class IpcHandlers {
  register() {
    this.registerUserDataHandlers();
    this.registerFileHandlers();
    this.registerSystemHandlers();
  }

  private registerUserDataHandlers() {
    ipcMain.handle('get-user-data', async () => {
      const userDataPath = app.getPath('userData');
      const configPath = path.join(userDataPath, 'config.json');
      
      try {
        const data = await fs.readFile(configPath, 'utf-8');
        return JSON.parse(data);
      } catch {
        return null;
      }
    });

    ipcMain.handle('save-user-data', async (_, data: unknown) => {
      const userDataPath = app.getPath('userData');
      const configPath = path.join(userDataPath, 'config.json');
      
      await fs.writeFile(configPath, JSON.stringify(data, null, 2));
      return true;
    });
  }

  private registerFileHandlers() {
    ipcMain.handle('select-file', async (_, options: Electron.OpenDialogOptions) => {
      const result = await dialog.showOpenDialog(mainWindow!, options);
      
      if (result.canceled || result.filePaths.length === 0) {
        return null;
      }

      const filePath = result.filePaths[0];
      const content = await fs.readFile(filePath, 'utf-8');
      
      return {
        path: filePath,
        content,
        name: path.basename(filePath),
      };
    });

    ipcMain.handle('save-file', async (_, filePath: string, content: string) => {
      await fs.writeFile(filePath, content, 'utf-8');
      return true;
    });
  }

  private registerSystemHandlers() {
    ipcMain.handle('show-notification', async (_, title: string, body: string) => {
      new Notification({ title, body }).show();
    });

    ipcMain.handle('open-external', async (_, url: string) => {
      await shell.openExternal(url);
    });

    ipcMain.handle('get-app-path', async (_, name: string) => {
      return app.getPath(name as Electron.appPath);
    });
  }
}

new IpcHandlers().register();
```

## 窗口管理

### 多窗口架构

```typescript
import { BrowserWindow, screen } from 'electron';

class WindowManager {
  private windows: Map<string, BrowserWindow> = new Map();

  createMainWindow(): BrowserWindow {
    const win = new BrowserWindow({
      width: 1200,
      height: 800,
      webPreferences: {
        contextIsolation: true,
        preload: path.join(__dirname, 'preload.js'),
      },
    });

    this.windows.set('main', win);
    
    win.on('closed', () => {
      this.windows.delete('main');
    });

    return win;
  }

  createSettingsWindow(): BrowserWindow {
    const mainWindow = this.windows.get('main');
    const { x, y } = mainWindow!.getBounds();

    const win = new BrowserWindow({
      width: 600,
      height: 500,
      x: x + 100,
      y: y + 100,
      parent: mainWindow!,
      modal: process.platform === 'darwin',
      webPreferences: {
        contextIsolation: true,
        preload: path.join(__dirname, 'preload.js'),
      },
    });

    this.windows.set('settings', win);
    
    win.on('closed', () => {
      this.windows.delete('settings');
    });

    return win;
  }

  getWindow(name: string): BrowserWindow | undefined {
    return this.windows.get(name);
  }

  closeAll(): void {
    for (const win of this.windows.values()) {
      win.close();
    }
    this.windows.clear();
  }
}
```

### 窗口状态持久化

```typescript
import { BrowserWindow, screen } from 'electron';
import Store from 'electron-store';

interface WindowState {
  x?: number;
  y?: number;
  width: number;
  height: number;
  isMaximized: boolean;
}

const store = new Store<{ windowState: WindowState }>();

function createWindowWithState(): BrowserWindow {
  const defaultState: WindowState = {
    width: 1200,
    height: 800,
    isMaximized: false,
  };

  const savedState = store.get('windowState', defaultState);
  const { width, height, x, y, isMaximized } = savedState;

  const win = new BrowserWindow({
    width,
    height,
    x,
    y,
    webPreferences: {
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  if (isMaximized) {
    win.maximize();
  }

  const saveState = () => {
    const state: WindowState = win.isMaximized()
      ? { ...savedState, isMaximized: true }
      : {
          ...win.getBounds(),
          isMaximized: false,
        };
    store.set('windowState', state);
  };

  win.on('close', saveState);
  win.on('resize', saveState);
  win.on('move', saveState);

  return win;
}
```

## 原生菜单

### 应用菜单

```typescript
import { Menu, app, shell } from 'electron';

function createAppMenu(): Menu {
  const template: Electron.MenuItemConstructorOptions[] = [
    {
      label: app.name,
      submenu: [
        { role: 'about' },
        { type: 'separator' },
        { role: 'services' },
        { type: 'separator' },
        { role: 'hide' },
        { role: 'hideOthers' },
        { role: 'unhide' },
        { type: 'separator' },
        { role: 'quit' },
      ],
    },
    {
      label: 'File',
      submenu: [
        {
          label: 'New File',
          accelerator: 'CmdOrCtrl+N',
          click: () => mainWindow?.webContents.send('menu-new-file'),
        },
        {
          label: 'Open...',
          accelerator: 'CmdOrCtrl+O',
          click: async () => {
            const result = await dialog.showOpenDialog({
              properties: ['openFile'],
            });
            if (!result.canceled) {
              mainWindow?.webContents.send('menu-open-file', result.filePaths[0]);
            }
          },
        },
        { type: 'separator' },
        { role: 'close' },
      ],
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' },
        { role: 'delete' },
        { type: 'separator' },
        { role: 'selectAll' },
      ],
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' },
      ],
    },
    {
      label: 'Window',
      submenu: [
        { role: 'minimize' },
        { role: 'zoom' },
        { type: 'separator' },
        { role: 'front' },
      ],
    },
    {
      role: 'help',
      submenu: [
        {
          label: 'Learn More',
          click: async () => {
            await shell.openExternal('https://example.com');
          },
        },
      ],
    },
  ];

  return Menu.buildFromTemplate(template);
}

Menu.setApplicationMenu(createAppMenu());
```

### 上下文菜单

```typescript
import { Menu, MenuItem } from 'electron';

ipcMain.on('show-context-menu', (event, menuItems: MenuItemOptions[]) => {
  const template: Electron.MenuItemConstructorOptions[] = menuItems.map(item => ({
    label: item.label,
    click: () => event.sender.send('context-menu-command', item.id),
  }));

  const menu = Menu.buildFromTemplate(template);
  menu.popup(BrowserWindow.fromWebContents(event.sender)!);
});

interface MenuItemOptions {
  id: string;
  label: string;
}
```

## 托盘图标

```typescript
import { Tray, Menu, nativeImage, app } from 'electron';
import path from 'path';

class TrayManager {
  private tray: Tray | null = null;

  create() {
    const iconPath = path.join(
      __dirname,
      process.platform === 'darwin' ? 'iconTemplate.png' : 'icon.png'
    );
    
    const icon = nativeImage.createFromPath(iconPath);
    
    if (process.platform === 'darwin') {
      icon.setTemplateImage(true);
    }

    this.tray = new Tray(icon.resize({ width: 16, height: 16 }));

    const contextMenu = Menu.buildFromTemplate([
      { label: 'Show Window', click: () => this.showMainWindow() },
      { type: 'separator' },
      { label: 'Settings', click: () => this.openSettings() },
      { type: 'separator' },
      { label: 'Quit', click: () => app.quit() },
    ]);

    this.tray.setToolTip(app.name);
    this.tray.setContextMenu(contextMenu);

    this.tray.on('double-click', () => {
      this.showMainWindow();
    });
  }

  private showMainWindow() {
    const win = windowManager.getWindow('main');
    if (win) {
      win.show();
      win.focus();
    }
  }

  private openSettings() {
    windowManager.createSettingsWindow();
  }

  destroy() {
    this.tray?.destroy();
    this.tray = null;
  }
}
```

## 自动更新

```typescript
import { autoUpdater } from 'electron-updater';
import { dialog } from 'electron';

class AutoUpdateManager {
  constructor() {
    autoUpdater.autoDownload = false;
    autoUpdater.autoInstallOnAppQuit = true;

    this.setupListeners();
  }

  private setupListeners() {
    autoUpdater.on('checking-for-update', () => {
      mainWindow?.webContents.send('update-status', 'checking');
    });

    autoUpdater.on('update-available', (info) => {
      mainWindow?.webContents.send('update-status', 'available', info);
      
      dialog.showMessageBox(mainWindow!, {
        type: 'info',
        title: 'Update Available',
        message: `Version ${info.version} is available. Download now?`,
        buttons: ['Download', 'Later'],
        defaultId: 0,
      }).then((result) => {
        if (result.response === 0) {
          autoUpdater.downloadUpdate();
        }
      });
    });

    autoUpdater.on('update-not-available', () => {
      mainWindow?.webContents.send('update-status', 'not-available');
    });

    autoUpdater.on('download-progress', (progress) => {
      mainWindow?.webContents.send('update-progress', {
        percent: progress.percent,
        transferred: progress.transferred,
        total: progress.total,
      });
    });

    autoUpdater.on('update-downloaded', () => {
      mainWindow?.webContents.send('update-status', 'downloaded');
      
      dialog.showMessageBox(mainWindow!, {
        type: 'info',
        title: 'Update Ready',
        message: 'Update downloaded. Restart to install?',
        buttons: ['Restart', 'Later'],
        defaultId: 0,
      }).then((result) => {
        if (result.response === 0) {
          autoUpdater.quitAndInstall();
        }
      });
    });

    autoUpdater.on('error', (error) => {
      mainWindow?.webContents.send('update-status', 'error', error.message);
    });
  }

  checkForUpdates() {
    autoUpdater.checkForUpdates();
  }
}
```

## 性能优化

### 启动优化

```typescript
import { app } from 'electron';

if (process.platform === 'darwin') {
  app.dock.hide();
}

app.whenReady().then(() => {
  createWindow();
  
  if (process.platform === 'darwin') {
    app.dock.show();
  }
});

app.on('before-quit', () => {
  mainWindow?.removeAllListeners('close');
});
```

### 内存管理

```typescript
import { BrowserWindow, session } from 'electron';

app.whenReady().then(() => {
  const ses = session.defaultSession;

  ses.webRequest.onBeforeRequest(
    { urls: ['*://*.doubleclick.net/*'] },
    (details, callback) => {
      callback({ cancel: true });
    }
  );

  ses.webRequest.onHeadersReceived((details, callback) => {
    callback({
      responseHeaders: {
        ...details.responseHeaders,
        'Content-Security-Policy': [
          "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'",
        ],
      },
    });
  });
});

setInterval(() => {
  const windows = BrowserWindow.getAllWindows();
  windows.forEach(win => {
    if (!win.isVisible()) {
      win.webContents.setBackgroundThrottling(true);
    }
  });
}, 30000);
```

## 打包配置

### electron-builder

```json
{
  "build": {
    "appId": "com.example.myapp",
    "productName": "My App",
    "directories": {
      "output": "dist",
      "buildResources": "build"
    },
    "files": [
      "dist/**/*",
      "node_modules/**/*",
      "package.json"
    ],
    "mac": {
      "category": "public.app-category.productivity",
      "hardenedRuntime": true,
      "gatekeeperAssess": false,
      "entitlements": "build/entitlements.mac.plist",
      "entitlementsInherit": "build/entitlements.mac.plist",
      "target": [
        { "target": "dmg", "arch": ["x64", "arm64"] },
        { "target": "zip", "arch": ["x64", "arm64"] }
      ]
    },
    "win": {
      "target": [
        { "target": "nsis", "arch": ["x64"] },
        { "target": "portable", "arch": ["x64"] }
      ],
      "certificateFile": "cert.pfx",
      "certificatePassword": "${CERT_PASSWORD}"
    },
    "linux": {
      "target": ["AppImage", "deb"],
      "category": "Utility",
      "maintainer": "developer@example.com"
    },
    "nsis": {
      "oneClick": false,
      "allowToChangeInstallationDirectory": true,
      "installerIcon": "build/icon.ico",
      "uninstallerIcon": "build/icon.ico"
    },
    "publish": {
      "provider": "github",
      "owner": "myorg",
      "repo": "myapp"
    }
  }
}
```

## 快速参考

| 模式 | 用途 |
|------|------|
| contextBridge | 安全暴露 API |
| ipcMain.handle | 主进程处理请求 |
| ipcRenderer.invoke | 渲染进程调用 |
| BrowserWindow | 窗口管理 |
| Tray | 系统托盘 |
| autoUpdater | 自动更新 |

**记住**：Electron 的安全性至关重要。始终使用 contextIsolation 和 preload 脚本，验证 IPC 通道，避免 nodeIntegration。合理管理窗口生命周期，优化内存使用。
