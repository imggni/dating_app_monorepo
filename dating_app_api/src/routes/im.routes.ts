import { Router } from 'express';

import imController from '../controllers/im.controller';
import authMiddleware = require('../middleware/auth.middleware');
import { validate } from '../middleware/validation.middleware';
import {
  imSendSchema,
  imGroupSendSchema,
  imGroupGetSchema,
  imGetSchema,
  imMarkReadSchema,
  imGroupCreateSchema,
  imGroupMemberSchema,
} from '../validators/im.schemas';

const router = Router();

router.get('/messages', authMiddleware, validate(imGetSchema), imController.getMessages);
router.post('/group/create', authMiddleware, validate(imGroupCreateSchema), imController.createGroup);
router.put('/group/member/add', authMiddleware, validate(imGroupMemberSchema), imController.addGroupMember);
router.put('/group/member/remove', authMiddleware, validate(imGroupMemberSchema), imController.removeGroupMember);
router.post('/send', authMiddleware, validate(imSendSchema), imController.sendMessage);
router.get('/conversations', authMiddleware, imController.getConversations);
router.put('/messages/:messageId/read', authMiddleware, validate(imMarkReadSchema), imController.markAsRead);
router.put('/messages/:messageId/recall', authMiddleware, imController.recallMessage);
router.get('/unread/count', authMiddleware, imController.getUnreadCount);
router.get('/group/:groupId/messages', authMiddleware, validate(imGroupGetSchema), imController.getGroupMessages);
router.post('/group/:groupId/send', authMiddleware, validate(imGroupSendSchema), imController.sendGroupMessage);

export default router;

