import prisma = require('../prisma/prisma');
import { HttpError } from '../errors/http-error';

const generateRoomCode = (len = 6) => {
  const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < len; i++) code += chars[Math.floor(Math.random() * chars.length)];
  return code;
};

export const getRooms = async (args: { page?: number; limit?: number; status?: string } = {}) => {
  const page = args.page ?? 1;
  const limit = args.limit ?? 20;
  const { status } = args;

  const skip = (page - 1) * limit;
  const where: any = {};
  if (status) where.status = status;

  const rooms = await prisma.gameRoom.findMany({
    where,
    orderBy: { createdAt: 'desc' },
    skip,
    take: limit,
    include: {
      members: { include: { user: { select: { id: true, nickname: true, avatar: true } } } },
    },
  });

  const total = await prisma.gameRoom.count({ where });

  return {
    rooms: rooms.map((r: any) => ({
      id: r.id,
      roomName: r.roomName,
      roomCode: r.roomCode,
      hostId: r.hostId,
      hostNickname: r.members?.find((m: any) => m.userId === r.hostId)?.user?.nickname,
      maxPlayers: r.maxPlayers,
      currentPlayers: r.currentPlayers,
      status: r.status,
      createdAt: r.createdAt,
    })),
    pagination: { page, limit, total, hasMore: total > skip + rooms.length },
  };
};

export const createRoom = async (
  userId: string,
  args: { name: string; maxPlayers?: number | undefined; gameType?: string | undefined }
) => {
  const { name } = args;
  const maxPlayers = args.maxPlayers ?? 4;

  let code = generateRoomCode();
  let tries = 0;
  while (tries < 5) {
    const exists = await prisma.gameRoom.findUnique({ where: { roomCode: code } });
    if (!exists) break;
    code = generateRoomCode();
    tries++;
  }

  const room = await prisma.gameRoom.create({
    data: {
      roomName: name,
      roomCode: code,
      hostId: userId,
      maxPlayers,
      currentPlayers: 1,
    },
  });

  await prisma.gameRoomMember.create({ data: { roomId: room.id, userId, role: 'host', score: 0 } });

  return { roomId: room.id, roomInfo: room };
};

export const getRoomById = async (roomId: string) => {
  const room = await prisma.gameRoom.findUnique({
    where: { id: roomId },
    include: { members: { include: { user: { select: { id: true, nickname: true, avatar: true } } } } },
  });
  if (!room) throw new HttpError(404, '房间不存在');

  return {
    id: room.id,
    name: (room as any).roomName,
    hostId: (room as any).hostId,
    players: (room as any).members.map((m: any) => ({
      userId: m.userId,
      nickname: m.user?.nickname,
      avatar: m.user?.avatar,
      role: m.role,
    })),
    maxPlayers: (room as any).maxPlayers,
    status: (room as any).status,
    createdAt: (room as any).createdAt,
  };
};

export const joinRoom = async (userId: string, roomId: string) => {
  return prisma.$transaction(async (tx) => {
    const db = tx as any;
    const room = await db.gameRoom.findUnique({ where: { id: roomId } });
    if (!room) throw new HttpError(404, '房间不存在');
    if ((room as any).status !== 'waiting') throw new HttpError(400, '房间不可加入');
    if ((room as any).currentPlayers >= (room as any).maxPlayers) throw new HttpError(400, '房间已满');

    const existing = await db.gameRoomMember
      .findUnique({ where: { roomId_userId: { roomId, userId } } })
      .catch(() => null);
    if (existing) throw new HttpError(400, '已经在房间中');

    await db.gameRoomMember.create({ data: { roomId, userId, role: 'player' } });
    const updated = await db.gameRoom.update({ where: { id: roomId }, data: { currentPlayers: { increment: 1 } } });
    return { roomId: (updated as any).id, currentPlayers: (updated as any).currentPlayers };
  });
};

