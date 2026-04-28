import { z } from 'zod';

export const userRegisterSchema = z.object({
  body: z.object({
    phone: z.string().regex(/^1[3-9]\d{9}$/, '手机号格式不正确'),
    password: z.string().min(6).max(20, '密码长度应为6-20位'),
    nickname: z.string().min(1).max(50, '昵称长度应为1-50位'),
    gender: z.enum(['male', 'female', 'other']).optional(),
    age: z.coerce.number().int().min(1).max(150).optional(),
  }),
});

export const userLoginSchema = z.object({
  body: z.object({
    phone: z.string().regex(/^1[3-9]\d{9}$/, '手机号格式不正确'),
    password: z.string().min(1, '密码不能为空'),
  }),
});

export const userUpdateSchema = z.object({
  body: z.object({
    nickname: z.string().min(1).max(50, '昵称长度应为1-50位').optional(),
    avatar: z.string().url('头像必须是合法URL').optional(),
    gender: z.enum(['male', 'female', 'other']).optional(),
    age: z.coerce.number().int().min(1).max(150).optional(),
    bio: z.string().max(200, '个人简介不能超过200字').optional(),
    tags: z.array(z.string()).optional(),
  }),
});

export const friendRequestSchema = z.object({
  body: z.object({
    friendId: z.string().min(1, 'friendId不能为空'),
    message: z.string().max(200).optional(),
  }),
});

export const friendHandleSchema = z.object({
  body: z.object({
    requestId: z.string().min(1, 'requestId不能为空'),
    action: z.enum(['accept', 'reject']),
  }),
});

export const tokenRefreshSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, '刷新令牌不能为空'),
  }),
});

