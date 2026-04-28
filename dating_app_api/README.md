# dating_app_api (Express + TypeScript + Prisma)

Backend API service for the Dating App monorepo.

## Requirements

- Node.js (LTS recommended)
- A MySQL database (via `DATABASE_URL`)

## Setup

```bash
cd dating_app_api
pnpm install
```

## Environment variables

This service loads env vars from `dating_app_api/.env` (do **not** commit secrets).

Create your local `.env` based on `dating_app_api/.env.example`:

```bash
cd dating_app_api
cp .env.example .env
```

Minimum variables:

- `PORT`: API port (default 3000)
- `NODE_ENV`: `development` / `test` / `production`
- `JWT_SECRET`: secret used to sign JWTs
- `DATABASE_URL`: Prisma database connection string
- (Optional) `ALLOWED_ORIGINS`, `CORS_ENABLED`
- (Optional) Upstash Redis / CloudBase / Tencent IM / JPush variables if those features are used

## Database (Prisma)

```bash
cd dating_app_api
pnpm prisma generate
pnpm prisma migrate dev
```

## Run

```bash
cd dating_app_api
pnpm dev
```

## Build & start

```bash
cd dating_app_api
pnpm build
pnpm start
```

## OpenAPI

Generate `src/openapi.json`:

```bash
cd dating_app_api
pnpm openapi
```

Swagger config: `src/config/swagger.ts`

## Tests

```bash
cd dating_app_api
pnpm test
```

Regression checklist: `docs/regression-checklist.md`

## API contract

Contract doc: `docs/api-contract.md`

## 打包

测试环境： `git tag api-test-v1.0.0`，`git push origin api-test-v1.0.0`
生产环境： `git tag api-prod-v1.0.0`，`git push origin api-prod-v1.0.0`

CloudBase 云托管使用同一个 `CLOUDBASE_ENV_ID`，按 tag 部署到不同服务：

- 测试环境：`dating-app-api-test`
- 生产环境：`dating-app-api`

GitHub Actions 只按环境区分数据库连接：

- 测试数据库：`API_TEST_DATABASE_URL`
- 生产数据库：`API_PROD_DATABASE_URL`

其他后端配置共用同一组 secrets，例如 `JWT_SECRET`、`CLOUDBASE_STORAGE_URL`、`TENCENT_IM_SECRET`、`JPUSH_MASTER_SECRET` 等。
