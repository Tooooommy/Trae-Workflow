---
name: mongodb-patterns
description: MongoDB 文档设计、聚合管道、索引优化和事务处理最佳实践。适用于所有 MongoDB 项目。
---

# MongoDB 开发模式

用于构建高性能、可扩展 MongoDB 应用的模式与最佳实践。

## 何时激活

- 设计 MongoDB 文档结构
- 编写聚合管道查询
- 优化 MongoDB 性能
- 处理分布式事务

## 技术栈版本

| 技术            | 最低版本 | 推荐版本 |
| --------------- | -------- | -------- |
| MongoDB         | 6.0+     | 7.0+     |
| MongoDB Driver  | 5.0+     | 最新     |
| Mongoose        | 8.0+     | 最新     |
| MongoDB Compass | 最新     | 最新     |
| mongosh         | 2.0+     | 最新     |

## 核心原则

### 1. 文档设计原则

- **嵌入 vs 引用**：频繁一起访问的数据嵌入，独立变化的数据引用
- **反范式化**：读多写少时，冗余数据减少查询
- **文档大小**：避免超过 16MB 限制
- **原子性**：单文档操作天然原子

### 2. 嵌入 vs 引用决策

```
嵌入:
- 一对少关系 (如用户-地址)
- 频繁一起读取
- 很少单独更新
- 数据量小

引用:
- 一对多/多对多关系
- 数据独立变化
- 需要单独访问
- 数据量大
```

## 文档模式

### 嵌入文档

```javascript
// 用户嵌入地址 (一对少)
{
  _id: ObjectId("..."),
  name: "Alice",
  email: "alice@example.com",
  addresses: [
    {
      type: "home",
      street: "123 Main St",
      city: "New York",
      zip: "10001"
    },
    {
      type: "work",
      street: "456 Office Blvd",
      city: "New York",
      zip: "10002"
    }
  ]
}

// 查询
db.users.findOne({ "addresses.city": "New York" })

// 更新特定地址
db.users.updateOne(
  { _id: userId, "addresses.type": "home" },
  { $set: { "addresses.$.street": "789 New St" } }
)
```

### 引用文档

```javascript
// 订单引用用户 (一对多)
// users collection
{
  _id: ObjectId("user1"),
  name: "Alice"
}

// orders collection
{
  _id: ObjectId("order1"),
  userId: ObjectId("user1"),
  items: [...],
  total: 100
}

// 使用 $lookup 关联
db.orders.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "userId",
      foreignField: "_id",
      as: "user"
    }
  },
  { $unwind: "$user" }
])
```

### 混合模式

```javascript
// 产品嵌入分类名称，引用完整分类
{
  _id: ObjectId("product1"),
  name: "Laptop",
  price: 999,
  // 嵌入常用字段
  category: {
    _id: ObjectId("cat1"),
    name: "Electronics"
  },
  // 完整分类在单独 collection
}

// 分类更新时同步更新产品
db.products.updateMany(
  { "category._id": categoryId },
  { $set: { "category.name": newName } }
)
```

### 树形结构

```javascript
// 物化路径模式
{
  _id: ObjectId("..."),
  name: "Smartphones",
  path: "Electronics,Phones,Smartphones"  // 或 "/Electronics/Phones/Smartphones"
}

// 查询所有子分类
db.categories.find({
  path: { $regex: "^Electronics" }
})

// 嵌套集模式 (左右值)
{
  _id: ObjectId("..."),
  name: "Electronics",
  left: 1,
  right: 20
}

// 查询子树
db.categories.find({
  left: { $gte: 1 },
  right: { $lte: 20 }
})
```

## 聚合管道

### 基本阶段

```javascript
// 筛选、分组、排序
db.orders.aggregate([
  // 1. 筛选
  { $match: { status: 'completed' } },

  // 2. 展开数组
  { $unwind: '$items' },

  // 3. 分组统计
  {
    $group: {
      _id: '$items.productId',
      totalQuantity: { $sum: '$items.quantity' },
      totalRevenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } },
      orderCount: { $sum: 1 },
    },
  },

  // 4. 计算
  {
    $addFields: {
      averageOrderValue: { $divide: ['$totalRevenue', '$orderCount'] },
    },
  },

  // 5. 排序
  { $sort: { totalRevenue: -1 } },

  // 6. 分页
  { $skip: 0 },
  { $limit: 10 },
]);
```

### 复杂聚合

