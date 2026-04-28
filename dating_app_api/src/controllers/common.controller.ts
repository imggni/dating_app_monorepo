import type { Request, Response, NextFunction } from 'express';

import commonService from '../services/common.service';
import { sendOk, sendBadRequest } from '../utils/response.util';

const firstQueryValue = (v: unknown): string | undefined => {
  if (Array.isArray(v)) return typeof v[0] === 'string' ? v[0] : undefined;
  return typeof v === 'string' ? v : undefined;
};

const controller = {
  uploadFile: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const file = (req as any).file as Express.Multer.File | undefined;
      const { type } = req.body as any;

      if (!file) return sendBadRequest(res, '文件不能为空', null);

      const result = await commonService.uploadFile(file, type);
      return sendOk(res, result, '文件上传成功');
    } catch (err) {
      next(err);
    }
  },

  refreshToken: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { refreshToken } = req.body as any;
      if (!refreshToken) return sendBadRequest(res, '刷新令牌不能为空', null);

      const result = await commonService.refreshToken(refreshToken);
      return sendOk(res, result, 'Token 刷新成功');
    } catch (err) {
      next(err);
    }
  },

  getRegions: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const type = firstQueryValue(q.type);
      const parentCode = firstQueryValue(q.parentCode);
      const result = await commonService.getRegions(type, parentCode);
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  getRegionByCode: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const raw = (req.params as any).code;
      const code = Array.isArray(raw) ? raw[0] : raw;
      const result = await commonService.getRegionByCode(String(code));
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  getDictionaries: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const type = firstQueryValue(q.type);
      const result = await commonService.getDictionaries(type);
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  getConfigs: async (_req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await commonService.getConfigs();
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  filterSensitiveContent: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { content, type } = req.body as any;
      if (!content) return sendBadRequest(res, '内容不能为空', null);

      const result = await commonService.filterSensitiveContent(content, type);
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  getOssToken: async (_req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await commonService.getOssToken();
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },
};

export default controller;

