# API 文档

## 概述

| 项目 | 内容 |
|------|------|
| API名称 | {API_NAME} |
| 版本 | v1.0 |
| 基础路径 | /api/v1 |
| 日期 | {DATE} |
| 作者 | backend-specialist |

## 1. 认证

| 方式 | 说明 |
|------|------|
| Bearer Token | JWT 认证 |
| API Key | 服务间调用 |

### 请求头

```
Authorization: Bearer <token>
Content-Type: application/json
```

## 2. 统一响应

### 成功响应

```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

### 错误响应

```json
{
  "success": false,
  "data": null,
  "error": "错误信息",
  "code": "ERROR_CODE"
}
```

## 3. 接口列表

### 3.1 {资源名称}

#### 列表查询

```
GET /api/v1/{resources}
```

**请求参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | number | 否 | 页码，默认 1 |
| limit | number | 否 | 每页数量，默认 20 |
| search | string | 否 | 搜索关键词 |

**响应示例**

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "totalPages": 5
  }
}
```

#### 详情查询

```
GET /api/v1/{resources}/:id
```

**路径参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | string | 资源ID |

**响应示例**

```json
{
  "success": true,
  "data": {
    "id": "...",
    ...
  }
}
```

#### 创建

```
POST /api/v1/{resources}
```

**请求体**

```json
{
  "field1": "value1",
  "field2": "value2"
}
```

**响应示例**

```json
{
  "success": true,
  "data": {
    "id": "...",
    ...
  }
}
```

#### 更新

```
PUT /api/v1/{resources}/:id
```

**请求体**

```json
{
  "field1": "new_value"
}
```

**响应示例**

```json
{
  "success": true,
  "data": {
    "id": "...",
    ...
  }
}
```

#### 删除

```
DELETE /api/v1/{resources}/:id
```

**响应示例**

```json
{
  "success": true,
  "data": null
}
```

## 4. 错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| VALIDATION_ERROR | 400 | 参数验证失败 |
| UNAUTHORIZED | 401 | 未授权 |
| FORBIDDEN | 403 | 无权限 |
| NOT_FOUND | 404 | 资源不存在 |
| CONFLICT | 409 | 资源冲突 |
| INTERNAL_ERROR | 500 | 服务器错误 |

## 5. 限流

| 类型 | 限制 |
|------|------|
| 普通用户 | 100 次/分钟 |
| 认证用户 | 1000 次/分钟 |

## 6. 变更日志

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | | 初始版本 |
