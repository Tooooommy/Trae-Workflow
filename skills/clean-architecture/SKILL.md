---
name: clean-architecture
description: 整洁架构 - 分层设计、依赖倒置、可测试性最佳实践。**必须激活当**：用户要求设计系统架构、创建分层结构、实现依赖注入或提高代码可测试性时。即使用户没有明确说"整洁架构"，当涉及软件架构、分层设计或依赖倒置时也应使用。
---

# 整洁架构

> 分层设计、依赖倒置、框架无关的最佳实践

## 何时激活

- 新项目架构设计
- 重构遗留系统
- 提高可测试性
- 解耦业务逻辑
- 多框架兼容

> **注意**：此技能为架构方法论，适用于任何编程语言和框架。

## 架构层次

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                   实体层 (Entities)                  │   │
│   │              业务核心规则和数据结构                   │   │
│   └─────────────────────────────────────────────────────┘   │
│                           ▲                                 │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                 用例层 (Use Cases)                   │   │
│   │              应用特定业务规则                        │   │
│   └─────────────────────────────────────────────────────┘   │
│                           ▲                                 │
│   ┌─────────────────────────────────────────────────────┐   │
│   │             接口适配层 (Interface Adapters)          │   │
│   │           控制器、网关、转换器                       │   │
│   └─────────────────────────────────────────────────────┘   │
│                           ▲                                 │
│   ┌─────────────────────────────────────────────────────┐   │
│   │            框架与驱动层 (Frameworks & Drivers)       │   │
│   │        Web框架、数据库、外部服务                      │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

依赖方向：外层 → 内层（依赖倒置）
```

## 实体层

```typescript
namespace Domain {
  export interface User {
    id: string;
    email: string;
    name: string;
    createdAt: Date;
  }

  export interface UserRepository {
    findById(id: string): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    save(user: User): Promise<void>;
    delete(id: string): Promise<void>;
  }

  export class UserEntity implements User {
    constructor(
      public readonly id: string,
      public email: string,
      public name: string,
      public readonly createdAt: Date = new Date()
    ) {}

    updateEmail(email: string): void {
      if (!this.isValidEmail(email)) {
        throw new Error('Invalid email format');
      }
      this.email = email;
    }

    private isValidEmail(email: string): boolean {
      return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }
  }
}
```

## 用例层

```typescript
namespace UseCases {
  export interface CreateUserInput {
    email: string;
    name: string;
  }

  export interface CreateUserOutput {
    id: string;
    email: string;
    name: string;
  }

  export interface CreateUserUseCase {
    execute(input: CreateUserInput): Promise<CreateUserOutput>;
  }

  export class CreateUser implements CreateUserUseCase {
    constructor(private userRepository: Domain.UserRepository) {}

    async execute(input: CreateUserInput): Promise<CreateUserOutput> {
      const existingUser = await this.userRepository.findByEmail(input.email);
      if (existingUser) {
        throw new Error('User already exists');
      }

      const user = new Domain.UserEntity(crypto.randomUUID(), input.email, input.name);

      await this.userRepository.save(user);

      return {
        id: user.id,
        email: user.email,
        name: user.name,
      };
    }
  }

  export class GetUser {
    constructor(private userRepository: Domain.UserRepository) {}

    async execute(id: string): Promise<Domain.User | null> {
      return this.userRepository.findById(id);
    }
  }

  export class UpdateUserEmail {
    constructor(private userRepository: Domain.UserRepository) {}

    async execute(id: string, email: string): Promise<void> {
      const user = await this.userRepository.findById(id);
      if (!user) {
        throw new Error('User not found');
      }

      const entity = new Domain.UserEntity(user.id, user.email, user.name, user.createdAt);
      entity.updateEmail(email);

      await this.userRepository.save(entity);
    }
  }
}
```

## 接口适配层

```typescript
namespace Adapters {
  export interface Controller {
    handle(request: any): Promise<Response>;
  }

  export interface Response {
    statusCode: number;
    body: any;
  }

  export class CreateUserController implements Controller {
    constructor(private createUserUseCase: UseCases.CreateUserUseCase) {}

    async handle(request: { body: UseCases.CreateUserInput }): Promise<Response> {
      try {
        const result = await this.createUserUseCase.execute(request.body);
        return { statusCode: 201, body: result };
      } catch (error) {
        return { statusCode: 400, body: { error: error.message } };
      }
    }
  }

  export class GetUserController implements Controller {
    constructor(private getUserUseCase: UseCases.GetUser) {}

    async handle(request: { params: { id: string } }): Promise<Response> {
      const user = await this.getUserUseCase.execute(request.params.id);

      if (!user) {
        return { statusCode: 404, body: { error: 'User not found' } };
      }

      return { statusCode: 200, body: user };
    }
  }

