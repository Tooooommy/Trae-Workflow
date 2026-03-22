---
name: validation-patterns
description: 数据验证模式 - 输入验证、类型安全、错误处理最佳实践
---

# 数据验证模式

> 输入验证、类型安全、错误处理的最佳实践

## 何时激活

- 实现 API 输入验证
- 表单数据验证
- 配置文件验证
- 数据库模型验证
- 外部 API 响应验证

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Zod | 3.0+ | 最新 |
| Joi | 17.0+ | 最新 |
| Yup | 1.0+ | 最新 |
| class-validator | 0.14+ | 最新 |

## 验证库对比

| 库 | 特点 | 适用场景 |
|------|------|----------|
| Zod | TypeScript 优先、类型推断 | 现代 TS 项目 |
| Joi | 功能丰富、生态成熟 | Node.js 项目 |
| Yup | 前端友好、异步验证 | React 表单 |
| class-validator | 装饰器风格 | NestJS/TypeORM |

## Zod 验证

### 基础 Schema

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  email: z.string().email('Invalid email format'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Must contain uppercase letter')
    .regex(/[0-9]/, 'Must contain number'),
  name: z.string().min(2).max(100).optional(),
  age: z.number().int().min(0).max(150).optional(),
  role: z.enum(['admin', 'user', 'guest']).default('user'),
  metadata: z.record(z.unknown()).optional(),
});

type User = z.infer<typeof UserSchema>;
```

### 自定义验证

```typescript
const PasswordSchema = z.string()
  .min(8)
  .refine(
    (val) => /[A-Z]/.test(val),
    { message: 'Must contain uppercase letter' }
  )
  .refine(
    (val) => /[a-z]/.test(val),
    { message: 'Must contain lowercase letter' }
  )
  .refine(
    (val) => /[0-9]/.test(val),
    { message: 'Must contain number' }
  )
  .refine(
    (val) => /[!@#$%^&*]/.test(val),
    { message: 'Must contain special character' }
  );

const DateSchema = z.string().refine(
  (val) => !isNaN(Date.parse(val)),
  { message: 'Invalid date format' }
).transform((val) => new Date(val));
```

### 异步验证

```typescript
const EmailSchema = z.string().email().refine(
  async (email) => {
    const exists = await checkEmailExists(email);
    return !exists;
  },
  { message: 'Email already registered' }
);

async function validateAsync<T>(schema: z.ZodSchema<T>, data: unknown): Promise<T> {
  return schema.parseAsync(data);
}
```

### 组合 Schema

```typescript
const AddressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string(),
  postalCode: z.string(),
});

const PersonSchema = z.object({
  name: z.string(),
  addresses: z.array(AddressSchema),
});

const EmployeeSchema = PersonSchema.extend({
  employeeId: z.string(),
  department: z.string(),
});

const MergeSchema = z.object({
  id: z.string(),
}).merge(UserSchema);
```

## Express 中间件

```typescript
import { Request, Response, NextFunction } from 'express';

function validateBody<T>(schema: z.ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    
    if (!result.success) {
      const errors = result.error.issues.map((issue) => ({
        path: issue.path.join('.'),
        message: issue.message,
      }));
      
      return res.status(400).json({
        error: 'Validation failed',
        details: errors,
      });
    }
    
    req.body = result.data;
    next();
  };
}

function validateQuery<T>(schema: z.ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.query);
    
    if (!result.success) {
      return res.status(400).json({
        error: 'Invalid query parameters',
        details: result.error.issues,
      });
    }
    
    req.query = result.data as any;
    next();
  };
}

app.post('/users', 
  validateBody(UserSchema),
  async (req: Request, res: Response) => {
    const user = await createUser(req.body);
    res.json(user);
  }
);
```

## NestJS 验证

```typescript
import { IsEmail, IsString, MinLength, validate } from 'class-validator';

class CreateUserDto {
  @IsString()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;
}

@Post('users')
async create(@Body() createUserDto: CreateUserDto) {
  const errors = await validate(createUserDto);
  if (errors.length > 0) {
    throw new BadRequestException(errors);
  }
  return this.userService.create(createUserDto);
}
```

## 验证规则分类

| 类别 | 验证项 | 示例 |
|------|--------|------|
| 格式 | Email, URL, UUID | `z.string().email()` |
| 长度 | Min, Max | `z.string().min(2).max(100)` |
| 数值 | Int, Positive, Range | `z.number().int().positive()` |
| 枚举 | Enum | `z.enum(['a', 'b'])` |
| 日期 | Date, DateTime | `z.date()` |
| 嵌套 | Object, Array | `z.object({}).array()` |

## 错误消息定制

```typescript
const customErrorMap: z.ZodErrorMap = (issue, ctx) => {
  if (issue.code === z.ZodIssueCode.invalid_type) {
    if (issue.expected === 'string') {
      return { message: 'Expected string, received ' + issue.received };
    }
  }
  
  if (issue.code === z.ZodIssueCode.too_small) {
    return { message: `Minimum length is ${issue.minimum}` };
  }
  
  return { message: ctx.defaultError };
};

z.setErrorMap(customErrorMap);
```

## 数据转换

```typescript
const schema = z.object({
  id: z.string().transform((val) => parseInt(val, 10)),
  email: z.string().email().transform((val) => val.toLowerCase()),
  tags: z.string().transform((val) => val.split(',').map((s) => s.trim())),
  createdAt: z.string().transform((val) => new Date(val)),
});

const result = schema.parse({
  id: '123',
  email: 'TEST@EXAMPLE.COM',
  tags: 'a, b, c',
  createdAt: '2024-01-01',
});
```

## 快速参考

```typescript
// 基础类型
z.string().min(1).max(100)
z.number().int().positive()
z.boolean()
z.date()
z.null()
z.undefined()
z.nullable(z.string())
z.optional(z.string())

// 复杂类型
z.object({ name: z.string() })
z.array(z.string()).min(1).max(10)
z.record(z.string(), z.number())
z.tuple([z.string(), z.number()])

// 验证
schema.parse(data)           // 抛出错误
schema.safeParse(data)       // 返回结果
schema.parseAsync(data)      // 异步验证

// 类型推断
type User = z.infer<typeof UserSchema>
```

## 参考

- [Zod Docs](https://zod.dev/)
- [Joi API](https://joi.dev/api/)
- [Yup Docs](https://github.com/jquense/yup)
- [class-validator](https://github.com/typestack/class-validator)
