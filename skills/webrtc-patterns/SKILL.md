---
name: webrtc-patterns
description: WebRTC 实时音视频模式 - P2P 连接、媒体流、数据通道最佳实践
---

# WebRTC 实时音视频模式

> P2P 连接、媒体流、数据通道的最佳实践

## 何时激活

- 视频通话应用
- 实时协作
- P2P 文件传输
- 直播推流
- 游戏语音

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| WebRTC API | - | 浏览器原生 |
| Simple-peer | 9.0+ | 最新 |
| PeerJS | 1.0+ | 最新 |
| mediasoup | 3.0+ | 最新 |

## 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                    WebRTC 架构                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │   Peer A    │────>│ 信令服务器   │<────│   Peer B    │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│         │                                       │          │
│         │              STUN/TURN               │          │
│         └──────────────────────────────────────┘          │
│                    P2P 连接                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 基础连接

```typescript
class WebRTCConnection {
  private peerConnection: RTCPeerConnection;
  private localStream: MediaStream | null = null;
  private remoteStream: MediaStream | null = null;

  constructor(private signalingServer: SignalingServer) {
    this.peerConnection = new RTCPeerConnection({
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' },
      ],
    });

    this.setupEventHandlers();
  }

  private setupEventHandlers() {
    this.peerConnection.onicecandidate = (event) => {
      if (event.candidate) {
        this.signalingServer.send({
          type: 'ice-candidate',
          candidate: event.candidate,
        });
      }
    };

    this.peerConnection.ontrack = (event) => {
      this.remoteStream = event.streams[0];
      this.onRemoteStream(event.streams[0]);
    };

    this.peerConnection.onconnectionstatechange = () => {
      console.log('Connection state:', this.peerConnection.connectionState);
    };
  }

  async getLocalStream(constraints: MediaStreamConstraints = { video: true, audio: true }) {
    this.localStream = await navigator.mediaDevices.getUserMedia(constraints);
    
    this.localStream.getTracks().forEach((track) => {
      this.peerConnection.addTrack(track, this.localStream!);
    });
    
    return this.localStream;
  }

  async createOffer() {
    const offer = await this.peerConnection.createOffer();
    await this.peerConnection.setLocalDescription(offer);
    return offer;
  }

  async createAnswer() {
    const answer = await this.peerConnection.createAnswer();
    await this.peerConnection.setLocalDescription(answer);
    return answer;
  }

  async setRemoteDescription(description: RTCSessionDescriptionInit) {
    await this.peerConnection.setRemoteDescription(description);
  }

  async addIceCandidate(candidate: RTCIceCandidateInit) {
    await this.peerConnection.addIceCandidate(candidate);
  }

  onRemoteStream(stream: MediaStream) {}

  close() {
    this.peerConnection.close();
    this.localStream?.getTracks().forEach((track) => track.stop());
  }
}
```

## 信令服务器

```typescript
import { Server } from 'socket.io';

const io = new Server(3000);

io.on('connection', (socket) => {
  socket.on('join', (roomId: string) => {
    socket.join(roomId);
    socket.to(roomId).emit('user-joined', socket.id);
  });

  socket.on('offer', (data: { roomId: string; offer: RTCSessionDescriptionInit }) => {
    socket.to(data.roomId).emit('offer', {
      from: socket.id,
      offer: data.offer,
    });
  });

  socket.on('answer', (data: { roomId: string; answer: RTCSessionDescriptionInit }) => {
    socket.to(data.roomId).emit('answer', {
      from: socket.id,
      answer: data.answer,
    });
  });

  socket.on('ice-candidate', (data: { roomId: string; candidate: RTCIceCandidateInit }) => {
    socket.to(data.roomId).emit('ice-candidate', {
      from: socket.id,
      candidate: data.candidate,
    });
  });

  socket.on('disconnecting', () => {
    socket.rooms.forEach((room) => {
      socket.to(room).emit('user-left', socket.id);
    });
  });
});
```

## 数据通道

```typescript
class DataChannelManager {
  private channel: RTCDataChannel | null = null;

  createChannel(peerConnection: RTCPeerConnection, label: string = 'data') {
    this.channel = peerConnection.createDataChannel(label, {
      ordered: true,
    });

    this.setupChannelHandlers();
    return this.channel;
  }

  private setupChannelHandlers() {
    if (!this.channel) return;

    this.channel.onopen = () => {
      console.log('Data channel opened');
    };

    this.channel.onclose = () => {
      console.log('Data channel closed');
    };

    this.channel.onmessage = (event) => {
      this.onMessage(JSON.parse(event.data));
    };

    this.channel.onerror = (error) => {
      console.error('Data channel error:', error);
    };
  }

  send(data: object) {
    if (this.channel?.readyState === 'open') {
      this.channel.send(JSON.stringify(data));
    }
  }

  onMessage(data: any) {}
}

peerConnection.ondatachannel = (event) => {
  const channel = event.channel;
  channel.onmessage = (e) => console.log('Received:', e.data);
};
```

## 屏幕共享

```typescript
async function startScreenShare() {
  const stream = await navigator.mediaDevices.getDisplayMedia({
    video: true,
    audio: true,
  });

  stream.getVideoTracks()[0].onended = () => {
    console.log('Screen sharing ended');
  };

  return stream;
}
```

## 录制

```typescript
class MediaRecorder {
  private recorder: globalThis.MediaRecorder | null = null;
  private chunks: Blob[] = [];

  start(stream: MediaStream, mimeType: string = 'video/webm') {
    this.recorder = new globalThis.MediaRecorder(stream, { mimeType });
    this.chunks = [];

    this.recorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        this.chunks.push(event.data);
      }
    };

    this.recorder.start(1000);
  }

  stop(): Promise<Blob> {
    return new Promise((resolve) => {
      this.recorder!.onstop = () => {
        const blob = new Blob(this.chunks, { type: 'video/webm' });
        resolve(blob);
      };
      this.recorder!.stop();
    });
  }
}
```

## 快速参考

```typescript
// 创建连接
const pc = new RTCPeerConnection({ iceServers: [...] });

// 获取媒体
const stream = await navigator.mediaDevices.getUserMedia({ video: true });

// 添加轨道
stream.getTracks().forEach(track => pc.addTrack(track, stream));

// 创建 Offer/Answer
const offer = await pc.createOffer();
await pc.setLocalDescription(offer);

// 数据通道
const channel = pc.createDataChannel('data');
channel.send('Hello');
```

## 参考

- [WebRTC API (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API)
- [Simple-peer](https://github.com/feross/simple-peer)
- [PeerJS](https://peerjs.com/)
- [mediasoup](https://mediasoup.org/)
