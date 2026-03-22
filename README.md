# Trae Workflow - Trae 配置项目

Trae Workflow — 智能体指令配置项目，提供生产就绪的 AI 编码插件，包含 28 个专业智能体、70+ 项技能以及用于软件开发的自动化工作流。

## 📋 项目概述

本项目为 Trae IDE 提供了一套完整的配置，包括：

- **28 个专业智能体**：覆盖规划、架构、测试、审查、安全、DevOps、ML、Git 等各个方面
- **89 项技能**：涵盖测试驱动开发、代码审查、部署模式、认证、实时通信等
- **完整的规则体系**：通用规则 + 语言特定规则
- **16+ MCP 服务器配置**：优化的 MCP 服务器配置

## 🚀 快速开始

### 方式一：使用 CLI 安装（推荐）

```bash
# 全局安装 CLI
npm install -g trae-workflow-cli

# 安装 Trae Workflow
traew install

# 查看版本
traew version
```

### 方式二：手动安装

详见下方安装步骤

### CLI 安装

Trae Workflow 提供了命令行工具，可以快速从 GitHub 下载并安装最新版本。

#### 安装 CLI

```bash
npm install -g trae-workflow-cli
```

#### 使用 CLI 安装

```bash
# 从默认仓库安装
traew install

# 从指定仓库安装
traew install username/repo

# 安装时备份现有配置
traew install --backup

# 跳过某些组件
traew install --skip-mcp --skip-skills

# 指定项目规则
traew install --path "C:\myproject" --type typescript
```

#### CLI 命令

| 命令                   | 说明                         |
| ---------------------- | ---------------------------- |
| `traew install [repo]` | 从 GitHub 安装 Trae Workflow |
| `traew update`         | 更新到最新版本               |
| `traew version`        | 显示当前版本                 |

#### CLI 选项

| 选项                   | 说明                     |
| ---------------------- | ------------------------ |
| `-b, --backup`         | 备份现有配置             |
| `--skip-mcp`           | 跳过 MCP 配置            |
| `--skip-skills`        | 跳过 Skills 配置         |
| `--skip-agents`        | 跳过 Agents 配置         |
| `--skip-rules`         | 跳过 Rules 配置          |
| `--skip-tracking`      | 跳过 Tracking 配置       |
| `--skip-project-rules` | 跳过 Project Rules 配置  |
| `-q, --quiet`          | 静默模式                 |
| `-f, --force`          | 强制执行                 |
| `-p, --path <path>`    | Project Rules 的项目路径 |
| `-t, --type <type>`    | 项目类型                 |

### 前置要求

- Trae IDE 已安装
- Node.js 18+ (用于 MCP 服务器)
- Git

### 一键安装

#### Windows

```powershell
# 双击运行 setup.bat，或在 PowerShell 中执行
.\setup.ps1

# 带备份的完整配置
.\setup.ps1 -Backup

# 跳过某些部分
.\setup.ps1 -SkipTracking
```

#### macOS/Linux

```bash
# 赋予执行权限
chmod +x setup.sh

# 运行配置脚本
./setup.sh

# 带备份的完整配置
./setup.sh --backup

# 跳过某些部分
./setup.sh --skip-tracking
```

### 手动安装

1. **克隆或下载此项目**

   ```bash
   git clone <repository-url>
   cd "Trae Workflow"
   ```

2. **配置 MCP 服务器**

   ```bash
   # 复制 MCP 配置到 Trae CN 配置目录
   # Windows: %USERPROFILE%\.trae-cn\mcp.json
   # macOS/Linux: ~/.trae-cn/mcp.json
   ```

3. **配置技能和规则**

   ```bash
   # 复制技能目录到 Trae CN 配置目录
   # Windows: %USERPROFILE%\.trae-cn\skills\
   # macOS/Linux: ~/.trae-cn/skills/

   # 复制用户规则目录到 Trae CN 配置目录
   # Windows: %USERPROFILE%\.trae-cn\user_rules\
   # macOS/Linux: ~/.trae-cn/user_rules/

   # 复制项目规则目录到 Trae CN 配置目录
   # Windows: %USERPROFILE%\.trae-cn\project_rules\
   # macOS/Linux: ~/.trae-cn/project_rules/
   ```

