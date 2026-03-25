# Trae Workflow CLI

> 命令行工具，用于安装和管理 Trae Workflow

---

## 安装

### 方式一：全局安装（推荐）

```bash
npm install -g trae-workflow-cli
```

### 方式二：本地安装

```bash
cd cli
npm install
npm link
traew version
```

---

## 命令

### 安装

```bash
# 从默认仓库安装
traew install

# 从指定仓库安装
traew install username/repo

# 从本地目录安装
traew install --local ./Trae-Workflow

# 安装并初始化项目规则
traew install --path ~/myproject --type typescript
```

### 更新

```bash
traew update
```

### 状态

```bash
traew status
```

### 初始化项目规则

```bash
# 在当前目录初始化
traew init

# 在指定项目初始化
traew init ~/myproject --type typescript
```

### 卸载

```bash
traew uninstall
```

### 版本

```bash
traew version
```

---

## 支持的项目类型

| 类型       | 说明                  |
| ---------- | --------------------- |
| typescript | TypeScript/JavaScript |
| python     | Python                |
| golang     | Go                    |
| rust       | Rust                  |
| java       | Java                  |
| kotlin     | Kotlin                |
| swift      | Swift                 |

---

## 安装选项

| 选项                | 说明             |
| ------------------- | ---------------- |
| `-b, --backup`      | 备份现有配置     |
| `--skip-mcp`        | 跳过 MCP 配置    |
| `--skip-skills`     | 跳过 Skills 配置 |
| `--skip-agents`     | 跳过 Agents 配置 |
| `--skip-rules`      | 跳过 Rules 配置  |
| `-q, --quiet`       | 静默模式         |
| `-f, --force`       | 强制执行         |
| `-p, --path <path>` | 项目路径         |
| `-t, --type <type>` | 项目类型         |
| `-l, --local <dir>` | 从本地目录安装   |

---

**设计理念**：简洁、易用、功能完整。
