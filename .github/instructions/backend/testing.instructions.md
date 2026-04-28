---
applyTo: "dating_app_api/**/*.test.ts, dating_app_api/**/*.spec.ts, dating_app_api/test/**"
---

# 后端测试规范

## 测试结构

```
dating_app_api/
├── src/
│   ├── routes/
│   ├── controllers/
│   ├── services/
│   └── repositories/
├── test/
│   ├── fixtures/          # 测试数据
│   ├── unit/              # 单元测试
│   │   ├── services/
│   │   ├── repositories/
│   │   └── utils/
│   ├── integration/       # 集成测试
│   │   └── routes/
│   └── setup.ts           # 测试环境
└── package.json
```

## 测试框架

使用 **Jest** 或 **Vitest**（推荐用与项目一致的框架）

```json
{
  "devDependencies": {
    "@types/jest": "^29.5.0",
    "jest": "^29.5.0",
    "ts-jest": "^29.1.0",
    "supertest": "^6.3.0"
  },
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

## 单元测试

### Service 层测试

```typescript
// test/unit/services/user.test.ts
import { userService } from '../../../src/services/user';
import { userRepository } from '../../../src/repositories/user';
import { ValidationError, ConflictError } from '../../../src/utils/errors';

jest.mock('../../../src/repositories/user');

describe('UserService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createUser', () => {
    it('should create a user with valid data', async () => {
      const userData = {
        email: 'test@test.com',
        name: 'Test User',
        password: 'password123',
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);
      (userRepository.create as jest.Mock).mockResolvedValue({
        id: '1',
        ...userData,
      });

      const result = await userService.createUser(userData);

      expect(result.id).toBe('1');
      expect(userRepository.findByEmail).toHaveBeenCalledWith(userData.email);
      expect(userRepository.create).toHaveBeenCalled();
    });

    it('should throw ConflictError if email already exists', async () => {
      const userData = {
        email: 'existing@test.com',
        name: 'Test User',
        password: 'password123',
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue({
        id: '2',
        email: userData.email,
      });

      await expect(userService.createUser(userData)).rejects.toThrow(
        ConflictError
      );
    });

    it('should throw ValidationError if email is invalid', async () => {
      const userData = {
        email: 'invalid-email',  // 无效邮箱
        name: 'Test User',
        password: 'password123',
      };

      await expect(userService.createUser(userData)).rejects.toThrow(
        ValidationError
      );
    });
  });
});
```

### Repository 层测试

```typescript
// test/unit/repositories/user.test.ts
import { userRepository } from '../../../src/repositories/user';
import { prisma } from '../../../src/db';

jest.mock('../../../src/db');

describe('UserRepository', () => {
  describe('findByEmail', () => {
    it('should return user if found', async () => {
      const mockUser = {
        id: '1',
        email: 'test@test.com',
        name: 'Test',
      };

      (prisma.user.findUnique as jest.Mock).mockResolvedValue(mockUser);

      const result = await userRepository.findByEmail('test@test.com');

      expect(result).toEqual(mockUser);
      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { email: 'test@test.com' },
      });
    });

    it('should return null if user not found', async () => {
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(null);

      const result = await userRepository.findByEmail('notfound@test.com');

      expect(result).toBeNull();
    });
  });
});
```

## 集成测试

### Route 层测试（E2E）

```typescript
// test/integration/routes/user.test.ts
import request from 'supertest';
import { app } from '../../../src/app';
import { prisma } from '../../../src/db';

describe('User Routes', () => {
  beforeAll(async () => {
    // 连接测试数据库
  });

  afterEach(async () => {
    // 清理测试数据
    await prisma.user.deleteMany();
  });

  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          email: 'newuser@test.com',
          name: 'New User',
          password: 'password123',
        });

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        code: 200,
        message: 'User created successfully',
        data: {
          id: expect.any(String),
          email: 'newuser@test.com',
          name: 'New User',
          createdAt: expect.any(String),
        },
      });
    });

    it('should return 400 for invalid email', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          email: 'invalid-email',
          name: 'User',
          password: 'password123',
        });

      expect(response.status).toBe(400);
      expect(response.body.code).toBe(400);
    });

    it('should return 409 if email already exists', async () => {
      // 先创建一个用户
      await request(app)
        .post('/api/users')
        .send({
          email: 'duplicate@test.com',
          name: 'User 1',
          password: 'password123',
        });

      // 尝试用同一邮箱创建
      const response = await request(app)
        .post('/api/users')
        .send({
          email: 'duplicate@test.com',
          name: 'User 2',
          password: 'password123',
        });

      expect(response.status).toBe(409);
      expect(response.body.code).toBe(409);
    });
  });

  describe('GET /api/users/:id', () => {
    it('should return user by id', async () => {
      // 先创建用户
      const createResponse = await request(app)
        .post('/api/users')
        .send({
          email: 'test@test.com',
          name: 'Test User',
          password: 'password123',
        });

      const userId = createResponse.body.data.id;

      const response = await request(app).get(`/api/users/${userId}`);

      expect(response.status).toBe(200);
      expect(response.body.data.id).toBe(userId);
      expect(response.body.data.email).toBe('test@test.com');
    });

    it('should return 404 if user not found', async () => {
      const response = await request(app).get('/api/users/nonexistent-id');

      expect(response.status).toBe(404);
      expect(response.body.code).toBe(404);
    });
  });
});
```

## 测试数据工厂

创建可复用的测试数据生成器：

```typescript
// test/fixtures/user.factory.ts
import { Prisma } from '@prisma/client';
import { prisma } from '../../src/db';

export class UserFactory {
  static async create(
    overrides?: Partial<Prisma.UserCreateInput>
  ) {
    return await prisma.user.create({
      data: {
        email: `user-${Date.now()}@test.com`,
        name: 'Test User',
        passwordHash: 'hashedpassword',
        ...overrides,
      },
    });
  }

  static async createMany(count: number) {
    const users = [];
    for (let i = 0; i < count; i++) {
      users.push(await this.create());
    }
    return users;
  }
}

// 使用
describe('User Tests', () => {
  it('should fetch user messages', async () => {
    const user = await UserFactory.create();
    // 测试逻辑...
  });
});
```

## 覆盖率要求

- **Service 层**：>= 80% 覆盖率
- **Repository 层**：>= 70% 覆盖率
- **整体项目**：>= 60% 覆盖率

```bash
npm run test:coverage

# 输出示例
-------|----------|----------|----------|----------|
File   | % Stmts  | % Branch | % Funcs  | % Lines  |
-------|----------|----------|----------|----------|
All    |   72.3   |   65.8   |   78.5   |   71.9   |
```

## 常见测试模式

### Mock 外部服务

```typescript
jest.mock('../../../src/services/email', () => ({
  sendEmail: jest.fn().mockResolvedValue(true),
}));
```

### 测试异常路径

```typescript
it('should handle database error gracefully', async () => {
  (prisma.user.create as jest.Mock).mockRejectedValue(
    new Error('Database error')
  );

  await expect(userService.createUser(userData)).rejects.toThrow(
    InternalError
  );
});
```

### 异步操作等待

```typescript
it('should process async operations', async () => {
  const promise = userService.createUser(userData);
  
  // 等待异步操作完成
  await expect(promise).resolves.toEqual(expectedUser);
});
```

## 性能测试

```typescript
describe('Performance', () => {
  it('should fetch 1000 users within 100ms', async () => {
    const startTime = Date.now();
    
    await userService.getUsersPaginated(1, 1000);
    
    const elapsed = Date.now() - startTime;
    expect(elapsed).toBeLessThan(100);
  });
});
```
