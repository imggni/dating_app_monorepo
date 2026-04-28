---
applyTo: "dating_app_api/prisma/schema.prisma, dating_app_api/src/repositories/**/*.ts, dating_app_api/src/models/**/*.ts"
---

# 数据库与 Prisma ORM 规范

## Prisma 基本原则

- **单一数据库操作方式**：全部使用 Prisma，禁止混用裸 SQL（特殊场景除外）
- **类型安全**：Prisma 自动生成类型，利用 TypeScript 严格模式检查
- **迁移管理**：所有 schema 改动必须通过 Prisma 迁移记录

## Schema 定义规范

### 模型命名

- 模型名称使用大驼峰 PascalCase：`User`, `Message`, `UserProfile`
- 字段名称使用小驼峰 camelCase：`userId`, `createdAt`, `isActive`
- 关键字段固定命名：
  - 主键：`id`（String @id @default(cuid()) 或 Int @id @default(autoincrement())）
  - 创建时间：`createdAt` @default(now())
  - 更新时间：`updatedAt` @updatedAt
  - 逻辑删除：`isDeleted` Boolean @default(false)（可选）

### Schema 示例

```prisma
model User {
  id            String    @id @default(cuid())
  email         String    @unique
  name          String
  avatar        String?
  passwordHash  String
  isActive      Boolean   @default(true)
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  // 关系
  messages      Message[]
  contacts      Contact[]

  @@map("users")  // 映射到表名
}

model Message {
  id        String   @id @default(cuid())
  senderId  String
  sender    User     @relation(fields: [senderId], references: [id], onDelete: Cascade)
  content   String
  createdAt DateTime @default(now())

  @@index([senderId])  // 性能优化
  @@map("messages")
}

model Contact {
  id        String   @id @default(cuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  phone     String
  address   String?
  createdAt DateTime @default(now())

  @@unique([userId, phone])  // 唯一性约束
  @@map("contacts")
}
```

## 关系定义

### 一对多（One-to-Many）

```prisma
model User {
  id       String    @id @default(cuid())
  messages Message[]  // 反向关系
}

model Message {
  id       String @id @default(cuid())
  userId   String
  user     User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

### 多对多（Many-to-Many）

```prisma
model User {
  id       String    @id @default(cuid())
  groups   Group[]    // 隐式中间表
}

model Group {
  id    String @id @default(cuid())
  users User[]
}
```

## Repository 操作规范

### 基础 CRUD

```typescript
// src/repositories/user.ts
import { prisma } from '../db';

export const userRepository = {
  // Create
  async create(data: { email: string; name: string; passwordHash: string }) {
    return await prisma.user.create({ data });
  },

  // Read by ID
  async findById(id: string) {
    return await prisma.user.findUnique({ where: { id } });
  },

  // Read by unique field
  async findByEmail(email: string) {
    return await prisma.user.findUnique({ where: { email } });
  },

  // Read multiple
  async findMany(skip = 0, take = 20) {
    return await prisma.user.findMany({ skip, take });
  },

  // Update
  async update(id: string, data: Partial<{ name: string; avatar: string }>) {
    return await prisma.user.update({ where: { id }, data });
  },

  // Delete (hard delete)
  async delete(id: string) {
    return await prisma.user.delete({ where: { id } });
  },
};
```

### 禁止事项

- ❌ **禁止全表操作**：`prisma.user.updateMany()` 无 where 条件
- ❌ **禁止裸 SQL**：`prisma.$queryRaw('SELECT ...')`（除非性能瓶颈，需充分论证）
- ❌ **禁止 N+1 查询**：使用 `include` 或 `select` 进行关系预加载
- ❌ **禁止返回敏感字段**：如 `passwordHash`、Token 等

### 关系预加载（避免 N+1）

```typescript
// ❌ 错误：N+1 查询
async function getUsersWithMessages() {
  const users = await prisma.user.findMany();
  for (const user of users) {
    user.messages = await prisma.message.findMany({ where: { userId: user.id } });
  }
}

// ✅ 正确：一次查询
async function getUsersWithMessages() {
  return await prisma.user.findMany({
    include: { messages: true },
  });
}

// ✅ 只选择需要的字段
async function getUsersWithMessageCount() {
  return await prisma.user.findMany({
    select: {
      id: true,
      name: true,
      _count: { select: { messages: true } },
    },
  });
}
```

## 迁移管理

### 生成迁移

```bash
cd dating_app_api
npx prisma migrate dev --name add_user_table
```

### 应用迁移（生产环境）

```bash
npx prisma migrate deploy
```

### 查看迁移状态

```bash
npx prisma migrate status
```

## 性能优化

### 索引

```prisma
model Message {
  id        String   @id
  senderId  String
  createdAt DateTime @default(now())

  @@index([senderId])        // 外键索引
  @@index([createdAt])       // 时间范围查询
  @@index([senderId, createdAt])  // 复合索引
}
```

### 分页查询

```typescript
async function getMessages(page = 1, pageSize = 20) {
  const skip = (page - 1) * pageSize;
  return await prisma.message.findMany({
    skip,
    take: pageSize,
    orderBy: { createdAt: 'desc' },
  });
}
```

### 批量操作

```typescript
// 批量创建
await prisma.user.createMany({
  data: [
    { email: 'a@a.com', name: 'A', passwordHash: 'xxx' },
    { email: 'b@b.com', name: 'B', passwordHash: 'yyy' },
  ],
});

// 批量更新
await prisma.user.updateMany({
  where: { isActive: false },
  data: { isActive: true },
});
```

## 错误处理

```typescript
import { PrismaClientKnownRequestError } from '@prisma/client/runtime';

export async function getUserSafe(id: string) {
  try {
    return await prisma.user.findUnique({ where: { id } });
  } catch (error) {
    if (error instanceof PrismaClientKnownRequestError) {
      if (error.code === 'P2025') {
        throw new Error('User not found');
      }
    }
    throw error;
  }
}
```
