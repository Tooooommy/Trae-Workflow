---
alwaysApply: false
globs:
  - '**/*.ts'
  - '**/*.tsx'
  - '**/*.js'
  - '**/*.jsx'
---

# TypeScript/JavaScript 安全

> TypeScript/JavaScript 语言特定的安全最佳实践。

## 密钥管理

```typescript
// NEVER: Hardcoded secrets
const apiKey = 'sk-proj-xxxxx';

// ALWAYS: Environment variables
const apiKey = process.env.OPENAI_API_KEY;

if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured');
}
```

## 输入验证

使用 Zod 进行输入验证：

```typescript
import { z } from 'zod';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

const validated = schema.parse(input);
```

## 相关智能体

- `security-reviewer` - 安全漏洞检测

## 相关技能

- `security-review` - 安全检查清单
- `validation-patterns` - 数据验证模式
