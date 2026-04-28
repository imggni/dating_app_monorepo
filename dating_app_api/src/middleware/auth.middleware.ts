import jwt, { JsonWebTokenError, TokenExpiredError } from 'jsonwebtoken';
import type { Request, Response, NextFunction } from 'express';

import config = require('../config/server.config');
import { HttpError } from '../errors/http-error';

type AuthedRequest = Request & {
  user?: unknown;
};

const authMiddleware = (req: AuthedRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return next(new HttpError(401, '未提供认证令牌'));
  }

  if (!config.jwtSecret) {
    return next(new HttpError(500, '服务端未配置 JWT_SECRET'));
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return next(new HttpError(401, '令牌格式不正确'));
  }

  const token = parts[1];
  try {
    const decoded = jwt.verify(token, config.jwtSecret);
    req.user = decoded;
    next();
  } catch (err) {
    if (err instanceof TokenExpiredError || (err as JsonWebTokenError)?.name === 'TokenExpiredError') {
      return next(new HttpError(401, '令牌已过期'));
    }
    return next(new HttpError(401, '令牌无效或已过期'));
  }
};

export = authMiddleware;

