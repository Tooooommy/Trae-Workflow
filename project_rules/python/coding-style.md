---
alwaysApply: false
globs:
  - '**/*.py'
  - '**/*.pyi'
---

# Python 编码风格

> Python 语言特定的编码规范。

## 标准

- 遵循 **PEP 8** 规范
- 在所有函数签名上使用 **类型注解**

## 不变性

优先使用不可变数据结构：

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class User:
    name: str
    email: str
```

## 相关智能体

- `code-reviewer` - 代码质量和规范检查

## 相关技能

- `coding-standards` - 通用编码标准
