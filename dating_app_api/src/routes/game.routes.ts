import { Router } from 'express';

import gameController from '../controllers/game.controller';
import authMiddleware = require('../middleware/auth.middleware');
import { validate } from '../middleware/validation.middleware';
import { gameCreateSchema, brushSyncSchema, roundActionSchema } from '../validators/game.schemas';

const router = Router();

router.get('/rooms', gameController.getRooms);
router.post('/create', authMiddleware, validate(gameCreateSchema), gameController.createRoom);
router.get('/rooms/:roomId', gameController.getRoomById);
router.post('/rooms/:roomId/join', authMiddleware, gameController.joinRoom);
router.post('/rooms/:roomId/leave', authMiddleware, gameController.leaveRoom);
router.post('/rooms/:roomId/start', authMiddleware, gameController.startGame);
router.post('/brush/sync', authMiddleware, validate(brushSyncSchema), gameController.syncBrush);
router.put('/rooms/:roomId/round/start', authMiddleware, validate(roundActionSchema), gameController.startRound);
router.put('/rooms/:roomId/round/end', authMiddleware, validate(roundActionSchema), gameController.endRound);
router.delete('/rooms/:roomId/destroy', authMiddleware, validate(roundActionSchema), gameController.destroyRoom);

export default router;

