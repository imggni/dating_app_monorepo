# Dating App API - OpenAPI 规范

这是一个完整的交友聊天应用后端API的OpenAPI 3.0.3规范文档。

## 功能模块

- **用户管理 (User)**: 注册、登录、个人资料管理、好友关系
- **即时通讯 (IM)**: 私聊、群聊、消息管理
- **圈子动态 (Circle)**: 帖子发布、评论、点赞
- **游戏房间 (Game)**: 房间创建、游戏管理、画笔同步
- **慢速聊天 (SlowChat)**: 延迟消息、匿名聊天
- **通用功能 (Common)**: 文件上传、地区数据、系统配置

## API 文档访问

启动服务器后，可以通过以下方式访问API文档：

- **Swagger UI**: `http://localhost:3000/api-docs`
- **OpenAPI JSON**: `http://localhost:3000/api/openapi.json`

## 开发和部署

### 本地开发

```bash
# 安装依赖
npm install

# 生成 OpenAPI 规范
npm run openapi

# 启动开发服务器
npm run dev
```

### 生产部署

```bash
# 构建生产版本
npm start
```

## API 规范特点

- ✅ **完整的接口文档**: 包含所有请求参数、响应结构和错误码
- ✅ **类型安全**: 使用 JSON Schema 严格定义数据结构
- ✅ **认证集成**: JWT Bearer Token 认证
- ✅ **分页支持**: 统一的 pagination 结构
- ✅ **错误处理**: 标准化的错误响应格式
- ✅ **可扩展**: 模块化设计，易于添加新功能

## 统一响应格式

所有API响应都遵循统一的格式：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    // 具体数据内容
  }
}
```

### 状态码说明

- `200`: 成功
- `400`: 参数错误
- `401`: 未授权
- `403`: 禁止访问
- `404`: 资源不存在
- `500`: 服务器错误

## 认证方式

大部分接口需要 JWT 认证，在请求头中添加：

```
Authorization: Bearer <your-jwt-token>
```

## 分页查询

支持分页的接口使用统一的查询参数：

- `page`: 页码（从1开始，默认1）
- `pageSize`: 每页条数（1-100，默认10）

响应中包含分页信息：

```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "pageSize": 10,
      "total": 125,
      "totalPages": 13
    }
  }
}
```

## 文件上传

支持的文件类型：
- 图片: JPEG, PNG, GIF, WebP
- 音频: MP3, WAV, OGG
- 视频: MP4, AVI, MOV
- 文档: PDF, TXT, DOC

最大文件大小: 10MB

## 实时通讯

应用使用 Socket.IO 进行实时通讯，支持：
- 私聊消息
- 群聊消息
- 游戏房间同步
- 在线状态更新

## 数据验证

所有请求参数都经过 Zod 模式验证，确保数据类型和格式正确。

## 敏感内容过滤

提供敏感内容检测和过滤功能，支持文本和图片内容的安全检查。