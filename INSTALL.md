# Trae Workflow 安装指南

本指南将帮助您安装和配置 Trae Workflow 项目。

## 📋 目录

- [系统要求](#系统要求)
- [安装步骤](#安装步骤)
- [配置 MCP 服务器](#配置-mcp-服务器)
- [配置技能和规则](#配置技能和规则)
- [设置环境变量](#设置环境变量)
- [验证安装](#验证安装)
- [卸载](#卸载)

## 系统要求

### 必需

- **Trae IDE**：最新版本
- **Node.js**：18.0 或更高版本
- **Git**：2.0 或更高版本

### 可选

- **GitHub 账户**：用于 GitHub MCP 服务器
- **Supabase 账户**：用于 Supabase MCP 服务器
- **Exa API 密钥**：用于网络搜索 MCP 服务器

## 安装步骤

### 步骤 1：获取项目

#### 选项 A：克隆仓库（推荐）

```bash
git clone <repository-url>
cd "Trae Workflow"
```

#### 选项 B：下载 ZIP 文件

1. 访问项目页面
2. 点击 "Code" → "Download ZIP"
3. 解压到本地目录
4. 进入解压后的目录

### 步骤 2：检查 Node.js 版本

```bash
node --version
# 应该显示 v18.0.0 或更高版本
```

如果未安装 Node.js，请从 [nodejs.org](https://nodejs.org/) 下载并安装。

### 步骤 3：验证项目结构

确保项目包含以下文件和目录：

```
Trae Workflow/
├── mcp.json                 # MCP 服务器配置
├── README.md                # 项目说明
├── INSTALL.md               # 安装指南
├── agents/                  # 智能体配置
│   ├── orchestrator.md      # 智能体协调器（总览）
│   ├── AGENT_WORKFLOW.md    # 智能体调用关系图
│   └── ...
├── trae-agents/             # Trae IDE 智能体模板
│   ├── README.md            # 使用说明
│   └── ...
├── skills/                  # 技能配置
├── project_rules/           # 项目规则
└── user_rules/              # 用户规则
```

## 配置 MCP 服务器

### Windows

1. **找到 Trae CN 配置目录**

   ```powershell
   # 通常位于
   %USERPROFILE%\.trae-cn\
   ```

2. **备份现有配置（如果存在）**

   ```powershell
   Copy-Item "$env:USERPROFILE\.trae-cn\mcp.json" "$env:USERPROFILE\.trae-cn\mcp.json.backup" -ErrorAction SilentlyContinue
   ```

3. **复制 MCP 配置**
   ```powershell
   Copy-Item "mcp.json" "$env:USERPROFILE\.trae-cn\mcp.json"
   ```

### macOS/Linux

1. **找到 Trae CN 配置目录**

   ```bash
   # 通常位于
   ~/.trae-cn/
   ```

2. **备份现有配置（如果存在）**

   ```bash
   cp ~/.trae-cn/mcp.json ~/.trae-cn/mcp.json.backup 2>/dev/null || true
   ```

3. **复制 MCP 配置**
   ```bash
   cp mcp.json ~/.trae-cn/mcp.json
   ```

### 自定义 MCP 服务器

编辑 `~/.trae-cn/mcp.json` 文件以启用/禁用服务器：

```json
{
  "mcpServers": {
    "github": {
      "enabled": true
    },
    "supabase": {
      "enabled": false
    }
  }
}
```

## 配置技能和规则

### 复制技能目录

#### Windows

```powershell
# 创建技能目录（如果不存在）
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.trae-cn\skills"

# 复制技能文件
Copy-Item -Path "skills\*" -Destination "$env:USERPROFILE\.trae-cn\skills" -Recurse -Force
```

#### macOS/Linux

```bash
# 创建技能目录（如果不存在）
mkdir -p ~/.trae-cn/skills

# 复制技能文件
cp -r skills/* ~/.trae-cn/skills/
```

### 复制用户规则目录

#### Windows

```powershell
# 创建用户规则目录（如果不存在）
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.trae-cn\user_rules"

# 复制用户规则文件
Copy-Item -Path "user_rules\*" -Destination "$env:USERPROFILE\.trae-cn\user_rules" -Recurse -Force
```

#### macOS/Linux

```bash
# 创建用户规则目录（如果不存在）
mkdir -p ~/.trae-cn/user_rules

# 复制用户规则文件
cp -r user_rules/* ~/.trae-cn/user_rules/
```

### 配置项目规则（可选）

Project Rules 包含语言特定的扩展规则，支持 7 种编程语言：

| 语言       | 框架/技术栈                                                                   |
| ---------- | ----------------------------------------------------------------------------- |
| TypeScript | React, Next.js, NestJS, Taro, UniApp, 微信小程序, Expo, React Native, Shopify |
| Python     | FastAPI, Django, Flask                                                        |
| Go         | Gin, Echo, Fiber                                                              |
| Java       | Spring Boot, Quarkus                                                          |
| Kotlin     | Spring Boot, Ktor                                                             |
| Swift      | Vapor, SwiftUI                                                                |
| Rust       | Actix-web, Axum                                                               |

#### 在项目中使用

**重要**：Project Rules 不是放在全局配置目录 `~/.trae-cn/`，而是在**创建具体项目时**复制到项目目录的 `.trae/rules/` 下。

规则优先级：

```
项目根目录/.trae/rules/  ← 最高优先级（项目特定）
    ↓
user_rules/              ← 高优先级（用户配置）
```

#### Windows

```powershell
# 在项目根目录创建 .trae/rules 目录
New-Item -ItemType Directory -Force -Path ".trae\rules"

# 根据项目语言复制对应的规则
# 例如 TypeScript 项目：
Copy-Item -Path "Trae Workflow\project_rules\typescript\*" -Destination ".trae\rules\" -Recurse -Force

# 例如 Python 项目：
Copy-Item -Path "Trae Workflow\project_rules\python\*" -Destination ".trae\rules\" -Recurse -Force
```

#### macOS/Linux

```bash
# 在项目根目录创建 .trae/rules 目录
mkdir -p .trae/rules

# 根据项目语言复制对应的规则
# 例如 TypeScript 项目：
cp -r "Trae Workflow/project_rules/typescript/"* ".trae/rules/"

# 例如 Python 项目：
cp -r "Trae Workflow/project_rules/python/"* ".trae/rules/"
```

#### 项目规则文件说明

每种语言的规则目录包含以下文件：

| 文件              | 说明                                       |
| ----------------- | ------------------------------------------ |
| `coding-style.md` | 语言特定的编码风格和约定                   |
| `testing.md`      | 语言特定的测试框架和策略                   |
| `security.md`     | 语言特定的安全最佳实践                     |
| `patterns.md`     | 语言特定的设计模式                         |
| `hooks.md`        | 语言特定的 Hooks 配置                      |
| `<framework>.md`  | 特定框架规则（如 react.md、fastapi.md 等） |

#### 示例：创建 TypeScript + React 项目

```bash
# 1. 创建项目目录
mkdir my-react-app
cd my-react-app

# 2. 初始化项目（如使用 Vite）
npm create vite@latest . -- --template react-ts

# 3. 复制 Project Rules
mkdir -p .trae/rules
cp -r "../Trae Workflow/project_rules/typescript/"* ".trae/rules/"

# 4. 现在 Trae 会自动加载这些规则
```

## 设置环境变量

### Windows

#### 方法 1：系统环境变量（推荐）

1. 右键点击 "此电脑" → "属性"
2. 点击 "高级系统设置"
3. 点击 "环境变量"
4. 在 "用户变量" 中添加以下变量：

| 变量名                | 值                                |
| --------------------- | --------------------------------- |
| GITHUB_PAT            | your_github_personal_access_token |
| EXA_API_KEY           | your_exa_api_key                  |
| SUPABASE_PROJECT_REF  | your_supabase_project_ref         |
| POSTGRES_URL          | your_postgres_connection_string   |
| SLACK_BOT_TOKEN       | your_slack_bot_token              |
| SLACK_TEAM_ID         | your_slack_team_id                |
| BRAVE_API_KEY         | your_brave_api_key                |
| GOOGLE_MAPS_API_KEY   | your_google_maps_api_key          |
| AWS_ACCESS_KEY_ID     | your_aws_access_key_id            |
| AWS_SECRET_ACCESS_KEY | your_aws_secret_access_key        |
| AWS_REGION            | your_aws_region                   |

#### 方法 2：PowerShell 临时设置

```powershell
$env:GITHUB_PAT="your_github_personal_access_token"
$env:EXA_API_KEY="your_exa_api_key"
$env:SUPABASE_PROJECT_REF="your_supabase_project_ref"
$env:POSTGRES_URL="your_postgres_connection_string"
```

### macOS/Linux

#### 方法 1：Shell 配置文件（推荐）

编辑 `~/.bashrc` 或 `~/.zshrc`：

```bash
# 添加以下行
export GITHUB_PAT="your_github_personal_access_token"
export EXA_API_KEY="your_exa_api_key"
export SUPABASE_PROJECT_REF="your_supabase_project_ref"
export POSTGRES_URL="your_postgres_connection_string"
export SLACK_BOT_TOKEN="your_slack_bot_token"
export SLACK_TEAM_ID="your_slack_team_id"
export BRAVE_API_KEY="your_brave_api_key"
export GOOGLE_MAPS_API_KEY="your_google_maps_api_key"
export AWS_ACCESS_KEY_ID="your_aws_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_aws_secret_access_key"
export AWS_REGION="your_aws_region"
```

然后重新加载配置：

```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

#### 方法 2：临时设置

```bash
export GITHUB_PAT="your_github_personal_access_token"
export EXA_API_KEY="your_exa_api_key"
export SUPABASE_PROJECT_REF="your_supabase_project_ref"
export POSTGRES_URL="your_postgres_connection_string"
```

### 获取 API 密钥

#### GitHub Personal Access Token

1. 访问 [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. 点击 "Generate new token"
3. 选择所需的权限（至少需要 `repo` 权限）
4. 生成并复制令牌

#### Exa API Key

1. 访问 [Exa AI](https://exa.ai/)
2. 注册账户
3. 在设置中获取 API 密钥

#### Supabase Project Reference

1. 访问 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择或创建项目
3. 在项目设置中找到 Project Reference

## 验证安装

### 1. 检查目录结构

确保以下目录结构正确：

```
~/.trae-cn/                    # 全局配置目录
├── mcp.json                   # MCP 服务器配置
├── tracking.json              # 跟踪分析配置（可选）
├── skills/                    # 技能目录（70+ 技能）
│   ├── tdd-workflow/
│   ├── analytics-tracking/
│   └── ...
└── user_rules/                # 用户规则目录
    ├── user-rules.md
    ├── core-principles.md
    └── ...

你的项目/
└── .trae/
    └── rules/                 # 项目特定规则（从 project_rules/ 复制）
        ├── coding-style.md
        ├── testing.md
        └── ...
```

### 2. 检查 Trae IDE 配置

1. 打开 Trae IDE
2. 检查设置 → MCP 服务器
3. 确认列出了配置的服务器

### 3. 测试 MCP 服务器

在 Trae IDE 中尝试以下操作：

- 使用 `memory` 服务器存储信息
- 使用 `context7` 查找文档
- 使用 `filesystem` 读取文件

### 4. 测试智能体

尝试使用以下智能体：

1. **planning-team**：请求制定一个简单的实施计划
2. **tdd-guide**：请求指导 TDD 工作流
3. **code-reviewer**：审查一段代码

### 5. 验证规则加载

检查 Trae IDE 是否正确加载了规则文件：

- 用户规则：`~/.trae-cn/user_rules/`
- 项目规则：`project_rules/<language>/`

## 卸载

### Windows

```powershell
# 删除 MCP 配置
Remove-Item "$env:USERPROFILE\.trae-cn\mcp.json" -ErrorAction SilentlyContinue

# 删除跟踪配置
Remove-Item "$env:USERPROFILE\.trae-cn\tracking.json" -ErrorAction SilentlyContinue

# 删除技能目录
Remove-Item "$env:USERPROFILE\.trae-cn\skills" -Recurse -Force -ErrorAction SilentlyContinue

# 删除用户规则目录
Remove-Item "$env:USERPROFILE\.trae-cn\user_rules" -Recurse -Force -ErrorAction SilentlyContinue

# 恢复备份（如果存在）
if (Test-Path "$env:USERPROFILE\.trae-cn\mcp.json.backup") {
    Copy-Item "$env:USERPROFILE\.trae-cn\mcp.json.backup" "$env:USERPROFILE\.trae-cn\mcp.json"
}

# 注意：项目目录中的 .trae/rules/ 需要手动删除
# Remove-Item ".trae" -Recurse -Force -ErrorAction SilentlyContinue

# 删除项目目录
Remove-Item "Trae Workflow" -Recurse -Force
```

### macOS/Linux

```bash
# 删除 MCP 配置
rm -f ~/.trae-cn/mcp.json

# 删除跟踪配置
rm -f ~/.trae-cn/tracking.json

# 删除技能目录
rm -rf ~/.trae-cn/skills

# 删除用户规则目录
rm -rf ~/.trae-cn/user_rules

# 恢复备份（如果存在）
if [ -f ~/.trae-cn/mcp.json.backup ]; then
    cp ~/.trae-cn/mcp.json.backup ~/.trae-cn/mcp.json
fi

# 注意：项目目录中的 .trae/rules/ 需要手动删除
# rm -rf .trae

# 删除项目目录
rm -rf "Trae Workflow"
```

## 常见问题

### 问题：MCP 服务器无法启动

**解决方案**：

1. 检查 Node.js 版本：`node --version`
2. 确保 npx 可用：`npx --version`
3. 检查网络连接（首次运行需要下载包）
4. 查看错误日志以获取详细信息

### 问题：环境变量未生效

**解决方案**：

1. 确保变量名拼写正确
2. 重启 Trae IDE
3. 检查变量是否在正确的配置文件中设置
4. 使用 `echo $VARIABLE_NAME`（Linux/macOS）或 `echo %VARIABLE_NAME%`（Windows）验证

### 问题：智能体无法使用

**解决方案**：

1. 检查智能体配置文件是否存在
2. 确认智能体在 [agents/orchestrator.md](agents/orchestrator.md) 中已配置
3. 重启 Trae IDE
4. 查看错误日志

### 问题：规则未加载

**解决方案**：

1. 检查规则文件路径是否正确（`~/.trae-cn/user_rules/`）
2. 确认规则文件格式正确（Markdown）
3. 检查规则优先级设置
4. 重启 Trae IDE

### 问题：技能无法使用

**解决方案**：

1. 检查技能目录是否存在（`~/.trae-cn/skills/`）
2. 确认 `SKILL.md` 文件存在
3. 检查 frontmatter 格式
4. 重启 Trae IDE

## 下一步

安装完成后，建议：

1. 阅读 [README.md](README.md) 了解项目概述
2. 查看 [agents/orchestrator.md](agents/orchestrator.md) 了解智能体协调指南
3. 查看 [故障排除文档](TROUBLESHOOTING.md) 了解常见问题
4. 探索 [智能体文档](agents/) 了解各智能体的使用方法
5. 阅读 [技能文档](skills/) 学习各种技能

## 获取帮助

如果遇到问题：

1. 查看 [故障排除文档](TROUBLESHOOTING.md)
2. 搜索现有 Issues
3. 创建新的 Issue 并提供：
   - 操作系统版本
   - Trae IDE 版本
   - Node.js 版本
   - 详细的错误信息
   - 重现步骤

---

**提示**：定期更新项目以获取最新的功能和修复。
