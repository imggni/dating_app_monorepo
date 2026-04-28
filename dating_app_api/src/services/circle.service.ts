import prisma = require('../prisma/prisma');
import { HttpError } from '../errors/http-error';

export const getCircles = async (args: { page?: number; limit?: number } = {}) => {
  const page = args.page ?? 1;
  const limit = args.limit ?? 20;
  const skip = (page - 1) * limit;

  const circles = await prisma.circle.findMany({ orderBy: { createdAt: 'desc' }, skip, take: limit });
  const total = await prisma.circle.count();

  return {
    circles: circles.map((c: any) => ({
      id: c.id,
      name: c.name,
      description: c.description,
      coverImage: c.coverImage,
      memberCount: c.memberCount,
      createdAt: c.createdAt,
    })),
    pagination: { page, limit, total, hasMore: total > skip + circles.length },
  };
};

export const getPosts = async (args: { userId?: string; page?: number; limit?: number } = {}) => {
  const page = args.page ?? 1;
  const limit = args.limit ?? 20;
  const skip = (page - 1) * limit;

  const posts = await prisma.circlePost.findMany({
    where: { isDeleted: false },
    orderBy: { createdAt: 'desc' },
    skip,
    take: limit,
    include: {
      user: { select: { id: true, nickname: true, avatar: true } },
      circle: { select: { id: true, name: true } },
    },
  });

  const total = await prisma.circlePost.count({ where: { isDeleted: false } });

  return {
    posts: posts.map((p: any) => ({
      id: p.id,
      userId: p.userId,
      nickname: p.user?.nickname,
      avatar: p.user?.avatar,
      circleId: p.circleId,
      circleName: p.circle?.name,
      content: p.content,
      images: p.images ? JSON.parse(p.images) : [],
      likes: p.likes,
      comments: p.comments,
      isLiked: false,
      createdAt: p.createdAt,
    })),
    pagination: { page, limit, total, hasMore: total > skip + posts.length },
  };
};

export const getPostList = async (args: { circleId?: string; page?: number; limit?: number } = {}) => {
  const { circleId } = args;
  const page = args.page ?? 1;
  const limit = args.limit ?? 20;
  const skip = (page - 1) * limit;

  const where: any = { isDeleted: false };
  if (circleId) where.circleId = circleId;

  const posts = await prisma.circlePost.findMany({
    where,
    orderBy: { createdAt: 'desc' },
    skip,
    take: limit,
    include: {
      user: { select: { id: true, nickname: true, avatar: true } },
      circle: { select: { id: true, name: true } },
    },
  });

  const total = await prisma.circlePost.count({ where });
  return {
    posts: posts.map((p: any) => ({
      id: p.id,
      userId: p.userId,
      nickname: p.user?.nickname,
      avatar: p.user?.avatar,
      circleId: p.circleId,
      circleName: p.circle?.name,
      content: p.content,
      images: p.images ? JSON.parse(p.images) : [],
      likes: p.likes,
      comments: p.comments,
      createdAt: p.createdAt,
    })),
    pagination: { page, limit, total, hasMore: total > skip + posts.length },
  };
};

export const createPost = async (userId: string, args: { circleId: string; content: string; images?: string[] }) => {
  const { circleId, content } = args;
  const images = args.images ?? [];

  if (!content || content.trim().length === 0) throw new HttpError(400, '内容不能为空');
  if (!circleId) throw new HttpError(400, '圈子ID不能为空');

  const circle = await prisma.circle.findUnique({ where: { id: circleId } });
  if (!circle) throw new HttpError(404, '圈子不存在');

  const post = await prisma.circlePost.create({
    data: { userId, circleId, content, images: images.length ? JSON.stringify(images) : null },
  });
  return { postId: post.id };
};

export const getPostById = async (postId: string) => {
  const post = await prisma.circlePost.findUnique({
    where: { id: postId, isDeleted: false } as any,
    include: {
      user: { select: { id: true, nickname: true, avatar: true } },
      circle: { select: { id: true, name: true } },
    },
  });
  if (!post) throw new HttpError(404, '帖子不存在');

  return {
    id: (post as any).id,
    userId: (post as any).userId,
    nickname: (post as any).user?.nickname,
    avatar: (post as any).user?.avatar,
    circleId: (post as any).circleId,
    circleName: (post as any).circle?.name,
    content: (post as any).content,
    images: (post as any).images ? JSON.parse((post as any).images) : [],
    likes: (post as any).likes,
    comments: (post as any).comments,
    createdAt: (post as any).createdAt,
  };
};

