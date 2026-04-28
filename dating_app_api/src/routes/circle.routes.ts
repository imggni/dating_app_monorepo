import { Router } from 'express';

import circleController from '../controllers/circle.controller';
import authMiddleware = require('../middleware/auth.middleware');
import { validate } from '../middleware/validation.middleware';
import { circleCreateSchema, circleCommentSchema, circleLikeCommentSchema } from '../validators/circle.schemas';

const router = Router();

router.get('/list', circleController.getCircles);
router.get('/posts', circleController.getPosts);
router.get('/post/list', circleController.getPostList);
router.get('/post/filter', circleController.filterPosts);

router.post('/posts', authMiddleware, validate(circleCreateSchema), circleController.createPost);
router.get('/posts/:postId', circleController.getPostById);
router.delete('/posts/:postId', authMiddleware, circleController.deletePost);
router.post('/posts/:postId/like', authMiddleware, circleController.likePost);
router.post('/posts/:postId/unlike', authMiddleware, circleController.unlikePost);

router.get('/posts/:postId/comments', circleController.getComments);
router.post('/posts/:postId/comments', authMiddleware, validate(circleCommentSchema), circleController.commentPost);
router.post('/comment/like', authMiddleware, validate(circleLikeCommentSchema), circleController.likeComment);

export default router;