4. **设置环境变量**

   ```bash
   # 在系统环境变量中设置以下变量（可选）
   GITHUB_PAT=your_github_personal_access_token
   EXA_API_KEY=your_exa_api_key
   SUPABASE_PROJECT_REF=your_supabase_project_ref
   ```

5. **重启 Trae IDE**

## 📁 项目结构

```
Trae Workflow/                    # 本仓库
├── setup.ps1                     # Windows 配置脚本
├── setup.bat                     # Windows 批处理包装器
├── setup.sh                      # Linux/macOS 配置脚本
├── mcp.json                      # MCP 服务器配置
├── tracking.json                 # 跟踪分析配置
├── agents/                       # 智能体配置（28 个）
│   ├── orchestrator.md           # 智能体协调器（总览）
│   ├── planner.md
│   ├── architect.md
│   ├── tdd-guide.md
│   ├── code-reviewer.md
│   ├── feedback-analyst.md       # 反馈分析智能体
│   ├── AGENT_WORKFLOW.md         # 智能体调用关系图
│   └── ...
├── trae-agents/                  # Trae IDE 智能体模板（29 个，可直接导入）
│   ├── README.md                 # 使用说明
│   ├── orchestrator.md           # 模板文件
│   └── ...
├── skills/                       # 技能配置（89 个）
│   ├── tdd-workflow/
│   ├── verification-loop/
│   ├── coding-standards/
│   ├── analytics-tracking/       # 分析跟踪技能
│   └── ...
├── project_rules/                # 项目规则模板（7 种语言）
│   ├── typescript/               # TypeScript 特定规则
│   ├── python/                   # Python 特定规则
│   ├── golang/                   # Go 特定规则
│   ├── java/                     # Java 特定规则
│   ├── kotlin/                   # Kotlin 特定规则
│   ├── swift/                    # Swift 特定规则
│   └── rust/                     # Rust 特定规则
└── user_rules/                   # 用户特定规则
    └── user-rules.md             # 最高优先级规则
```

### 配置位置说明

| 配置类型     | 位置                | 说明                             |
| ------------ | ------------------- | -------------------------------- |
| **全局配置** | `~/.trae-cn/`       | MCP、Skills、User Rules 放在这里 |
| **项目配置** | `项目/.trae/rules/` | Project Rules 复制到具体项目目录 |

例如：

```
~/.trae-cn/                       # 全局配置（自动配置）
├── mcp.json
├── skills/
└── user_rules/

my-project/                       # 你的项目（手动复制）
└── .trae/
    └── rules/                    # 从 project_rules/typescript/ 复制
```

## 🤖 可用智能体

### 核心智能体

| 智能体            | 目的               | 何时使用                   |
| ----------------- | ------------------ | -------------------------- |
| orchestrator      | 智能体协调器       | 复杂任务、多智能体协作     |
| planner           | 实施规划           | 复杂功能、重构             |
| architect         | 系统设计与可扩展性 | 架构决策                   |
| tdd-guide         | 测试驱动开发       | 新功能、错误修复           |
| code-reviewer     | 代码质量审查       | TypeScript/JavaScript 代码 |
| security-reviewer | 漏洞检测           | 提交前、敏感代码           |

### 语言特定审查器

| 智能体          | 目的            | 何时使用       |
| --------------- | --------------- | -------------- |
| python-reviewer | Python 代码审查 | Python 项目    |
| go-reviewer     | Go 代码审查     | Go 项目        |
| rust-reviewer   | Rust 代码审查   | Rust 项目      |
| swift-reviewer  | Swift 代码审查  | Swift/iOS 项目 |
| java-reviewer   | Java 代码审查   | Java 项目      |
| kotlin-reviewer | Kotlin 代码审查 | Kotlin 项目    |

### 专用智能体

| 智能体               | 目的               | 何时使用           |
| -------------------- | ------------------ | ------------------ |
| build-error-resolver | 修复构建/类型错误  | 构建失败时         |
| go-build-resolver    | Go 构建错误        | Go 构建失败        |
| database-reviewer    | 数据库专家         | 模式设计、查询优化 |
| e2e-runner           | 端到端测试         | 关键用户流程       |
| refactor-cleaner     | 清理无用代码       | 代码维护           |
| doc-updater          | 文档和代码地图更新 | 更新文档           |

### 新增专业智能体