  export class UserPresenter {
    static toResponse(user: Domain.User): any {
      return {
        id: user.id,
        email: user.email,
        name: user.name,
        createdAt: user.createdAt.toISOString(),
      };
    }

    static toListResponse(users: Domain.User[]): any {
      return users.map(this.toResponse);
    }
  }
}
```

## 框架与驱动层

```typescript
namespace Infrastructure {
  import { Pool } from 'pg';

  export class PostgresUserRepository implements Domain.UserRepository {
    constructor(private pool: Pool) {}

    async findById(id: string): Promise<Domain.User | null> {
      const result = await this.pool.query('SELECT * FROM users WHERE id = $1', [id]);

      if (result.rows.length === 0) return null;

      return this.toDomain(result.rows[0]);
    }

    async findByEmail(email: string): Promise<Domain.User | null> {
      const result = await this.pool.query('SELECT * FROM users WHERE email = $1', [email]);

      if (result.rows.length === 0) return null;

      return this.toDomain(result.rows[0]);
    }

    async save(user: Domain.User): Promise<void> {
      await this.pool.query(
        `INSERT INTO users (id, email, name, created_at)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (id) DO UPDATE SET email = $2, name = $3`,
        [user.id, user.email, user.name, user.createdAt]
      );
    }

    async delete(id: string): Promise<void> {
      await this.pool.query('DELETE FROM users WHERE id = $1', [id]);
    }

    private toDomain(row: any): Domain.User {
      return {
        id: row.id,
        email: row.email,
        name: row.name,
        createdAt: row.created_at,
      };
    }
  }
}
```

## 依赖注入

```typescript
import 'reflect-metadata';
import { Container, injectable, inject } from 'inversify';

const TYPES = {
  UserRepository: Symbol('UserRepository'),
  CreateUserUseCase: Symbol('CreateUserUseCase'),
  CreateUserController: Symbol('CreateUserController'),
};

@injectable()
class CreateUserUseCaseImpl implements UseCases.CreateUserUseCase {
  constructor(@inject(TYPES.UserRepository) private userRepository: Domain.UserRepository) {}

  async execute(input: UseCases.CreateUserInput): Promise<UseCases.CreateUserOutput> {
    // Implementation
  }
}

const container = new Container();

container
  .bind<Domain.UserRepository>(TYPES.UserRepository)
  .to(Infrastructure.PostgresUserRepository);

container.bind<UseCases.CreateUserUseCase>(TYPES.CreateUserUseCase).to(CreateUserUseCaseImpl);

export { container };
```

## Express 集成

```typescript
import express from 'express';

const app = express();
app.use(express.json());

app.post('/users', async (req, res) => {
  const controller = container.get<Adapters.Controller>(TYPES.CreateUserController);
  const response = await controller.handle({ body: req.body });
  res.status(response.statusCode).json(response.body);
});

app.get('/users/:id', async (req, res) => {
  const controller = container.get<Adapters.GetUser>(TYPES.GetUserUseCase);
  const user = await controller.execute(req.params.id);
  res.json(Adapters.UserPresenter.toResponse(user));
});
```

## 测试策略

```typescript
class MockUserRepository implements Domain.UserRepository {
  private users = new Map<string, Domain.User>();

  async findById(id: string): Promise<Domain.User | null> {
    return this.users.get(id) || null;
  }

  async save(user: Domain.User): Promise<void> {
    this.users.set(user.id, user);
  }

  async delete(id: string): Promise<void> {
    this.users.delete(id);
  }
}

describe('CreateUser Use Case', () => {
  let useCase: UseCases.CreateUserUseCase;
  let mockRepo: MockUserRepository;

  beforeEach(() => {
    mockRepo = new MockUserRepository();
    useCase = new UseCases.CreateUser(mockRepo);
  });

  it('should create a user', async () => {
    const input = { email: 'test@example.com', name: 'Test User' };
    const result = await useCase.execute(input);

    expect(result.email).toBe(input.email);
    expect(result.name).toBe(input.name);
  });

  it('should fail if user exists', async () => {
    await mockRepo.save({
      id: '1',
      email: 'test@example.com',
      name: 'Existing',
      createdAt: new Date(),
    });

    await expect(useCase.execute({ email: 'test@example.com', name: 'Test' })).rejects.toThrow(
      'User already exists'
    );
  });
});
```

## 快速参考

```
实体层：业务核心规则，无外部依赖
用例层：应用业务规则，编排实体
接口适配层：格式转换，控制器
框架层：外部工具，数据库，Web框架

依赖规则：外层依赖内层，内层不知道外层
```

## 参考

- [Clean Architecture (Robert C. Martin)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [The Clean Architecture in TypeScript](https://github.com/stemmlerjs/ddd-forum)
- [InversifyJS](https://inversify.io/)
