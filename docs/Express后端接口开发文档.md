# Express 后端接口开发文档

> 基于 `交友聊天App（Flutter+Express+CloudBase）完整开发方案.md` 3.3 节
> 更新日期：2026-04-23

---

## 一、现有接口 vs 需求文档差距分析

### 1.1 用户管理模块 (User)

| 需求文档接口 | 现有实现 | 状态 | 说明 |
|------------|---------|------|------|
| POST /api/user/register | ✅ 已实现 | 完整 | |
| POST /api/user/login | ✅ 已实现 | 完整 | |
| GET /api/user/profile | ✅ 已实现 | 完整 | |
| PUT /api/user/profile | ✅ 已实现 | 完整 | |
| POST /api/user/friend/request | ✅ 已实现 | 完整 | 已实现：/users/friend/request（包含 Zod 校验、Service、Controller） |
| PUT /api/user/friend/handle | ✅ 已实现 | 完整 | 已实现：/users/friend/handle（接受/拒绝逻辑） |
| GET /api/user/friend/list | ✅ 已实现 | 完整 | 已实现：/users/friend/list（返回好友列表） |
| POST /api/user/logout | ✅ 已实现 | 完整 | 已实现：/users/logout（使用 POST 实现注销/登出） |
| GET /api/user/online/status | ✅ 已实现 | 完整 | 已实现：/users/online/:userId（基于 Redis 查询） |

### 1.2 IM即时通讯模块 (IM)

| 需求文档接口 | 现有实现 | 状态 | 说明 |
|------------|---------|------|------|
| POST /api/im/message/save | ✅ 已实现 | 完整 | 已实现：/im/send（含事务、Redis 未读计数、Zod 校验） |
| GET /api/im/message/history | ✅ 已实现 | 完整 | 已实现：/im/messages（支持分页与基于时间的滚动加载、Zod 校验） |
| PUT /api/im/message/read | ✅ 已实现 | 完整 | 已实现：/im/messages/:messageId/read（标记已读并同步 Redis 未读计数） |
| PUT /api/im/message/recall | ✅ 已实现 | 完整 | 已实现：/im/messages/:messageId/recall（标记撤回） |
| GET /api/im/message/unread/count | ✅ 已实现 | 完整 | 已实现：/im/unread/count（返回未读消息数） |
| POST /api/im/group/create | ✅ 已实现 | 完整 | 已实现：/im/group/create（群组创建） |
| PUT /api/im/group/member | ✅ 已实现 | 完整 | 已实现：/im/group/member/add、/im/group/member/remove（群组成员管理） |
| POST /api/im/group/{groupId}/send | ✅ 已实现 | 完整 | 已实现：/im/group/:groupId/send（群消息发送并通过 Socket.IO 广播） |
| GET /api/im/group/{groupId}/messages | ✅ 已实现 | 完整 | 已实现：/im/group/:groupId/messages（群消息历史查询） |

（新增）已实现：/im/group/create、/im/group/member/add、/im/group/member/remove（群组创建与成员管理）

### 1.3 你画我猜游戏模块 (Game)

| 需求文档接口 | 现有实现 | 状态 | 说明 |
|------------|---------|------|------|
| POST /api/game/room/create | ✅ 已实现 | 完整 | 已实现：/game/create（创建房间，生成 roomCode，并加入房主为成员） |
| GET /api/game/room/list | ✅ 已实现 | 完整 | 已实现：/game/rooms（分页查询房间列表） |
| POST /api/game/room/join | ✅ 已实现 | 完整 | 已实现：/game/rooms/:roomId/join（加入房间，事务保护） |
| POST /api/game/room/exit | ✅ 已实现 | 完整 | 已实现：/game/rooms/:roomId/leave（离开房间，房主转移/结束处理） |
| POST /api/game/brush/sync | ❌ 未实现 | **待开发** | 需要新增（Socket.IO） |
| PUT /api/game/round/start | ❌ 未实现 | **待开发** | 需要新增 |
| PUT /api/game/round/end | ❌ 未实现 | **待开发** | 需要新增 |
| DELETE /api/game/room/destroy | ❌ 未实现 | **待开发** | 需要新增 |

（更新）已实现：/game/brush/sync（REST 保存画笔数据）、/game/rooms/{roomId}/round/start、/game/rooms/{roomId}/round/end、/game/rooms/{roomId}/destroy（房间销毁）

### 1.4 慢社交模块 (SlowChat)

| 需求文档接口 | 现有实现 | 状态 | 说明 |
|------------|---------|------|------|
| POST /api/slowchat/send | ⚠️ 部分实现 | sendSlowMessage 占位 | 需完善业务逻辑 |
| GET /api/slowchat/list | ⚠️ 部分实现 | getRooms 占位 | 需完善业务逻辑 |
| PUT /api/slowchat/open | ❌ 未实现 | **待开发** | 需要新增 |
| DELETE /api/slowchat/delete | ❌ 未实现 | **待开发** | 需要新增 |
| PUT /api/slowchat/anonymous | ❌ 未实现 | **待开发** | 需要新增 |