export const deletePost = async (userId: string, postId: string) => {
  const post = await prisma.circlePost.findUnique({ where: { id: postId } });
  if (!post) throw new HttpError(404, '帖子不存在');
  if ((post as any).userId !== userId) throw new HttpError(403, '无权删除此帖子');

  await prisma.circlePost.update({ where: { id: postId }, data: { isDeleted: true } });
  return { success: true };
};

export const likePost = async (_userId: string, postId: string) => {
  const post = await prisma.circlePost.findUnique({ where: { id: postId, isDeleted: false } as any });
  if (!post) throw new HttpError(404, '帖子不存在');

  const updated = await prisma.circlePost.update({ where: { id: postId }, data: { likes: { increment: 1 } } });
  return { likes: (updated as any).likes };
};

export const unlikePost = async (_userId: string, postId: string) => {
  const post = await prisma.circlePost.findUnique({ where: { id: postId, isDeleted: false } as any });
  if (!post) throw new HttpError(404, '帖子不存在');

  const newCount = Math.max(0, ((post as any).likes || 0) - 1);
  const updated = await prisma.circlePost.update({ where: { id: postId }, data: { likes: newCount } });
  return { likes: (updated as any).likes };
};

export const filterPosts = async (args: { keyword?: string; tags?: string; page?: number; limit?: number } = {}) => {
  const page = args.page ?? 1;
  const limit = args.limit ?? 20;
  const skip = (page - 1) * limit;

  const where: any = { isDeleted: false };
  if (args.keyword) where.content = { contains: args.keyword };
  if (args.tags) where.content = { ...(where.content || {}), contains: args.tags };

  const posts = await prisma.circlePost.findMany({
    where,
    orderBy: { createdAt: 'desc' },
    skip,
    take: limit,
    include: {
      user: { select: { id: true, nickname: true, avatar: true } },
      circle: { select: { id: true, name: true } },
    },
  });
  const total = await prisma.circlePost.count({ where });

  return {
    posts: posts.map((p: any) => ({
      id: p.id,
      userId: p.userId,
      nickname: p.user?.nickname,
      avatar: p.user?.avatar,
      circleId: p.circleId,
      circleName: p.circle?.name,
      content: p.content,
      images: p.images ? JSON.parse(p.images) : [],
      likes: p.likes,
      comments: p.comments,
      createdAt: p.createdAt,
    })),
    pagination: { page, limit, total, hasMore: total > skip + posts.length },
  };
};

export const getComments = async (postId: string, args: { page?: number; limit?: number } = {}) => {
  const page = args.page ?? 1;
  const limit = args.limit ?? 20;
  const skip = (page - 1) * limit;

  const comments = await prisma.circleComment.findMany({
    where: { postId },
    orderBy: { createdAt: 'desc' },
    skip,
    take: limit,
    include: { user: { select: { id: true, nickname: true, avatar: true } } },
  });
  const total = await prisma.circleComment.count({ where: { postId } });

  return {
    comments: comments.map((c: any) => ({
      id: c.id,
      userId: c.userId,
      nickname: c.user?.nickname,
      avatar: c.user?.avatar,
      content: c.content,
      likes: c.likes,
      createdAt: c.createdAt,
    })),
    pagination: { page, limit, total, hasMore: total > skip + comments.length },
  };
};

export const commentPost = async (userId: string, postId: string, args: { content: string }) => {
  const { content } = args;
  if (!content || content.trim().length === 0) throw new HttpError(400, '评论内容不能为空');

  const post = await prisma.circlePost.findUnique({ where: { id: postId, isDeleted: false } as any });
  if (!post) throw new HttpError(404, '帖子不存在');

  const comment = await prisma.circleComment.create({ data: { postId, userId, content } });
  await prisma.circlePost.update({ where: { id: postId }, data: { comments: { increment: 1 } } });
  return { commentId: comment.id };
};

export const likeComment = async (_userId: string, commentId: string) => {
  const comment = await prisma.circleComment.findUnique({ where: { id: commentId } });
  if (!comment) throw new HttpError(404, '评论不存在');

  const updated = await prisma.circleComment.update({ where: { id: commentId }, data: { likes: { increment: 1 } } });
  return { likes: (updated as any).likes };
};

export default {
  getCircles,
  getPosts,
  getPostList,
  createPost,
  getPostById,
  deletePost,
  likePost,
  unlikePost,
  filterPosts,
  getComments,
  commentPost,
  likeComment,
};