export const leaveRoom = async (userId: string, roomId: string) => {
  return prisma.$transaction(async (tx) => {
    const db = tx as any;
    const member = await db.gameRoomMember
      .findUnique({ where: { roomId_userId: { roomId, userId } } })
      .catch(() => null);
    if (!member) throw new HttpError(404, '不在房间中');

    await db.gameRoomMember.delete({ where: { id: (member as any).id } });
    const room = await db.gameRoom.findUnique({ where: { id: roomId } });
    if (!room) throw new HttpError(404, '房间不存在');

    if ((member as any).role === 'host') {
      const other = await db.gameRoomMember.findFirst({ where: { roomId }, orderBy: { joinTime: 'asc' } }).catch(() => null);
      if (other) {
        await db.gameRoom.update({
          where: { id: roomId },
          data: { hostId: (other as any).userId, currentPlayers: { decrement: 1 } },
        });
      } else {
        await db.gameRoom.update({ where: { id: roomId }, data: { status: 'ended', currentPlayers: 0 } });
      }
    } else {
      await db.gameRoom.update({ where: { id: roomId }, data: { currentPlayers: { decrement: 1 } } });
    }

    return { success: true };
  });
};

export const startGame = async (userId: string, roomId: string) => {
  return prisma.$transaction(async (tx) => {
    const db = tx as any;
    const room = await db.gameRoom.findUnique({ where: { id: roomId } });
    if (!room) throw new HttpError(404, '房间不存在');
    if ((room as any).hostId !== userId) throw new HttpError(403, '只有房主可以开始游戏');
    if ((room as any).currentPlayers < 2) throw new HttpError(400, '玩家数量不足');

    const updated = await db.gameRoom.update({
      where: { id: roomId },
      data: { status: 'playing', gameRound: { increment: 1 } },
    });
    return { success: true, room: updated };
  });
};

export const syncBrush = async (userId: string, args: { roomId: string; round?: number; content: unknown }) => {
  const { roomId, content } = args;
  const round = args.round ?? 1;

  const room = await prisma.gameRoom.findUnique({ where: { id: roomId } });
  if (!room) throw new HttpError(404, '房间不存在');

  const member = await prisma.gameRoomMember.findFirst({ where: { roomId, userId } });
  if (!member) throw new HttpError(403, '非房间成员不可同步画笔数据');

  return prisma.gameRecord.create({
    data: {
      roomId,
      round,
      drawerId: userId,
      word: '',
      brushData: JSON.stringify(content ?? {}),
    },
  });
};

export const startRound = async (userId: string, roomId: string) => {
  return prisma.$transaction(async (tx) => {
    const db = tx as any;
    const room = await db.gameRoom.findUnique({ where: { id: roomId } });
    if (!room) throw new HttpError(404, '房间不存在');
    if ((room as any).hostId !== userId) throw new HttpError(403, '只有房主可以开始回合');

    const updated = await db.gameRoom.update({
      where: { id: roomId },
      data: { gameRound: { increment: 1 }, status: 'playing' },
    });
    return { success: true, gameRound: (updated as any).gameRound };
  });
};

export const endRound = async (userId: string, roomId: string) => {
  return prisma.$transaction(async (tx) => {
    const db = tx as any;
    const room = await db.gameRoom.findUnique({ where: { id: roomId } });
    if (!room) throw new HttpError(404, '房间不存在');
    if ((room as any).hostId !== userId) throw new HttpError(403, '只有房主可以结束回合');

    const updated = await db.gameRoom.update({ where: { id: roomId }, data: { status: 'waiting' } });
    return { success: true, room: updated };
  });
};

export const destroyRoom = async (userId: string, roomId: string) => {
  return prisma.$transaction(async (tx) => {
    const db = tx as any;
    const room = await db.gameRoom.findUnique({ where: { id: roomId } });
    if (!room) throw new HttpError(404, '房间不存在');
    if ((room as any).hostId !== userId) throw new HttpError(403, '只有房主可以销毁房间');

    await db.gameRecord.deleteMany({ where: { roomId } });
    await db.gameRoomMember.deleteMany({ where: { roomId } });
    await db.gameRoom.delete({ where: { id: roomId } });
    return { success: true };
  });
};

export default {
  getRooms,
  createRoom,
  getRoomById,
  joinRoom,
  leaveRoom,
  startGame,
  syncBrush,
  startRound,
  endRound,
  destroyRoom,
};

