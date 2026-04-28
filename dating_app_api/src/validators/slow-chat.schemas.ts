import { z } from 'zod';

export const slowSendSchema = z.object({
  body: z.object({
    receiverId: z.string().min(1),
    title: z.string().min(1).max(50).optional(),
    content: z.string().min(1),
    messageType: z.string().optional(),
    delayTime: z.coerce.number().int().min(0).optional(),
    isAnonymous: z.coerce.boolean().optional(),
  }),
});

