import { Router } from 'express';

import userRoutes from './user.routes';
import imRoutes from './im.routes';
import gameRoutes from './game.routes';
import slowChatRoutes from './slow-chat.routes';
import circleRoutes from './circle.routes';
import commonRoutes from './common.routes';

const router = Router();

router.use('/users', userRoutes);
router.use('/im', imRoutes);
router.use('/game', gameRoutes);
router.use('/slow-chat', slowChatRoutes);
router.use('/circle', circleRoutes);
router.use('/common', commonRoutes);

export default router;

