# 架构模式

## API 响应

```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "meta": { "total": 100, "page": 1, "limit": 20 }
}
```

## 仓储

| 操作 | 说明 |
|------|------|
| findAll | 获取所有 |
| findById | ID 查询 |
| create | 创建 |
| update | 更新 |
| delete | 删除 |

原则：依赖抽象接口，不依赖存储。

## 骨架

1. 搜索验证
2. 评估安全
3. 克隆最佳
4. 迭代改进
