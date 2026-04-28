import type { Request, Response, NextFunction } from 'express';

import circleService from '../services/circle.service';
import { sendOk } from '../utils/response.util';
import { HttpError } from '../errors/http-error';

const firstQueryValue = (v: unknown): string | undefined => {
  if (Array.isArray(v)) return typeof v[0] === 'string' ? v[0] : undefined;
  return typeof v === 'string' ? v : undefined;
};

const firstParamValue = (v: unknown): string => {
  if (Array.isArray(v)) return String(v[0]);
  return String(v);
};

type AuthedRequest = Request & { user?: { id?: string } | undefined };

const getUserId = (req: AuthedRequest) => {
  const uid = req.user?.id;
  if (!uid) throw new HttpError(401, '未登录');
  return uid;
};

const controller = {
  getCircles: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const result = await circleService.getCircles({ page: page ? Number(page) : 1, limit: limit ? Number(limit) : 20 });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  getPosts: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const result = await circleService.getPosts({
        userId: req.user?.id,
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
      });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  getPostList: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const circleId = firstQueryValue(q.circleId);
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const result = await circleService.getPostList({
        circleId,
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
      });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  createPost: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const result = await circleService.createPost(getUserId(req), req.body);
      return sendOk(res, result, '发布成功');
    } catch (err) {
      next(err);
    }
  },

  getPostById: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const postId = firstParamValue((req.params as any).postId);
      const result = await circleService.getPostById(postId);
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  deletePost: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const postId = firstParamValue((req.params as any).postId);
      const result = await circleService.deletePost(getUserId(req), postId);
      return sendOk(res, result, '删除成功');
    } catch (err) {
      next(err);
    }
  },

  likePost: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const postId = firstParamValue((req.params as any).postId);
      const result = await circleService.likePost(getUserId(req), postId);
      return sendOk(res, result, '点赞成功');
    } catch (err) {
      next(err);
    }
  },

  unlikePost: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const postId = firstParamValue((req.params as any).postId);
      const result = await circleService.unlikePost(getUserId(req), postId);
      return sendOk(res, result, '取消成功');
    } catch (err) {
      next(err);
    }
  },

  filterPosts: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const keyword = firstQueryValue(q.keyword);
      const tags = firstQueryValue(q.tags);
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const result = await circleService.filterPosts({
        keyword,
        tags,
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
      });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  getComments: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const q = req.query as any;
      const page = firstQueryValue(q.page);
      const limit = firstQueryValue(q.limit);
      const postId = firstParamValue((req.params as any).postId);
      const result = await circleService.getComments(postId, {
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
      });
      return sendOk(res, result, '成功');
    } catch (err) {
      next(err);
    }
  },

  commentPost: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const postId = firstParamValue((req.params as any).postId);
      const result = await circleService.commentPost(getUserId(req), postId, req.body);
      return sendOk(res, result, '评论成功');
    } catch (err) {
      next(err);
    }
  },

  likeComment: async (req: AuthedRequest, res: Response, next: NextFunction) => {
    try {
      const commentId = firstParamValue((req.params as any).commentId);
      const result = await circleService.likeComment(getUserId(req), commentId);
      return sendOk(res, result, '点赞成功');
    } catch (err) {
      next(err);
    }
  },
};

export default controller;

