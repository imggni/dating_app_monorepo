---
name: "nestjs-backend-specs"
description: "Node.js + NestJS 后端开发规范。在编写后端接口、设计数据库模型、集成 Socket.IO、或者对接腾讯云 CloudBase 等服务时调用，确保后端代码符合项目既定技术栈。"
---

# Node.js + NestJS 后端开发规范

本项目后端架构基于 **NestJS + TypeScript + Prisma + 腾讯云 CloudBase**。在开发后端业务时，请严格遵守以下架构规范与技术选型。

## 1. 核心技术栈
- **核心框架**: `Node.js 20+` + `NestJS` (全栈 TypeScript 支持，严禁退回纯 Express)
- **数据库 & ORM**: `腾讯云 CloudBase 云数据库 (PostgreSQL 16+)` + `Prisma 5.10+`
- **缓存**: `CloudBase Redis 7.2+` + `ioredis 5.3+`
- **实时通信**: `Socket.IO 4.7+` + `NestJS Socket 模块` (用于你画我猜笔触实时同步、补充 IM 推送)
- **认证鉴权**: `JWT` + `Passport.js` + `腾讯云 CAM`
- **数据校验**: `class-validator` + `class-transformer`

## 2. 后端架构规范 (目录结构)
遵循 NestJS 生产级开发规范，采用**模块化分层架构+职责单一**原则设计。

- `src/main.ts`: 项目入口，初始化 NestJS、全局中间件/异常过滤器。
- `src/common/`: 存放全局公共逻辑。
  - `filters/`: 全局异常过滤器 (如统一返回标准 JSON)。
  - `guards/`: 全局守卫 (如 JWT 鉴权 `auth.guard.ts`)。
  - `interceptors/`: 全局拦截器 (日志记录、响应格式化)。
  - `utils/`: JWT 工具、数据库/Redis 封装工具等。
- `src/config/`: 存放全局配置 (如 CloudBase、JWT、数据库等配置的读取模块)。
- `src/modules/`: **业务模块目录，按领域驱动划分 (DDD)**。
  - 每个业务领域必须独立成模块，如 `user/`, `im/`, `game/`, `slow-chat/`, `circle/`。
  - 核心文件包含: `*.module.ts` (模块声明), `*.controller.ts` (处理前端请求), `*.service.ts` (业务逻辑)。
  - `dto/`: 存放该领域的请求体验证类 (`class-validator`)。
  - `socket/`: 若涉及实时通信（如 IM、Game），存放在业务模块下的 Socket 目录中 (`*.gateway.ts`)。

## 3. 编码要求
- 所有的 Controller 方法必须包含明确的返回类型或 DTO 类型，便于集成 Swagger (`NestJS Swagger`) 生成文档。
- 数据验证必须在 DTO 层通过 `class-validator` 装饰器完成，禁止在 Controller 内写手动 `if/else` 校验参数。
- 业务异常必须通过 NestJS 内置的 HttpException (或其派生类) 抛出，交给 `src/common/filters/` 统一处理。
- 对于频繁请求的数据（如用户在线状态、排行榜），必须优先读写 Redis 缓存，减轻 PostgreSQL 数据库压力。
