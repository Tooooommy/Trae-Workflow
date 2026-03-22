---
name: grpc-patterns
description: gRPC 通信模式 - Protocol Buffers、流式通信、服务定义最佳实践
---

# gRPC 通信模式

> Protocol Buffers、流式通信、服务定义的最佳实践

## 何时激活

- 微服务间通信
- 高性能 RPC
- 流式数据传输
- 跨语言服务
- 强类型 API

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| gRPC | 1.60+ | 最新 |
| Protocol Buffers | 3.0+ | 最新 |
| @grpc/grpc-js | 1.9+ | 最新 |

## 通信模式对比

| 模式 | 特点 | 适用场景 |
|------|------|----------|
| 一元 RPC | 请求-响应 | 标准 API |
| 服务端流 | 单请求多响应 | 数据推送 |
| 客户端流 | 多请求单响应 | 文件上传 |
| 双向流 | 双向实时 | 聊天、游戏 |

## Protocol Buffers 定义

```protobuf
syntax = "proto3";

package userservice;

service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc CreateUser(CreateUserRequest) returns (User);
  rpc ListUsers(ListUsersRequest) returns (stream User);
  rpc UploadUsers(stream CreateUserRequest) returns (UploadSummary);
}

message User {
  string id = 1;
  string email = 2;
  string name = 3;
}

message GetUserRequest {
  string id = 1;
}

message CreateUserRequest {
  string email = 1;
  string name = 2;
}
```

## Node.js 服务端

```typescript
import * as grpc from '@grpc/grpc-js';
import * as protoLoader from '@grpc/proto-loader';

const packageDefinition = protoLoader.loadSync('./proto/users.proto');
const proto = grpc.loadPackageDefinition(packageDefinition).userservice;

const users = new Map<string, User>();

const server = new grpc.Server();
server.addService((proto as any).UserService.service, {
  GetUser: async (call, callback) => {
    const user = users.get(call.request.id);
    if (!user) {
      return callback({ code: grpc.status.NOT_FOUND });
    }
    callback(null, user);
  },
  
  CreateUser: async (call, callback) => {
    const user = { id: crypto.randomUUID(), ...call.request };
    users.set(user.id, user);
    callback(null, user);
  },
  
  ListUsers: async (call) => {
    for (const user of users.values()) {
      call.write(user);
    }
    call.end();
  },
});

server.bindAsync('0.0.0.0:50051', grpc.ServerCredentials.createInsecure(), () => {
  console.log('Server running on port 50051');
});
```

## 快速参考

```typescript
// 创建连接
const client = new UserServiceClient('localhost:50051', credentials);

// 一元调用
client.GetUser({ id: '123' }, (err, user) => {});

// 流式调用
const stream = client.ListUsers({});
stream.on('data', (user) => {});
```

## 参考

- [gRPC Docs](https://grpc.io/docs/)
- [Protocol Buffers](https://protobuf.dev/)
- [gRPC Node.js](https://grpc.io/docs/languages/node/)