| 智能体                | 目的           | 何时使用               |
| --------------------- | -------------- | ---------------------- |
| performance-optimizer | 性能优化专家   | 性能瓶颈分析、优化建议 |
| devops-engineer       | DevOps 工程师  | CI/CD、基础设施、部署  |
| qa-engineer           | QA 工程师      | 测试策略、质量保证     |
| ml-engineer           | 机器学习工程师 | 模型训练、MLOps        |
| mobile-developer      | 移动开发专家   | React Native/Flutter   |
| data-engineer         | 数据工程师     | 数据管道、ETL          |
| ux-designer           | UX 设计师      | 用户体验、交互设计     |
| cloud-architect       | 云架构师       | 云服务选型、架构设计   |

> 💡 **提示**：查看 [agents/orchestrator.md](agents/orchestrator.md) 了解完整的智能体协调指南。

## 🛠️ MCP 服务器

### 核心服务器（默认启用）

| 服务器              | 描述             | 用途                  |
| ------------------- | ---------------- | --------------------- |
| memory              | 跨会话持久化记忆 | 存储和检索上下文信息  |
| sequential-thinking | 链式思维推理     | 复杂问题的逐步分析    |
| context7            | 实时文档查找     | 快速查找技术文档      |
| filesystem          | 文件系统操作     | 读写项目文件          |
| github              | GitHub 操作      | 管理 PR、Issue 和仓库 |
| exa-web-search      | 网络搜索         | 研究和获取最新信息    |
| supabase            | Supabase 数据库  | 数据库操作和管理      |
| vercel              | Vercel 部署      | 管理部署和项目        |

### 可选服务器

| 服务器           | 描述              | 用途                 |
| ---------------- | ----------------- | -------------------- |
| postgres         | PostgreSQL 数据库 | 直接数据库查询和操作 |
| slack            | Slack 集成        | 发送消息和管理频道   |
| puppeteer        | 浏览器自动化      | 网页抓取和截图       |
| brave-search     | Brave 搜索        | 隐私友好的网络搜索   |
| google-maps      | Google Maps       | 地理位置和路线规划   |
| aws-kb-retrieval | AWS 知识库        | AWS 服务文档检索     |
| docker           | Docker 操作       | 管理容器和镜像       |
| kubernetes       | Kubernetes        | 集群管理和部署       |

按需启用其他服务器，详见 [mcp.json](mcp.json)。

## 📚 核心原则

1. **智能体优先** — 将领域任务委托给专业智能体
2. **测试驱动** — 先写测试再实现，要求 80%+ 覆盖率
3. **安全第一** — 绝不妥协安全；验证所有输入
4. **不可变性** — 总是创建新对象，永不修改现有对象
5. **先规划后执行** — 在编写代码前规划复杂功能
6. **持续改进** — 跟踪调用数据，不断优化 SKILL 和 Agent

## 📊 跟踪改进系统

本项目包含完整的跟踪改进系统，用于持续优化 SKILL 和 Agent：

### 核心组件

| 组件       | 文件                                                     | 功能                     |
| ---------- | -------------------------------------------------------- | ------------------------ |
| 跟踪配置   | [tracking.json](tracking.json)                           | 定义跟踪规则、告警、报告 |
| 分析技能   | [analytics-tracking](skills/analytics-tracking/SKILL.md) | 数据收集和分析           |
| 反馈智能体 | [feedback-analyst](agents/feedback-analyst.md)           | 生成改进建议             |

### 使用方式

```bash
# 初始化跟踪数据库
npx ts-node scripts/init-analytics.ts

# 生成周报
npx ts-node scripts/generate-report.ts --days 7

# 查看改进建议
sqlite3 ~/.trae-cn/analytics.db "SELECT * FROM improvement_suggestions WHERE status='pending'"
```

### 自动功能

- **调用记录**：自动记录 SKILL 和 Agent 调用
- **成功率分析**：监控各组件成功率
- **告警触发**：成功率低于阈值时告警
- **报告生成**：自动生成日报、周报、月报
- **改进建议**：基于数据分析生成优化建议

## 🔧 配置说明

### 规则优先级

1. **最高优先级**：`user_rules/user-rules.md`
2. **高优先级**：`project_rules/<language>/*.md`
3. **中优先级**：`project_rules/common/*.md`

语言特定规则覆盖通用规则，用户规则覆盖所有规则。

