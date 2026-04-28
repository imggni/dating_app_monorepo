import type { Request, Response, NextFunction } from 'express';

import logger = require('../utils/logger.util');

type RequestWithUser = Request & {
  user?: { id?: string } | undefined;
};

const sanitizeForLog = (req: RequestWithUser) => {
  const auth = req?.headers?.authorization;
  const hasAuth = typeof auth === 'string' && auth.length > 0;

  return {
    method: req.method,
    path: req.originalUrl,
    ip: req.ip,
    userId: req.user?.id,
    hasAuthHeader: hasAuth,
    userAgent: req.headers['user-agent'],
  };
};

const errorMiddleware = (err: any, req: RequestWithUser, res: Response, _next: NextFunction) => {
  const meta =
    process.env.NODE_ENV === 'development'
      ? {
          stack: err?.stack,
          request: sanitizeForLog(req),
          body: req.body,
          query: req.query,
          params: req.params,
        }
      : {
          request: sanitizeForLog(req),
        };

  logger.error(err?.message || 'Unknown error', meta);

  const status = err?.status || 500;
  const message = status === 500 ? '服务器内部错误' : err?.message;

  res.status(status).json({
    code: status,
    message,
    data: process.env.NODE_ENV === 'development' ? { stack: err?.stack } : null,
  });
};

export = errorMiddleware;

