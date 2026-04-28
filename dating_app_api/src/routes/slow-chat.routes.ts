import { Router } from 'express';

import slowChatController from '../controllers/slow-chat.controller';
import authMiddleware = require('../middleware/auth.middleware');
import { validate } from '../middleware/validation.middleware';
import { slowSendSchema } from '../validators/slow-chat.schemas';

const router = Router();

router.get('/rooms', slowChatController.getRooms);
router.post('/rooms', authMiddleware, slowChatController.createRoom);
router.get('/rooms/:roomId', slowChatController.getRoomById);
router.post('/rooms/:roomId/join', authMiddleware, slowChatController.joinRoom);
router.post('/rooms/:roomId/leave', authMiddleware, slowChatController.leaveRoom);
router.get('/rooms/:roomId/messages', authMiddleware, slowChatController.getRoomMessages);

router.post('/send', authMiddleware, validate(slowSendSchema), slowChatController.sendSlowMessage);
router.put('/messages/:messageId/open', authMiddleware, slowChatController.openSlowMessage);
router.delete('/messages/:messageId', authMiddleware, slowChatController.deleteSlowMessage);
router.put('/messages/:messageId/anonymous', authMiddleware, slowChatController.setAnonymous);

export default router;

