# dating_app (Flutter)

Flutter client app for the Dating App monorepo.

## Requirements

- Flutter SDK installed
- A running backend API (`dating_app_api/`) or a reachable API server

## Environment variables

This app reads environment variables from `dating_app/.env`.

Example (`dating_app/.env`):

```bash
BASE_URL=http://127.0.0.1:3000/api
IM_SDK_APP_ID=1600138422
APP_NAME=轻语
```

Notes:

- `BASE_URL` should point to the backend REST base path (ends with `/api`).
- For Android emulator, you may need `10.0.2.2` to reach host localhost.

## Run

```bash
cd dating_app
flutter pub get
flutter run
```

## Formatting

```bash
cd dating_app
dart format .
```

## 打包

测试包： `git tag app-test-v1.0.0`，`git push origin app-test-v1.0.0`
正式包： `git tag app-prod-v1.0.0`，`git push origin app-prod-v1.0.0`

GitHub Actions 只按环境区分后端接口地址：

- 测试包：`APP_TEST_BASE_URL`
- 正式包：`APP_PROD_BASE_URL`

其他前端配置测试包和正式包共用，不需要分别配置 test/prod secrets。
