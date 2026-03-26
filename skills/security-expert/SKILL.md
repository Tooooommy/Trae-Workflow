---
name: security-expert
description: 安全专家模式。根据安全检查清单和安全最佳实践，生成安全代码和处理敏感数据。集成身份验证、授权、输入验证、密钥管理等安全功能。当需要进行身份验证、处理用户输入、管理密钥、创建API、处理支付或存储敏感数据时使用此Skill。
---

# 安全专家模式

根据 PRD 和安全需求文档，生成安全代码、处理敏感数据、实施安全控制。

## 何时激活

- 实现身份验证或授权
- 处理用户输入或文件上传
- 创建新的 API 端点
- 处理密钥或凭据
- 实现支付功能
- 存储或传输敏感数据
- 集成第三方 API

## 核心职责

1. **安全评估** - 识别潜在安全风险
2. **代码生成** - 生成安全的代码模板
3. **密钥管理** - 实施安全的密钥管理方案
4. **输入验证** - 实施严格的输入验证
5. **漏洞修复** - 修复已知安全漏洞

## 输入要求

### PRD 安全需求

```markdown
## 安全需求

- 用户认证采用 JWT
- 密码加密存储
- API 需要限流保护
- 敏感数据加密传输

## 合规要求

- GDPR 数据保护
- 用户数据加密存储
```

### 安全检查清单

| 检查项       | 说明               |
| ------------ | ------------------ |
| OWASP Top 10 | Web 应用安全标准   |
| 密钥管理     | 无硬编码、环境变量 |
| 输入验证     | Zod schema 验证    |
| SQL 注入     | 参数化查询         |
| XSS 防护     | HTML 清理、CSP     |
| CSRF 防护    | Token 验证         |
| 速率限制     | API 限流           |
| 敏感数据     | 日志脱敏、错误信息 |

## 输出产物

### 安全中间件模板

```typescript
// middleware/security.ts
import { helmet } from 'helmet';
import { csrf } from '@/lib/csrf';
import { rateLimit } from '@/lib/rate-limit';

export const securityMiddleware = [
  helmet(),
  csrf(),
  rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }),
];
```

### 身份验证模板

```typescript
// services/auth.service.ts
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET!;
const SALT_ROUNDS = 12;

export class AuthService {
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
  }

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  generateToken(userId: string, role: string): string {
    return jwt.sign({ userId, role }, JWT_SECRET, { expiresIn: '24h' });
  }

  verifyToken(token: string): { userId: string; role: string } {
    return jwt.verify(token, JWT_SECRET) as { userId: string; role: string };
  }
}

export const authService = new AuthService();
```

### 输入验证模板

```typescript
// validation/schemas.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  password: z.string().min(8).regex(/[A-Z]/).regex(/[0-9]/),
});

export const UpdateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  avatar: z.string().url().optional(),
});

export const IdParamSchema = z.object({
  id: z.string().uuid(),
});

export type CreateUserDto = z.infer<typeof CreateUserSchema>;
export type UpdateUserDto = z.infer<typeof UpdateUserSchema>;
```

### 文件上传验证

```typescript
// validation/file.ts
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/gif'];
const MAX_SIZE = 5 * 1024 * 1024;
const ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.gif'];

export function validateFileUpload(file: { name: string; size: number; type: string }) {
  if (file.size > MAX_SIZE) {
    throw new Error('File too large (max 5MB)');
  }

  if (!ALLOWED_TYPES.includes(file.type)) {
    throw new Error('Invalid file type');
  }

  const extension = file.name.toLowerCase().match(/\.[^.]+$/)?.[0];
  if (!extension || !ALLOWED_EXTENSIONS.includes(extension)) {
    throw new Error('Invalid file extension');
  }

  return true;
}
```

### SQL 注入防护

```typescript
// DANGEROUS - SQL Injection
// const query = `SELECT * FROM users WHERE email = '${email}'`;

// SAFE - Parameterized Query
const { data } = await supabase.from('users').select('*').eq('email', email);

await db.query('SELECT * FROM users WHERE email = $1', [email]);
```

### XSS 防护

```typescript
// lib/sanitize.ts
import DOMPurify from 'isomorphic-dompurify';

export function sanitizeHtml(html: string): string {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br'],
    ALLOWED_ATTR: [],
  });
}

// next.config.js - CSP Headers
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: `
      default-src 'self';
      script-src 'self' 'unsafe-eval' 'unsafe-inline';
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      connect-src 'self' https://api.example.com;
    `
      .replace(/\s{2,}/g, ' ')
      .trim(),
  },
];
```

### CSRF 防护

```typescript
// lib/csrf.ts
import { randomBytes } from 'crypto';

export function generateCsrfToken(): string {
  return randomBytes(32).toString('hex');
}

export function verifyCsrfToken(token: string, sessionToken: string): boolean {
  return token === sessionToken;
}

// Cookie 设置
res.setHeader('Set-Cookie', [
  `session=${sessionId}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600`,
  `csrf=${csrfToken}; Secure; SameSite=Strict`,
]);
```

