import type { Request, Response, NextFunction } from 'express';

import logger = require('../utils/logger.util');

export default (req: Request, _res: Response, next: NextFunction) => {
  logger.info(`${req.method} ${req.url}`);
  next();
};

