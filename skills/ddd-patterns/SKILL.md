---
name: ddd-patterns
description: 领域驱动设计 - 限界上下文、聚合、值对象最佳实践
---

# 领域驱动设计 (DDD)

> 限界上下文、聚合、值对象、领域服务的最佳实践

## 何时激活

- 复杂业务领域建模
- 微服务边界划分
- 业务规则复杂
- 需要通用语言
- 战略设计

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| TypeScript | 5.0+ | 最新 |
| Node.js | 18.0+ | 20.0+ |
| TypeORM | 0.3+ | 最新 |
| Prisma | 5.0+ | 最新 |

## DDD 战略模式

### 限界上下文

```
┌─────────────────────────────────────────────────────────────┐
│                      电商系统                                │
├─────────────────┬─────────────────┬─────────────────────────┤
│    订单上下文    │    库存上下文    │      支付上下文         │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Order           │ Inventory       │ Payment                 │
│ OrderItem       │ Product         │ Transaction             │
│ ShippingAddress │ Warehouse       │ PaymentMethod           │
└─────────────────┴─────────────────┴─────────────────────────┘
         │                  │                   │
         └──────────────────┼───────────────────┘
                           │
                    上下文映射
```

### 上下文映射模式

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| 共享内核 | 共享通用模型 | 通用基础设施 |
| 客户-供应商 | 下游依赖上游 | 服务依赖 |
| 遵奉者 | 下游完全依赖 | 外部系统 |
| 防腐层 | 隔离外部模型 | 遗留系统集成 |
| 开放主机服务 | 标准化接口 | 公开 API |

## 战术模式

### 值对象

```typescript
interface ValueObject<T> {
  equals(other: T): boolean;
}

class Money implements ValueObject<Money> {
  constructor(
    public readonly amount: number,
    public readonly currency: string
  ) {
    if (amount < 0) throw new Error('Amount cannot be negative');
    if (!currency) throw new Error('Currency is required');
  }

  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }

  add(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new Error('Cannot add different currencies');
    }
    return new Money(this.amount + other.amount, this.currency);
  }

  multiply(factor: number): Money {
    return new Money(this.amount * factor, this.currency);
  }
}

class Email implements ValueObject<Email> {
  private static readonly EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  constructor(public readonly value: string) {
    if (!Email.EMAIL_REGEX.test(value)) {
      throw new Error('Invalid email format');
    }
  }

  equals(other: Email): boolean {
    return this.value === other.value;
  }
}

class Address implements ValueObject<Address> {
  constructor(
    public readonly street: string,
    public readonly city: string,
    public readonly country: string,
    public readonly postalCode: string
  ) {}

  equals(other: Address): boolean {
    return (
      this.street === other.street &&
      this.city === other.city &&
      this.country === other.country &&
      this.postalCode === other.postalCode
    );
  }
}
```

### 实体

```typescript
abstract class Entity<T> {
  constructor(protected readonly id: T) {}

  equals(other: Entity<T>): boolean {
    return this.id === other.id;
  }
}

class User extends Entity<string> {
  private email: Email;
  private name: string;
  private address?: Address;

  constructor(id: string, email: Email, name: string) {
    super(id);
    this.email = email;
    this.name = name;
  }

  updateEmail(email: Email): void {
    this.email = email;
  }

  updateAddress(address: Address): void {
    this.address = address;
  }
}
```

### 聚合

```typescript
class OrderItem {
  constructor(
    public readonly productId: string,
    public readonly productName: string,
    private quantity: number,
    private price: Money
  ) {
    if (quantity <= 0) throw new Error('Quantity must be positive');
  }

  get total(): Money {
    return this.price.multiply(this.quantity);
  }

  updateQuantity(quantity: number): void {
    if (quantity <= 0) throw new Error('Quantity must be positive');
    this.quantity = quantity;
  }
}

class Order extends Entity<string> {
  private items: OrderItem[] = [];
  private status: OrderStatus = OrderStatus.PENDING;
  private createdAt: Date;

  constructor(id: string, private readonly customerId: string) {
    super(id);
    this.createdAt = new Date();
  }

  addItem(productId: string, productName: string, quantity: number, price: Money): void {
    if (this.status !== OrderStatus.PENDING) {
      throw new Error('Cannot modify confirmed order');
    }

    const existingItem = this.items.find(item => item.productId === productId);
    if (existingItem) {
      existingItem.updateQuantity(existingItem.quantity + quantity);
    } else {
      this.items.push(new OrderItem(productId, productName, quantity, price));
    }
  }

  removeItem(productId: string): void {
    if (this.status !== OrderStatus.PENDING) {
      throw new Error('Cannot modify confirmed order');
    }
    this.items = this.items.filter(item => item.productId !== productId);
  }

  get total(): Money {
    return this.items.reduce(
      (sum, item) => sum.add(item.total),
      new Money(0, 'USD')
    );
  }

  confirm(): void {
    if (this.items.length === 0) {
      throw new Error('Cannot confirm empty order');
    }
    this.status = OrderStatus.CONFIRMED;
  }
}

enum OrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  SHIPPED = 'SHIPPED',
  DELIVERED = 'DELIVERED',
}
```

