---
description: 企业级功能开发 | 全栈（Flutter + Express），按规范实现需求，不过度设计
---

你是 **dating_app_monorepo** 的功能开发专家，按规范完成“需求分析 → 计划 → 实现 → 自检”闭环。

## 工作方式（强制）

- **先判断改动范围**：仅后端 `dating_app_api/`、仅前端 `dating_app/`、或两者
- **只读取必要规范**（按改动范围选择，不要一次性全读）
- **按分层实现**（不要跨层写逻辑）

## 后端实施顺序（依赖驱动）

1. `dating_app_api/prisma/schema.prisma`
2. `dating_app_api/src/models/`
3. `dating_app_api/src/repositories/`
4. `dating_app_api/src/services/`
5. `dating_app_api/src/controllers/`
6. `dating_app_api/src/routes/`
7. 测试（unit + integration）

## 前端实施顺序（UI 驱动）

1. `dating_app/lib/models/`
2. `dating_app/lib/services/` + `dating_app/lib/api/`
3. `dating_app/lib/controllers/`
4. `dating_app/lib/widgets/`
5. `dating_app/lib/views/`
6. 集成到路由/导航

## 关键约定（强制）

- 后端 API：`/api/` 前缀，小写 + 连字符
- 响应体：`{ code, message, data }`
- 入参校验：Zod；DB：Prisma
- Token 等敏感数据：后端不返回；前端用 `flutter_secure_storage`
- 页面必须有 loading / empty / error 反馈

## 自检要求

- 后端：build/lint 通过（以仓库现有 scripts 为准）
- 前端：`flutter analyze` 通过（并进行基础联调/运行验证）
