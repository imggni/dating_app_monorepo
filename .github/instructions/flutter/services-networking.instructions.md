---
applyTo: "dating_app/lib/services/**/*.dart, dating_app/lib/api/**/*.dart"
---

# Flutter 服务与网络通信规范

## API 客户端集中管理

### Dio + Retrofit 配置

```dart
// lib/api/api_client.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'retrofit.dart';  // 生成的 part 文件

part 'api_client.g.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._();

  factory ApiClient() => _instance;

  ApiClient._() {
    _setupDio();
  }

  late Dio _dio;

  void _setupDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        headers: {
          'User-Agent': 'DatingApp/1.0',
        },
      ),
    );

    // 请求拦截器：添加认证 Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 从本地存储读取 Token
          final token = await _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 检查响应码
          if (response.statusCode == 200 || response.statusCode == 201) {
            return handler.next(response);
          }
          // 返回自定义错误
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              message: response.data?['message'] ?? 'Unknown error',
              response: response,
            ),
          );
        },
        onError: (error, handler) {
          // 统一错误处理
          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getAuthToken() async {
    // 从 flutter_secure_storage 读取 Token
    // final storage = const FlutterSecureStorage();
    // return await storage.read(key: 'access_token');
    return null;  // 实现见 storage-state.instructions.md
  }

  void _handleError(DioException error) {
    String errorMsg = 'Network error';
    
    if (error.type == DioExceptionType.connectionTimeout) {
      errorMsg = 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMsg = 'Receive timeout';
    } else if (error.response != null) {
      errorMsg = error.response?.data?['message'] ?? errorMsg;
    }

    // 全局错误提示（可选）
    // Get.snackbar('Error', errorMsg);
  }

  Dio get dio => _dio;
}

// 使用 Retrofit 定义 API 接口
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  @GET('/api/users/{id}')
  Future<Map<String, dynamic>> getUserById(@Path('id') String id);

  @POST('/api/users')
  Future<Map<String, dynamic>> createUser(@Body() Map<String, dynamic> user);
}
```

### 生成 Retrofit 代码

```bash
# pubspec.yaml
dev_dependencies:
  retrofit_generator: ^8.0.0
  build_runner: ^2.0.0

# 生成代码
flutter pub run build_runner build
```

## Service 层（业务服务）

### API Service

```dart
// lib/services/user_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class UserService extends GetxService {
  late Dio _dio;

  @override
  void onInit() {
    _dio = ApiClient()._dio;
    super.onInit();
  }

  /// 获取用户信息
  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('/api/users/$id');
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        return User.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Unknown error');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// 创建用户
  Future<User> createUser({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/users',
        data: {
          'email': email,
          'name': name,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return User.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Unknown error');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// 批量获取用户
  Future<List<User>> getUsers({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(
        '/api/users',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final data = response.data['data'];
        return (data['items'] as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception(response.data['message'] ?? 'Unknown error');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// 统一 DioException 处理
  void _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw Exception('Connection timeout');
      case DioExceptionType.sendTimeout:
        throw Exception('Send timeout');
      case DioExceptionType.receiveTimeout:
        throw Exception('Receive timeout');
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized');
        }
        if (e.response?.statusCode == 403) {
          throw Exception('Forbidden');
        }
        throw Exception(e.response?.data?['message'] ?? 'Server error');
      case DioExceptionType.cancel:
        throw Exception('Request cancelled');
      default:
        throw Exception('Network error: ${e.message}');
    }
  }
}
```

## 响应模型与映射

### 统一响应体

后端返回格式：
```json
{
  "code": 200,
  "message": "Success",
  "data": { /* 业务数据 */ }
}
```

### 响应包装类

```dart
// lib/models/api_response.dart
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  bool get isSuccess => code == 200;
}
```

## 缓存管理

### 简单缓存

```dart
// lib/services/cached_user_service.dart
class CachedUserService extends GetxService {
  final _userCache = <String, User>{};
  final _cacheExpiry = <String, DateTime>{};

  /// 获取用户（带缓存）
  Future<User> getUserById(String id, {bool forceRefresh = false}) async {
    // 检查缓存
    if (!forceRefresh && _isCacheValid(id)) {
      return _userCache[id]!;
    }

    try {
      final user = await UserService().getUserById(id);
      
      // 缓存数据（5 分钟过期）
      _userCache[id] = user;
      _cacheExpiry[id] = DateTime.now().add(const Duration(minutes: 5));
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  bool _isCacheValid(String id) {
    final expiry = _cacheExpiry[id];
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  void clearCache() {
    _userCache.clear();
    _cacheExpiry.clear();
  }
}
```

## 错误处理最佳实践

```dart
// lib/utils/error_handler.dart
class ErrorHandler {
  /// 处理错误并返回用户友好的消息
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时，请检查网络';
        case DioExceptionType.receiveTimeout:
          return '服务器响应超时';
        case DioExceptionType.badResponse:
          return error.response?.data?['message'] ?? '请求失败';
        default:
          return '网络错误，请重试';
      }
    }

    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return 'Unknown error';
  }
}

// 在 Controller 中使用
Future<void> loadData() async {
  try {
    isLoading.value = true;
    final users = await userService.getUsers();
    this.users.value = users;
  } catch (e) {
    errorMessage.value = ErrorHandler.handleError(e);
  } finally {
    isLoading.value = false;
  }
}
```

## 禁止事项

- ❌ **不在 Widget 中直接调用 API**：必须通过 Service
- ❌ **不忽视网络超时**：必须设置合理的超时时间
- ❌ **不在 UI 线程做耗时操作**：使用异步
- ❌ **不硬编码 API 地址**：使用环境变量
- ❌ **不返回原始 DioException**：包装为业务异常
