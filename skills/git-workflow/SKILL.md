---
name: git-workflow
description: Git 版本控制最佳实践 - 分支策略、提交规范、合并流程、版本发布
priority: high
version: 1.0.0
---

# Git 版本控制技能

> 掌握 Git 分支策略、提交规范、合并流程和版本发布的最佳实践

## 技能概述

本技能提供 Git 版本控制的完整指南，帮助团队建立规范的版本控制流程。

## 核心能力

### 1. 分支策略设计

- **Git Flow** — 适合有计划发布周期的项目
- **Trunk-Based** — 适合持续部署的项目
- **GitHub Flow** — 简化的工作流，适合小型团队

### 2. 提交规范

- **Conventional Commits** — 标准化的提交消息格式
- **语义化版本** — 版本号管理规范
- **提交模板** — 团队统一的提交模板

### 3. 合并管理

- **Pull Request 流程** — 代码审查和合并
- **冲突解决策略** — 处理合并冲突
- **变基 vs 合并** — 选择合适的集成方式

### 4. 版本发布

- **标签管理** — 版本标签的创建和管理
- **CHANGELOG** — 变更日志的维护
- **发布分支** — 发布准备工作流程

## 分支策略详解

### Git Flow 模型

```
main (生产分支)
  │
  ├── develop (开发分支)
  │     │
  │     ├── feature/* (功能分支)
  │     ├── bugfix/* (修复分支)
  │     └── refactor/* (重构分支)
  │
  ├── release/* (发布分支)
  │
  └── hotfix/* (紧急修复分支)
```

**适用场景**：

- 有计划的发布周期
- 需要维护多个版本
- 严格的发布流程

### Trunk-Based 模型

```
main (主干)
  │
  ├── feature/* (短生命周期功能分支)
  │
  └── release/* (可选的发布分支)
```

**适用场景**：

- 持续集成/持续部署
- 高频发布
- 团队经验丰富

### GitHub Flow 模型

```
main (主分支，始终可部署)
  │
  └── feature/* (功能分支，合并后删除)
```

**适用场景**：

- 小型团队
- 单一版本
- 快速迭代

## 提交规范

### Conventional Commits 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 提交类型

| 类型     | 说明      | 示例                               |
| -------- | --------- | ---------------------------------- |
| feat     | 新功能    | feat(auth): add OAuth2 login       |
| fix      | Bug 修复  | fix(api): resolve null pointer     |
| docs     | 文档更新  | docs(readme): update install guide |
| style    | 代码格式  | style(lint): fix indentation       |
| refactor | 重构      | refactor(user): extract validation |
| test     | 测试      | test(auth): add unit tests         |
| chore    | 构建/工具 | chore(deps): update dependencies   |
| perf     | 性能优化  | perf(db): optimize query           |
| ci       | CI 配置   | ci(github): add workflow           |
| revert   | 回滚      | revert: revert feat(auth)          |

### Scope 示例

| Scope | 说明     |
| ----- | -------- |
| api   | API 相关 |
| auth  | 认证授权 |
| db    | 数据库   |
| ui    | 用户界面 |
| core  | 核心功能 |
| deps  | 依赖管理 |

## 合并策略

### Merge vs Rebase

| 场景                   | 推荐方式        | 原因         |
| ---------------------- | --------------- | ------------ |
| 功能分支合并到 develop | Merge (--no-ff) | 保留分支历史 |
| 本地分支同步主分支     | Rebase          | 保持历史整洁 |
| 已推送分支             | Merge           | 避免强制推送 |
| 私有分支               | Rebase          | 保持历史清晰 |

### 冲突解决流程

```bash
# 1. 查看冲突文件
git status

# 2. 列出所有冲突
git diff --name-only --diff-filter=U

# 3. 解决冲突后标记
git add <resolved-file>

# 4. 继续合并/变基
git merge --continue
# 或
git rebase --continue
```

### 冲突解决策略

| 场景     | 策略                   |
| -------- | ---------------------- |
| 功能冲突 | 手动合并，保留双方功能 |
| 样式冲突 | 选择最新或更好的方案   |
| 重构冲突 | 优先使用重构后的代码   |
| 配置冲突 | 合并配置项，不覆盖     |

## 版本发布流程

