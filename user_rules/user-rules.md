# 用户规则

> 优先级最高

## 文件索引

| 文件 | 说明 |
|------|------|
| core-principles.md | 核心原则 |
| project-config.md | 项目配置 |
| coding-style.md | 代码规范 |
| development-workflow.md | 开发工作流 |
| testing.md | 测试规范 |
| security.md | 安全规范 |
| git-workflow.md | Git 规范 |
| patterns.md | 架构模式 |

## 成功指标

- [x] 测试通过 80%+
- [x] 无安全漏洞
- [x] 代码可维护
- [x] 性能可接受

## 审查清单

- [ ] 符合编码风格
- [ ] 测试通过
- [ ] 覆盖率 >= 80%
- [ ] 无硬编码密钥
- [ ] 输入已验证

## 规则层级

```
user_rules/           ← 最高
project_rules/<lang>/ ← 语言特定
```
