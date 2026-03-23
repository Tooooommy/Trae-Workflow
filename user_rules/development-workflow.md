# 开发工作流

> 定义开发流程。

---

## 4 步工作流

```
1. 规划 → 使用 planner 智能体，识别依赖项和风险，分解为阶段
2. TDD  → 使用 tdd-guide 智能体，先写测试，实现，重构
3. 审查 → 立即使用 code-quality 智能体，解决 CRITICAL/HIGH 问题
4. 提交 → 约定式提交格式，全面的 PR 摘要
```

---

## 详细流程

### 1. 规划阶段

- 使用 **planner** 智能体创建实施计划
- 识别依赖项和风险
- 分解为多个阶段
- 在编码前生成规划文档

### 2. TDD 阶段

- 使用 **tdd-guide** 智能体
- 先写测试（RED）→ 测试应该失败
- 编写最小实现（GREEN）→ 测试应该通过
- 重构（IMPROVE）→ 验证覆盖率 80%+

### 3. 审查阶段

- 编写代码后立即使用 **code-quality** 智能体
- 处理 CRITICAL 和 HIGH 级别的问题
- 尽可能修复 MEDIUM 级别的问题

### 4. 提交阶段

- 详细的提交信息
- 遵循约定式提交格式
- 包含全面的 PR 摘要
- 详见 [git-workflow.md](git-workflow.md)

---

## 研究与复用

任何新实现之前强制进行：

1. **GitHub 代码搜索** - 查找现有实现、模板和模式
2. **包注册表搜索** - npm、PyPI、crates.io 等
3. **优先采用** - 经过验证的方法优于全新代码

---

## 相关技能

- **tdd-workflow** - 详细的 TDD 工作流和代码示例
- **coding-standards** - 通用编码标准和最佳实践
- **git-workflow** - Git 分支策略和提交规范
- **clean-architecture** - 整洁架构模式

---

## 相关智能体

- **planner** - 功能规划专家
- **tdd-guide** - TDD 实践专家
- **code-quality** - 代码质量专家
- **reviewer** - 代码审查专家
- **git-expert** - Git 专家