```javascript
// 销售报表：按日期、产品、地区分组
db.orders.aggregate([
  // 日期范围筛选
  {
    $match: {
      createdAt: {
        $gte: ISODate('2024-01-01'),
        $lte: ISODate('2024-12-31'),
      },
    },
  },

  // 添加日期字段
  {
    $addFields: {
      year: { $year: '$createdAt' },
      month: { $month: '$createdAt' },
      day: { $dayOfMonth: '$createdAt' },
    },
  },

  // 关联用户获取地区
  {
    $lookup: {
      from: 'users',
      localField: 'userId',
      foreignField: '_id',
      as: 'user',
    },
  },
  { $unwind: '$user' },

  // 展开订单项
  { $unwind: '$items' },

  // 多级分组
  {
    $group: {
      _id: {
        year: '$year',
        month: '$month',
        region: '$user.region',
        productId: '$items.productId',
      },
      quantity: { $sum: '$items.quantity' },
      revenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } },
    },
  },

  // 重新分组按地区汇总
  {
    $group: {
      _id: {
        year: '$_id.year',
        month: '$_id.month',
        region: '$_id.region',
      },
      products: {
        $push: {
          productId: '$_id.productId',
          quantity: '$quantity',
          revenue: '$revenue',
        },
      },
      totalRevenue: { $sum: '$revenue' },
    },
  },

  // 排序
  { $sort: { '_id.year': 1, '_id.month': 1, totalRevenue: -1 } },
]);
```

### 条件聚合

```javascript
db.orders.aggregate([
  {
    $project: {
      status: 1,
      total: 1,
      // 条件字段
      statusLabel: {
        $switch: {
          branches: [
            { case: { $eq: ['$status', 'pending'] }, then: '待处理' },
            { case: { $eq: ['$status', 'processing'] }, then: '处理中' },
            { case: { $eq: ['$status', 'completed'] }, then: '已完成' },
            { case: { $eq: ['$status', 'cancelled'] }, then: '已取消' },
          ],
          default: '未知',
        },
      },
      // 条件计算
      discount: {
        $cond: {
          if: { $gte: ['$total', 1000] },
          then: { $multiply: ['$total', 0.1] },
          else: 0,
        },
      },
    },
  },
]);
```

### 分面搜索

```javascript
db.products.aggregate([
  // 筛选条件
  { $match: { category: 'Electronics' } },

  {
    $facet: {
      // 分页结果
      products: [{ $sort: { price: 1 } }, { $skip: 0 }, { $limit: 20 }],

      // 品牌统计
      brands: [{ $group: { _id: '$brand', count: { $sum: 1 } } }, { $sort: { count: -1 } }],

      // 价格区间
      priceRanges: [
        {
          $bucket: {
            groupBy: '$price',
            boundaries: [0, 100, 500, 1000, 5000],
            default: '5000+',
            output: { count: { $sum: 1 } },
          },
        },
      ],

      // 总数
      totalCount: [{ $count: 'count' }],
    },
  },
]);
```

## 索引优化

### 索引类型

```javascript
// 单字段索引
db.users.createIndex({ email: 1 }, { unique: true });

// 复合索引 (查询顺序很重要)
db.orders.createIndex({ userId: 1, createdAt: -1 });

// 多键索引 (数组字段)
db.products.createIndex({ tags: 1 });

// 文本索引
db.articles.createIndex({ title: 'text', content: 'text' });

// 地理空间索引
db.stores.createIndex({ location: '2dsphere' });

// TTL 索引 (自动过期)
db.sessions.createIndex({ createdAt: 1 }, { expireAfterSeconds: 3600 });

// 部分索引
db.orders.createIndex({ status: 1 }, { partialFilterExpression: { status: 'pending' } });
```

### 索引策略

```javascript
// ESR 规则: Equality, Sort, Range
// 查询: { status: "active" } .sort({ createdAt: -1 }).find({ price: { $gt: 100 } })
// 最佳索引: { status: 1, createdAt: -1, price: 1 }

// 查看执行计划
db.orders.find({ status: 'active' }).sort({ createdAt: -1 }).explain('executionStats');

// 检查索引使用
db.orders.aggregate([{ $indexStats: {} }]);
```

### 覆盖查询

```javascript
// 索引
db.users.createIndex({ email: 1, name: 1 });

// 覆盖查询 (不需要访问文档)
db.users.find({ email: 'test@example.com' }, { _id: 0, email: 1, name: 1 });

// 非覆盖查询 (需要访问文档获取 age)
db.users.find({ email: 'test@example.com' }, { email: 1, name: 1, age: 1 });
```

