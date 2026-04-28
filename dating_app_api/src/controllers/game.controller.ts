import type { Request, Response, NextFunction } from 'express';

import gameService from '../services/game.service';
import { sendOk } from '../utils/response.util';
import { HttpError } from '../errors/http-error';

const firstQueryValue = (v: unknown): string | undefined => {
  if (Array.isArray(v)) return typeof v[0] === 'string' ? v[0] : undefined;
  return typeof v === 'string' ? v : undefined;
};

const firstParamValue = (v: unknown): string => {
  if (Array.isArray(v)) return String(v[0]);
  return String(v);
};

type AuthedRequest = Request & { user?: { id?: string } | undefined };

const getUserId = (req: AuthedRequest) => {
  const uid = req.user?.id;
  if (!uid) throw new HttpError(401, '未登录');
  return uid;
};

const controller = {
  getRooms: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const status = firstQueryValue(q.status);
      const result = await gameService.getRooms({
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
        status,
      });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  createRoom: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await gameService.createRoom(getUserId(req), req.body);
      return sendOk(res, result, '房间创建成功');
    } catch (err) {
      next(err);
    }
  },

  getRoomById: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const roomId = firstParamValue((req.params as any).roomId);
      const result = await gameService.getRoomById(roomId);
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  joinRoom: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const roomId = firstParamValue((req.params as any).roomId);
      const result = await gameService.joinRoom(getUserId(req), roomId);
      return sendOk(res, result, '加入成功');
    } catch (err) {
      next(err);
    }
  },

  leaveRoom: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const roomId = firstParamValue((req.params as any).roomId);
      const result = await gameService.leaveRoom(getUserId(req), roomId);
      return sendOk(res, result, '离开成功');
    } catch (err) {
      next(err);
    }
  },

  startGame: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const roomId = firstParamValue((req.params as any).roomId);
      const result = await gameService.startGame(getUserId(req), roomId);
      return sendOk(res, result, '游戏开始');
    } catch (err) {
      next(err);
    }
  },

  syncBrush: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const { roomId, round, content } = req.body as any;
      const result = await gameService.syncBrush(getUserId(req), { roomId, round, content });
      return sendOk(res, result, '同步成功');
    } catch (err) {
      next(err);
    }
  },

  startRound: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const roomId = firstParamValue((req.params as any).roomId);
      const result = await gameService.startRound(getUserId(req), roomId);
      return sendOk(res, result, '回合开始');
    } catch (err) {
      next(err);
    }
  },

  endRound: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const roomId = firstParamValue((req.params as any).roomId);
      const result = await gameService.endRound(getUserId(req), roomId);
      return sendOk(res, result, '回合结束');
    } catch (err) {
      next(err);
    }
  },

  destroyRoom: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const roomId = firstParamValue((req.params as any).roomId);
      const result = await gameService.destroyRoom(getUserId(req), roomId);
      return sendOk(res, result, '房间已销毁');
    } catch (err) {
      next(err);
    }
  },
};

export default controller;

