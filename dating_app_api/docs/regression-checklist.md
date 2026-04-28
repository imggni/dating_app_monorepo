## Regression checklist (minimum)

This is a **manual + integration** checklist used while refactoring the backend.

### Global

- All JSON responses are enveloped as `{ code, message, data }` (target contract).
- Error responses do not leak secrets (no tokens/passwords/PII in logs or `data` in production).
- Validation errors return HTTP `400` with `message=参数校验失败` and `data.errors[]`.
- 404 unknown route under `/api/*` returns consistent envelope and Chinese message.

### User

- `POST /api/user/register`
  - success: `201`, `code=0`, has `data.user` and `data.token/refreshToken`
  - invalid body: `400` validation envelope
- `POST /api/user/login`
  - success: `200`, `code=0`, has tokens
  - wrong password: `401`/`400` (whichever is defined), consistent envelope
- `GET /api/user/profile` (auth required)
  - missing/invalid token: `401` envelope
  - success: `200` envelope

### Common

- `POST /api/common/upload` (auth required)
  - missing file: `400` envelope
  - success: `200` envelope with `data.url`
- `POST /api/common/token/refresh`
  - missing refreshToken: `400` envelope
  - success: `200` envelope with new tokens

### IM

- `GET /api/im/messages?friendId=...`
  - invalid pagination params: `400` validation envelope
  - success: `200` envelope
- `POST /api/im/send`
  - missing receiverId/content: `400` validation envelope
  - success: `200` envelope with message payload
- `PUT /api/im/messages/:messageId/read`
  - invalid messageId: `400` validation envelope
  - success: `200` envelope

### Circle

- `GET /api/circle/posts?page=1&limit=10`
  - success: `200` envelope with pagination payload

### Game

- `GET /api/game/rooms`
  - success: `200` envelope
