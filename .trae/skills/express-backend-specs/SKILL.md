---
name: "express-backend-specs"
description: "Express.js 后端开发规范。在编写 Express 后端接口、设计数据库模型、集成 Socket.IO、或者对接腾讯云 CloudBase 等服务时调用，确保后端代码符合项目既定技术栈。"
---

# Express.js 后端开发规范

本项目后端架构基于 **Express.js + Node.js + Prisma + 腾讯云 CloudBase**。在开发后端业务时，请严格遵守以下架构规范与技术选型。

## 1. 核心技术栈
- **核心框架**: `Express.js 4.18+` + `Node.js 18+`
- **数据库 & ORM**: `腾讯云 CloudBase 云数据库 (PostgreSQL 16+)` + `Prisma 5.10+`
- **缓存**: `CloudBase Redis 7.2+` + `ioredis 5.3+`
- **实时通信**: `Socket.IO 4.7+` (用于你画我猜笔触实时同步、补充 IM 推送)
- **认证鉴权**: `jsonwebtoken` + `bcrypt`
- **数据校验**: `joi` 或 `express-validator`
- **接口文档**: `swagger-jsdoc` + `swagger-ui-express`

## 2. 后端架构规范 (目录结构)
遵循 **Router -> Controller -> Service -> DB** 分层架构。

- `src/app.js`: 项目入口，初始化 Express、中间件、路由注册。
- `src/server.js`: 服务器启动文件。
- `src/config/`: 存放全局配置 (如 CloudBase、JWT、数据库等配置的读取)。
- `src/middleware/`: 存放中间件 (如 `auth.middleware.js`, `errorHandler.middleware.js`, `logger.middleware.js`)。
- `src/controllers/`: 控制器层，处理请求参数，调用 Service 层。
- `src/services/`: 服务层，业务逻辑处理。
- `src/routes/`: 路由层，按功能模块拆分 (如 `user.routes.js`, `im.routes.js`)。
- `src/models/`: 数据模型层 (Prisma Schema 生成的 Client)。
- `src/utils/`: 工具函数 (JWT 工具、响应封装等)。

## 3. 编码要求
- 所有路由文件必须添加 **Swagger JSDoc 注释**，便于生成 `openapi.json` 接口文档。
- 数据验证必须在 `joi/express-validator` 验证层完成，禁止在 Controller 内写手动 `if/else` 校验参数。
- 业务异常必须通过自定义 `HttpError` 类抛出，交给全局错误处理中间件统一处理。
- 对于频繁请求的数据（如用户在线状态、排行榜），必须优先读写 Redis 缓存，减轻 PostgreSQL 数据库压力。

## 4. API 路由规范
- **RESTful 风格**: 接口路径使用名词复数，小写短横线分隔（如 `/api/user-profiles`）。
- **统一返回格式**:
  ```json
  {
    "code": 0,
    "message": "success",
    "data": {}
  }
  ```
- **版本控制**: 所有 API 路径必须带有版本号前缀，如 `/api/...`。
- **分页规范**: 分页接口统一使用 `page`（从 1 开始）和 `limit` 参数，返回数据必须包含 `total` 字段。
- **命名规范**: JSON 字段必须使用 `camelCase` 驼峰命名法。

## 5. 错误处理规范
- 使用自定义错误类 `HttpError`，包含 `statusCode`、`message`、`code` 属性。
- 全局错误处理中间件捕获所有错误，转换为标准 API 返回格式。
- 错误日志必须包含堆栈信息和上下文参数。
- 用户友好提示，禁止将数据库报错等细节直接暴露给前端。

## 6. 安全规范
- 密码必须使用 `bcrypt` 加盐哈希存储。
- 敏感信息必须脱敏处理后返回给前端。
- 需鉴权接口必须校验 JWT Token。
- 关键接口必须接入频控（Rate Limit），防止恶意暴力破解。
- SQL 注入防护：必须通过 Prisma ORM 或参数化查询与数据库交互，严禁手动拼接 SQL 字符串。

## 7. Swagger 文档规范
每个路由必须包含完整的 JSDoc 注释：
```javascript
/**
 * @swagger
 * /users/register:
 *   post:
 *     summary: 用户注册
 *     description: 创建新用户账号
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - password
 *             properties:
 *               phone:
 *                 type: string
 *                 description: 手机号
 *               password:
 *                 type: string
 *                 description: 密码
 *     responses:
 *       200:
 *         description: 注册成功
 */
router.post('/register', userController.register);
```

## 8. 项目命令
- 开发环境: `npm run dev`
- 生产构建: `npm run build`
- 生成 OpenAPI 文档: `npm run swagger:generate`
- 运行测试: `npm run test`