# API 设计规范

**核心约束（必须遵守）**
1. **RESTful 风格**: 接口路径使用名词复数，小写短横线分隔（如 `/api/user-profiles`），方法使用 GET/POST/PUT/DELETE。
2. **统一返回格式**: 
   所有接口必须返回统一 JSON 结构：
   ```json
   {
     "code": 0,           // 0 表示成功，非 0 表示业务错误
     "message": "success",// 提示信息
     "data": {}           // 具体业务数据
   }
   ```
3. **分页规范**: 分页接口统一使用 `page`（从 1 开始）和 `limit` 参数。返回数据必须包含 `total` 字段。
4. **命名规范**: JSON 字段必须使用 `camelCase` 驼峰命名法，严禁使用下划线。