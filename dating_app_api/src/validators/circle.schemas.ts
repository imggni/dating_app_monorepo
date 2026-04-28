import { z } from 'zod';

export const circleCreateSchema = z.object({
  body: z.object({
    circleId: z.string().min(1, '圈子ID不能为空'),
    content: z.string().min(1, '内容不能为空'),
    images: z.array(z.string().url()).max(9).optional(),
  }),
});

export const circleCommentSchema = z.object({
  body: z.object({
    content: z.string().min(1, '评论不能为空'),
  }),
});

export const circleLikeCommentSchema = z.object({
  body: z.object({
    commentId: z.string().min(1, '评论ID不能为空'),
  }),
});

