# Socket.IO 客户端示例 — 带 Token 的连接与心跳

示例使用 `socket.io-client` 在连接时携带 Bearer token，用于后端在 `io.use()` 中验证并把 socket 加入以 `userId` 命名的房间：

客户端示例（JavaScript / 浏览器 或 Node）：

```javascript
import { io } from 'socket.io-client';

// 在登录后获取后端颁发的 JWT
const token = '<JWT_FROM_LOGIN>'; // e.g. localStorage.getItem('token')

// 建议将 token 放在 handshake 的 auth 字段中
const socket = io('https://api.example.com', {
  auth: {
    token,
  },
  transports: ['websocket'],
});

socket.on('connect', () => {
  console.log('connected, socket id=', socket.id);
  // 启动心跳（每 30 秒发送一次）
  setInterval(() => {
    socket.emit('heartbeat');
  }, 30000);
});

socket.on('connect_error', (err) => {
  console.error('Socket connect error', err.message || err);
});

// 接收单聊消息
socket.on('receive_message', (msg) => {
  console.log('receive_message', msg);
});

// 接收群消息
socket.on('group_message', (payload) => {
  console.log('group_message', payload);
});

// 发送单聊
function sendToUser(receiverId, message) {
  socket.emit('send_message', { receiverId, message });
}

// 发送群消息（也可以走 REST API）
function sendGroupMessage(groupId, content) {
  socket.emit('send_group_message', { groupId, content });
}
```

说明：
- 服务器端会在 `io.use()` 中解析并验证 `token`，验证通过后将 socket 加入 `userId` 房间，便于通过 `io.to(userId).emit(...)` 精准推送。
- 客户端需要定期发送 `heartbeat` 以刷新服务器端在 Redis 的在线状态 TTL（示例每 30 秒）。
- 如果需要更安全的做法，可在握手时使用短期 token 或在连接时使用双向认证（TLS + token）。
