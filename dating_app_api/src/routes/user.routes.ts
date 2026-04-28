import { Router } from 'express';

import userController from '../controllers/user.controller';
import authMiddleware = require('../middleware/auth.middleware');
import { validate } from '../middleware/validation.middleware';
import {
  userRegisterSchema,
  userLoginSchema,
  userUpdateSchema,
  friendRequestSchema,
  friendHandleSchema,
} from '../validators/user.schemas';

const router = Router();

router.post('/register', validate(userRegisterSchema), userController.register);
router.post('/login', validate(userLoginSchema), userController.login);
router.get('/profile', authMiddleware, userController.getProfile);
router.put('/profile', authMiddleware, validate(userUpdateSchema), userController.updateProfile);
router.post('/friend/request', authMiddleware, validate(friendRequestSchema), userController.sendFriendRequest);
router.put('/friend/handle', authMiddleware, validate(friendHandleSchema), userController.handleFriendRequest);
router.get('/friend/list', authMiddleware, userController.getFriendList);
router.post('/logout', authMiddleware, userController.logout);
router.get('/online/:userId', userController.getOnlineStatus);

export default router;

