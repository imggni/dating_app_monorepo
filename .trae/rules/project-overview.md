# 全局项目上下文 (Dating App)

本项目是一个跨端的交友聊天应用（对标 Slow/Tell 等），采用前后端分离架构。
在处理任何需求时，请注意该项目由两部分组成，必须明确用户意图是修改前端还是后端。

## 1. 项目整体架构
- **前端**: `Flutter 3.22+` / `Dart 3.0+`
  - 核心框架：GetX (状态与路由管理)、Dio (网络请求)
  - UI：Material 3 + 阿里 iconfont
  - 本地存储：Hive + flutter_secure_storage
- **后端**: `Node.js 20+` / `NestJS` / `TypeScript`
  - 数据库：PostgreSQL 16+ (使用 Prisma ORM)
  - 缓存：Redis (使用 ioredis)
  - 实时通信：Socket.IO
- **云服务依赖**:
  - IM 即时通讯：腾讯 IM SDK
  - 推送：极光推送
  - 云函数/数据库/存储托管：腾讯云 CloudBase

## 2. 协作与处理原则
- **双端意识**: 在涉及接口联调、数据模型修改时，必须同时考虑对 NestJS DTO 和 Flutter Model 的同步影响。
- **遵循专项规则**: 
  - 前端开发请遵循 `.trae/rules/flutter-specific.md` 和 `.trae/skills/flutter-dev-specs/SKILL.md`。
  - 后端开发请遵循 `.trae/rules/express-specific.md` 和 `.trae/skills/express-backend-specs/SKILL.md`。
  - 打包、合规与热更新请遵循 `.trae/skills/app-compliance-deploy/SKILL.md`。
- **禁止行为**: 不要在此项目中混用其他不相关的框架规范（例如不要引入 Vue/React 概念，不要使用 Express 编写新的后端逻辑）。
