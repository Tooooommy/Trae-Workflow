---
name: api-versioning
description: API 版本控制模式 - URL/Header/Query 版本管理最佳实践
---

# API 版本控制模式

> URL/Header/Query 版本管理、向后兼容、迁移策略的最佳实践

## 何时激活

- 设计新 API
- 规划 API 版本策略
- 处理 API 变更
- 实现向后兼容
- 设计 API 生命周期

## 技术栈版本

| 技术    | 最低版本 | 推荐版本 |
| ------- | -------- | -------- |
| Express | 4.18+    | 最新     |
| Fastify | 4.0+     | 最新     |
| NestJS  | 10.0+    | 最新     |

## 版本控制策略对比

| 策略         | 格式                          | 优点         | 缺点     |
| ------------ | ----------------------------- | ------------ | -------- |
| URL 路径     | `/v1/users`                   | 直观、易缓存 | URL 变化 |
| Header       | `Accept-Version: v1`          | URL 稳定     | 不易调试 |
| Query        | `/users?version=1`            | 灵活         | 参数污染 |
| Content-Type | `application/vnd.api.v1+json` | RESTful      | 复杂     |

## URL 路径版本控制

### Express 实现

```typescript
import express, { Router } from 'express';

const app = express();

const v1Router = Router();
const v2Router = Router();

v1Router.get('/users', (req, res) => {
  res.json({ version: 'v1', users: [] });
});

v2Router.get('/users', (req, res) => {
  res.json({ version: 'v2', users: [], meta: { total: 0 } });
});

app.use('/v1', v1Router);
app.use('/v2', v2Router);

app.use((req, res, next) => {
  res.redirect('/v2' + req.path);
});
```

### NestJS 实现

```typescript
import { Controller, Get, Version } from '@nestjs/common';

@Controller('users')
export class UsersController {
  @Get()
  @Version('1')
  findAllV1() {
    return { version: 'v1', users: [] };
  }

  @Get()
  @Version('2')
  findAllV2() {
    return { version: 'v2', users: [], meta: { total: 0 } };
  }
}

const app = await NestFactory.create(AppModule);
app.enableVersioning({
  type: VersioningType.URI,
});
```

## Header 版本控制

```typescript
function versionMiddleware(req, res, next) {
  const version = req.headers['accept-version'] || req.headers['x-api-version'] || 'v1';
  req.apiVersion = version;
  next();
}

app.use(versionMiddleware);

app.get('/users', (req, res) => {
  switch (req.apiVersion) {
    case 'v1':
      return res.json({ version: 'v1', users: [] });
    case 'v2':
      return res.json({ version: 'v2', users: [], meta: {} });
    default:
      return res.status(400).json({ error: 'Unsupported version' });
  }
});
```

## 版本路由器

```typescript
class VersionRouter {
  private versions = new Map<string, Router>();

  register(version: string, router: Router) {
    this.versions.set(version, router);
  }

  middleware() {
    return (req: Request, res: Response, next: NextFunction) => {
      const version = this.extractVersion(req);
      const router = this.versions.get(version);

      if (router) {
        return router(req, res, next);
      }

      const latestVersion = this.getLatestVersion();
      return this.versions.get(latestVersion)!(req, res, next);
    };
  }

  private extractVersion(req: Request): string {
    const match = req.path.match(/^\/v(\d+)/);
    if (match) return `v${match[1]}`;

    return (req.headers['x-api-version'] as string) || 'v1';
  }

  private getLatestVersion(): string {
    const versions = Array.from(this.versions.keys());
    return versions.sort().pop() || 'v1';
  }
}
```

## 版本废弃处理

```typescript
interface DeprecatedEndpoint {
  version: string;
  sunset: Date;
  link?: string;
}

const deprecations: Map<string, DeprecatedEndpoint> = new Map([
  ['/v1/users', { version: 'v1', sunset: new Date('2024-12-31'), link: '/v2/users' }],
]);

function deprecationMiddleware(req: Request, res: Response, next: NextFunction) {
  const deprecation = deprecations.get(req.path);

  if (deprecation) {
    res.setHeader('Deprecation', 'true');
    res.setHeader('Sunset', deprecation.sunset.toUTCString());

    if (deprecation.link) {
      res.setHeader('Link', `<${deprecation.link}>; rel="successor-version"`);
    }
  }

  next();
}
```

## 版本响应头

```typescript
function addVersionHeaders(req: Request, res: Response, next: NextFunction) {
  res.setHeader('X-API-Version', req.apiVersion);
  res.setHeader('X-API-Supported-Versions', 'v1, v2, v3');
  next();
}
```

## 变更类型

| 变更类型     | 是否需要新版本 | 示例            |
| ------------ | -------------- | --------------- |
| 新增字段     | 否             | 添加可选属性    |
| 新增端点     | 否             | 新增 API 路径   |
| 删除字段     | 是             | 移除属性        |
| 修改字段类型 | 是             | string → number |
| 修改行为     | 是             | 排序逻辑变更    |
| 删除端点     | 是             | 移除 API 路径   |

## 迁移指南

```typescript
interface MigrationGuide {
  fromVersion: string;
  toVersion: string;
  changes: Change[];
}

interface Change {
  type: 'breaking' | 'deprecated' | 'added';
  description: string;
  migration: string;
}

const migrationGuides: MigrationGuide[] = [
  {
    fromVersion: 'v1',
    toVersion: 'v2',
    changes: [
      {
        type: 'breaking',
        description: 'User response structure changed',
        migration: 'Use user.data instead of user directly',
      },
      {
        type: 'added',
        description: 'Pagination support',
        migration: 'Add page and limit query parameters',
      },
    ],
  },
];

app.get('/migrations/:from/:to', (req, res) => {
  const guide = migrationGuides.find(
    (g) => g.fromVersion === req.params.from && g.toVersion === req.params.to
  );

  if (!guide) {
    return res.status(404).json({ error: 'Migration guide not found' });
  }

  res.json(guide);
});
```

## 版本生命周期

```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│   开发中    │   当前版本   │   旧版本    │   已废弃    │
│  (Draft)    │  (Current)  │  (Legacy)   │  (Sunset)   │
├─────────────┼─────────────┼─────────────┼─────────────┤
│  测试阶段   │  主要版本   │  维护模式   │  6个月过渡  │
│  无SLA     │  完全支持   │  安全修复   │  迁移警告   │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

## 快速参考

```typescript
// URL 版本
app.use('/v1', v1Router);
app.use('/v2', v2Router);

// Header 版本
const version = req.headers['x-api-version'];

// 废弃警告
res.setHeader('Deprecation', 'true');
res.setHeader('Sunset', 'Sat, 31 Dec 2024 00:00:00 GMT');

// 版本路由
@Version('1')
@Version('2')
```

## 参考

- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines/blob/vNext/Guidelines.md#12-versioning)
- [NestJS Versioning](https://docs.nestjs.com/techniques/versioning)
- [API Versioning Best Practices](https://www.postman.com/api-platform/api-versioning/)
- [HTTP Deprecation Header](https://datatracker.ietf.org/doc/html/draft-dalal-deprecation-header)
