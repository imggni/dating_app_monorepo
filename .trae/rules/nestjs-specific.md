---
alwaysApply: false
---
# NestJS 项目规范（严格精简版）

**核心约束（必须遵守）**
1. **框架与语言**: 强制 `NestJS` + `TypeScript`，开启 `strict` 模式。
2. **架构分层**: 强制采用 DDD 领域驱动，模块内严格遵守 `Controller -> Service -> DB` 层级。
3. **数据校验**: 必须使用 `class-validator` 校验 DTO，严禁在 Controller 手写参数校验。
4. **异步与错误**: 所有异步方法必须 `async/await`，严禁直接 `.then()`。业务错误统一抛出 NestJS `HttpException`，由全局 Filter 处理。
5. **命名规范**: 文件名 `[name].[type].ts` 使用 `kebab-case`；类名 `PascalCase`；接口不加 `I` 前缀。
6. **配置与注入**: 必须使用 `@nestjs/config` 管理环境变量，避免硬编码。必须使用构造函数注入依赖（Constructor Injection）。
7. **接口文档**: Controller 方法需声明明确的返回类型或 DTO，以支持 Swagger 文档生成。
8. **安全守卫**: 需鉴权路由必须挂载 `@UseGuards()`。

> 详情及 CloudBase、Redis、Socket 整合方案，请调用 `nestjs-backend-specs` 技能获取。