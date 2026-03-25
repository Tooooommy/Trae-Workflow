# 核心原则

> 优先级最高

## 五条原则

| #   | 原则             | 说明                             |
| --- | ---------------- | -------------------------------- |
| 1   | **智能体优先**   | 委托专业智能体处理复杂任务       |
| 2   | **测试驱动**     | 先写测试，要求 80%+ 覆盖率       |
| 3   | **安全第一**     | 验证所有输入，保护敏感数据       |
| 4   | **不可变性**     | 创建新对象，永不修改现有对象     |
| 5   | **先规划后执行** | 复杂功能先规划再实现             |

## 不可变性示例

```
WRONG:  modify(obj, 'field', value)  → 原地修改
CORRECT: update(obj, 'field', value)  → 返回新副本
```

## 相关文档

- 智能体：[agents/README.md](../agents/README.md)
- 测试：[testing.md](testing.md)
- 安全：[security.md](security.md)
- 开发：[development-workflow.md](development-workflow.md)
