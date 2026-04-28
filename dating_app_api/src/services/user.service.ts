import jwt from 'jsonwebtoken';

import prisma = require('../prisma/prisma');
import config = require('../config/server.config');
import redis = require('../utils/redis.util');
import * as encryption from '../utils/encryption.util';
import { HttpError } from '../errors/http-error';

type RegisterArgs = {
  phone: string;
  password: string;
  nickname: string;
  gender?: string | null | undefined;
  age?: number | null | undefined;
};

type LoginArgs = {
  phone: string;
  password: string;
};

export const register = async (userData: RegisterArgs) => {
  const { phone, password, nickname, gender, age } = userData;

  const existingUser = await prisma.user.findUnique({ where: { phone } });
  if (existingUser) throw new HttpError(400, '该手机号已注册');

  if (!config.jwtSecret) throw new HttpError(500, '服务端未配置 JWT_SECRET');

  const hashedPassword = await encryption.hashPassword(password);
  const user = await prisma.user.create({
    data: { phone, password: hashedPassword, nickname, gender, age },
  });

  const token = jwt.sign({ id: user.id }, config.jwtSecret, { expiresIn: '7d' });
  return { userId: user.id, token };
};

export const login = async (args: LoginArgs) => {
  const { phone, password } = args;

  const user = await prisma.user.findUnique({ where: { phone } });
  if (!user) throw new HttpError(401, '手机号或密码错误');

  const isMatch = await encryption.comparePassword(password, user.password as string);
  if (!isMatch) throw new HttpError(401, '手机号或密码错误');

  if (!config.jwtSecret) throw new HttpError(500, '服务端未配置 JWT_SECRET');
  const token = jwt.sign({ id: user.id }, config.jwtSecret, { expiresIn: '7d' });

  return {
    userId: user.id,
    token,
    userInfo: {
      id: user.id,
      phone: user.phone,
      nickname: user.nickname,
      avatar: user.avatar,
      gender: user.gender,
      age: user.age,
      bio: user.bio,
      tags: user.tags,
      gameScore: user.gameScore,
      onlineStatus: user.onlineStatus,
    },
  };
};

export const getUserById = async (id: string) => {
  const user = await prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      phone: true,
      nickname: true,
      avatar: true,
      gender: true,
      age: true,
      bio: true,
      tags: true,
      gameScore: true,
      onlineStatus: true,
      createdAt: true,
    },
  });

  if (!user) throw new HttpError(404, '用户不存在');
  return user;
};

export const updateProfile = async (userId: string, updateData: any) => {
  const { nickname, avatar, gender, age, bio, tags } = updateData;

  return prisma.user.update({
    where: { id: userId },
    data: { nickname, avatar, gender, age, bio, tags },
    select: {
      id: true,
      phone: true,
      nickname: true,
      avatar: true,
      gender: true,
      age: true,
      bio: true,
      tags: true,
      gameScore: true,
      onlineStatus: true,
    },
  });
};

export const sendFriendRequest = async (userId: string, args: { friendId: string; message?: string | undefined }) => {
  const { friendId } = args;
  if (userId === friendId) throw new HttpError(400, '不能添加自己为好友');

  const friend = await prisma.user.findUnique({ where: { id: friendId } });
  if (!friend) throw new HttpError(404, '目标用户不存在');

  const existing = await prisma.friendRelation.findFirst({
    where: {
      OR: [{ userId, friendId }, { userId: friendId, friendId: userId }],
    },
  });
  if (existing) {
    if (existing.status === 'pending') throw new HttpError(400, '已有待处理的好友请求');
    if (existing.status === 'accepted') throw new HttpError(400, '已是好友');
  }

  return prisma.friendRelation.create({
    data: { userId, friendId, status: 'pending' },
  });
};

export const handleFriendRequest = async (userId: string, args: { requestId: string; action: 'accept' | 'reject' }) => {
  const { requestId, action } = args;

  const request = await prisma.friendRelation.findUnique({ where: { id: requestId } });
  if (!request) throw new HttpError(404, '好友请求不存在');
  if (request.friendId !== userId) throw new HttpError(403, '无权处理该请求');
  if (request.status !== 'pending') throw new HttpError(400, '该请求已被处理');

  if (action === 'reject') {
    return prisma.friendRelation.update({ where: { id: requestId }, data: { status: 'rejected' } });
  }

  const updated = await prisma.friendRelation.update({ where: { id: requestId }, data: { status: 'accepted' } });

  try {
    await prisma.friendRelation.create({
      data: { userId: request.friendId, friendId: request.userId, status: 'accepted' },
    });
  } catch {
    // Ignore duplicates.
  }

  return updated;
};

export const getFriendList = async (userId: string) => {
  const relations = await prisma.friendRelation.findMany({
    where: { OR: [{ userId, status: 'accepted' }, { friendId: userId, status: 'accepted' }] },
  });

  const friendIds = relations.map((r: any) => (r.userId === userId ? r.friendId : r.userId));
  const friends = await prisma.user.findMany({
    where: { id: { in: friendIds } },
    select: { id: true, nickname: true, avatar: true, gender: true },
  });
  return friends;
};

export const logout = async (userId: string) => {
  await redis.del(`online:${userId}`);
  return prisma.user.update({ where: { id: userId }, data: { onlineStatus: false } });
};

export const getOnlineStatus = async (userId: string) => {
  const key = `online:${userId}`;
  const val = await redis.get<string>(key);
  if (val !== null) return true;

  const user = await prisma.user.findUnique({ where: { id: userId }, select: { onlineStatus: true } });
  return !!(user && user.onlineStatus);
};

export default {
  register,
  login,
  getUserById,
  updateProfile,
  sendFriendRequest,
  handleFriendRequest,
  getFriendList,
  logout,
  getOnlineStatus,
};

