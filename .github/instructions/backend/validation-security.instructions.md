---
applyTo: "dating_app_api/src/schemas/**/*.ts, dating_app_api/src/middleware/**/*.ts, dating_app_api/src/routes/**/*.ts"
---

# 校验与安全规范

## 输入校验（Zod）

### 基本原则

- **全部校验**：所有用户输入都必须校验，禁止信任原始请求数据
- **使用 Zod**：统一使用 Zod Schema 进行 TypeScript 类型安全的校验
- **提前拒绝**：在 Controller 或 Route 层立即校验，失败立即返回 400

### Schema 定义

```typescript
// src/schemas/user.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email('Invalid email format'),
  name: z.string().min(1).max(50),
  password: z.string().min(8).max(50),
});

export const UpdateUserSchema = z.object({
  name: z.string().min(1).max(50).optional(),
  avatar: z.string().url().optional(),
});

export const PaginationSchema = z.object({
  page: z.number().int().positive().default(1),
  pageSize: z.number().int().positive().max(100).default(20),
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
export type UpdateUserInput = z.infer<typeof UpdateUserSchema>;
```

### 校验执行

```typescript
// src/controllers/user.ts
import { CreateUserSchema } from '../schemas/user';
import { ValidationError } from '../utils/errors';

export const userController = {
  async createUser(data: unknown) {
    try {
      const validated = CreateUserSchema.parse(data);
      return await userService.createUser(validated);
    } catch (error) {
      if (error instanceof z.ZodError) {
        throw new ValidationError(error.errors[0].message);
      }
      throw error;
    }
  },
};
```

### 或使用 Route 中间件

```typescript
// src/middleware/validate.ts
import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { ValidationError } from '../utils/errors';

export function validate(schema: z.ZodSchema) {
  return (req: Request, _res: Response, next: NextFunction) => {
    try {
      req.body = schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        next(new ValidationError(error.errors[0].message));
      } else {
        next(error);
      }
    }
  };
}

// 使用
router.post('/users', validate(CreateUserSchema), async (req, res, next) => {
  try {
    const result = await userController.createUser(req.body);
    res.json({ code: 200, message: 'Success', data: result });
  } catch (error) {
    next(error);
  }
});
```

## 敏感数据保护

### 环境变量管理

**禁止硬编码**任何敏感信息：

```typescript
// ❌ 错误
const DB_URL = 'postgresql://user:password@localhost:5432/db';
const JWT_SECRET = 'my-secret-key-12345';
const API_KEY = 'sk_test_xxxxx';

// ✅ 正确
const DB_URL = process.env.DATABASE_URL;
const JWT_SECRET = process.env.JWT_SECRET;
const API_KEY = process.env.TENCENT_IM_API_KEY;
```

**环境变量校验**：

```typescript
// src/config/env.ts
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['dev', 'test', 'prod']).default('dev'),
  PORT: z.number().default(3000),
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string(),
  REDIS_URL: z.string(),
  TENCENT_IM_APP_ID: z.string(),
  TENCENT_IM_SECRET_KEY: z.string(),
});

export const env = EnvSchema.parse(process.env);
```

### 密码哈希

```typescript
import bcrypt from 'bcrypt';

// 创建用户时加密密码
export async function hashPassword(password: string): Promise<string> {
  return await bcrypt.hash(password, 10);
}

// 验证密码
export async function verifyPassword(
  password: string,
  hash: string
): Promise<boolean> {
  return await bcrypt.compare(password, hash);
}

// Service 层
async createUser(data: { email: string; password: string }) {
  const passwordHash = await hashPassword(data.password);
  return await userRepository.create({
    email: data.email,
    passwordHash,  // 存储哈希值，不存储明文
  });
}
```

### 敏感字段过滤

```typescript
// Repository 返回时移除敏感字段
export async function getUserById(id: string) {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) return null;
  
  // 移除敏感字段
  const { passwordHash, ...safeUser } = user;
  return safeUser;
}
```

## SQL 注入防护

### ✅ 使用 Prisma（自动防护）

```typescript
// Prisma 自动处理参数绑定，防止 SQL 注入
const user = await prisma.user.findUnique({
  where: { email: userInput.email },  // 安全
});
```

### ❌ 避免拼接 SQL

```typescript
// ❌ 危险：直接拼接
const result = await prisma.$queryRaw(
  `SELECT * FROM users WHERE email = '${userInput.email}'`
);

// ✅ 正确：使用参数化查询
const result = await prisma.$queryRaw`
  SELECT * FROM users WHERE email = ${userInput.email}
`;
```

## XSS 防护

### HTML 转义

若需要返回用户生成的内容，必须转义：

```typescript
import DOMPurify from 'isomorphic-dompurify';

export function sanitizeHTML(html: string): string {
  return DOMPurify.sanitize(html);
}

// Service 层
async createPost(data: { title: string; content: string }) {
  return await postRepository.create({
    title: data.title,
    content: sanitizeHTML(data.content),  // 转义 HTML
  });
}
```

## CSRF 防护

使用中间件验证 CSRF Token（如果不是纯 API）：

```typescript
import csrf from 'csurf';
import cookieParser from 'cookie-parser';

app.use(cookieParser());
app.use(csrf({ cookie: true }));

// 返回 CSRF Token
app.get('/csrf-token', (req, res) => {
  res.json({ token: req.csrfToken() });
});

// 验证 CSRF Token（POST/PUT/DELETE 自动检查）
app.post('/users', (req, res) => {
  // csrfToken 中间件会自动验证
});
```

## 速率限制

防止恶意请求：

```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 分钟
  max: 100,                  // 最多 100 请求
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false,
});

// 应用到所有路由
app.use('/api/', limiter);

// 或针对特定端点（如登录）更严格
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,  // 登录只允许 5 次失败
});

app.post('/api/auth/login', loginLimiter, async (req, res, next) => {
  // ...
});
```

## 安全头

```typescript
import helmet from 'helmet';

// 设置安全头
app.use(helmet());

// 或自定义配置
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
      },
    },
  })
);
```

## 跨域（CORS）

```typescript
import cors from 'cors';

// 严格配置 CORS
app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true,  // 允许 Cookie
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
  })
);
```
