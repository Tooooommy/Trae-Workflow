---
name: cqrs-patterns
description: CQRS 命令查询职责分离 - 读写分离、事件溯源最佳实践。**必须激活当**：用户要求实现 CQRS 模式、设计读写分离或构建事件溯源系统时。即使用户没有明确说"CQRS"，当涉及命令查询分离或事件溯源时也应使用。
---

# CQRS 模式

> 命令查询职责分离 - 读写分离、事件溯源的最佳实践

## 何时激活

- 高读写比例系统
- 复杂业务逻辑
- 需要审计追踪
- 事件驱动架构
- 微服务拆分

## 技术栈版本

| 技术           | 最低版本 | 推荐版本 |
| -------------- | -------- | -------- |
| EventStore     | 21.0+    | 最新     |
| Axon Framework | 4.0+     | 最新     |
| MediatR        | 12.0+    | 最新     |
| NestJS CQRS    | 10.0+    | 最新     |

## CQRS 核心概念

```
┌─────────────────────────────────────────────────────────────┐
│                        CQRS 架构                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     ┌─────────────┐                      │
│   │   Command   │     │   Query     │                      │
│   │   (写操作)   │     │   (读操作)   │                      │
│   └──────┬──────┘     └──────┬──────┘                      │
│          │                   │                              │
│          ▼                   ▼                              │
│   ┌─────────────┐     ┌─────────────┐                      │
│   │  Command    │     │   Query     │                      │
│   │  Handler    │     │   Handler   │                      │
│   └──────┬──────┘     └──────┬──────┘                      │
│          │                   │                              │
│          ▼                   ▼                              │
│   ┌─────────────┐     ┌─────────────┐                      │
│   │  Write DB   │────>│   Read DB   │                      │
│   │  (主数据库)  │     │  (读副本)    │                      │
│   └─────────────┘     └─────────────┘                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Command 实现

```typescript
interface Command {
  type: string;
  payload: unknown;
  timestamp: Date;
  correlationId: string;
}

interface CommandHandler<T extends Command> {
  handle(command: T): Promise<void>;
}

class CreateUserCommand implements Command {
  type = 'CREATE_USER';
  constructor(
    public payload: { email: string; name: string },
    public timestamp = new Date(),
    public correlationId = crypto.randomUUID()
  ) {}
}

class CreateUserHandler implements CommandHandler<CreateUserCommand> {
  constructor(
    private userRepository: UserRepository,
    private eventBus: EventBus
  ) {}

  async handle(command: CreateUserCommand): Promise<void> {
    const { email, name } = command.payload;

    const user = await this.userRepository.create({ email, name });

    await this.eventBus.publish(new UserCreatedEvent(user, command.correlationId));
  }
}
```

## Query 实现

```typescript
interface Query<T> {
  type: string;
  payload: unknown;
}

interface QueryHandler<TQuery extends Query<TResult>, TResult> {
  handle(query: TQuery): Promise<TResult>;
}

class GetUserQuery implements Query<User> {
  type = 'GET_USER';
  constructor(public payload: { id: string }) {}
}

class GetUserHandler implements QueryHandler<GetUserQuery, User> {
  constructor(private readRepository: UserReadRepository) {}

  async handle(query: GetUserQuery): Promise<User> {
    return this.readRepository.findById(query.payload.id);
  }
}
```

## Command Bus

```typescript
class CommandBus {
  private handlers = new Map<string, CommandHandler<any>>();

  register<T extends Command>(type: string, handler: CommandHandler<T>) {
    this.handlers.set(type, handler);
  }

  async dispatch<T extends Command>(command: T): Promise<void> {
    const handler = this.handlers.get(command.type);

    if (!handler) {
      throw new Error(`No handler for command: ${command.type}`);
    }

    await handler.handle(command);
  }
}
```

## Query Bus

```typescript
class QueryBus {
  private handlers = new Map<string, QueryHandler<any, any>>();

  register<TQuery extends Query<TResult>, TResult>(
    type: string,
    handler: QueryHandler<TQuery, TResult>
  ) {
    this.handlers.set(type, handler);
  }

  async execute<TQuery extends Query<TResult>, TResult>(query: TQuery): Promise<TResult> {
    const handler = this.handlers.get(query.type);

    if (!handler) {
      throw new Error(`No handler for query: ${query.type}`);
    }

    return handler.handle(query);
  }
}
```

## 事件溯源

```typescript
interface Event {
  type: string;
  aggregateId: string;
  payload: unknown;
  version: number;
  timestamp: Date;
}