## 事务处理

### 多文档事务

```javascript
const session = db.getMongo().startSession();

try {
  session.startTransaction();

  const orders = session.getDatabase('mydb').orders;
  const inventory = session.getDatabase('mydb').inventory;

  // 创建订单
  const order = await orders.insertOne({ userId, items, total, status: 'pending' }, { session });

  // 扣减库存
  for (const item of items) {
    const result = await inventory.updateOne(
      { productId: item.productId, stock: { $gte: item.quantity } },
      { $inc: { stock: -item.quantity } },
      { session }
    );

    if (result.modifiedCount === 0) {
      throw new Error('Insufficient stock');
    }
  }

  // 更新订单状态
  await orders.updateOne({ _id: order.insertedId }, { $set: { status: 'confirmed' } }, { session });

  await session.commitTransaction();
} catch (error) {
  await session.abortTransaction();
  throw error;
} finally {
  await session.endSession();
}
```

### 重试事务

```javascript
async function withTransaction(callback) {
  const session = db.getMongo().startSession();

  try {
    let result;
    await session.withTransaction(async () => {
      result = await callback(session);
    });
    return result;
  } finally {
    await session.endSession();
  }
}

// 使用
await withTransaction(async (session) => {
  await db.orders.insertOne(order, { session });
  await db.inventory.updateOne({ productId }, { $inc: { stock: -quantity } }, { session });
});
```

## 性能优化

### 批量操作

```javascript
// 批量插入
db.products.insertMany([
  { name: 'Product 1', price: 100 },
  { name: 'Product 2', price: 200 },
]);

// 批量更新
db.orders.bulkWrite([
  {
    updateOne: {
      filter: { _id: ObjectId('...') },
      update: { $set: { status: 'completed' } },
    },
  },
  {
    updateOne: {
      filter: { _id: ObjectId('...') },
      update: { $set: { status: 'completed' } },
    },
  },
]);
```

### 投影优化

```javascript
// 只返回需要的字段
db.users.find({ status: 'active' }, { name: 1, email: 1, _id: 0 });

// 排除大字段
db.posts.find(
  { author: userId },
  { content: 0 } // 排除大文本
);
```

### 分页优化

```javascript
// 传统分页 (skip 性能差)
db.orders.find().skip(10000).limit(10);

// 范围分页 (推荐)
db.orders
  .find({
    _id: { $gt: lastId }, // 上一页最后一条的 ID
  })
  .limit(10);

// 基于时间范围分页
db.orders
  .find({
    createdAt: { $lt: lastCreatedAt },
  })
  .sort({ createdAt: -1 })
  .limit(10);
```

## 数据建模

### 预聚合模式

```javascript
// 订单预聚合统计
{
  _id: ObjectId("..."),
  userId: ObjectId("..."),
  // 订单数据
  orders: [...],
  // 预聚合统计
  stats: {
    totalOrders: 10,
    totalSpent: 5000,
    lastOrderDate: ISODate("...")
  }
}

// 更新时同步更新统计
db.userStats.updateOne(
  { userId },
  {
    $inc: { "stats.totalOrders": 1, "stats.totalSpent": orderTotal },
    $set: { "stats.lastOrderDate": new Date() }
  }
)
```

### 版本化文档

```javascript
// 文档版本控制
{
  _id: ObjectId("..."),
  docId: "product-123",  // 业务 ID
  version: 3,
  data: { name: "Product", price: 100 },
  createdBy: "user1",
  createdAt: ISODate("..."),
  changes: [
    { version: 1, field: "price", oldValue: 80, newValue: 90 },
    { version: 2, field: "price", oldValue: 90, newValue: 100 }
  ]
}

// 查询最新版本
db.products.find({ docId: "product-123" })
  .sort({ version: -1 })
  .limit(1);
```

## 快速参考

| 模式     | 用途                 |
| -------- | -------------------- |
| 嵌入文档 | 一对少，频繁一起读取 |
| 引用文档 | 一对多，独立访问     |
| 物化路径 | 树形结构             |
| 预聚合   | 读多写少统计         |
| 复合索引 | 多条件查询           |
| 覆盖查询 | 避免访问文档         |

**记住**：MongoDB 的文档模型设计取决于访问模式。根据查询模式设计文档结构，而不是根据数据关系。
