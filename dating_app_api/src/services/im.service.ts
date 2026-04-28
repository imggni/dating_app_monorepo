import prisma = require('../prisma/prisma');
import { HttpError } from '../errors/http-error';
import redis = require('../utils/redis.util');

type MessageType = 'text' | 'image' | 'voice' | 'video';

const sanitizeContent = (content: string) => {
  if (!content) return content;
  return content.replace(/<\/?script[^>]*>/gi, '');
};

export const getMessages = async (args: { userId: string; friendId: string; page?: number; limit?: number }) => {
  const { userId, friendId } = args;
  const page = args.page ?? 1;
  const limit = args.limit ?? 20;
  const skip = (page - 1) * limit;

  const messages = await prisma.imMessage.findMany({
    where: {
      OR: [
        { senderId: userId, receiverId: friendId },
        { senderId: friendId, receiverId: userId },
      ],
      deletedAt: null,
    },
    orderBy: { sendTime: 'desc' },
    skip,
    take: limit,
    include: {
      sender: {
        select: { id: true, nickname: true, avatar: true },
      },
    },
  });

  const total = await prisma.imMessage.count({
    where: {
      OR: [
        { senderId: userId, receiverId: friendId },
        { senderId: friendId, receiverId: userId },
      ],
      deletedAt: null,
    },
  });

  return {
    messages: messages.reverse(),
    pagination: {
      page,
      limit,
      total,
      hasMore: total > skip + messages.length,
    },
  };
};

export const sendMessage = async (args: {
  senderId: string;
  receiverId: string;
  messageType?: MessageType | undefined;
  content: string;
}) => {
  const { senderId, receiverId, content } = args;
  const messageType = args.messageType ?? 'text';

  const receiver = await prisma.user.findUnique({ where: { id: receiverId } });
  if (!receiver) throw new HttpError(404, '接收用户不存在');

  if (messageType !== 'text') {
    try {
      const u = new URL(content);
      if (!u.protocol.startsWith('http')) throw new Error('invalid');
    } catch {
      throw new HttpError(400, '多媒体消息 content 应为有效 URL');
    }
  }

  const safeContent = sanitizeContent(content);

  const created = await prisma.$transaction(async (tx) => {
    const db = tx as any;
    const msg = await db.imMessage.create({
      data: {
        senderId,
        receiverId,
        messageType,
        content: safeContent,
      },
      include: {
        sender: {
          select: { id: true, nickname: true, avatar: true },
        },
      },
    });

    try {
      await redis.incr(`im:unread:${receiverId}`);
    } catch (e: any) {
      console.warn('Redis 增加未读计数失败', e?.message || e);
    }

    return msg;
  });

  return created;
};

export const getConversations = async (userId: string) => {
  const messages = await prisma.imMessage.findMany({
    where: {
      OR: [{ senderId: userId }, { receiverId: userId }],
      deletedAt: null,
    },
    orderBy: { sendTime: 'desc' },
    take: 500,
    select: {
      senderId: true,
      receiverId: true,
      content: true,
      sendTime: true,
      isRead: true,
    },
  });

  const conversationMap = new Map<
    string,
    {
      friendId: string;
      lastMessage: { content: string; createdAt: Date };
      unreadCount: number;
    }
  >();

  for (const msg of messages) {
    const friendId = msg.senderId === userId ? msg.receiverId : msg.senderId;
    if (!conversationMap.has(friendId)) {
      conversationMap.set(friendId, {
        friendId,
        lastMessage: {
          content: msg.content,
          createdAt: msg.sendTime,
        },
        unreadCount: msg.receiverId === userId && !msg.isRead ? 1 : 0,
      });
    } else if (msg.receiverId === userId && !msg.isRead) {
      conversationMap.get(friendId)!.unreadCount++;
    }
  }

  const friendIds = Array.from(conversationMap.keys());
  if (friendIds.length === 0) return [];

  const friends = await prisma.user.findMany({
    where: { id: { in: friendIds } },
    select: { id: true, nickname: true, avatar: true },
  });
  const friendMap = new Map(friends.map((f: any) => [f.id, f]));

  return Array.from(conversationMap.values()).map((conv) => ({
    ...conv,
    friendInfo: friendMap.get(conv.friendId) || null,
  }));
};

export const markAsRead = async (userId: string, messageId: string) => {
  const message = await prisma.imMessage.findUnique({ where: { id: messageId } });
  if (!message) throw new HttpError(404, '消息不存在');
  if (message.receiverId !== userId) throw new HttpError(403, '无权操作此消息');

  const updated = await prisma.imMessage.update({ where: { id: messageId }, data: { isRead: true } });

  try {
    const key = `im:unread:${userId}`;
    const val = await redis.get<string>(key);
    const n = parseInt(val || '0', 10);
    if (n > 0) await redis.decr(key);
  } catch (e: any) {
    console.warn('Redis 减少未读计数失败', e?.message || e);
  }

  return updated;
};

export const recallMessage = async (userId: string, messageId: string) => {
  const message = await prisma.imMessage.findUnique({ where: { id: messageId } });
  if (!message) throw new HttpError(404, '消息不存在');
  if (message.senderId !== userId) throw new HttpError(403, '无权撤回该消息');

  return prisma.imMessage.update({ where: { id: messageId }, data: { isRecalled: true } });
};

export const sendGroupMessage = async (args: {
  senderId: string;
  groupId: string;
  messageType?: MessageType | undefined;
  content: string;
}) => {
  throw new HttpError(501, '群聊功能未启用');
};

export const getGroupMessages = async (args: { groupId: string; page?: number; limit?: number }) => {
  throw new HttpError(501, '群聊功能未启用');
};

export const getUnreadCount = async (userId: string) => {
  const count = await prisma.imMessage.count({ where: { receiverId: userId, isRead: false, deletedAt: null } });
  return { unreadCount: count };
};

export default {
  getMessages,
  sendMessage,
  getConversations,
  markAsRead,
  recallMessage,
  sendGroupMessage,
  getGroupMessages,
  getUnreadCount,
};