class EventStore {
  constructor(private db: Database) {}

  async append(aggregateId: string, events: Event[]): Promise<void> {
    for (const event of events) {
      await this.db.insert('events', event);
    }
  }

  async getEvents(aggregateId: string): Promise<Event[]> {
    return this.db.query('SELECT * FROM events WHERE aggregateId = ? ORDER BY version', [
      aggregateId,
    ]);
  }
}

abstract class AggregateRoot {
  private uncommittedEvents: Event[] = [];
  protected version = 0;

  protected apply(event: Event): void {
    this.handle(event);
    this.version++;
    this.uncommittedEvents.push({ ...event, version: this.version });
  }

  abstract handle(event: Event): void;

  getUncommittedEvents(): Event[] {
    return this.uncommittedEvents;
  }

  markEventsAsCommitted(): void {
    this.uncommittedEvents = [];
  }

  loadFromHistory(events: Event[]): void {
    for (const event of events) {
      this.handle(event);
      this.version = event.version;
    }
  }
}
```

## 聚合示例

```typescript
class User extends AggregateRoot {
  private id: string;
  private email: string;
  private name: string;
  private active = true;

  static create(id: string, email: string, name: string): User {
    const user = new User();
    user.apply({
      type: 'USER_CREATED',
      aggregateId: id,
      payload: { email, name },
      timestamp: new Date(),
    } as Event);
    return user;
  }

  updateName(name: string): void {
    this.apply({
      type: 'USER_NAME_UPDATED',
      aggregateId: this.id,
      payload: { name },
      timestamp: new Date(),
    } as Event);
  }

  deactivate(): void {
    this.apply({
      type: 'USER_DEACTIVATED',
      aggregateId: this.id,
      payload: {},
      timestamp: new Date(),
    } as Event);
  }

  handle(event: Event): void {
    switch (event.type) {
      case 'USER_CREATED':
        this.id = event.aggregateId;
        this.email = event.payload.email;
        this.name = event.payload.name;
        break;
      case 'USER_NAME_UPDATED':
        this.name = event.payload.name;
        break;
      case 'USER_DEACTIVATED':
        this.active = false;
        break;
    }
  }
}
```

## 读写模型分离

```typescript
class UserReadModel {
  constructor(private db: Database) {}

  async findById(id: string): Promise<UserDto | null> {
    return this.db.query('SELECT * FROM user_read_model WHERE id = ?', [id]);
  }

  async findByEmail(email: string): Promise<UserDto | null> {
    return this.db.query('SELECT * FROM user_read_model WHERE email = ?', [email]);
  }

  async search(query: string): Promise<UserDto[]> {
    return this.db.query('SELECT * FROM user_read_model WHERE name LIKE ? OR email LIKE ?', [
      `%${query}%`,
      `%${query}%`,
    ]);
  }
}

class UserProjector {
  constructor(private readModel: UserReadModel) {}

  async onUserCreated(event: UserCreatedEvent): Promise<void> {
    await this.readModel.insert({
      id: event.aggregateId,
      email: event.payload.email,
      name: event.payload.name,
      active: true,
    });
  }

  async onUserNameUpdated(event: UserNameUpdatedEvent): Promise<void> {
    await this.readModel.update(event.aggregateId, {
      name: event.payload.name,
    });
  }
}
```

## 优缺点

| 优点             | 缺点         |
| ---------------- | ------------ |
| 读写独立优化     | 复杂度增加   |
| 更好的扩展性     | 最终一致性   |
| 清晰的关注点分离 | 学习曲线陡峭 |
| 完整的审计追踪   | 需要事件存储 |

## 快速参考

```typescript
// 发送命令
await commandBus.dispatch(new CreateUserCommand({ email, name }));

// 执行查询
const user = await queryBus.execute(new GetUserQuery({ id }));

// 应用事件
aggregate.apply(event);

// 加载历史
aggregate.loadFromHistory(events);
```

## 参考

- [Martin Fowler - CQRS](https://martinfowler.com/bliki/CQRS.html)
- [Event Store](https://www.eventstore.com/)
- [NestJS CQRS](https://docs.nestjs.com/recipes/cqrs)
- [Axon Framework](https://docs.axoniq.io/reference-guide/)
