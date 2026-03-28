# Trae Workflow 安装指南

## 快速安装

### 方式一：使用安装脚本（推荐）

#### Windows

```powershell
# 双击运行 setup.bat 或在 PowerShell 中执行
.\setup.ps1
```

#### Linux/macOS

```bash
# 赋予执行权限
chmod +x setup.sh

# 运行安装脚本
./setup.sh
```

### 方式二：使用 CLI

```bash
# 安装 CLI
npm install -g trae-workflow-cli

# 安装配置
traew install

# 更新
traew update
```

### 方式三：手动安装

#### 1. 获取项目

```bash
git clone <repository-url>
cd "Trae Workflow"
```

#### 2. 复制技能目录

**Windows:**

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.trae-cn\skills"
Copy-Item -Path "skills\*" -Destination "$env:USERPROFILE\.trae-cn\skills" -Recurse -Force
```

**Linux/macOS:**

```bash
mkdir -p ~/.trae-cn/skills
cp -r skills/* ~/.trae-cn/skills/
```

#### 3. 复制用户规则

**Windows:**

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.trae-cn\user_rules"
Copy-Item -Path "user_rules\*" -Destination "$env:USERPROFILE\.trae-cn\user_rules" -Recurse -Force
```

**Linux/macOS:**

```bash
mkdir -p ~/.trae-cn/user_rules
cp -r user_rules/* ~/.trae-cn/user_rules/
```

#### 4. 复制跟踪配置（可选）

**Windows:**

```powershell
Copy-Item "tracking.json" "$env:USERPROFILE\.trae-cn\tracking.json"
```

**Linux/macOS:**

```bash
cp tracking.json ~/.trae-cn/tracking.json
```

## 系统要求

| 软件 | 版本要求 |
|------|----------|
| Trae IDE | 最新版本 |
| Node.js | 18.0+ |
| Git | 2.0+ |

## 配置目录结构

安装完成后，配置目录结构如下：

```
~/.trae-cn/                    # 全局配置目录
├── skills/                    # 技能目录（58+ 技能）
│   ├── orchestrator/          # 协调中枢
│   ├── product-strategist/    # 产品战略
│   ├── frontend-specialist/   # 前端开发
│   ├── backend-specialist/    # 后端开发
│   └── ...                    # 其他技能
├── user_rules/                # 用户规则目录
│   ├── core-principles.md     # 核心原则
│   ├── coding-style.md        # 代码规范
│   ├── testing.md             # 测试规范
│   ├── security.md            # 安全规范
│   └── ...                    # 其他规则
└── tracking.json              # 跟踪分析配置（可选）
```

## 验证安装

### 1. 检查目录结构

```bash
# Windows
dir $env:USERPROFILE\.trae-cn\skills

# Linux/macOS
ls ~/.trae-cn/skills
```

### 2. 重启 Trae IDE

重启 Trae IDE 以加载新配置。

### 3. 测试技能

在 Trae IDE 中尝试使用技能：

- `orchestrator` - 开始一个新项目
- `tdd-patterns` - 请求 TDD 工作流指导
- `quality-engineer` - 审查代码质量

## 卸载

### Windows

```powershell
Remove-Item "$env:USERPROFILE\.trae-cn\skills" -Recurse -Force
Remove-Item "$env:USERPROFILE\.trae-cn\user_rules" -Recurse -Force
Remove-Item "$env:USERPROFILE\.trae-cn\tracking.json" -ErrorAction SilentlyContinue
```

### Linux/macOS

```bash
rm -rf ~/.trae-cn/skills
rm -rf ~/.trae-cn/user_rules
rm -f ~/.trae-cn/tracking.json
```

## 常见问题

### 问题：技能无法使用

**解决方案：**

1. 检查技能目录是否存在
2. 确认 `SKILL.md` 文件存在
3. 重启 Trae IDE

### 问题：规则未加载

**解决方案：**

1. 检查规则文件路径是否正确
2. 确认规则文件格式正确（Markdown）
3. 重启 Trae IDE

### 问题：配置未生效

**解决方案：**

1. 重启 Trae IDE
2. 清除 Trae IDE 缓存
3. 检查配置文件是否正确复制

## 下一步

安装完成后，建议：

1. 阅读 [README.md](README.md) 了解项目概述
2. 查看 [skills/orchestrator/SKILL.md](skills/orchestrator/SKILL.md) 了解协调中枢
3. 探索 [skills/](skills/) 目录了解各种技能
