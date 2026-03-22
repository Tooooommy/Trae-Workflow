---
name: realtime-websocket
description: 实时通信模式 - WebSocket、SSE、Socket.IO 最佳实践
---

# 实时通信模式

> WebSocket、Server-Sent Events、实时数据同步的最佳实践

## 何时激活

- 实现聊天/消息功能
- 实时数据推送
- 协作编辑功能
- 实时通知系统
- 游戏/直播互动

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Socket.IO | 4.0+ | 最新 |
| ws | 8.0+ | 最新 |
| Redis Adapter | 7.0+ | 最新 |
| Ably | 1.2+ | 最新 |

## 通信方案对比

| 方案 | 方向 | 断线重连 | 浏览器支持 | 适用场景 |
|------|------|----------|-----------|----------|
| WebSocket | 双向 | 需实现 | 广泛 | 聊天、游戏 |
| SSE | 单向 | 自动 | 广泛 | 通知、流 |
| Long Polling | 双向 | 自动 | 全部 | 兼容方案 |
| Socket.IO | 双向 | 自动 | 广泛 | 通用方案 |

## WebSocket 原生实现

### 服务端

```typescript
import { WebSocketServer, WebSocket } from 'ws';

const wss = new WebSocketServer({ port: 8080 });

interface Client {
  ws: WebSocket;
  userId: string;
  rooms: Set<string>;
}

const clients = new Map<WebSocket, Client>();

wss.on('connection', (ws, req) => {
  const userId = authenticate(req);
  
  clients.set(ws, {
    ws,
    userId,
    rooms: new Set(),
  });
  
  ws.on('message', (data) => {
    const message = JSON.parse(data);
    handleMessage(ws, message);
  });
  
  ws.on('close', () => {
    clients.delete(ws);
  });
  
  ws.send(JSON.stringify({ type: 'connected', userId }));
});

function broadcast(room: string, message: object) {
  const payload = JSON.stringify(message);
  
  clients.forEach((client) => {
    if (client.rooms.has(room)) {
      client.ws.send(payload);
    }
  });
}
```

### 客户端

```typescript
class WebSocketClient {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 1000;
  
  connect(url: string) {
    this.ws = new WebSocket(url);
    
    this.ws.onopen = () => {
      this.reconnectAttempts = 0;
      console.log('Connected');
    };
    
    this.ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      this.onMessage(message);
    };
    
    this.ws.onclose = () => {
      this.reconnect(url);
    };
  }
  
  private reconnect(url: string) {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => this.connect(url), this.reconnectDelay * this.reconnectAttempts);
    }
  }
  
  send(message: object) {
    this.ws?.send(JSON.stringify(message));
  }
  
  onMessage(message: any) {
    // Override this method
  }
}
```

## Socket.IO 实现

### 服务端

```typescript
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import Redis from 'ioredis';

const io = new Server(3000, {
  cors: {
    origin: process.env.CLIENT_URL,
    credentials: true,
  },
});

const pubClient = new Redis(process.env.REDIS_URL);
const subClient = pubClient.duplicate();
io.adapter(createAdapter(pubClient, subClient));

io.use(async (socket, next) => {
  const token = socket.handshake.auth.token;
  const user = await verifyToken(token);
  
  if (!user) {
    return next(new Error('Unauthorized'));
  }
  
  socket.data.user = user;
  next();
});

io.on('connection', (socket) => {
  const { user } = socket.data;
  
  socket.join(`user:${user.id}`);
  
  socket.on('join:room', (roomId: string) => {
    socket.join(`room:${roomId}`);
    socket.to(`room:${roomId}`).emit('user:joined', user);
  });
  
  socket.on('message:send', async (data: { roomId: string; content: string }) => {
    const message = await saveMessage({
      roomId: data.roomId,
      userId: user.id,
      content: data.content,
    });
    
    io.to(`room:${data.roomId}`).emit('message:new', message);
  });
  
  socket.on('disconnect', () => {
    socket.rooms.forEach((room) => {
      socket.to(room).emit('user:left', user);
    });
  });
});
```

### 客户端

```typescript
import { io, Socket } from 'socket.io-client';

class ChatClient {
  private socket: Socket;
  
  constructor(url: string, token: string) {
    this.socket = io(url, {
      auth: { token },
      transports: ['websocket'],
      reconnection: true,
      reconnectionAttempts: 10,
      reconnectionDelay: 1000,
    });
    
    this.setupListeners();
  }
  
  private setupListeners() {
    this.socket.on('connect', () => {
      console.log('Connected:', this.socket.id);
    });
    
    this.socket.on('message:new', (message) => {
      this.onNewMessage(message);
    });
    
    this.socket.on('user:joined', (user) => {
      this.onUserJoined(user);
    });
    
    this.socket.on('disconnect', (reason) => {
      console.log('Disconnected:', reason);
    });
  }
  
  joinRoom(roomId: string) {
    this.socket.emit('join:room', roomId);
  }
  
  sendMessage(roomId: string, content: string) {
    this.socket.emit('message:send', { roomId, content });
  }
  
  onNewMessage(message: any) {}
  onUserJoined(user: any) {}
}
```

## Server-Sent Events (SSE)

```typescript
import express from 'express';

const app = express();

app.get('/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  
  const sendEvent = (data: object) => {
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  };
  
  const interval = setInterval(() => {
    sendEvent({ time: new Date().toISOString() });
  }, 1000);
  
  req.on('close', () => {
    clearInterval(interval);
  });
});
```

## 房间管理

```typescript
class RoomManager {
  private rooms = new Map<string, Set<string>>();
  
  join(roomId: string, userId: string) {
    if (!this.rooms.has(roomId)) {
      this.rooms.set(roomId, new Set());
    }
    this.rooms.get(roomId)!.add(userId);
  }
  
  leave(roomId: string, userId: string) {
    this.rooms.get(roomId)?.delete(userId);
    if (this.rooms.get(roomId)?.size === 0) {
      this.rooms.delete(roomId);
    }
  }
  
  getMembers(roomId: string): string[] {
    return Array.from(this.rooms.get(roomId) || []);
  }
  
  getUserRooms(userId: string): string[] {
    const rooms: string[] = [];
    this.rooms.forEach((members, roomId) => {
      if (members.has(userId)) {
        rooms.push(roomId);
      }
    });
    return rooms;
  }
}
```

## 消息确认机制

```typescript
socket.on('message:send', async (data, callback) => {
  try {
    const message = await saveMessage(data);
    io.to(`room:${data.roomId}`).emit('message:new', message);
    callback({ success: true, messageId: message.id });
  } catch (error) {
    callback({ success: false, error: error.message });
  }
});
```

## 安全最佳实践

| 措施 | 实现 |
|------|------|
| 认证 | JWT Token 验证 |
| 授权 | 房间权限检查 |
| 速率限制 | 消息频率控制 |
| 输入验证 | 消息内容过滤 |
| CORS | 限制来源域名 |

## 快速参考

```typescript
// Socket.IO 服务端
io.to('room:123').emit('event', data);
socket.join('room:123');
socket.leave('room:123');

// Socket.IO 客户端
socket.emit('event', data, (ack) => {});
socket.on('event', (data) => {});

// SSE
res.write(`data: ${JSON.stringify(data)}\n\n`);
```

## 参考

- [Socket.IO Docs](https://socket.io/docs/v4/)
- [WebSocket API](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
- [MDN Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
