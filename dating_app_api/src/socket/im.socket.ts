import type { Server as SocketIOServer, Socket } from 'socket.io';

type SocketUser = { id?: string } & Record<string, unknown>;
type AuthedSocket = Socket & { user?: SocketUser };

const init = (socket: AuthedSocket, io: SocketIOServer) => {
  socket.on('send_message', (data: { receiverId: string; message: unknown }) => {
    const { receiverId, message } = data;
    io.to(receiverId).emit('receive_message', message);
  });

  socket.on('heartbeat', async () => {
    try {
      const redis = await import('../utils/redis.util');
      const client: any = (redis as any).default ?? (redis as any);
      if (socket.user && socket.user.id) {
        await client.set(`online:${socket.user.id}`, socket.id, { ex: 120 });
      }
    } catch (e: any) {
      console.warn('heartbeat 更新在线状态失败', e?.message || e);
    }
  });

  socket.on('update_online_status', (_status: unknown) => {
    // Reserved for future use.
  });
};

export default { init };

