import type { Request, Response, NextFunction } from 'express';

import userService from '../services/user.service';
import { sendOk, sendCreated } from '../utils/response.util';
import { HttpError } from '../errors/http-error';

type AuthedRequest = Request & { user?: { id?: string } | undefined };

const getUserId = (req: AuthedRequest) => {
  const uid = req.user?.id;
  if (!uid) throw new HttpError(401, '未登录');
  return uid;
};

const controller = {
  register: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await userService.register(req.body);
      return sendCreated(res, result, '注册成功');
    } catch (err) {
      next(err);
    }
  },

  login: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await userService.login(req.body);
      return sendOk(res, result, '登录成功');
    } catch (err) {
      next(err);
    }
  },

  getProfile: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const user = await userService.getUserById(getUserId(req));
      return sendOk(res, user, '成功');
    } catch (err) {
      next(err);
    }
  },

  updateProfile: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const user = await userService.updateProfile(getUserId(req), req.body);
      return sendOk(res, user, '更新成功');
    } catch (err) {
      next(err);
    }
  },

  getUserById: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = Array.isArray((req.params as any).userId) ? (req.params as any).userId[0] : (req.params as any).userId;
      const user = await userService.getUserById(String(userId));
      return sendOk(res, user, '成功');
    } catch (err) {
      next(err);
    }
  },

  sendFriendRequest: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await userService.sendFriendRequest(getUserId(req), req.body);
      return sendOk(res, result, '好友请求已发送');
    } catch (err) {
      next(err);
    }
  },

  handleFriendRequest: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await userService.handleFriendRequest(getUserId(req), req.body);
      return sendOk(res, result, '处理成功');
    } catch (err) {
      next(err);
    }
  },

  getFriendList: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const list = await userService.getFriendList(getUserId(req));
      return sendOk(res, list, '成功');
    } catch (err) {
      next(err);
    }
  },

  logout: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      await userService.logout(getUserId(req));
      return sendOk(res, null, '注销成功');
    } catch (err) {
      next(err);
    }
  },

  getOnlineStatus: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const raw = (req.params as any).userId;
      const userId = Array.isArray(raw) ? raw[0] : raw;
      const status = await userService.getOnlineStatus(String(userId));
      return sendOk(res, { online: status }, '成功');
    } catch (err) {
      next(err);
    }
  },
};

export default controller;

