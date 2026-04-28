---
applyTo: "dating_app_api/src/routes/**/*.ts, dating_app_api/src/controllers/**/*.ts, dating_app_api/src/services/**/*.ts, dating_app_api/src/repositories/**/*.ts"
---

# 后端架构分层规范

## 标准分层架构（强制）

```
Route 路由层 
  ↓
Controller 控制层
  ↓
Service 业务层
  ↓
Repository 数据层
  ↓
Model（数据库模型）
```

每一层职责明确，禁止跨层调用。

### Route 层（路由）

**职责**：请求入口，路由映射

- 定义 HTTP 端点（GET / POST / PUT / DELETE）
- 接收请求参数，调用 Controller
- 返回统一响应格式
- **禁止业务逻辑**

**示例**：

```typescript
// src/routes/user.ts
import { Router } from 'express';
import { userController } from '../controllers/user';

const router = Router();

router.post('/users', async (req, res, next) => {
  try {
    const result = await userController.createUser(req.body);
    res.json({ code: 200, message: 'Success', data: result });
  } catch (error) {
    next(error);
  }
});

export default router;
```

### Controller 层（控制层）

**职责**：请求处理，参数校验，调用 Service

- 接收 Route 层的参数
- 调用 Service 层处理业务逻辑
- 返回数据给 Route 层
- **禁止直接操作数据库**

**示例**：

```typescript
// src/controllers/user.ts
import { userService } from '../services/user';
import { CreateUserSchema } from '../schemas/user';

export const userController = {
  async createUser(data: unknown) {
    const validated = CreateUserSchema.parse(data);
    return await userService.createUser(validated);
  },
};
```

### Service 层（业务层）

**职责**：业务逻辑实现

- 调用 Repository 层获取数据
- 实现业务逻辑、规则校验
- 调用第三方服务（Redis、IM 等）
- **禁止直接返回数据库对象**

**示例**：

```typescript
// src/services/user.ts
import { userRepository } from '../repositories/user';

export const userService = {
  async createUser(data: { name: string; email: string }) {
    // Check business rules
    const existing = await userRepository.findByEmail(data.email);
    if (existing) {
      throw new Error('Email already exists');
    }

    // Create user
    const user = await userRepository.create(data);
    return user;
  },
};
```

### Repository 层（数据层）

**职责**：数据访问

- 使用 Prisma ORM 操作数据库
- 提供数据库 CRUD 操作接口
- **禁止业务逻辑**
- **禁止裸 SQL**

**示例**：

```typescript
// src/repositories/user.ts
import { prisma } from '../db';

export const userRepository = {
  async findByEmail(email: string) {
    return await prisma.user.findUnique({ where: { email } });
  },

  async create(data: { name: string; email: string }) {
    return await prisma.user.create({ data });
  },
};
```

## 禁止事项

- ❌ Route 直接调用 Service（必须走 Controller）
- ❌ Service 直接调用 Route（单向依赖）
- ❌ Repository 包含业务逻辑（只管数据访问）
- ❌ 跨模块直接调用（通过接口）
- ❌ 业务逻辑混在 Route/Controller 中

## 模块化拆分

按业务域组织路由，统一挂载：

```
src/
├── routes/
│   ├── index.ts          # 路由统一注册
│   ├── auth.ts           # 认证相关
│   ├── user.ts           # 用户相关
│   └── message.ts        # 消息相关
├── controllers/
│   ├── auth.ts
│   ├── user.ts
│   └── message.ts
├── services/
│   ├── auth.ts
│   ├── user.ts
│   └── message.ts
└── repositories/
    ├── user.ts
    ├── message.ts
    └── ...
```

**挂载示例**：

```typescript
// src/routes/index.ts
import authRoutes from './auth';
import userRoutes from './user';
import messageRoutes from './message';

export function registerRoutes(app: Express) {
  app.use('/api/auth', authRoutes);
  app.use('/api/users', userRoutes);
  app.use('/api/messages', messageRoutes);
}
```
