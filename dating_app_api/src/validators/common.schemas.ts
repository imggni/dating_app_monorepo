import { z } from 'zod';

export const sensitiveFilterSchema = z.object({
  body: z.object({
    content: z.string().min(1, '内容不能为空'),
    type: z.enum(['text', 'image']).optional().default('text'),
  }),
});

