# Git 规范

## 提交格式

```
<type>(<scope>): <subject>
<body>
<footer>
```

## 提交类型

| 类型     | 说明               |
| -------- | ------------------ |
| feat     | 新功能             |
| fix      | 修复 bug           |
| docs     | 文档更新           |
| style    | 代码格式           |
| refactor | 重构               |
| test     | 添加测试           |
| chore    | 构建/工具变动      |
| perf     | 性能优化           |
| ci       | CI 配置变动        |

## 主题要求

- 动词-名词格式
- ≤ 50 字符

## PR 工作流

1. 分析提交历史
2. `git diff base...HEAD` 查看更改
3. 起草 PR 摘要
4. 包含测试计划
5. 新分支用 `-u` 推送