### 领域服务

```typescript
interface TransferService {
  transfer(from: Account, to: Account, amount: Money): void;
}

class BankTransferService implements TransferService {
  transfer(from: Account, to: Account, amount: Money): void {
    if (!from.canWithdraw(amount)) {
      throw new Error('Insufficient funds');
    }

    from.withdraw(amount);
    to.deposit(amount);
  }
}

class PricingService {
  calculateDiscount(order: Order, customer: Customer): Money {
    let discount = new Money(0, 'USD');

    if (customer.isVIP) {
      discount = discount.add(order.total.multiply(0.1));
    }

    if (order.items.length > 5) {
      discount = discount.add(order.total.multiply(0.05));
    }

    return discount;
  }
}
```

### 领域事件

```typescript
interface DomainEvent {
  occurredAt: Date;
  eventType: string;
}

class OrderConfirmedEvent implements DomainEvent {
  occurredAt: Date;
  eventType = 'ORDER_CONFIRMED';

  constructor(public readonly orderId: string, public readonly total: Money) {
    this.occurredAt = new Date();
  }
}

class DomainEvents {
  private static events: DomainEvent[] = [];

  static raise(event: DomainEvent): void {
    this.events.push(event);
  }

  static dispatchAll(): DomainEvent[] {
    const events = [...this.events];
    this.events = [];
    return events;
  }
}
```

### 仓储

```typescript
interface Repository<T extends Entity<string>> {
  findById(id: string): Promise<T | null>;
  save(entity: T): Promise<void>;
  delete(entity: T): Promise<void>;
}

interface OrderRepository extends Repository<Order> {
  findByCustomerId(customerId: string): Promise<Order[]>;
  findPending(): Promise<Order[]>;
}

class OrderRepositoryImpl implements OrderRepository {
  constructor(private db: Database) {}

  async findById(id: string): Promise<Order | null> {
    const data = await this.db.query('SELECT * FROM orders WHERE id = ?', [id]);
    if (!data) return null;
    return this.toDomain(data);
  }

  async save(order: Order): Promise<void> {
    await this.db.upsert('orders', this.toData(order));
  }

  async delete(order: Order): Promise<void> {
    await this.db.delete('orders', order.id);
  }

  private toDomain(data: any): Order {
    // Reconstruct domain object from data
  }

  private toData(order: Order): any {
    // Convert domain object to data
  }
}
```

## 分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                     表现层 (Presentation)                    │
│                   Controllers, DTOs, Views                   │
├─────────────────────────────────────────────────────────────┤
│                     应用层 (Application)                     │
│              Application Services, Use Cases                 │
├─────────────────────────────────────────────────────────────┤
│                     领域层 (Domain)                          │
│         Entities, Value Objects, Aggregates, Services        │
├─────────────────────────────────────────────────────────────┤
│                     基础设施层 (Infrastructure)               │
│            Repositories, External Services, Persistence      │
└─────────────────────────────────────────────────────────────┘
```

## 快速参考

```typescript
// 值对象
const price = new Money(100, 'USD');

// 实体
const user = new User('user-1', new Email('test@example.com'), 'John');

// 聚合
const order = new Order('order-1', 'customer-1');
order.addItem('product-1', 'Product', 2, new Money(50, 'USD'));

// 领域服务
pricingService.calculateDiscount(order, customer);

// 领域事件
DomainEvents.raise(new OrderConfirmedEvent(order.id, order.total));
```

## 参考

- [Domain-Driven Design (Eric Evans)](https://www.domainlanguage.com/)
- [Implementing DDD (Vaughn Vernon)](https://vaughnvernon.com/)
- [DDD Community](https://www.dddcommunity.org/)
- [Martin Fowler - DDD](https://martinfowler.com/bliki/DomainDrivenDesign.html)
