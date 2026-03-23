---
alwaysApply: false
globs:
  - '**/*.py'
  - '**/*.pyi'
---

# Python 测试

> Python 语言特定的测试框架和策略。

## 测试框架

使用 **pytest** 作为测试框架。

## 覆盖率

```bash
pytest --cov=src --cov-report=term-missing
```

## 测试组织

使用 `pytest.mark` 进行测试分类：

```python
import pytest

@pytest.mark.unit
def test_calculate_total():
    ...

@pytest.mark.integration
def test_database_connection():
    ...
```

## Fixtures

```python
@pytest.fixture
def client():
    app = create_app()
    return TestClient(app)
```

## 相关智能体

- `testing-expert` - TDD 工作流和测试策略

## 相关技能

- `python-testing` - pytest 测试策略
- `tdd-workflow` - 测试驱动开发
