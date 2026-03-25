---
name: graphql-patterns
description: GraphQL Schema 设计、查询优化、N+1 问题解决和 Federation 最佳实践。适用于所有 GraphQL 项目。**必须激活当**：用户要求设计 GraphQL Schema、实现 Resolver、解决 N+1 查询或构建 Federation 时。即使用户没有明确说"GraphQL"，当涉及 GraphQL API 查询、变更或订阅时也应使用。
---

# GraphQL 开发模式

用于构建高效、可维护 GraphQL API 的模式与最佳实践。

## 何时激活

- 设计 GraphQL Schema
- 实现 GraphQL Resolver
- 解决 N+1 查询问题
- 设计 GraphQL Federation

## 技术栈版本

| 技术                    | 最低版本 | 推荐版本 |
| ----------------------- | -------- | -------- |
| GraphQL                 | 最新     | 最新     |
| Apollo Server           | 4.0+     | 最新     |
| GraphQL Yoga            | 5.0+     | 最新     |
| Pothos (Schema Builder) | 4.0+     | 最新     |
| TypeScript              | 5.0+     | 最新     |

## 核心原则

### 1. Schema 优先

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  comments: [Comment!]!
  createdAt: DateTime!
}

type Comment {
  id: ID!
  content: String!
  author: User!
  post: Post!
  createdAt: DateTime!
}

type Query {
  user(id: ID!): User
  users(limit: Int = 10, offset: Int = 0): [User!]!
  post(id: ID!): Post
  posts(limit: Int = 10, offset: Int = 0): [Post!]!
  search(query: String!): SearchResult!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!

  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
  deletePost(id: ID!): Boolean!
}

input CreateUserInput {
  name: String!
  email: String!
}

input UpdateUserInput {
  name: String
  email: String
}

input CreatePostInput {
  title: String!
  content: String!
  authorId: ID!
}

union SearchResult = User | Post | Comment

scalar DateTime
```

### 2. 命名约定

```graphql
# 查询：名词，描述资源
type Query {
  user(id: ID!): User
  users(filter: UserFilter): UserConnection!
  post(id: ID!): Post
}

# 变更：动词 + 名词
type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): DeleteUserResult!
}

# 输入类型：动作 + 实体 + Input
input CreateUserInput { ... }
input UpdateUserInput { ... }

# 返回类型：动作 + 实体 + Result (复杂返回)
type DeleteUserResult {
  success: Boolean!
  message: String
  deletedUserId: ID
}
```

## 分页模式

### Relay 风格分页

```graphql
type Query {
  users(first: Int, after: String, last: Int, before: String, filter: UserFilter): UserConnection!
}

type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

```typescript
const resolvers = {
  Query: {
    users: async (_, { first, after, filter }, { dataSources }) => {
      const { users, hasNextPage } = await dataSources.userAPI.getUsers({
        limit: first,
        cursor: after,
        filter,
      });

      const edges = users.map((user) => ({
        node: user,
        cursor: user.id,
      }));

      return {
        edges,
        pageInfo: {
          hasNextPage,
          hasPreviousPage: !!after,
          startCursor: edges[0]?.cursor,
          endCursor: edges[edges.length - 1]?.cursor,
        },
        totalCount: await dataSources.userAPI.countUsers(filter),
      };
    },
  },
};
```

### 简单分页

```graphql
type Query {
  users(limit: Int = 10, offset: Int = 0): [User!]!
  usersCount: Int!
}
```

## N+1 问题解决

### DataLoader

```typescript
import DataLoader from 'dataloader';

// 批量加载用户
const userLoader = new DataLoader(async (userIds) => {
  const users = await User.find({ _id: { $in: userIds } });
  const userMap = new Map(users.map((u) => [u.id.toString(), u]));
  return userIds.map((id) => userMap.get(id.toString()));
});

// 在 Resolver 中使用
const resolvers = {
  Post: {
    author: async (post, _, { loaders }) => {
      return loaders.user.load(post.authorId);
    },
  },
};

// 批量加载关联数据
const postsByAuthorLoader = new DataLoader(async (authorIds) => {
  const posts = await Post.find({ authorId: { $in: authorIds } });
  return authorIds.map((authorId) =>
    posts.filter((p) => p.authorId.toString() === authorId.toString())
  );
});
```

### Apollo Server 集成

