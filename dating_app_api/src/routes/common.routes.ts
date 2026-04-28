import { Router } from 'express';
import multer from 'multer';

import commonController from '../controllers/common.controller';
import authMiddleware = require('../middleware/auth.middleware');
import { validate } from '../middleware/validation.middleware';
import { tokenRefreshSchema } from '../validators/user.schemas';
import { sensitiveFilterSchema } from '../validators/common.schemas';

const router = Router();

const upload = multer({
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const allowedTypes = [
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
      'audio/mpeg',
      'audio/wav',
      'audio/ogg',
      'video/mp4',
      'video/avi',
      'video/mov',
      'application/pdf',
      'text/plain',
      'application/msword',
    ];

    if (allowedTypes.includes(file.mimetype)) cb(null, true);
    else cb(new Error('不支持的文件类型'));
  },
});

router.post('/upload', authMiddleware, upload.single('file'), commonController.uploadFile);
router.post('/token/refresh', validate(tokenRefreshSchema), commonController.refreshToken);
router.post('/sensitive/filter', authMiddleware, validate(sensitiveFilterSchema), commonController.filterSensitiveContent);
router.get('/regions', commonController.getRegions);
router.get('/regions/:code', commonController.getRegionByCode);
router.get('/dictionaries', commonController.getDictionaries);
router.get('/configs', commonController.getConfigs);
router.get('/oss/token', authMiddleware, commonController.getOssToken);

export default router;

