---
applyTo: "dating_app_api/src/routes/**/*.ts, dating_app_api/src/schemas/**/*.ts"
---

# API 契约与响应格式规范

## 统一响应契约

### 成功响应

```typescript
{
  code: 200,
  message: 'Success',
  data: {
    // 业务数据
  }
}
```

### 失败响应

```typescript
{
  code: 400,
  message: 'Email already exists',  // 用户可读的错误信息
  data: null
}
```

### TypeScript 类型定义

```typescript
// src/types/response.ts

export interface ApiResponse<T = any> {
  code: number;
  message: string;
  data: T | null;
}

export interface ListResponse<T> {
  code: number;
  message: string;
  data: {
    items: T[];
    total: number;
    page: number;
    pageSize: number;
  };
}
```

## 错误响应详解

| 错误码 | HTTP 状态 | 场景 | 响应示例 |
|-------|---------|------|--------|
| 200 | 200 | 成功 | `{ code: 200, message: 'Success', data: {...} }` |
| 400 | 400 | 参数错误 | `{ code: 400, message: 'Email format invalid', data: null }` |
| 400 | 400 | 业务校验失败 | `{ code: 400, message: 'Email already exists', data: null }` |
| 401 | 401 | 未认证 | `{ code: 401, message: 'Unauthorized', data: null }` |
| 403 | 403 | 权限不足 | `{ code: 403, message: 'Forbidden', data: null }` |
| 404 | 404 | 资源不存在 | `{ code: 404, message: 'User not found', data: null }` |
| 409 | 409 | 冲突 | `{ code: 409, message: 'Email already exists', data: null }` |
| 500 | 500 | 服务异常 | `{ code: 500, message: 'Internal Server Error', data: null }` |

## RESTful 路由设计

### 路由命名规范

- 路径使用小写 + 连字符：`/api/user-profiles` ✅ 不要 `/UserProfiles`
- 资源名称用名词复数：`/users` 而不是 `/user`
- 操作通过 HTTP 方法表示

### 标准端点

```typescript
// 列表（查询参数分页）
GET /api/users?page=1&pageSize=20
Response: {
  code: 200,
  message: 'Success',
  data: {
    items: [ { id, name, email, createdAt }, ... ],
    total: 100,
    page: 1,
    pageSize: 20
  }
}

// 详情
GET /api/users/:id
Response: {
  code: 200,
  message: 'Success',
  data: { id, name, email, createdAt, updatedAt }
}

// 创建
POST /api/users
Request Body: { email, name, password }
Response: {
  code: 200,
  message: 'User created successfully',
  data: { id, name, email, createdAt }
}

// 更新
PUT /api/users/:id
Request Body: { name?, avatar? }
Response: {
  code: 200,
  message: 'User updated successfully',
  data: { id, name, email, avatar, updatedAt }
}

// 删除
DELETE /api/users/:id
Response: {
  code: 200,
  message: 'User deleted successfully',
  data: null
}
```

## 分页响应

```typescript
// src/routes/user.ts
router.get(
  '/users',
  validate(PaginationSchema),
  asyncHandler(async (req, res) => {
    const { page, pageSize } = req.query;
    
    const [items, total] = await Promise.all([
      userService.getUsersPaginated(page, pageSize),
      userService.getUserCount(),
    ]);

    res.json({
      code: 200,
      message: 'Success',
      data: {
        items,
        total,
        page,
        pageSize,
      },
    });
  })
);
```

## Response Schema 定义

### 响应模型

```typescript
// src/schemas/user.ts
import { z } from 'zod';

// ❌ 不推荐：混合请求和响应
export const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string(),
  passwordHash: z.string(),  // 不应该在响应中
  createdAt: z.date(),
});

// ✅ 推荐：分离请求和响应
export const CreateUserRequestSchema = z.object({
  email: z.string().email('Invalid email'),
  name: z.string().min(1).max(50),
  password: z.string().min(8).max(50),
});

export const UserResponseSchema = z.object({
  id: z.string(),
  email: z.string(),
  name: z.string(),
  avatar: z.string().nullable(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

export type CreateUserRequest = z.infer<typeof CreateUserRequestSchema>;
export type UserResponse = z.infer<typeof UserResponseSchema>;
```

### 返回响应

```typescript
// src/routes/user.ts
import { ApiResponse } from '../types/response';
import { UserResponse } from '../schemas/user';

router.get(
  '/users/:id',
  asyncHandler(async (req, res): Promise<void> => {
    const user = await userService.getUserById(req.params.id);
    
    if (!user) {
      res.status(404).json({
        code: 404,
        message: 'User not found',
        data: null,
      } as ApiResponse<null>);
      return;
    }

    res.json({
      code: 200,
      message: 'Success',
      data: user,
    } as ApiResponse<UserResponse>);
  })
);
```

## 嵌套资源

对于关系数据，使用嵌套路由：

```typescript
// 用户的消息
GET /api/users/:userId/messages

// 消息的评论
GET /api/messages/:messageId/comments

// Response 包含关系数据
{
  code: 200,
  message: 'Success',
  data: {
    id: 'msg-1',
    content: 'Hello',
    sender: { id: 'user-1', name: 'Alice' },
    comments: [
      { id: 'cmt-1', content: 'Nice!', author: { id: 'user-2', name: 'Bob' } }
    ],
    createdAt: '2024-01-01T00:00:00Z'
  }
}
```

## 批量操作

```typescript
// 批量删除
POST /api/users/batch-delete
Request: { ids: ['user-1', 'user-2'] }
Response: {
  code: 200,
  message: 'Users deleted',
  data: { deletedCount: 2 }
}

// 批量更新
POST /api/users/batch-update
Request: { updates: [{ id: 'user-1', name: 'Alice' }] }
Response: {
  code: 200,
  message: 'Users updated',
  data: { updatedCount: 1 }
}
```

## 搜索与过滤

```typescript
// Query 参数用于过滤、搜索
GET /api/users?search=alice&status=active&sort=-createdAt&page=1&pageSize=20

Response: {
  code: 200,
  message: 'Success',
  data: {
    items: [...],
    total: 50,
    page: 1,
    pageSize: 20
  }
}
```

## 速率限制响应

若触发速率限制，返回 429：

```typescript
{
  code: 429,
  message: 'Too many requests',
  data: {
    retryAfter: 60  // 秒数
  }
}
```