```typescript
import { ApolloServer } from '@apollo/server';
import DataLoader from 'dataloader';

const server = new ApolloServer({
  typeDefs,
  resolvers,
});

const context = async ({ req }) => ({
  loaders: {
    user: new DataLoader(async (ids) => {
      const users = await User.find({ _id: { $in: ids } });
      const map = new Map(users.map((u) => [u.id, u]));
      return ids.map((id) => map.get(id));
    }),
    post: new DataLoader(async (ids) => {
      const posts = await Post.find({ _id: { $in: ids } });
      const map = new Map(posts.map((p) => [p.id, p]));
      return ids.map((id) => map.get(id));
    }),
  },
});
```

## 认证授权

### 上下文认证

```typescript
const context = async ({ req }) => {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return { user: null };
  }

  try {
    const decoded = verifyToken(token);
    const user = await User.findById(decoded.userId);
    return { user };
  } catch (error) {
    return { user: null };
  }
};

// Resolver 中检查
const resolvers = {
  Query: {
    me: (_, __, { user }) => {
      if (!user) throw new AuthenticationError('Not authenticated');
      return user;
    },
  },
  Mutation: {
    createPost: async (_, { input }, { user }) => {
      if (!user) throw new AuthenticationError('Not authenticated');
      return Post.create({ ...input, authorId: user.id });
    },
  },
};
```

### 字段级授权

```typescript
const resolvers = {
  User: {
    email: (user, _, { currentUser }) => {
      // 只有用户自己或管理员可以看到邮箱
      if (!currentUser) return null;
      if (currentUser.id === user.id || currentUser.role === 'admin') {
        return user.email;
      }
      return null;
    },
  },
};

// 使用 @auth 指令
const typeDefs = `#graphql
  directive @auth(requires: Role!) on FIELD_DEFINITION
  
  enum Role {
    ADMIN
    USER
  }
  
  type User {
    id: ID!
    name: String!
    email: String @auth(requires: ADMIN)
  }
`;
```

## 错误处理

### 自定义错误

```typescript
class UserNotFoundError extends ApolloError {
  constructor(id: string) {
    super(`User with id ${id} not found`, 'USER_NOT_FOUND', { id });
  }
}

class ValidationError extends ApolloError {
  constructor(errors: FieldError[]) {
    super('Validation failed', 'VALIDATION_ERROR', { errors });
  }
}

interface FieldError {
  field: string;
  message: string;
}

const resolvers = {
  Query: {
    user: async (_, { id }) => {
      const user = await User.findById(id);
      if (!user) {
        throw new UserNotFoundError(id);
      }
      return user;
    },
  },
  Mutation: {
    createUser: async (_, { input }) => {
      const errors = validateUser(input);
      if (errors.length > 0) {
        throw new ValidationError(errors);
      }
      return User.create(input);
    },
  },
};
```

### 错误格式化

```typescript
const server = new ApolloServer({
  typeDefs,
  resolvers,
  formatError: (error) => {
    // 生产环境隐藏内部错误
    if (process.env.NODE_ENV === 'production') {
      if (error.extensions?.code === 'INTERNAL_SERVER_ERROR') {
        return new ApolloError('Internal server error');
      }
    }

    // 记录错误
    console.error(error);

    return error;
  },
});
```

## Federation

### 子服务定义

```graphql
# users-service/schema.graphql
extend type Query {
  me: User
  user(id: ID!): User
}

type User @key(fields: "id") {
  id: ID!
  name: String!
  email: String!
}
```

```typescript
// users-service/resolvers.ts
const resolvers = {
  Query: {
    me: (_, __, { user }) => user,
    user: (_, { id }) => User.findById(id),
  },
  User: {
    __resolveReference: async ({ id }) => {
      return User.findById(id);
    },
  },
};
```

```graphql
# posts-service/schema.graphql
extend type Query {
  posts: [Post!]!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
}

extend type User @key(fields: "id") {
  id: ID! @external
  posts: [Post!]!
}
```

```typescript
// posts-service/resolvers.ts
const resolvers = {
  Query: {
    posts: () => Post.find(),
  },
  Post: {
    author: (post) => ({ __typename: 'User', id: post.authorId }),
  },
  User: {
    posts: async (user) => {
      return Post.find({ authorId: user.id });
    },
  },
};
```

### 网关配置

```typescript
import { ApolloGateway } from '@apollo/gateway';
import { ApolloServer } from '@apollo/server';

const gateway = new ApolloGateway({
  serviceList: [
    { name: 'users', url: 'http://users-service:4001' },
    { name: 'posts', url: 'http://posts-service:4002' },
    { name: 'comments', url: 'http://comments-service:4003' },
  ],
});

const server = new ApolloServer({
  gateway,
});
```