### Project Rules 说明

**重要区别**：Project Rules 与全局配置不同，需要在**创建具体项目时**手动复制到项目目录。

| 配置类型     | 位置                | 使用时机               |
| ------------ | ------------------- | ---------------------- |
| **全局配置** | `~/.trae-cn/`       | 一次配置，所有项目共享 |
| **项目规则** | `项目/.trae/rules/` | 每个项目单独配置       |

#### 支持的 7 种编程语言

| 语言       | 技术栈                                                                        |
| ---------- | ----------------------------------------------------------------------------- |
| TypeScript | React, Next.js, NestJS, Taro, UniApp, 微信小程序, Expo, React Native, Shopify |
| Python     | FastAPI, Django, Flask                                                        |
| Go         | Gin, Echo, Fiber                                                              |
| Java       | Spring Boot, Quarkus                                                          |
| Kotlin     | Spring Boot, Ktor                                                             |
| Swift      | Vapor, SwiftUI                                                                |
| Rust       | Actix-web, Axum                                                               |

#### 使用方法

```bash
# 1. 创建项目
mkdir my-project && cd my-project

# 2. 初始化项目（如 npm init、go mod init 等）

# 3. 复制对应语言的 Project Rules
mkdir -p .trae/rules
cp -r "../Trae Workflow/project_rules/typescript/"* ".trae/rules/"

# 4. Trae 会自动加载项目目录下的规则
```

每种语言包含以下规则文件：

- `coding-style.md` - 编码风格和约定
- `testing.md` - 测试框架和策略
- `security.md` - 安全最佳实践
- `patterns.md` - 设计模式
- `hooks.md` - Hooks 配置
- `<framework>.md` - 特定框架规则

### 环境变量

| 变量名                | 描述                  | 必需 |
| --------------------- | --------------------- | ---- |
| GITHUB_PAT            | GitHub 个人访问令牌   | 可选 |
| EXA_API_KEY           | Exa API 密钥          | 可选 |
| SUPABASE_PROJECT_REF  | Supabase 项目引用     | 可选 |
| POSTGRES_URL          | PostgreSQL 连接字符串 | 可选 |
| SLACK_BOT_TOKEN       | Slack 机器人令牌      | 可选 |
| SLACK_TEAM_ID         | Slack 团队 ID         | 可选 |
| BRAVE_API_KEY         | Brave 搜索 API 密钥   | 可选 |
| GOOGLE_MAPS_API_KEY   | Google Maps API 密钥  | 可选 |
| AWS_ACCESS_KEY_ID     | AWS 访问密钥 ID       | 可选 |
| AWS_SECRET_ACCESS_KEY | AWS 秘密访问密钥      | 可选 |
| AWS_REGION            | AWS 区域              | 可选 |

## 📖 详细文档

- [安装指南](INSTALL.md) - 详细的安装和配置步骤
- [故障排除](TROUBLESHOOTING.md) - 常见问题和解决方案
- [智能体协调器](agents/orchestrator.md) - 智能体协调指南
- [智能体文档](agents/) - 各智能体的详细说明
- [技能文档](skills/) - 各技能的详细说明

## 🎯 使用示例

### 开发新功能

1. 使用 **planner** 智能体制定实施计划
2. 使用 **tdd-guide** 智能体遵循 TDD 工作流
3. 编写代码
4. 使用 **code-reviewer** 智能体审查代码
5. 使用 **security-reviewer** 智能体进行安全审查

### 修复 Bug

1. 使用 **systematic-debugging** 技能分析问题
2. 使用 **tdd-guide** 智能体编写测试
3. 修复代码
4. 验证测试通过

### 架构决策

1. 使用 **architect** 智能体进行架构设计
2. 使用 **brainstorming** 技能探索方案
3. 使用 **planner** 智能体制定实施计划

## 🤝 贡献

欢迎贡献！请遵循以下步骤：

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证。

## 🆘 支持

如遇问题，请：

1. 查看 [故障排除文档](TROUBLESHOOTING.md)
2. 搜索现有 Issues
3. 创建新的 Issue 并提供详细信息

## 📞 联系方式

- 项目主页：[GitHub Repository]
- 问题反馈：[GitHub Issues]

---

**注意**：本配置项目专为 Trae IDE 设计，确保您的 Trae IDE 版本兼容。
