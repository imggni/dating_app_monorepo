import { z, ZodTypeAny } from 'zod';
import type { Request, Response, NextFunction } from 'express';

import * as userSchemas from '../validators/user.schemas';
import * as imSchemas from '../validators/im.schemas';
import * as gameSchemas from '../validators/game.schemas';
import * as circleSchemas from '../validators/circle.schemas';
import * as commonSchemas from '../validators/common.schemas';
import * as slowChatSchemas from '../validators/slow-chat.schemas';

type RequestLike = Request & {
  validated?: unknown;
};

export const validate = (schema: ZodTypeAny) => (req: RequestLike, res: Response, next: NextFunction) => {
  try {
    const parsed = schema.parse({
      body: req.body,
      query: req.query,
      params: req.params,
    });

    req.validated = parsed;
    if (parsed?.body) req.body = parsed.body;
    if (parsed?.query) req.query = parsed.query;
    if (parsed?.params) req.params = parsed.params;

    next();
  } catch (err) {
    if (err instanceof z.ZodError) {
      const errors = err.errors.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
      }));
      return res.status(400).json({
        code: 400,
        message: '参数校验失败',
        data: { errors },
      });
    }
    next(err);
  }
};

export {
  userSchemas,
  imSchemas,
  gameSchemas,
  circleSchemas,
  commonSchemas,
  slowChatSchemas,
};

export const schemas = {
  ...userSchemas,
  ...imSchemas,
  ...gameSchemas,
  ...circleSchemas,
  ...commonSchemas,
  ...slowChatSchemas,
};

export default {
  validate,
  ...schemas,
};

