# 安装脚本使用指南

## 概述

Trae Workflow 提供了三个配置脚本，用于自动配置 Trae IDE 的 MCP、Skills 和 Rules：

| 文件 | 平台 | 说明 |
|------|------|------|
| `setup.bat` | Windows | 批处理包装器（双击运行） |
| `setup.ps1` | Windows | PowerShell 脚本（推荐） |
| `setup.sh` | Linux/macOS | Bash 脚本 |

## 新功能（v1.1.0）

### 1. 日志记录

所有操作都会自动记录到日志文件：
- **Windows**: `setup-YYYYMMDD_HHMMSS.log`
- **Linux/macOS**: `setup-YYYYMMDD_HHMMSS.log`

日志包含：
- 时间戳
- 操作级别（INFO/WARN/ERROR）
- 详细操作信息

### 2. 错误处理

- 完整的 try-catch 错误捕获
- 友好的错误提示
- 失败时自动退出并记录错误

### 3. 进度显示

- 显示当前步骤/总步骤数
- 清晰的进度指示
- 实时状态更新

### 4. 安全检查

#### Windows
- 检查管理员权限
- 检查 Trae IDE 是否运行
- 提供确认选项

#### Linux/macOS
- 检查 Trae IDE 是否运行
- 提供确认选项

### 5. 新增参数

| 参数 | 说明 | 平台 |
|------|------|------|
| `--quiet` | 静默模式，减少输出 | 全部 |
| `--force` | 强制执行，跳过所有确认 | 全部 |

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

# 组合使用
.\setup.ps1 -Backup -SkipTracking -Quiet
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

# 组合使用
./setup.sh --backup --skip-tracking --quiet

# 查看帮助
./setup.sh --help
```

## 参数说明

### 全部平台

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--backup` | 备份现有配置 | false |
| `--skip-mcp` | 跳过 MCP 配置 | false |
| `--skip-skills` | 跳过 Skills 配置 | false |
| `--skip-rules` | 跳过 Rules 配置 | false |
| `--skip-tracking` | 跳过 Tracking 配置 | false |
| `--quiet` | 静默模式，减少输出 | false |
| `--force` | 强制执行，跳过所有确认 | false |
| `--help` | 显示帮助信息 | - |

### Windows 特定

| 参数 | PowerShell | 批处理 |
|------|-----------|----------|
| 备份 | `-Backup` | `--backup` |
| 跳过 MCP | `-SkipMCP` | `--skip-mcp` |
| 跳过 Skills | `-SkipSkills` | `--skip-skills` |
| 跳过 Rules | `-SkipRules` | `--skip-rules` |
| 跳过 Tracking | `-SkipTracking` | `--skip-tracking` |
| 静默 | `-Quiet` | `--quiet` |
| 强制 | `-Force` | `--force` |

## 输出示例

### 正常输出

```
========================================
  Trae Workflow 配置脚本
  版本: 1.1.0
========================================

[1/6] 创建配置目录...
      ✓ 配置目录: C:\Users\Username\.trae-cn

[2/6] 备份现有配置...
      ✓ 备份完成: C:\Users\Username\.trae-cn\backup_20240321_143022

[3/6] 配置 MCP 服务器...
      ✓ MCP 配置已复制

[4/6] 配置 Skills...
      ✓ 已复制 71 个技能

[5/6] 配置 User Rules...
      ✓ User Rules 已复制

[6/6] 配置 Tracking...
      ✓ Tracking 配置已复制

========================================
  配置完成！
========================================

请重启 Trae IDE 以应用更改

配置文件位置: C:\Users\Username\.trae-cn

Project Rules 说明:
  Project Rules 需要在创建具体项目时手动复制到项目目录:
  项目根目录/.trae/rules/

  例如，创建 TypeScript 项目时:
    Copy-Item -Path 'project_rules\typescript\*' -Destination '.\.trae\rules\' -Recurse -Force

环境变量设置（可选）:
  [Environment]::SetEnvironmentVariable('GITHUB_PAT', 'your_token', 'User')
  [Environment]::SetEnvironmentVariable('EXA_API_KEY', 'your_key', 'User')

配置摘要:
  - MCP 服务器: 已配置
  - Skills: 已配置
  - User Rules: 已配置
  - Tracking: 已配置

验证配置...
  ✓ 所有配置验证通过

日志文件: C:\Users\Administrator\Desktop\traeconf\Trae Workflow\setup-20240321_143022.log

按 Enter 键退出
```

