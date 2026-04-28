import type { Server as SocketIOServer, Socket } from 'socket.io';

const init = (socket: Socket, io: SocketIOServer) => {
  socket.on('draw_stroke', (data: { roomId: string; stroke: unknown }) => {
    const { roomId, stroke } = data;
    socket.to(roomId).emit('stroke_received', stroke);
  });

  socket.on('join_game_room', (roomId: string) => {
    socket.join(roomId);
    io.to(roomId).emit('player_joined', { userId: socket.id });
  });
};

export default { init };

