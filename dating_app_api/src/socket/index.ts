import jwt from 'jsonwebtoken';
import type { Server as SocketIOServer, Socket } from 'socket.io';

import serverConfig = require('../config/server.config');
import redis = require('../utils/redis.util');

import gameSocket from './game.socket';
import imSocket from './im.socket';

type SocketUser = { id?: string } & Record<string, unknown>;
type AuthedSocket = Socket & { user?: SocketUser };

let io: SocketIOServer | undefined;

const init = (socketIo: SocketIOServer) => {
  io = socketIo;

  io.use((socket: AuthedSocket, next) => {
    try {
      const token =
        (socket.handshake as any)?.auth?.token ||
        (socket.handshake.headers &&
          (socket.handshake.headers as any).authorization &&
          String((socket.handshake.headers as any).authorization).split(' ')[1]);

      if (!token) {
        const err: any = new Error('Authentication error: token required');
        err.data = { code: 401, message: 'token required' };
        return next(err);
      }

      const decoded = jwt.verify(token, serverConfig.jwtSecret as string) as SocketUser;
      socket.user = decoded;

      if (decoded && decoded.id) {
        socket.join(decoded.id);
        try {
          redis.set(`online:${decoded.id}`, socket.id, { ex: 120 }).catch(() => {});
        } catch (e: any) {
          console.warn('设置在线状态到 Redis 失败', e?.message || e);
        }
      }
      return next();
    } catch (e: any) {
      const err: any = new Error('Authentication error');
      err.data = { code: 401, message: e?.message || 'invalid token' };
      return next(err);
    }
  });

  io.on('connection', (socket: AuthedSocket) => {
    console.log('New client connected:', socket.id, 'user:', socket.user?.id);

    gameSocket.init(socket, io!);
    imSocket.init(socket, io!);

    socket.on('heartbeat', async () => {
      try {
        if (socket.user && socket.user.id) {
          await redis.set(`online:${socket.user.id}`, socket.id, { ex: 120 });
        }
      } catch (e: any) {
        console.warn('刷新在线状态失败', e?.message || e);
      }
    });

    socket.on('disconnect', async () => {
      console.log('Client disconnected:', socket.id, 'user:', socket.user?.id);
      try {
        if (socket.user && socket.user.id) {
          const key = `online:${socket.user.id}`;
          const cur = await redis.get<string>(key);
          if (cur === socket.id) {
            await redis.del(key);
          }
        }
      } catch (e: any) {
        console.warn('断开连接清理在线状态失败', e?.message || e);
      }
    });
  });
};

const getIO = () => {
  if (!io) throw new Error('Socket.io not initialized');
  return io;
};

const socketManager = { init, getIO };
export default socketManager;
export { init, getIO };