（更新）已实现：/slow-chat/send, /slow-chat/messages/:messageId/open, /slow-chat/messages/:messageId, /slow-chat/messages/:messageId/anonymous（慢社交发送/开封/删除/匿名设置）

> ⚠️ 注意：内部定时接口"延迟消息推送"由后端定时任务处理，不对外暴露 API。

### 1.5 兴趣圈子模块 (Circle)

| 需求文档接口 | 现有实现 | 状态 | 说明 |
|------------|---------|------|------|
| GET /api/circle/list | ✅ 已实现 | 完整 | 已实现：/circle/list（获取圈子列表） |
| GET /api/circle/post/list | ✅ 已实现 | 完整 | 已实现：/circle/post/list（获取帖子列表，支持圈子过滤） |
| GET /api/circle/post/detail | ✅ 已实现 | 完整 | 已实现：/circle/posts/:postId（获取帖子详情） |
| POST /api/circle/post/publish | ✅ 已实现 | 完整 | 已实现：/circle/posts（发布帖子，包含圈子ID） |
| POST /api/circle/post/like | ✅ 已实现 | 完整 | 已实现：/circle/posts/:postId/like（点赞帖子） |
| POST /api/circle/comment/add | ✅ 已实现 | 完整 | 已实现：/circle/posts/:postId/comments（添加评论） |
| POST /api/circle/comment/like | ✅ 已实现 | 完整 | 已实现：/circle/comment/like（点赞评论） |
| DELETE /api/circle/post/delete | ✅ 已实现 | 完整 | 已实现：/circle/posts/:postId（软删除帖子） |
| GET /api/circle/post/filter | ✅ 已实现 | 完整 | 已实现：/circle/post/filter（关键词和标签过滤） |

### 1.6 通用公共模块 (Common)

| 需求文档接口 | 现有实现 | 状态 | 说明 |
|------------|---------|------|------|
| POST /api/common/upload | ✅ 已实现 | 完整 | 已实现：/common/upload（腾讯云 CloudBase 上传，支持多种文件类型） |
| POST /api/common/token/refresh | ✅ 已实现 | 完整 | 已实现：/common/token/refresh（JWT refresh token 机制） |
| GET /api/common/config | ✅ 已实现 | 完整 | 已实现：/common/configs（从 SystemConfig 表获取配置） |
| POST /api/common/sensitive/filter | ✅ 已实现 | 完整 | 已实现：/common/sensitive/filter（腾讯云内容安全 API） |

---

## 二、需人工配置的外部依赖

在开发以下接口前，需要人工配置以下服务：

### 2.1 腾讯云 CloudBase 相关
| 配置项 | 用途 | 文档位置 |
|-------|------|---------|
| `DATABASE_URL` | PostgreSQL 数据库连接 | `.env` |
| `REDIS_URL` | Redis 连接（可选，用 Upstash） | `.env` |
| `JWT_SECRET` | JWT 签名密钥 | `.env` |

### 2.2 腾讯云内容安全 API
| 配置项 | 用途 | 说明 |
|-------|------|------|
| `TC_SECRET_ID` | 腾讯云 SecretId | 用于敏感词过滤接口 |
| `TC_SECRET_KEY` | 腾讯云 SecretKey | 用于敏感词过滤接口 |

**配置方式**：在 `.env` 文件中添加：
```env
TC_SECRET_ID=your_secret_id
TC_SECRET_KEY=your_secret_key
```

### 2.3 腾讯云 CloudBase 存储（免费）
> CloudBase 提供每月 10GB 免费存储空间，适合小规模应用

| 配置项 | 用途 | 说明 |
|-------|------|------|
| `CLOUDBASE_STORAGE_URL` | CloudBase 存储访问域名 | 用于文件上传接口 |
| `CLOUDBASE_ENV_ID` | CloudBase 环境 ID | 用于文件上传接口 |

**配置方式**：在 `.env` 文件中添加：
```env
CLOUDBASE_STORAGE_URL=https://your-env.cloudbase.net
CLOUDBASE_ENV_ID=your-environment-id
```

### 2.4 腾讯 IM SDK
| 配置项 | 用途 | 说明 |
|-------|------|------|
| `IM_SDK_APP_ID` | 腾讯 IM AppId | 用于 IM 模块集成 |
| `IM_SDK_SECRET` | 腾讯 IM Secret | 用于 IM 模块集成 |

### 2.5 极光/腾讯推送
| 配置项 | 用途 | 说明 |
|-------|------|------|
| `JPUSH_APP_KEY` | 极光 AppKey | 用于慢社交推送 |
| `JPUSH_MASTER_SECRET` | 极光 MasterSecret | 用于慢社交推送 |

