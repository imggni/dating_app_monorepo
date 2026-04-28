import type { Request, Response, NextFunction } from 'express';

import imService from '../services/im.service';
import imGroupService from '../services/im.group.service';
import { sendOk } from '../utils/response.util';
import { HttpError } from '../errors/http-error';

type AuthedRequest = Request & { user?: { id?: string } | undefined };

const firstQueryValue = (v: unknown): string | undefined => {
  if (Array.isArray(v)) return typeof v[0] === 'string' ? v[0] : undefined;
  return typeof v === 'string' ? v : undefined;
};

const firstParamValue = (v: unknown): string => {
  if (Array.isArray(v)) return String(v[0]);
  return String(v);
};

const getUserId = (req: AuthedRequest) => {
  const uid = req.user?.id;
  if (!uid) throw new HttpError(401, '未登录');
  return uid;
};

const controller = {
  getMessages: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const friendId = firstQueryValue(q.friendId);
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const result = await imService.getMessages({
        userId: getUserId(req),
        friendId: friendId || '',
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
      });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  sendMessage: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const { receiverId, messageType, content } = req.body as any;
      const result = await imService.sendMessage({
        senderId: getUserId(req),
        receiverId,
        messageType,
        content,
      });
      return sendOk(res, result, '消息发送成功');
    } catch (err) {
      next(err);
    }
  },

  getConversations: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await imService.getConversations(getUserId(req));
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  markAsRead: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const messageId = firstParamValue((req.params as any).messageId);
      const result = await imService.markAsRead(getUserId(req), messageId);
      return sendOk(res, result, '标记成功');
    } catch (err) {
      next(err);
    }
  },

  recallMessage: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const messageId = firstParamValue((req.params as any).messageId);
      const result = await imService.recallMessage(getUserId(req), messageId);
      return sendOk(res, result, '撤回成功');
    } catch (err) {
      next(err);
    }
  },

  getUnreadCount: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await imService.getUnreadCount(getUserId(req));
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  createGroup: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await imGroupService.createGroup(getUserId(req), req.body);
      return sendOk(res, result, '群组创建成功');
    } catch (err) {
      next(err);
    }
  },

  addGroupMember: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await imGroupService.addGroupMember(getUserId(req), req.body);
      return sendOk(res, result, '添加成员成功');
    } catch (err) {
      next(err);
    }
  },

  removeGroupMember: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await imGroupService.removeGroupMember(getUserId(req), req.body);
      return sendOk(res, result, '移除成员成功');
    } catch (err) {
      next(err);
    }
  },

  sendGroupMessage: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const groupId = firstParamValue((req.params as any).groupId);
      const { content, messageType } = req.body as any;
      const result = await imService.sendGroupMessage({ senderId: getUserId(req), groupId, content, messageType });
      return sendOk(res, result, '群消息发送成功');
    } catch (err) {
      next(err);
    }
  },

  getGroupMessages: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const groupId = firstParamValue((req.params as any).groupId);
      const q = req.query as any;
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const result = await imService.getGroupMessages({
        groupId,
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
      });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },
};

export default controller;

