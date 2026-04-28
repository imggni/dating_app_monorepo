# Express 项目规范（精简版）

**核心约束（必须遵守）**
1. **框架与语言**: 强制 `Express.js` + `Node.js 18+`，使用 `JavaScript` 或 `TypeScript`。
2. **架构分层**: 严格遵守 `Router -> Controller -> Service -> DB` 层级，严禁在路由层写业务逻辑。
3. **数据校验**: 必须使用 `zod` 校验输入参数，严禁在 Controller 手写参数校验。
4. **异步与错误**: 所有异步方法必须 `async/await`，使用 `try/catch` 捕获错误。统一使用自定义 `HttpError` 类，由全局错误处理中间件处理。
5. **命名规范**: 文件名 `[name].[type].js` 使用 `kebab-case`；类名 `PascalCase`；变量与方法名使用 `camelCase`。
6. **路由组织**: 按功能模块拆分为独立路由文件（如 `user.routes.js`），在 `app.js` 中统一注册。
7. **中间件**: 鉴权、日志、错误处理等公共逻辑必须抽离为独立中间件文件。
8. **接口文档**: 使用 `swagger-jsdoc` + `swagger-ui-express` 生成接口文档，所有路由必须添加 JSDoc 注释。

> 详情及 CloudBase、Redis、Socket 整合方案，请调用 `express-backend-specs` 技能获取。