# MCP 服务器配置

Trae Workflow 提供了一套完整的 MCP 服务器配置，基于 **MCP-Rules-Skills-Agents** 四层架构，为智能系统提供底层通信支持。

## 🎯 架构分层

```
┌─────────────────────────────────────────────────────────┐
│                      Agents 层                         │
│ （智能体：决策与执行）                                 │
├─────────────────────────────────────────────────────────┤
│                      Skills 层                         │
│ （技能：具体可执行的能力）                             │
├─────────────────────────────────────────────────────────┤
│                      Rules 层                          │
│ （规则：行为规范与约束）                               │
├─────────────────────────────────────────────────────────┤
│                      MCP 层                           │
│ （通信协议：底层连接与数据交换）                       │
└─────────────────────────────────────────────────────────┘
```

## 📊 MCP 服务器分类

### 🧠 核心服务器 (Core Servers)

| 服务器                  | 描述             | 相关智能体 |
| ----------------------- | ---------------- | ---------- |
| **memory**              | 内存管理服务器   | 所有智能体 |
| **sequential-thinking** | 顺序思考服务器   | 所有智能体 |
| **context7**            | 上下文管理服务器 | 所有智能体 |

### 💾 存储服务器 (Storage Servers)

| 服务器           | 描述              | 相关智能体               |
| ---------------- | ----------------- | ------------------------ |
| **file-storage** | 文件存储服务器    | `doc-updater`            |
| **github**       | GitHub 集成服务器 | `reviewer`, `git-expert` |
| **database**     | 数据库服务器      | `database-expert`        |

### 🔌 服务集成 (Service Integration)

| 服务器             | 描述              | 相关智能体       |
| ------------------ | ----------------- | ---------------- |
| **email**          | 邮件服务服务器    | `devops`         |
| **payment-stripe** | Stripe 支付服务器 | `backend-expert` |
| **analytics**      | 分析跟踪服务器    | `performance`    |

### 🌐 网络与通信 (Network & Communication)

| 服务器            | 描述             | 相关智能体       |
| ----------------- | ---------------- | ---------------- |
| **websocket**     | WebSocket 服务器 | `backend-expert` |
| **webrtc**        | WebRTC 服务器    | `backend-expert` |
| **message-queue** | 消息队列服务器   | `backend-expert` |

## 🔄 协同工作流程

### MCP 服务器引用模式

每个智能体通过 MCP 服务器实现：

- **MCP 层**：提供底层通信和数据交换
- **Skills 层**：通过 MCP 调用具体能力
- **Agents 层**：通过 MCP 与外部系统交互

### 示例配置

```yaml
# 智能体 MCP 配置示例
planner:
  mcp_servers:
    - memory
    - sequential-thinking
    - context7

reviewer:
  mcp_servers:
    - memory
    - sequential-thinking
    - context7
    - github

devops:
  mcp_servers:
    - memory
    - sequential-thinking
    - context7
    - email
    - analytics
```

## 🛠️ 内置工具

所有智能体都支持以下内置工具：

| 工具           | 描述         | 用途               |
| -------------- | ------------ | ------------------ |
| **read**       | 文件读取工具 | 代码审查、文档分析 |
| **filesystem** | 文件系统工具 | 文件操作、项目管理 |
| **terminal**   | 终端工具     | 命令执行、构建测试 |
| **web-search** | 网络搜索工具 | 技术调研、问题解决 |

## 📖 详细配置

### 核心服务器配置

```yaml
# memory 服务器
memory:
  type: memory
  config:
    max_size: 1GB
    persistence: true

# sequential-thinking 服务器
sequential-thinking:
  type: thinking
  config:
    max_steps: 10
    timeout: 300s

# context7 服务器
context7:
  type: context
  config:
    max_tokens: 8000
    retention: 24h
```

### 集成服务器配置

```yaml
# github 服务器
github:
  type: github
  config:
    token: ${GITHUB_TOKEN}
    base_url: https://api.github.com

# file-storage 服务器
file-storage:
  type: storage
  config:
    provider: local
    base_path: ./storage
```

## 🔧 部署说明

### 本地开发环境

```bash
# 启动 MCP 服务器
trae-mcp start --config mcp/config.yaml

# 验证服务器状态
trae-mcp status
```

### 生产环境

```yaml
# Docker Compose 配置
version: '3.8'
services:
  mcp-memory:
    image: trae/mcp-memory:latest
    ports:
      - '8080:8080'
    environment:
      - MAX_SIZE=2GB

  mcp-github:
    image: trae/mcp-github:latest
    ports:
      - '8081:8081'
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
```

## 📚 相关文档

- [智能体系统](../agents/README.md) - 智能体角色和工作流
- [技能系统](../skills/README.md) - 技能模式和实现
- [规则体系](../user_rules/README.md) - 行为规范和约束

---

**架构理念**：MCP 管"连接"，Rules 管"边界"，Skills 管"动作"，Agent 管"决策与执行"。它们从底层到高层，共同构成了一个完整的智能系统。
