---
alwaysApply: false
globs:
  - '**/*.py'
  - '**/*.pyi'
---

# Python 安全

> Python 语言特定的安全最佳实践。

## 密钥管理

```python
import os
from dotenv import load_dotenv

load_dotenv()

api_key = os.environ["OPENAI_API_KEY"]  # Raises KeyError if missing
```

## 安全扫描

使用 **bandit** 进行静态安全分析：

```bash
bandit -r src/
```

## 输入验证

使用 Pydantic 进行输入验证：

```python
from pydantic import BaseModel, EmailStr, validator

class UserInput(BaseModel):
    email: EmailStr
    age: int

    @validator('age')
    def validate_age(cls, v):
        if v < 0 or v > 150:
            raise ValueError('Invalid age')
        return v
```

## 相关智能体

- `security-reviewer` - 安全漏洞检测

## 相关技能

- `security-review` - 安全检查清单
- `validation-patterns` - 数据验证模式