## 订阅

### WebSocket 订阅

```graphql
type Subscription {
  postCreated: Post!
  commentAdded(postId: ID!): Comment!
  userUpdated(userId: ID!): User!
}
```

```typescript
import { PubSub } from 'graphql-subscriptions';

const pubsub = new PubSub();

const resolvers = {
  Subscription: {
    postCreated: {
      subscribe: () => pubsub.asyncIterator(['POST_CREATED']),
    },
    commentAdded: {
      subscribe: (_, { postId }) => pubsub.asyncIterator([`COMMENT_ADDED_${postId}`]),
    },
  },
  Mutation: {
    createPost: async (_, { input }) => {
      const post = await Post.create(input);
      pubsub.publish('POST_CREATED', { postCreated: post });
      return post;
    },
    addComment: async (_, { postId, content }, { user }) => {
      const comment = await Comment.create({ postId, content, authorId: user.id });
      pubsub.publish(`COMMENT_ADDED_${postId}`, { commentAdded: comment });
      return comment;
    },
  },
};
```

### 服务器配置

```typescript
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import { useServer } from 'graphql-ws/lib/use/ws';
import { makeExecutableSchema } from '@graphql-tools/schema';

const schema = makeExecutableSchema({ typeDefs, resolvers });

const httpServer = createServer(app);

const wsServer = new WebSocketServer({
  server: httpServer,
  path: '/graphql',
});

useServer({ schema }, wsServer);
```

## 性能优化

### 查询复杂度限制

```typescript
import { createComplexityLimitRule } from 'graphql-validation-complexity';

const complexityLimit = createComplexityLimitRule(1000, {
  onCost: (cost) => console.log('Query cost:', cost),
  formatErrorMessage: (cost) => `Query with cost ${cost} exceeds maximum allowed complexity`,
});

const server = new ApolloServer({
  typeDefs,
  resolvers,
  validationRules: [complexityLimit],
});
```

### 查询深度限制

```typescript
import depthLimit from 'graphql-depth-limit';

const server = new ApolloServer({
  typeDefs,
  resolvers,
  validationRules: [depthLimit(5)],
});
```

### 持久化查询

```typescript
import { ApolloServerPluginLandingPageDisabled } from '@apollo/server/plugin/landingPage/disabled';

const server = new ApolloServer({
  typeDefs,
  resolvers,
  plugins: [ApolloServerPluginLandingPageDisabled()],
  // 启用持久化查询
  persistedQueries: {
    cache: new Map(),
  },
});
```

## 测试

### 单元测试

```typescript
import { graphql } from 'graphql';
import { makeExecutableSchema } from '@graphql-tools/schema';

describe('User Query', () => {
  const schema = makeExecutableSchema({ typeDefs, resolvers });

  it('should return user by id', async () => {
    const query = `
      query GetUser($id: ID!) {
        user(id: $id) {
          id
          name
          email
        }
      }
    `;

    const result = await graphql({
      schema,
      source: query,
      variableValues: { id: '1' },
      contextValue: { user: mockUser },
    });

    expect(result.errors).toBeUndefined();
    expect(result.data.user.name).toBe('Alice');
  });
});
```

### 集成测试

```typescript
import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';

describe('GraphQL Integration', () => {
  let server, url;

  beforeAll(async () => {
    server = new ApolloServer({ typeDefs, resolvers });
    const { url: serverUrl } = await startStandaloneServer(server);
    url = serverUrl;
  });

  afterAll(async () => {
    await server.stop();
  });

  it('should create and fetch user', async () => {
    const mutation = `
      mutation CreateUser($input: CreateUserInput!) {
        createUser(input: $input) {
          id
          name
        }
      }
    `;

    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: mutation,
        variables: { input: { name: 'Alice', email: 'alice@example.com' } },
      }),
    });

    const { data } = await response.json();
    expect(data.createUser.name).toBe('Alice');
  });
});
```

## 快速参考

| 模式       | 用途          |
| ---------- | ------------- |
| DataLoader | 解决 N+1 问题 |
| Relay 分页 | 标准分页方案  |
| Federation | 微服务架构    |
| 订阅       | 实时数据推送  |
| 复杂度限制 | 防止过度查询  |
| 指令       | 字段级授权    |

**记住**：GraphQL 的灵活性是双刃剑。使用 DataLoader、复杂度限制和深度限制来保护服务器免受滥用。
