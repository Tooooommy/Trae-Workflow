---
alwaysApply: false
globs:
  - '**/*'
---

# 通用架构模式

> 所有项目通用的架构模式。

## API 响应格式

```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "meta": { "total": 100, "page": 1, "limit": 20 }
}
```

## 仓储模式

| 操作 | 说明 |
|------|------|
| findAll | 获取所有记录 |
| findById | 根据 ID 获取 |
| create | 创建记录 |
| update | 更新记录 |
| delete | 删除记录 |

**原则**：业务逻辑依赖抽象接口

## 分层架构

```
├── controllers/  # 请求处理
├── services/    # 业务逻辑
├── repositories/ # 数据访问
└── models/      # 数据模型
```
