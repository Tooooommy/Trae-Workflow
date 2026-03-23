# 技能系统

Trae Workflow 提供了一套完整的技能系统，基于 **MCP-Rules-Skills-Agents** 四层架构，涵盖软件开发的各个方面。

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

## 📊 技能分类

### 🧪 测试与质量 (Testing & Quality)

| 技能                                    | 描述            | 相关智能体     |
| --------------------------------------- | --------------- | -------------- |
| [tdd-workflow](tdd-workflow/)           | TDD 工作流模式  | `tdd-guide`    |
| [python-testing](python-testing/)       | Python 测试模式 | `python-dev`   |
| [golang-testing](golang-testing/)       | Go 测试模式     | `go-dev`       |
| [e2e-testing](e2e-testing/)             | 端到端测试模式  | `e2e-tester`   |
| [verification-loop](verification-loop/) | 验证循环模式    | `code-quality` |

### 🔒 安全与认证 (Security & Authentication)

| 技能                                                | 描述         | 相关智能体          |
| --------------------------------------------------- | ------------ | ------------------- |
| [security-review](security-review/)                 | 安全审查模式 | `security-reviewer` |
| [authentication-patterns](authentication-patterns/) | 认证模式     | `api-designer`      |
| [rate-limiting](rate-limiting/)                     | 限流模式     | `devops`            |
| [validation-patterns](validation-patterns/)         | 验证模式     | `reviewer`          |

### 🚀 部署与运维 (Deployment & DevOps)

| 技能                                        | 描述             | 相关智能体 |
| ------------------------------------------- | ---------------- | ---------- |
| [ci-cd-patterns](ci-cd-patterns/)           | CI/CD 流水线模式 | `devops`   |
| [deployment-patterns](deployment-patterns/) | 部署模式         | `devops`   |
| [docker-patterns](docker-patterns/)         | Docker 模式      | `devops`   |
| [kubernetes-patterns](kubernetes-patterns/) | Kubernetes 模式  | `devops`   |

### � 开发与架构 (Development & Architecture)

| 技能                                              | 描述         | 相关智能体     |
| ------------------------------------------------- | ------------ | -------------- |
| [clean-architecture](clean-architecture/)         | 整洁架构模式 | `architect`    |
| [microservices-patterns](microservices-patterns/) | 微服务模式   | `architect`    |
| [ddd-patterns](ddd-patterns/)                     | 领域驱动设计 | `architect`    |
| [api-design](api-design/)                         | API 设计模式 | `api-designer` |

### � 语言特定 (Language Specific)

| 技能                                | 描述        | 相关智能体   |
| ----------------------------------- | ----------- | ------------ |
| [python-patterns](python-patterns/) | Python 模式 | `python-dev` |
| [golang-patterns](golang-patterns/) | Go 模式     | `go-dev`     |
| [rust-patterns](rust-patterns/)     | Rust 模式   | `rust-dev`   |
| [java-patterns](java-patterns/)     | Java 模式   | `java-dev`   |

### 📊 前端与 UI (Frontend & UI)

| 技能                                      | 描述          | 相关智能体        |
| ----------------------------------------- | ------------- | ----------------- |
| [react-modern-stack](react-modern-stack/) | React 现代栈  | `frontend-expert` |
| [vue-patterns](vue-patterns/)             | Vue 模式      | `frontend-expert` |
| [angular-patterns](angular-patterns/)     | Angular 模式  | `frontend-expert` |
| [tailwind-patterns](tailwind-patterns/)   | Tailwind 模式 | `frontend-expert` |

### 📱 移动端 (Mobile)

| 技能                                                    | 描述              | 相关智能体   |
| ------------------------------------------------------- | ----------------- | ------------ |
| [react-native-ignite-stack](react-native-ignite-stack/) | React Native 栈   | `mobile-dev` |
| [react-native-patterns](react-native-patterns/)         | React Native 模式 | `mobile-dev` |
| [android-native-patterns](android-native-patterns/)     | Android 原生模式  | `mobile-dev` |
| [ios-native-patterns](ios-native-patterns/)             | iOS 原生模式      | `mobile-dev` |

