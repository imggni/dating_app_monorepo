import type { Request, Response, NextFunction } from 'express';

import slowChatService from '../services/slow-chat.service';
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
  getRooms: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const result = await slowChatService.listSlowChats(getUserId(req), {
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
      });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  createRoom: async (_req: AuthedRequest, res: Response) => {
    return sendOk(res, {}, '房间创建成功');
  },

  getRoomById: async (_req: Request, res: Response) => {
    return sendOk(res, {}, '成功');
  },

  joinRoom: async (_req: AuthedRequest, res: Response) => {
    return sendOk(res, {}, '加入成功');
  },

  leaveRoom: async (_req: AuthedRequest, res: Response) => {
    return sendOk(res, {}, '离开成功');
  },

  getRoomMessages: async (_req: AuthedRequest, res: Response) => {
    return sendOk(res, [], '成功');
  },

  sendSlowMessage: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await slowChatService.sendSlowMessage(getUserId(req), req.body);
      return sendOk(res, result, '慢消息已发送');
    } catch (err) {
      next(err);
    }
  },

  openSlowMessage: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const messageId = firstParamValue((req.params as any).messageId);
      const result = await slowChatService.openSlowChat(getUserId(req), messageId);
      return sendOk(res, result, '开封成功');
    } catch (err) {
      next(err);
    }
  },

  deleteSlowMessage: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const messageId = firstParamValue((req.params as any).messageId);
      const result = await slowChatService.deleteSlowChat(getUserId(req), messageId);
      return sendOk(res, result, '删除成功');
    } catch (err) {
      next(err);
    }
  },

  setAnonymous: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const { isAnonymous } = req.body as any;
      const messageId = firstParamValue((req.params as any).messageId);
      const result = await slowChatService.setAnonymous(getUserId(req), messageId, !!isAnonymous);
      return sendOk(res, result, '设置成功');
    } catch (err) {
      next(err);
    }
  },
};

export default controller;

