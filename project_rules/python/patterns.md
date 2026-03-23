---
alwaysApply: false
globs:
  - '**/*.py'
  - '**/*.pyi'
---

# Python 模式

> Python 语言特定的架构模式。

## 协议（鸭子类型）

```python
from typing import Protocol

class Repository(Protocol):
    def find_by_id(self, id: str) -> dict | None: ...
    def save(self, entity: dict) -> dict: ...
```

## 数据类作为 DTO

```python
from dataclasses import dataclass

@dataclass
class CreateUserRequest:
    name: str
    email: str
```

## 相关智能体

- `architect` - 架构设计和模式选择

## 相关技能

- `python-patterns` - Python 惯用模式
- `clean-architecture` - 整洁架构
