---
name: authentication-patterns
description: OAuth2/JWT/OIDC 认证授权模式 - 用户身份验证与会话管理最佳实践
---

# 认证授权模式

> 安全可靠的用户身份验证与会话管理方案

## 何时激活

- 实现用户登录/注册功能
- 添加 OAuth 社交登录
- 实现 API 认证保护
- 设计权限控制系统
- 处理会话管理

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| JWT | - | JWT.io 规范 |
| OAuth 2.0 | - | RFC 6749 |
| OIDC | - | OpenID Connect 1.0 |
| bcrypt | 5.0+ | 最新 |
| passport.js | 0.6+ | 最新 |
| jose | 5.0+ | 最新 |

## 核心模式

### 1. JWT 认证流程

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Client    │ -> │   Server    │ -> │   Verify    │
│  (Login)    │    │ (Generate)  │    │   (JWT)     │
└─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │
       │                  ▼                  │
       │         ┌─────────────┐            │
       └────────>│   Access    │<───────────┘
                 │   Token     │
                 └─────────────┘
```

### 2. OAuth 2.0 授权码流程

```
User -> Client -> Auth Server -> User Login/Consent
                                        │
User <- Client <- Auth Server (Code) <-┘
                    │
Client -> Auth Server (Code + Secret)
                    │
Client <- Auth Server (Access Token)
```

### 3. 刷新令牌模式

```typescript
interface TokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  token_type: 'Bearer';
}

async function refreshAccessToken(refreshToken: string): Promise<TokenResponse> {
  const response = await fetch('/oauth/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
    }),
  });
  return response.json();
}
```

## 认证方案对比

| 方案 | 适用场景 | 优点 | 缺点 |
|------|----------|------|------|
| JWT | 无状态 API | 可扩展、自包含 | 无法撤销 |
| Session | 传统 Web | 可控、安全 | 需要存储 |
| OAuth | 社交登录 | 用户体验好 | 依赖第三方 |
| API Key | 服务间调用 | 简单直接 | 权限粒度粗 |

## 安全最佳实践

### 密码存储

```typescript
import { hash, compare } from 'bcrypt';

const SALT_ROUNDS = 12;

async function hashPassword(password: string): Promise<string> {
  return hash(password, SALT_ROUNDS);
}

async function verifyPassword(password: string, hashed: string): Promise<boolean> {
  return compare(password, hashed);
}
```

### JWT 安全配置

```typescript
import { SignJWT, jwtVerify } from 'jose';

const secret = new TextEncoder().encode(process.env.JWT_SECRET);

async function createToken(payload: object) {
  return new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('2h')
    .sign(secret);
}

async function verifyToken(token: string) {
  const { payload } = await jwtVerify(token, secret);
  return payload;
}
```

### 中间件实现

```typescript
function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const payload = verifyToken(token);
    req.user = payload;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

## RBAC 权限模型

```typescript
interface Permission {
  resource: string;
  action: 'create' | 'read' | 'update' | 'delete';
}

interface Role {
  name: string;
  permissions: Permission[];
}

const roles: Record<string, Role> = {
  admin: {
    name: 'admin',
    permissions: [
      { resource: '*', action: 'create' },
      { resource: '*', action: 'read' },
      { resource: '*', action: 'update' },
      { resource: '*', action: 'delete' },
    ],
  },
  user: {
    name: 'user',
    permissions: [
      { resource: 'profile', action: 'read' },
      { resource: 'profile', action: 'update' },
    ],
  },
};

function hasPermission(role: string, resource: string, action: string): boolean {
  return roles[role]?.permissions.some(
    p => (p.resource === '*' || p.resource === resource) && p.action === action
  ) ?? false;
}
```

## 常见安全漏洞防护

| 漏洞 | 防护措施 |
|------|----------|
| 暴力破解 | 速率限制、账户锁定 |
| 会话劫持 | HTTPS、HttpOnly Cookie |
| CSRF | CSRF Token、SameSite Cookie |
| XSS | 输入验证、输出编码 |
| SQL 注入 | 参数化查询 |

## 快速参考

```bash
# 生成密钥
openssl rand -base64 32

# JWT 解码 (调试)
echo "TOKEN" | cut -d. -f2 | base64 -d

# 测试 OAuth 端点
curl -X POST https://auth.example.com/oauth/token \
  -H "Content-Type: application/json" \
  -d '{"grant_type":"client_credentials"}'
```

## 参考

- [OAuth 2.0 RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)
- [OpenID Connect](https://openid.net/connect/)
- [JWT.io](https://jwt.io/)
- [OWASP Auth Cheatsheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
