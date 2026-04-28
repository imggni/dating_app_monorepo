import { z } from 'zod';

export const imSendSchema = z.object({
  body: z.object({
    receiverId: z.string().min(1),
    content: z.string().min(1),
    messageType: z.enum(['text', 'image', 'voice', 'video']).optional(),
  }),
});

export const imGetSchema = z.object({
  query: z.object({
    friendId: z.string().min(1),
    page: z.coerce.number().int().min(1).optional(),
    limit: z.coerce.number().int().min(1).max(100).optional(),
    before: z.string().optional(),
  }),
});

export const imMarkReadSchema = z.object({
  params: z.object({
    messageId: z.string().min(1),
  }),
});

export const imGroupSendSchema = z.object({
  params: z.object({ groupId: z.string().min(1) }),
  body: z.object({
    content: z.string().min(1),
    messageType: z.enum(['text', 'image', 'voice', 'video']).optional(),
  }),
});

export const imGroupGetSchema = z.object({
  params: z.object({ groupId: z.string().min(1) }),
  query: z
    .object({
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(100).optional(),
    })
    .optional(),
});

export const imGroupCreateSchema = z.object({
  body: z.object({
    name: z.string().min(1),
    memberIds: z.array(z.string()).optional(),
  }),
});

export const imGroupMemberSchema = z.object({
  body: z.object({
    groupId: z.string().min(1),
    memberId: z.string().min(1),
  }),
});