### 语义化版本

```
MAJOR.MINOR.PATCH

MAJOR - 不兼容的 API 变更
MINOR - 向后兼容的功能新增
PATCH - 向后兼容的问题修复
```

### 发布检查清单

- [ ] 所有测试通过
- [ ] 更新版本号
- [ ] 更新 CHANGELOG.md
- [ ] 创建版本标签
- [ ] 推送标签到远程
- [ ] 创建 GitHub Release

### 标签管理

```bash
# 创建带注释的标签
git tag -a v1.0.0 -m "Release 1.0.0"

# 推送单个标签
git push origin v1.0.0

# 推送所有标签
git push origin --tags

# 删除本地标签
git tag -d v1.0.0

# 删除远程标签
git push origin --delete v1.0.0
```

## 常用命令速查

### 分支操作

```bash
# 查看所有分支
git branch -a

# 创建并切换分支
git checkout -b feature/new-feature

# 删除已合并分支
git branch -d feature/old-feature

# 强制删除分支
git branch -D feature/old-feature

# 重命名分支
git branch -m old-name new-name
```

### 远程操作

```bash
# 查看远程仓库
git remote -v

# 添加远程仓库
git remote add upstream <url>

# 拉取远程分支
git fetch origin

# 推送并设置上游
git push -u origin feature/new-feature

# 删除远程分支
git push origin --delete feature/old-feature
```

### 历史操作

```bash
# 图形化历史
git log --oneline --graph --all

# 查看文件历史
git log --follow -p <file>

# 查看特定提交
git show <commit-hash>

# 交互式变基
git rebase -i HEAD~5

# 选择性合并
git cherry-pick <commit-hash>
```

### 撤销操作

```bash
# 撤销工作区修改
git checkout -- <file>

# 撤销暂存
git reset HEAD <file>

# 撤销最近提交（保留修改）
git reset --soft HEAD~1

# 撤销最近提交（丢弃修改）
git reset --hard HEAD~1

# 创建撤销提交
git revert <commit-hash>
```

## 最佳实践

### 提交原则

1. **原子性** — 每个提交只做一件事
2. **独立性** — 提交之间不依赖顺序
3. **可逆性** — 每个提交都可以安全回滚
4. **清晰性** — 提交消息清晰描述变更

### 分支原则

1. **短生命周期** — 功能分支尽快合并
2. **命名规范** — 使用一致的分支命名
3. **保护分支** — main/develop 设置保护规则
4. **及时清理** — 删除已合并的分支

### 协作原则

1. **提交前拉取** — 避免不必要的冲突
2. **小步提交** — 频繁提交小的变更
3. **代码审查** — 所有变更经过审查
4. **文档同步** — 保持文档与代码同步

## 危险信号

- **长期分支** — 功能分支超过 2 周
- **大合并** — 一次合并超过 500 行
- **强制推送** — 向保护分支强制推送
- **直接提交** — 直接向 main/develop 提交
- **未审查合并** — 跳过 PR 审查流程
- **敏感信息** — 提交包含密钥或凭证

## 工具集成

### Git Hooks

| Hook       | 用途         |
| ---------- | ------------ |
| pre-commit | 提交前检查   |
| commit-msg | 验证提交消息 |
| pre-push   | 推送前检查   |
| pre-rebase | 变基前检查   |

### 推荐工具

| 工具             | 用途             |
| ---------------- | ---------------- |
| commitlint       | 提交消息规范检查 |
| husky            | Git Hooks 管理   |
| standard-version | 自动化版本管理   |
| semantic-release | 自动化发布流程   |
| git-cz           | 交互式提交工具   |

## 技术栈版本

| 工具      | 版本  | 说明         |
| --------- | ----- | ------------ |
| Git       | 2.40+ | 版本控制系统 |
| GitHub    | -     | 代码托管平台 |
| GitLab    | -     | 代码托管平台 |
| Bitbucket | -     | 代码托管平台 |

## 相关技能

- [ci-cd-patterns](../ci-cd-patterns/) — CI/CD 流程配置
- [deployment-patterns](../deployment-patterns/) — 部署模式
- [coding-standards](../coding-standards/) — 编码规范
- [tdd-workflow](../tdd-workflow/) — 测试驱动开发
