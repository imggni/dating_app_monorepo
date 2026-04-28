## API contract (Dating App API)

This backend aims to expose a consistent REST contract for all endpoints under `/api`.

### Response envelope

All HTTP JSON responses should use the envelope below:

```json
{
  "code": 0,
  "message": "操作成功",
  "data": {}
}
```

- **`code`**: business-level code
  - `0` means success.
  - non-zero means failure (when possible, align with HTTP status code or a stable business code set; pick one strategy and keep it consistent).
- **`message`**: human-readable message, **Chinese**.
- **`data`**: payload
  - success: object/array/primitive, depending on endpoint
  - error: `null` or `{ errors: [...] }` for validation failures

### HTTP status

- Success should respond with `2xx` (`200` typical; `201` for resource creation).
- Failures should respond with appropriate `4xx/5xx`.

### Validation failures

For request validation failures, return HTTP `400` with:

```json
{
  "code": 400,
  "message": "参数校验失败",
  "data": {
    "errors": [
      { "field": "body.phone", "message": "Required" }
    ]
  }
}
```

### Notes

- This document is the **target contract**. Some existing endpoints may temporarily deviate while refactors are in progress; those deviations should be eliminated in Phase 2 (contract consistency).

