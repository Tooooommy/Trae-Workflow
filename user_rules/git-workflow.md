# Git 规范

> 定义 Git 工作流。

---

## 提交格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

---

## 提交类型

| 类型     | 说明                           |
| -------- | ------------------------------ |
| feat     | 新功能                         |
| fix      | 修复 bug                       |
| docs     | 文档更新                       |
| style    | 代码格式（不影响代码运行）     |
| refactor | 重构（既不是新功能也不是修复） |
| test     | 添加测试                       |
| chore    | 构建过程或辅助工具的变动       |
| perf     | 性能优化                       |
| ci       | CI 配置文件和脚本的变动        |

---

## 提交范围

影响的文件或模块，例如：`user`、`auth`、`api`、`ui`

---

## 主题要求

- 简短描述，符合动词-名词格式
- 不超过 50 个字符

---

## PR 工作流

1. 分析完整的提交历史
2. 使用 `git diff [base-branch]...HEAD` 查看所有更改
3. 起草全面的 PR 摘要
4. 包含测试计划
5. 如果是新分支，使用 `-u` 标志推送

---

## 相关技能

- **git-workflow** - Git 分支策略、提交规范、版本发布
- **ci-cd-patterns** - CI/CD 流水线模式
- **verification-loop** - 验证循环模式

---

## 相关智能体

- **git-expert** - Git 专家
- **reviewer** - 代码审查专家
- **devops** - DevOps 专家
