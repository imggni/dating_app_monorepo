---
title: dating_app_monorepo 企业级全局开发规范
applyTo: "**/*"
---

# 项目信息

**项目名称**：dating_app_monorepo（交友聊天 App）  
**项目描述**：一个全栈交友聊天应用，支持实时通讯、媒体管理、用户匹配等功能。

## 技术栈

| 层 | 技术 |
|----|------|
| **前端** | Flutter 3.7.2 + GetX + Dio + Retrofit + json_serializable + Hive + flutter_secure_storage + socket_io_client + 腾讯云 IM SDK |
| **后端** | Express.js + TypeScript + Prisma ORM + Zod + Redis + Socket.IO + 腾讯云 IM 服务端 SDK |
| **实时通讯** | Socket.IO + 腾讯云 IM |
| **配置** | 环境变量（.env）管理，禁止硬编码 |

## Mono-repo 结构

```
dating_app_monorepo/
├── dating_app/              # Flutter 前端应用
│   ├── lib/
│   │   ├── models/          # Domain 数据模型（dataclass / enum）
│   │   ├── services/        # 业务逻辑服务（API / IM / Storage）
│   │   ├── controllers/     # GetX 控制器（状态管理）
│   │   ├── views/           # 页面视图
│   │   ├── widgets/         # 可复用组件
│   │   ├── config/          # 配置与常量
│   │   └── utils/           # 工具函数
│   └── pubspec.yaml
├── dating_app_api/          # Express 后端 API
│   ├── src/
│   │   ├── routes/          # 路由层（请求入口）
│   │   ├── controllers/     # 控制层（请求处理）
│   │   ├── services/        # 业务层（业务逻辑）
│   │   ├── repositories/    # 数据层（数据访问）
│   │   ├── models/          # 数据模型（Domain 类型）
│   │   ├── middleware/      # 中间件（认证、日志等）
│   │   ├── config/          # 配置与常量
│   │   └── utils/           # 工具函数
│   ├── prisma/
│   │   └── schema.prisma    # 数据库定义
│   ├── package.json
│   └── tsconfig.json
└── docs/                    # 设计文档与开发指南
```

## 关键约定

1. **语言与注释**
   - 用户界面文案（UI 文本、错误消息）：**中文**
   - 代码注释、函数文档、类型定义：**英文**

2. **环境配置**
   - 所有配置通过 **.env** 管理（域名、API Key、Secret、Token 等）
   - **禁止硬编码** 敏感信息到源代码

3. **类型安全**
   - 严格类型检查，禁止滥用 `any` / `dynamic`
   - 变量/函数：小驼峰 `camelCase`；类名/结构体：大驼峰 `PascalCase`
   - 禁止单字母、无意义命名（`a`、`b`、`temp`、`data`）
   - 必须添加清晰注释：功能、业务场景、参数、返回值

4. **前后端统一标准**
   - **RESTful 接口**：路径小写 + 连字符（如 `/api/user-profile`）
   - **统一响应体**：`{ code: number, message: string, data: any }`
   - **错误码标准**：
     - `200` 成功
     - `400` 参数错误
     - `401` 未授权
     - `403` 禁止访问
     - `500` 服务异常
   - 全局异常拦截、错误捕获、日志输出

5. **架构分层**
   - **前后端分层清晰**，禁止逻辑耦合
   - 复用逻辑必须抽离为公共方法/服务
   - 不跨层直接调用（如 UI 不能直接调 API）

6. **安全与合规**
   - 所有用户输入必须校验，防止 SQL 注入、XSS、参数非法
   - 敏感数据（Token、密码）使用 `flutter_secure_storage` 或安全存储
   - 遵循国内隐私合规，权限申请、用户授权、隐私协议逻辑完备

## Context7 强制规则

所有涉及第三方库、框架、SDK 的代码生成，**必须优先通过 Context7 获取最新官方文档**，禁止使用过时、废弃、幻觉 API。