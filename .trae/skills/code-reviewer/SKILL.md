---
name: "code-reviewer"
description: "交友App专属代码审查规范。在需要检查代码质量、寻找潜在Bug、优化性能，或在提交/合并代码前进行 Review 时调用此技能。"
---

# Code Reviewer (代码审查与质量控制规范)

本项目包含 **Flutter (前端)** 和 **Express.js (后端)** 代码，为确保交友App的高可用性和稳定性，请在进行代码审查（Code Review）时严格遵循以下规范。

## 1. 架构与选型审查 (Architecture & Stack)
- **前端 (Flutter)**:
  - 检查是否严格使用 `GetX` 进行状态/路由管理，严禁 `Provider` / `Bloc` 等第三方库混用。
  - UI 必须符合 `Material 3` 规范。
  - 页面结构是否严格遵守 `view -> controller -> binding` 的解耦分层。
- **后端 (Express.js)**:
  - 检查是否符合 `Router -> Controller -> Service -> DB` 分层。
  - 是否正确使用了 `zod` 进行参数校验，避免在 Controller 层写手动校验。
  - 是否避免了在 Controller 中写核心业务逻辑。

## 2. 性能优化审查 (Performance)
- **前端**:
  - 检查是否滥用 `setState` 或 `GetBuilder` / `Obx`，确保 UI 仅做局部状态刷新。
  - 长列表（聊天记录、圈子动态）是否正确使用了 `ListView.builder` 或 `SliverList` 实现懒加载。
  - 无状态的 Widget 和常量是否添加了 `const` 修饰符。
  - 图片和音视频资源是否进行了缓存策略 (`cached_network_image`) 处理。
- **后端**:
  - 数据库查询是否考虑了 N+1 问题（如 Prisma 关联查询）。
  - 高频请求（如用户在线状态、房间信息）是否合理使用了 `Redis` 缓存。
  - 所有异步操作是否全部使用 `async/await`，以避免阻塞 Node.js 事件循环。

## 3. 安全与合规审查 (Security & Compliance)
- 敏感信息（如 Token、密码）是否使用了加密存储：前端必须使用 `flutter_secure_storage`，后端密码需 Hash 存储。
- 所有需保护的后端接口是否全部经过了 JWT 或鉴权中间件拦截。
- 前端是否妥善处理了权限申请（如相册、麦克风）被拒的边界情况，避免崩溃，且符合合规弹窗要求。
- 业务代码是否有可能引发 SQL 注入或 XSS 等安全漏洞。

## 4. 代码风格与规范 (Style & Conventions)
- **命名规范**：文件、类、变量名是否符合 Dart/TypeScript 官方规范及项目自定义规则（如前端目录 `snake_case`，类名 `PascalCase`）。
- **错误处理**：
  - 后端：是否统一使用自定义 `HttpError` 类和全局错误处理中间件抛出和捕获错误。
  - 前端：是否具有全局错误捕获机制和友好的 UI 提示（如 Dio 拦截器中的超时和弱网提示）。
- **魔法值**：代码中是否存在未提取为常量的“魔法数字”或“魔法字符串”。
- **注释**：核心业务逻辑、复杂算法、接口定义是否有清晰的文档注释。

## 审查输出格式要求
在输出 Code Review 结果时，请按照以下结构组织回答，以便开发者快速定位和修复：
1. **🔍 发现的问题 (Issues)**: 明确指出代码行和问题原因，可分级别（🛑 严重、⚠️ 警告、💡 建议）。
2. **💡 优化思路 (Suggestions)**: 简要提供具体的优化原因或思路。
3. **✨ 重构代码 (Refactored Code)**: 直接给出修改后的优质代码片段。
