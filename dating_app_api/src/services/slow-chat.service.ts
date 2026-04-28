import prisma = require('../prisma/prisma');
import { HttpError } from '../errors/http-error';

type MessageType = 'text' | 'image' | 'voice' | 'video';

export const sendSlowMessage = async (
  senderId: string,
  args: {
    receiverId: string;
    title?: string | undefined;
    content: string;
    messageType?: MessageType | undefined;
    delayTime?: number | undefined;
    isAnonymous?: boolean | undefined;
  }
) => {
  const { receiverId, content } = args;
  const title = (args.title && args.title.trim().length > 0 ? args.title.trim() : content.slice(0, 20)) || '慢消息';
  const messageType = args.messageType ?? 'text';
  const delayTime = args.delayTime ?? 0;
  const isAnonymous = args.isAnonymous ?? false;

  if (!content || content.trim().length === 0) throw new HttpError(400, '内容不能为空');

  const receiver = await prisma.user.findUnique({ where: { id: receiverId } });
  if (!receiver) throw new HttpError(404, '接收者不存在');

  return prisma.slowChat.create({
    data: { senderId, receiverId, title, content, messageType, delayTime, isAnonymous },
  });
};

export const listSlowChats = async (userId: string, args: { page?: number; limit?: number } = {}) => {
  const page = args.page ?? 1;
  const limit = args.limit ?? 20;
  const skip = (page - 1) * limit;

  const msgs = await prisma.slowChat.findMany({
    where: { receiverId: userId },
    orderBy: { createdAt: 'desc' },
    skip,
    take: limit,
    include: { sender: { select: { id: true, nickname: true, avatar: true } } },
  });

  const total = await prisma.slowChat.count({ where: { receiverId: userId } });

  return {
    messages: msgs.map((m: any) => ({
      id: m.id,
      senderId: m.senderId,
      nickname: m.sender?.nickname,
      content: m.content,
      isOpened: m.isOpened,
      isAnonymous: m.isAnonymous,
      sendTime: m.sendTime,
    })),
    pagination: { page, limit, total, hasMore: total > skip + msgs.length },
  };
};

export const openSlowChat = async (userId: string, messageId: string) => {
  const msg = await prisma.slowChat.findUnique({ where: { id: messageId } });
  if (!msg) throw new HttpError(404, '消息不存在');
  if (msg.receiverId !== userId) throw new HttpError(403, '无权开封该消息');

  return prisma.slowChat.update({
    where: { id: messageId },
    data: { isOpened: true, actualSendTime: new Date() },
  });
};

export const deleteSlowChat = async (userId: string, messageId: string) => {
  const msg = await prisma.slowChat.findUnique({ where: { id: messageId } });
  if (!msg) throw new HttpError(404, '消息不存在');
  if (msg.receiverId !== userId && msg.senderId !== userId) throw new HttpError(403, '无权删除');

  await prisma.slowChat.delete({ where: { id: messageId } });
  return { success: true };
};

export const setAnonymous = async (userId: string, messageId: string, isAnonymous: boolean) => {
  const msg = await prisma.slowChat.findUnique({ where: { id: messageId } });
  if (!msg) throw new HttpError(404, '消息不存在');
  if (msg.senderId !== userId) throw new HttpError(403, '无权修改');

  return prisma.slowChat.update({ where: { id: messageId }, data: { isAnonymous } });
};

export default {
  sendSlowMessage,
  listSlowChats,
  openSlowChat,
  deleteSlowChat,
  setAnonymous,
};

