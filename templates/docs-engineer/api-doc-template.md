# API 文档

> 服务: {服务名称}
> 版本: {v1.0}
> 基础路径: {/api/v1}

---

## 概述

[API 服务简要描述]

### 认证方式

| 方式 | 说明 |
|------|------|
| Bearer Token | JWT Token 认证 |
| API Key | 服务间调用 |

### 通用响应格式

```json
{
  "success": true,
  "data": {},
  "error": null,
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

### 错误码

| 错误码 | 说明 |
|--------|------|
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

---

## 接口列表

### 用户模块 `/api/users`

#### 获取用户列表

**GET** `/api/users`

**权限**: `user:read`

**Query 参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | number | 否 | 页码，默认 1 |
| limit | number | 否 | 每页数量，默认 20 |
| search | string | 否 | 搜索关键词 |

**请求示例**

```bash
curl -X GET "https://api.example.com/api/users?page=1&limit=20" \
  -H "Authorization: Bearer {token}"
```

**响应示例**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "张三",
      "email": "zhangsan@example.com",
      "createdAt": "2024-01-15T10:00:00Z"
    }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "totalPages": 5
  }
}
```

---

#### 创建用户

**POST** `/api/users`

**权限**: `user:create`

**请求体**

```json
{
  "name": "张三",
  "email": "zhangsan@example.com",
  "password": "password123"
}
```

**请求参数说明**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 用户名，2-50字符 |
| email | string | 是 | 邮箱地址 |
| password | string | 是 | 密码，至少8位 |

**响应示例**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "张三",
    "email": "zhangsan@example.com",
    "createdAt": "2024-01-15T10:00:00Z"
  }
}
```

---

#### 获取用户详情

**GET** `/api/users/:id`

**权限**: `user:read`

**路径参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | string | 用户ID |

**响应示例**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "张三",
    "email": "zhangsan@example.com",
    "avatar": "https://example.com/avatar.jpg",
    "createdAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2024-01-15T12:00:00Z"
  }
}
```

---

#### 更新用户

**PUT** `/api/users/:id`

**权限**: `user:update`

**请求体**

```json
{
  "name": "李四",
  "avatar": "https://example.com/new-avatar.jpg"
}
```

**响应示例**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "李四",
    "updatedAt": "2024-01-15T14:00:00Z"
  }
}
```

---

#### 删除用户

**DELETE** `/api/users/:id`

**权限**: `user:delete`

**响应示例**

```json
{
  "success": true,
  "data": null
}
```

---

## 数据模型

### User

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 唯一标识 |
| name | string | 用户名 |
| email | string | 邮箱 |
| avatar | string | 头像URL |
| createdAt | datetime | 创建时间 |
| updatedAt | datetime | 更新时间 |

---

## 变更记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | YYYY-MM-DD | 初始版本 |
