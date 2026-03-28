# 安装脚本使用指南

## 概述

Trae Workflow 提供了三个配置脚本，用于自动配置 Trae IDE 的 Skills 和 Rules：

| 文件        | 平台        | 说明                     |
| ----------- | ----------- | ------------------------ |
| `setup.bat` | Windows     | 批处理包装器（双击运行） |
| `setup.ps1` | Windows     | PowerShell 脚本（推荐）  |
| `setup.sh`  | Linux/macOS | Bash 脚本                |

## 使用方法

### Windows

#### 方法一：双击运行

直接双击 `setup.bat` 文件即可自动配置。

#### 方法二：PowerShell 命令行

```powershell
# 完整配置
.\setup.ps1

# 带备份的完整配置
.\setup.ps1 -Backup

# 跳过某些部分
.\setup.ps1 -SkipTracking

# 静默模式
.\setup.ps1 -Quiet

# 强制执行（跳过确认）
.\setup.ps1 -Force
```

#### 方法三：批处理命令行

```cmd
setup.bat
setup.bat --backup
setup.bat --skip-tracking --quiet
setup.bat --help
```

### Linux/macOS

```bash
# 赋予执行权限
chmod +x setup.sh

# 完整配置
./setup.sh

# 带备份的完整配置
./setup.sh --backup

# 跳过某些部分
./setup.sh --skip-tracking

# 静默模式
./setup.sh --quiet

# 强制执行（跳过确认）
./setup.sh --force
```

## 参数说明

| 参数              | 说明                   | 默认值 |
| ----------------- | ---------------------- | ------ |
| `--backup`        | 备份现有配置           | false  |
| `--skip-skills`   | 跳过 Skills 配置       | false  |
| `--skip-rules`    | 跳过 Rules 配置        | false  |
| `--skip-tracking` | 跳过 Tracking 配置     | false  |
| `--quiet`         | 静默模式，减少输出     | false  |
| `--force`         | 强制执行，跳过所有确认 | false  |
| `--help`          | 显示帮助信息           | -      |

## 输出示例

```
========================================
  Trae Workflow 配置脚本
  版本: 1.1.0
========================================

[1/5] 创建配置目录...
      ✓ 配置目录: C:\Users\Username\.trae-cn

[2/5] 备份现有配置...
      ✓ 备份完成: C:\Users\Username\.trae-cn\backup_20240321_143022

[3/5] 配置 Skills...
      ✓ 已复制 58 个技能

[4/5] 配置 User Rules...
      ✓ User Rules 已复制

[5/5] 配置 Tracking...
      ✓ Tracking 配置已复制

========================================
  配置完成！
========================================

请重启 Trae IDE 以应用更改

配置文件位置: C:\Users\Username\.trae-cn
```

## 配置目录结构

安装完成后，配置目录结构如下：

```
~/.trae-cn/                    # 全局配置目录
├── skills/                    # 技能目录（58+ 技能）
│   ├── orchestrator/
│   ├── product-strategist/
│   ├── frontend-specialist/
│   └── ...
├── user_rules/                # 用户规则目录
│   ├── core-principles.md
│   ├── coding-style.md
│   └── ...
└── tracking.json              # 跟踪分析配置（可选）
```

## 故障排除

### 问题：脚本无法运行

**Windows**:

1. 确保已安装 PowerShell 5.1+
2. 检查执行策略：`Get-ExecutionPolicy`
3. 如需修改：`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

**Linux/macOS**:

1. 确保已安装 Bash 4.0+
2. 赋予执行权限：`chmod +x setup.sh`

### 问题：配置未生效

1. 重启 Trae IDE
2. 清除 Trae IDE 缓存
3. 检查配置文件是否正确复制

### 问题：权限错误

1. 以管理员/Root 身份运行脚本
2. 检查目标目录权限
3. 关闭占用文件的程序

## 版本历史

### v1.1.0

- ✨ 新增日志记录功能
- ✨ 新增进度显示
- ✨ 新增错误处理
- ✨ 新增安全检查
- ✨ 新增静默模式
- ✨ 新增强制执行模式

### v1.0.0

- 初始版本
- 支持 Skills、Rules 配置
- 支持 Tracking 配置
- 支持备份功能
