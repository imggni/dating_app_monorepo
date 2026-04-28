import { z } from 'zod';

export const gameCreateSchema = z.object({
  body: z.object({
    name: z.string().min(1, '房间名称不能为空'),
    maxPlayers: z.coerce.number().int().min(2).max(10).optional(),
    gameType: z.string().optional(),
  }),
});

export const brushSyncSchema = z.object({
  body: z.object({
    roomId: z.string().min(1),
    round: z.coerce.number().int().min(1).optional(),
    content: z.unknown(),
  }),
});

export const roundActionSchema = z.object({
  params: z.object({ roomId: z.string().min(1) }),
});