---

## 三、开发任务优先级

### P0 - 核心业务（必须实现）

1. **用户管理模块补全**
   - 好友请求接口
   - 好友请求处理接口
   - 好友列表接口

2. **IM模块补全**
   - 消息存储接口（完善 sendMessage）
   - 历史消息查询（完善 getMessages）
   - 消息已读（完善 markAsRead）
   - 消息撤回接口

3. **游戏模块补全**
   - 房间创建（完善 createRoom）
   - 房间列表（完善 getRooms）
   - 加入/离开房间

### P1 - 重要功能

4. **慢社交模块补全**
   - 慢消息发送
   - 慢消息列表
   - 消息开封

5. **兴趣圈子模块补全**
   - 帖子发布
   - 帖子列表
   - 点赞/评论

6. **通用模块补全**
   - Token 刷新
   - 文件上传

### P2 - 增强功能

7. **高级功能**
   - 游戏笔触同步（Socket.IO）
   - 游戏回合管理
   - 敏感词过滤
   - 未读消息计数
   - 用户在线状态

8. **群聊功能**
   - 群聊创建
   - 群聊成员管理

---

## 四、数据模型补充

根据需求文档，需要在 `schema.prisma` 中补充以下模型：

### 4.1 SystemConfig (系统配置)
```prisma
model SystemConfig {
  id        String   @id @default(uuid())
  key       String   @unique
  value     Json
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

### 4.2 Circle (兴趣圈子)
```prisma
model Circle {
  id          String   @id @default(uuid())
  name        String
  description String?
  coverImage  String?
  memberCount Int      @default(0)
  createdAt   DateTime @default(now())
  posts       CirclePost[]
}
```

### 4.3 CircleComment (圈子评论点赞)
```prisma
model CircleComment {
  id        String   @id @default(uuid())
  postId    String
  authorId  String
  content   String
  likeCount Int      @default(0)
  createdAt DateTime @default(now())

  post   CirclePost @relation(fields: [postId], references: [id], onDelete: Cascade)
  author User       @relation(fields: [authorId], references: [id], onDelete: Cascade)
}
```

---

## 五、路由路径规范

根据需求文档，API 路径应做如下调整：

### 5.1 当前路径 vs 标准路径

| 模块 | 当前路径 | 需求文档路径 | 建议 |
|-----|---------|------------|------|
| 用户注册 | /users/register | /user/register | 保持现状（RESTful） |
| 用户登录 | /users/login | /user/login | 保持现状 |
| 好友请求 | - | /user/friend/request | 新增路由 |
| 消息历史 | /im/messages | /im/message/history | 建议统一 |
| 游戏创建 | /game/create | /game/room/create | 建议统一 |
| 慢聊列表 | /slow-chat/rooms | /slowchat/list | 建议统一 |
| 圈子列表 | /circle/posts | /circle/list | 建议统一 |

### 5.2 路径调整建议

为了与需求文档保持一致，建议按以下方式组织路由：

```
/api
├── users/
│   ├── register
│   ├── login
│   ├── profile
│   ├── friend/
│   │   ├── request
│   │   ├── handle
│   │   └── list
│   └── online/status
├── im/
│   ├── message/
│   │   ├── history
│   │   ├── read
│   │   ├── recall
│   │   └── unread/count
│   ├── group/
│   │   ├── create
│   │   └── member
│   └── conversations
├── game/
│   ├── room/
│   │   ├── create
│   │   ├── list
│   │   ├── join
│   │   ├── exit
│   │   └── destroy
│   ├── brush/sync
│   └── round/
│       ├── start
│       └── end
├── slowchat/
│   ├── send
│   ├── list
│   ├── open
│   ├── delete
│   └── anonymous
├── circle/
│   ├── list
│   └── post/
│       ├── publish
│       ├── list
│       ├── detail
│       ├── like
│       ├── filter
│       └── delete
├── common/
│   ├── upload
│   ├── token/refresh
│   ├── config
│   └── sensitive/filter
```

---

## 六、下一步行动

1. **人工配置**：请先配置 `.env` 文件中的外部服务密钥（腾讯云、阿里云等）
2. **数据迁移**：运行 `npx prisma migrate dev` 更新数据库结构
3. **按优先级开发**：按 P0 -> P1 -> P2 顺序实现接口
4. **Swagger 更新**：每完成一个接口，同步更新 Swagger 文档注释
5. **测试验证**：使用 `/api-docs` 页面测试接口

---

## 七、联系方式

如在开发过程中遇到问题，请检查：
1. `.env` 配置是否完整
2. 数据库连接是否正常
3. Redis 连接是否正常
4. 腾讯云/阿里云服务是否开通