### �️ 数据库 (Database)

| 技能                                        | 描述            | 相关智能体        |
| ------------------------------------------- | --------------- | ----------------- |
| [database-migrations](database-migrations/) | 数据库迁移模式  | `database-expert` |
| [postgres-patterns](postgres-patterns/)     | PostgreSQL 模式 | `database-expert` |
| [mongodb-patterns](mongodb-patterns/)       | MongoDB 模式    | `database-expert` |
| [prisma-patterns](prisma-patterns/)         | Prisma ORM 模式 | `database-expert` |

### 🔄 实时通信 (Real-time Communication)

| 技能                                              | 描述           | 相关智能体       |
| ------------------------------------------------- | -------------- | ---------------- |
| [realtime-websocket](realtime-websocket/)         | WebSocket 模式 | `backend-expert` |
| [webrtc-patterns](webrtc-patterns/)               | WebRTC 模式    | `backend-expert` |
| [message-queue-patterns](message-queue-patterns/) | 消息队列模式   | `backend-expert` |
| [grpc-patterns](grpc-patterns/)                   | gRPC 模式      | `backend-expert` |

### 🤖 AI/ML (Artificial Intelligence)

| 技能                                                        | 描述         | 相关智能体    |
| ----------------------------------------------------------- | ------------ | ------------- |
| [llm-integration-patterns](llm-integration-patterns/)       | LLM 集成模式 | `ml-engineer` |
| [rag-patterns](rag-patterns/)                               | RAG 模式     | `ml-engineer` |
| [foundation-models-on-device](foundation-models-on-device/) | 设备上模型   | `mobile-dev`  |

### � 性能与缓存 (Performance & Caching)

| 技能                                  | 描述       | 相关智能体    |
| ------------------------------------- | ---------- | ------------- |
| [caching-patterns](caching-patterns/) | 缓存模式   | `performance` |
| [redis-patterns](redis-patterns/)     | Redis 模式 | `performance` |
| [circuit-breaker](circuit-breaker/)   | 熔断器模式 | `performance` |

### 🌐 国际化与无障碍 (Internationalization & Accessibility)

| 技能                            | 描述       | 相关智能体        |
| ------------------------------- | ---------- | ----------------- |
| [i18n-patterns](i18n-patterns/) | 国际化模式 | `frontend-expert` |
| [a11y-patterns](a11y-patterns/) | 无障碍模式 | `frontend-expert` |

## 🔄 协同工作流程

### 技能引用模式

每个智能体通过技能引用实现：

- **Rules 层**：定义要求和约束
- **Skills 层**：提供详细的实现模式
- **Agents 层**：定义专家角色和工作流

### 示例工作流

```yaml
# 开发新功能
planner:
  - clean-architecture
  - tdd-workflow
  - git-workflow

architect:
  - microservices-patterns
  - api-design
  - database-migrations

python-dev:
  - python-patterns
  - python-testing
  - deployment-patterns

reviewer:
  - coding-standards
  - error-handling-patterns
  - validation-patterns
```

## 📖 详细文档

- [测试与质量技能](testing-quality/) - 测试和质量保证模式
- [安全与认证技能](security-auth/) - 安全和认证模式
- [部署与运维技能](deployment-devops/) - DevOps 和部署模式
- [开发与架构技能](development-architecture/) - 开发和架构模式
- [语言特定技能](language-specific/) - 语言特定模式
- [前端与 UI 技能](frontend-ui/) - 前端和 UI 模式
- [移动端技能](mobile/) - 移动端开发模式
- [数据库技能](database/) - 数据库模式
- [实时通信技能](realtime-communication/) - 实时通信模式
- [AI/ML 技能](ai-ml/) - AI/ML 模式
- [性能与缓存技能](performance-caching/) - 性能和缓存模式
- [国际化与无障碍技能](i18n-a11y/) - 国际化和无障碍模式

---

**架构理念**：MCP 管"连接"，Rules 管"边界"，Skills 管"动作"，Agent 管"决策与执行"。它们从底层到高层，共同构成了一个完整的智能系统。