### 静默模式输出

```
[1/6] 创建配置目录...
      ✓ 配置目录: C:\Users\Username\.trae-cn
[2/6] 备份现有配置...
      ✓ 备份完成: C:\Users\Username\.trae-cn\backup_20240321_143022
[3/6] 配置 MCP 服务器...
      ✓ MCP 配置已复制
[4/6] 配置 Skills...
      ✓ 已复制 71 个技能
[5/6] 配置 User Rules...
      ✓ User Rules 已复制
[6/6] 配置 Tracking...
      ✓ Tracking 配置已复制
```

## 错误处理

### 常见错误

#### 1. 不在项目目录中运行

```
错误: 请在 Trae Workflow 项目目录中运行此脚本
```

**解决方案**: 确保在包含 `mcp.json` 的目录中运行脚本。

#### 2. Trae IDE 正在运行

```
警告: 检测到 Trae IDE 正在运行
警告: 建议关闭 Trae IDE 后再运行此脚本
是否继续？(Y/N)
```

**解决方案**: 
- 关闭 Trae IDE 后继续
- 使用 `--force` 参数跳过确认

#### 3. 权限不足（Windows）

```
警告: 注意: 建议以管理员身份运行此脚本
是否继续？(Y/N)
```

**解决方案**:
- 以管理员身份运行 PowerShell
- 使用 `--force` 参数跳过确认

#### 4. 配置复制失败

```
错误: ✗ MCP 配置复制失败: Access to the path 'C:\Users\Username\.trae-cn' is denied.
```

**解决方案**:
- 检查目录权限
- 以管理员身份运行脚本
- 关闭占用文件的程序

## 日志文件

### 日志格式

```
[2024-03-21 14:30:22] [INFO] 配置脚本启动
[2024-03-21 14:30:22] [INFO] [1/6] 创建配置目录...
[2024-03-21 14:30:22] [INFO]       ✓ 配置目录: C:\Users\Username\.trae-cn
[2024-03-21 14:30:22] [INFO] 配置目录创建成功: C:\Users\Username\.trae-cn
[2024-03-21 14:30:22] [INFO] [2/6] 备份现有配置...
[2024-03-21 14:30:23] [INFO]       ✓ 备份完成: C:\Users\Username\.trae-cn\backup_20240321_143022
[2024-03-21 14:30:23] [INFO] 备份完成: C:\Users\Username\.trae-cn\backup_20240321_143022
```

### 日志级别

| 级别 | 说明 |
|--------|------|
| INFO | 一般信息 |
| WARN | 警告信息 |
| ERROR | 错误信息 |

## 最佳实践

### 1. 首次安装

```powershell
# 带备份的完整配置
.\setup.ps1 -Backup
```

### 2. 更新配置

```powershell
# 跳过备份，仅更新需要的内容
.\setup.ps1 -SkipTracking
```

### 3. 自动化脚本

```powershell
# 在 CI/CD 中使用静默模式
.\setup.ps1 -Backup -Quiet -Force
```

### 4. 故障排除

```powershell
# 使用日志文件排查问题
Get-Content setup-*.log | Select-String "ERROR"
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

1. 检查日志文件中的错误
2. 确认配置文件已正确复制
3. 重启 Trae IDE
4. 清除 Trae IDE 缓存

### 问题：权限错误

1. 以管理员/Root 身份运行脚本
2. 检查目标目录权限
3. 关闭占用文件的程序

## 版本历史

### v1.1.0 (2024-03-21)
- ✨ 新增日志记录功能
- ✨ 新增进度显示
- ✨ 新增错误处理
- ✨ 新增安全检查
- ✨ 新增静默模式
- ✨ 新增强制执行模式
- 🐛 修复备份时遗漏 tracking.json
- 📝 改进文档和帮助信息

### v1.0.0
- 初始版本
- 支持 MCP、Skills、Rules 配置
- 支持 Tracking 配置
- 支持备份功能

## 支持

如遇问题，请：
1. 查看日志文件
2. 检查本文档的故障排除部分
3. 提交 Issue 并附上日志文件
