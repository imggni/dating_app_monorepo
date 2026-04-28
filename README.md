# dating_app_monorepo

Monorepo for **Dating App**.

- **Flutter app**: `dating_app/`
- **Express API (TypeScript + Prisma)**: `dating_app_api/`
- **Docs**: `docs/` and `dating_app_api/docs/`

## Quick start

### Frontend (Flutter)

See `dating_app/README.md`.

### Backend (API)

See `dating_app_api/README.md`.

## Tooling

- **Git hooks**: Husky is enabled via root `package.json` (`npm run prepare`).
- **Pre-commit**: `lint-staged` runs:
  - `dating_app/**/*.dart`: `dart format`
  - `dating_app_api/**/*.{js,ts,tsx}`: Prettier + ESLint fix
  - `dating_app_api/**/*.{json,md,yml,yaml}`: Prettier
