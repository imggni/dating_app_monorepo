---
applyTo: "dating_app/lib/controllers/**/*.dart, dating_app/lib/models/**/*.dart, dating_app/lib/utils/**/*.dart"
---

# Flutter 状态管理与本地存储规范

## GetX 状态管理

### 声明可观测状态

```dart
// lib/controllers/auth_controller.dart
import 'package:get/get.dart';

class AuthController extends GetxController {
  // 简单类型
  final isLoggedIn = false.obs;
  final userName = ''.obs;
  
  // 对象类型
  final user = Rxn<User>();  // nullable
  
  // 集合类型
  final messages = <Message>[].obs;
  
  // 复杂状态（可选）
  late final loginState = Rx<LoginState>(const LoginState.idle());

  void updateUserName(String name) {
    userName.value = name;
  }

  void setUser(User? newUser) {
    user.value = newUser;
  }

  void addMessage(Message msg) {
    messages.add(msg);
  }
}
```

### 在 View 中监听状态变化

```dart
class LoginPage extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 单一状态监听
          Obx(() => Text(controller.userName.value)),
          
          // 多个状态监听
          Obx(
            () => Column(
              children: [
                Text('User: ${controller.user.value?.name ?? 'Unknown'}'),
                Text('Messages: ${controller.messages.length}'),
              ],
            ),
          ),
          
          // 条件渲染
          Obx(
            () => controller.isLoggedIn.value
                ? LoggedInWidget()
                : LoggedOutWidget(),
          ),
        ],
      ),
    );
  }
}
```

## Hive 本地存储（常规数据）

### 配置 Hive

```dart
// lib/main.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';

void main() async {
  // 初始化 Hive
  await Hive.initFlutter();
  
  // 注册适配器（json_serializable 生成）
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(MessageAdapter());
  
  // 打开 Box
  await Hive.openBox<User>('users');
  await Hive.openBox<Message>('messages');
  await Hive.openBox('app_settings');
  
  runApp(const MyApp());
}
```

### 操作本地数据

```dart
// lib/services/storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  late Box<User> userBox;
  late Box<Message> messageBox;
  late Box settingsBox;

  @override
  void onInit() {
    userBox = Hive.box<User>('users');
    messageBox = Hive.box<Message>('messages');
    settingsBox = Hive.box('app_settings');
    super.onInit();
  }

  // 用户相关
  Future<void> saveUser(User user) async {
    await userBox.put(user.id, user);
  }

  User? getUser(String id) => userBox.get(id);

  Future<void> deleteUser(String id) async {
    await userBox.delete(id);
  }

  List<User> getAllUsers() => userBox.values.toList();

  // 消息相关
  Future<void> saveMessage(Message msg) async {
    await messageBox.put(msg.id, msg);
  }

  List<Message> getMessages(String userId) {
    return messageBox.values
        .where((msg) => msg.senderId == userId)
        .toList();
  }

  // 应用设置
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  // 清空所有数据
  Future<void> clearAll() async {
    await userBox.clear();
    await messageBox.clear();
    await settingsBox.clear();
  }
}
```

### Model 定义

```dart
// lib/models/user.dart
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';
part 'user.h.dart';  // Hive 生成

@HiveType(typeId: 0)
@JsonSerializable()
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

## flutter_secure_storage（敏感数据）

### 配置

```dart
// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorageService extends GetxService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keystore: AndroidKeystore(),
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_available,
    ),
  );

  // 保存敏感数据
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // 读取敏感数据
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // 删除敏感数据
  Future<void> removeToken() async {
    await _storage.delete(key: 'access_token');
  }

  // 保存用户密码（谨慎使用）
  Future<void> savePassword(String password) async {
    await _storage.write(key: 'user_password', value: password);
  }

  // 清空所有敏感数据（登出时调用）
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### 使用场景

```dart
// lib/services/auth_service.dart
class AuthService extends GetxService {
  late SecureStorageService secureStorage;
  late StorageService localStorage;

  @override
  void onInit() {
    secureStorage = Get.find();
    localStorage = Get.find();
    super.onInit();
  }

  /// 登录
  Future<void> login(String email, String password) async {
    try {
      final response = await apiClient.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response['data']['access_token'];
      final user = User.fromJson(response['data']['user']);

      // 敏感数据存到 flutter_secure_storage
      await secureStorage.saveToken(token);

      // 用户信息存到 Hive
      await localStorage.saveUser(user);

    } catch (e) {
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    await secureStorage.clearAll();
    await localStorage.clearAll();
  }

  /// 检查登录状态
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
```

## 复杂状态管理（Freezed + Riverpod 可选）

如需更复杂的状态管理，可选用 Freezed + 状态枚举：

```dart
// lib/models/states.dart
class LoginState {
  const LoginState._();

  const factory LoginState.idle() = _Idle;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.success(User user) = _Success;
  const factory LoginState.error(String message) = _Error;
}

// lib/controllers/auth_controller.dart
class AuthController extends GetxController {
  final loginState = Rx<LoginState>(const LoginState.idle());

  Future<void> login(String email, String password) async {
    try {
      loginState.value = const LoginState.loading();
      final user = await authService.login(email, password);
      loginState.value = LoginState.success(user);
    } catch (e) {
      loginState.value = LoginState.error(e.toString());
    }
  }
}

// View
Obx(
  () => loginState.loginState.when(
    idle: () => LoginForm(),
    loading: () => LoadingWidget(),
    success: (user) => SuccessWidget(user: user),
    error: (msg) => ErrorWidget(message: msg),
  ),
)
```

## 最佳实践

### 初始化 Service（app 启动）

```dart
// lib/main.dart
void main() async {
  // 注册 Services
  Get.put(SecureStorageService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(ApiClient(), permanent: true);
  Get.put(AuthService(), permanent: true);
  
  runApp(const MyApp());
}
```

### 在 Controller 中访问状态

```dart
// lib/controllers/home_controller.dart
class HomeController extends GetxController {
  final authService = Get.find<AuthService>();
  final storageService = Get.find<StorageService>();

  final userProfile = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final users = storageService.getAllUsers();
      if (users.isNotEmpty) {
        userProfile.value = users.first;
      }
    } catch (e) {
      // 处理错误
    }
  }
}
```

## 禁止事项

- ❌ **不直接存储敏感数据到 Hive**：必须用 flutter_secure_storage
- ❌ **不在 Model 中混合 GetX 状态**：GetX 状态只在 Controller 中
- ❌ **不过度使用全局状态**：优先用 Controller 局部状态
- ❌ **不忘记在登出时清空数据**：必须调用 clearAll
- ❌ **不在 onInit 中做耗时操作**：用 onReady 或异步处理
