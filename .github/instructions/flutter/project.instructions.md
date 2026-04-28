---
applyTo: "dating_app/lib/**/*.dart, dating_app/pubspec.yaml, dating_app/analysis_options.yaml"
---

# Flutter 项目总览规范

## 项目结构

```
dating_app/
├── lib/
│   ├── main.dart                     # 应用入口
│   ├── app.dart                      # 应用配置（路由、主题等）
│   ├── config/                       # 常量与配置
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── themes.dart
│   ├── models/                       # Domain 数据模型
│   │   ├── user.dart
│   │   ├── message.dart
│   │   └── states.dart
│   ├── views/                        # 页面（GetView）
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   ├── home_controller.dart
│   │   │   ├── home_binding.dart
│   │   │   └── widgets/
│   │   └── profile/
│   ├── controllers/                  # GetX Controllers
│   │   ├── home_controller.dart
│   │   ├── auth_controller.dart
│   │   └── bindings/
│   │       ├── home_binding.dart
│   │       └── auth_binding.dart
│   ├── services/                     # 业务服务
│   │   ├── auth_service.dart
│   │   ├── user_service.dart
│   │   └── storage_service.dart
│   ├── api/                          # API 客户端
│   │   └── api_client.dart
│   ├── widgets/                      # 可复用组件
│   │   ├── buttons/
│   │   ├── cards/
│   │   └── common/
│   ├── utils/                        # 工具函数
│   │   ├── error_handler.dart
│   │   └── validators.dart
│   └── routes/                       # 路由配置
│       └── app_routes.dart
├── assets/                           # 静态资源
│   ├── images/
│   └── fonts/
├── test/                             # 测试
├── pubspec.yaml
└── analysis_options.yaml
```

## 依赖管理

### 核心依赖（pubspec.yaml）

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 状态管理与依赖注入
  get: ^4.6.6

  # 网络请求
  dio: ^5.3.0
  retrofit: ^4.1.0
  json_serializable: ^6.7.0

  # 本地存储
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # 即时通讯（腾讯云 IM）
  socket_io_client: ^2.0.0
  tencent_im_sdk_plugin: ^2.3.0  # 或官方腾讯云 IM SDK

  # 工具库
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # 代码生成
  build_runner: ^2.4.0
  hive_generator: ^2.0.0
  retrofit_generator: ^8.0.0

  # 分析与检查
  flutter_lints: ^2.0.0
```

## 命名规范

### 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| Widget/Page | snake_case | `home_page.dart` |
| Controller | snake_case | `home_controller.dart` |
| Service | snake_case | `user_service.dart` |
| Model | snake_case | `user.dart` |
| Util 函数 | snake_case | `error_handler.dart` |

### 代码命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | PascalCase | `class HomePage {}` |
| 函数/方法 | camelCase | `void loadData()` |
| 变量/常量 | camelCase | `final userName = ''` |
| 常量（全局） | camelCase | `const appName = 'DatingApp'` |
| 私有成员 | 前缀 `_` | `final _storage = ...` |

## 空安全规范

### 处理 Nullable 类型

```dart
// ❌ 错误：强制解包
final name = user!.name;

// ✅ 正确：使用 ? 安全导航
final name = user?.name;

// ✅ 正确：使用 ?? 默认值
final name = user?.name ?? 'Unknown';

// ✅ 正确：在 null 时返回
if (user == null) return;
final name = user.name;
```

### Nullable 状态

```dart
// lib/controllers/user_controller.dart
class UserController extends GetxController {
  // Nullable 对象
  final user = Rxn<User>();  // 初始为 null
  
  // 非 nullable（必须初始化）
  final userName = ''.obs;
  
  void setUser(User? newUser) {
    user.value = newUser;
  }

  // 在 View 中安全访问
  // Obx(() => user.value != null ? UserCard(user: user.value!) : Empty())
}
```

## 异常处理

### 统一异常类

```dart
// lib/utils/exceptions.dart
class AppException implements Exception {
  final String message;
  final dynamic originalError;

  AppException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({required String message})
      : super(message: 'Network Error: $message');
}

class ValidationException extends AppException {
  ValidationException({required String message})
      : super(message: 'Validation Error: $message');
}

class AuthException extends AppException {
  AuthException({required String message})
      : super(message: 'Auth Error: $message');
}
```

### 错误捕获

```dart
// lib/controllers/home_controller.dart
Future<void> loadData() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    
    final data = await homeService.fetchItems();
    items.value = data;
  } on NetworkException catch (e) {
    errorMessage.value = '网络连接失败，请检查网络设置';
    // 特定处理
  } on AppException catch (e) {
    errorMessage.value = e.message;
  } catch (e) {
    errorMessage.value = '出现未知错误';
    print('Unexpected error: $e');
  } finally {
    isLoading.value = false;
  }
}
```

## 环境配置

### flutter_dotenv 管理

```dart
// lib/config/env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  static String get appName => dotenv.env['APP_NAME'] ?? 'DatingApp';
  static String get tencentImAppId => dotenv.env['TENCENT_IM_APP_ID'] ?? '';
}

// lib/main.dart
void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

// .env 文件（不提交到版本控制）
API_BASE_URL=http://localhost:3000
APP_NAME=DatingApp
TENCENT_IM_APP_ID=123456789
```

## 代码风格检查

### analysis_options.yaml

```yaml
linter:
  rules:
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - control_flow_in_finally
    - empty_statements
    - hash_and_equals
    - invariant_booleans
    - iterable_contains_unrelated_type
    - list_remove_unrelated_type
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - prefer_void_to_null
    - throw_in_finally
    - unnecessary_statements
    - unrelated_type_equality_checks
```

### 格式化

```bash
# 代码格式化
dart format lib/ test/

# 分析
dart analyze
```

## 性能优化

### const 构造函数

```dart
// ❌ 不推荐
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Title'),
      Icon(Icons.home),
    ],
  );
}

// ✅ 推荐
@override
Widget build(BuildContext context) {
  return const Column(
    children: [
      Text('Title'),
      Icon(Icons.home),
    ],
  );
}
```

### 图片优化

```dart
// ❌ 不推荐
Image.network('https://...', width: 300, height: 300)

// ✅ 推荐：添加缓存管理
Image.network(
  'https://...',
  width: 300,
  height: 300,
  cacheWidth: 300,
  cacheHeight: 300,
)
```

## 禁止事项

- ❌ **不使用全局变量**：优先用 GetX 依赖注入
- ❌ **不在 Widget build 中做耗时操作**：用 FutureBuilder 或 Controller
- ❌ **不忽视内存泄漏**：释放资源、取消订阅、关闭连接
- ❌ **不硬编码字符串**：使用常量或国际化
- ❌ **不混合不同的状态管理方案**：统一用 GetX