### 速率限制

```typescript
// lib/rate-limit.ts
import rateLimit from 'express-rate-limit';

export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests',
});

export const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 5,
  message: 'Too many authentication attempts',
});

export const searchLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  message: 'Too many search requests',
});
```

### 安全日志模板

```typescript
// DANGEROUS - 泄露敏感信息
// console.log('Login:', { email, password });

// SAFE - 日志脱敏
console.log('User login:', {
  email: email.replace(/(.{2}).*(@.*)/, '$1***$2'),
  userId,
  timestamp: new Date().toISOString(),
});
```

### 错误处理模板

```typescript
// DANGEROUS - 暴露内部信息
// return { error: error.message, stack: error.stack };

// SAFE - 通用错误消息
catch (error) {
  console.error('Internal error:', error);
  return {
    error: 'An error occurred. Please try again.',
    code: 'INTERNAL_ERROR',
  };
}
```

## 安全检查清单

### 部署前检查

- [ ] 无硬编码 API 密钥
- [ ] 所有输入已验证
- [ ] 参数化 SQL 查询
- [ ] HTML 内容已清理
- [ ] CSRF 防护已启用
- [ ] JWT 存储在 httpOnly Cookie
- [ ] API 限流已配置
- [ ] 安全 Headers 已设置

### 依赖项检查

```bash
npm audit
npm audit fix
```

## 技术栈版本

| 技术         | 最低版本 | 推荐版本 |
| ------------ | -------- | -------- |
| OWASP Top 10 | 2021     | 最新     |
| Zod          | 3.22+    | 最新     |
| helmet       | 7.0+     | 最新     |
| bcrypt       | 5.0+     | 最新     |
| jsonwebtoken | 9.0+     | 最新     |
| DOMPurify    | 3.0+     | 最新     |

## 质量门禁

| 检查项      | 阈值   |
| ----------- | ------ |
| 漏洞扫描    | 0 高危 |
| npm audit   | 0 高危 |
| lint / type | 100%   |

## 子技能映射

| 类型     | 调用 Skill        | 触发关键词               |
| -------- | ----------------- | ------------------------ |
| 前端安全 | `frontend-expert` | XSS, CSP, 前端安全       |
| 后端安全 | `backend-expert`  | 身份验证, 授权, API 安全 |
| 密钥管理 | `security-expert` | 密钥, 凭据, 环境变量     |
| 渗透测试 | `security-expert` | 渗透测试, 漏洞扫描       |

## 附加内容

### 区块链安全（Solana）

#### 钱包验证

```typescript
import { verify } from '@solana/web3.js';

async function verifyWalletOwnership(publicKey: string, signature: string, message: string) {
  try {
    const isValid = verify(
      Buffer.from(message),
      Buffer.from(signature, 'base64'),
      Buffer.from(publicKey, 'base64')
    );
    return isValid;
  } catch (error) {
    return false;
  }
}
```

#### 交易验证

```typescript
async function verifyTransaction(transaction: Transaction) {
  if (transaction.to !== expectedRecipient) {
    throw new Error('Invalid recipient');
  }

  if (transaction.amount > maxAmount) {
    throw new Error('Amount exceeds limit');
  }

  const balance = await getBalance(transaction.from);
  if (balance < transaction.amount) {
    throw new Error('Insufficient balance');
  }

  return true;
}
```

#### 验证检查清单

- [ ] 已验证钱包签名
- [ ] 已验证交易详情
- [ ] 交易前检查余额
- [ ] 没有盲签名交易

### 依赖项安全

#### 定期更新

```bash
# Check for vulnerabilities
npm audit

# Fix automatically fixable issues
npm audit fix

# Update dependencies
npm update

# Check for outdated packages
npm outdated
```

#### 锁定文件

```bash
# ALWAYS commit lock files
git add package-lock.json

# Use in CI/CD for reproducible builds
npm ci
```

#### 检查清单

- [ ] 依赖项是最新的
- [ ] 没有已知漏洞（npm audit 检查通过）
- [ ] 提交了锁定文件
- [ ] GitHub 上启用了 Dependabot
- [ ] 定期进行安全更新

### 安全测试

#### 自动化安全测试

```typescript
test('requires authentication', async () => {
  const response = await fetch('/api/protected');
  expect(response.status).toBe(401);
});

test('requires admin role', async () => {
  const response = await fetch('/api/admin', {
    headers: { Authorization: `Bearer ${userToken}` },
  });
  expect(response.status).toBe(403);
});

test('rejects invalid input', async () => {
  const response = await fetch('/api/users', {
    method: 'POST',
    body: JSON.stringify({ email: 'not-an-email' }),
  });
  expect(response.status).toBe(400);
});

test('enforces rate limits', async () => {
  const requests = Array(101)
    .fill(null)
    .map(() => fetch('/api/resource'));
  const responses = await Promise.all(requests);
  expect(responses.filter((r) => r.status === 429).length).toBeGreaterThan(0);
});
```
