---
applyTo: "dating_app_api/src/middleware/**/*.ts, dating_app_api/src/**/*.ts"
---

# 错误处理与异常规范

## 统一响应格式

所有 API 响应必须遵循统一格式：

```typescript
// 成功响应
{
  code: 200,
  message: 'Success',
  data: { /* 业务数据 */ }
}

// 失败响应
{
  code: 400,       // HTTP 状态码
  message: 'Email already exists',  // 用户可读的错误信息
  data: null       // 可选的错误详情
}
```

## 错误码标准

| 错误码 | HTTP 状态 | 场景 |
|-------|---------|------|
| 200 | 200 | 成功 |
| 400 | 400 | 参数错误、业务校验失败 |
| 401 | 401 | 未认证（无有效 Token） |
| 403 | 403 | 权限不足（Token 有效但无权限） |
| 404 | 404 | 资源不存在 |
| 409 | 409 | 冲突（如唯一性约束冲突） |
| 500 | 500 | 服务异常、未捕获异常 |

## 异常类定义

```typescript
// src/utils/errors.ts

export class AppError extends Error {
  constructor(
    public code: number,
    message: string,
    public statusCode: number = 500
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

// 业务异常
export class ValidationError extends AppError {
  constructor(message: string) {
    super(400, message, 400);
  }
}

export class NotFoundError extends AppError {
  constructor(message: string) {
    super(404, message, 404);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(401, message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') {
    super(403, message, 403);
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(409, message, 409);
  }
}

export class InternalError extends AppError {
  constructor(message: string = 'Internal Server Error') {
    super(500, message, 500);
  }
}
```

## Service 层异常处理

```typescript
// src/services/user.ts
import { ValidationError, ConflictError } from '../utils/errors';
import { userRepository } from '../repositories/user';

export const userService = {
  async createUser(data: { email: string; name: string }) {
    // 业务校验
    if (!data.email || !data.name) {
      throw new ValidationError('Email and name are required');
    }

    // 检查唯一性约束
    const existing = await userRepository.findByEmail(data.email);
    if (existing) {
      throw new ConflictError('Email already exists');
    }

    // 创建用户
    return await userRepository.create(data);
  },
};
```

## 全局错误中间件

```typescript
// src/middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors';

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
) {
  console.error('Error:', err);

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      code: err.code,
      message: err.message,
      data: null,
    });
  }

  // 未知异常
  res.status(500).json({
    code: 500,
    message: 'Internal Server Error',
    data: null,
  });
}
```

## Route 层异常捕获

```typescript
// src/routes/user.ts
import { Router } from 'express';
import { userController } from '../controllers/user';

const router = Router();

// 异步 Route 必须用 try-catch 或中间件包装
router.post('/users', async (req, res, next) => {
  try {
    const result = await userController.createUser(req.body);
    res.json({ code: 200, message: 'Success', data: result });
  } catch (error) {
    next(error);  // 传递给 errorHandler 中间件
  }
});

export default router;
```

## Async 路由包装器

为避免重复的 try-catch，可以创建包装器：

```typescript
// src/utils/asyncHandler.ts
import { Request, Response, NextFunction } from 'express';

export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<void>
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

// 使用
router.post(
  '/users',
  asyncHandler(async (req, res) => {
    const result = await userController.createUser(req.body);
    res.json({ code: 200, message: 'Success', data: result });
  })
);
```

## 日志记录

关键异常必须记录日志：

```typescript
// 在 errorHandler 中增加日志
export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
) {
  const requestId = req.get('x-request-id') || 'unknown';
  const timestamp = new Date().toISOString();

  console.error(`[${timestamp}] [${requestId}] Error:`, {
    path: req.path,
    method: req.method,
    error: err.message,
    stack: err.stack,
  });

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      code: err.code,
      message: err.message,
      data: null,
      requestId,
    });
  }

  res.status(500).json({
    code: 500,
    message: 'Internal Server Error',
    data: null,
    requestId,
  });
}
```

## 常见错误模式

### ❌ 错误：同步抛出异常

```typescript
// 异步路由必须用 try-catch
router.post('/users', (req, res) => {
  const result = userService.createUser(req.body);  // 未 await，异常不会被捕获
  res.json(result);
});
```

### ✅ 正确：异步 await + try-catch

```typescript
router.post('/users', async (req, res, next) => {
  try {
    const result = await userService.createUser(req.body);
    res.json({ code: 200, message: 'Success', data: result });
  } catch (error) {
    next(error);
  }
});
```

### ❌ 错误：Prisma 异常不处理

```typescript
// Prisma 异常可能不会被自动捕获
const user = await prisma.user.findUniqueOrThrow({ where: { id: 'xxx' } });
```

### ✅ 正确：明确处理 Prisma 异常

```typescript
try {
  const user = await prisma.user.findUnique({ where: { id: 'xxx' } });
  if (!user) {
    throw new NotFoundError('User not found');
  }
  return user;
} catch (error) {
  if (error instanceof PrismaClientKnownRequestError) {
    throw new InternalError('Database error');
  }
  throw error;
}
```
