---
applyTo: "dating_app/lib/views/**/*.dart, dating_app/lib/controllers/**/*.dart, dating_app/lib/services/**/*.dart, dating_app/lib/models/**/*.dart"
---

# Flutter 架构分层规范

## GetX 标准分层架构（强制）

```
View 视图层（页面）
  ↓（绑定 GetX）
Controller 控制层（逻辑与状态管理）
  ↓
Service 服务层（数据获取与业务逻辑）
  ↓
Model 数据层（Domain 模型）
```

**核心原则**：UI 与业务逻辑彻底分离，通过 GetX 依赖注入与生命周期管理。

### View 层（页面视图）

**职责**：只负责 UI 展示，监听 Controller 状态变化

```dart
// lib/views/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Obx(
        () {
          // 监听 controller 状态变化
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.errorMessage.value),
                  ElevatedButton(
                    onPressed: controller.loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.items.isEmpty) {
            return const Center(child: Text('No data'));
          }

          return ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ListTile(
                title: Text(item.name),
                onTap: () => controller.selectItem(item),
              );
            },
          );
        },
      ),
    );
  }
}
```

**禁止事项**：
- ❌ 在 View 中调用 API
- ❌ 在 View 中写复杂业务逻辑
- ❌ View 直接修改 Model 数据

### Controller 层（GetX Controller）

**职责**：管理状态、处理用户交互、调用 Service

```dart
// lib/controllers/home_controller.dart
import 'package:get/get.dart';
import '../services/home_service.dart';
import '../models/item.dart';

class HomeController extends GetxController {
  final HomeService homeService = Get.find();

  // 声明可观测状态
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final items = <Item>[].obs;
  final selectedItem = Rxn<Item>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // 加载数据
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await homeService.fetchItems();
      items.value = data;
    } on Exception catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 处理用户交互
  void selectItem(Item item) {
    selectedItem.value = item;
    Get.toNamed('/detail', arguments: item);
  }

  @override
  void onClose() {
    // 清理资源
    super.onClose();
  }
}
```

**GetX Bindings（依赖注入与生命周期管理）**：

```dart
// lib/controllers/bindings/home_binding.dart
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../services/home_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 注册 Service（单例）
    Get.lazyPut<HomeService>(() => HomeService());
    
    // 注册 Controller（页面销毁时自动销毁）
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

// 在路由中绑定
GetPage(
  name: '/home',
  page: () => const HomePage(),
  binding: HomeBinding(),
),
```

### Service 层（业务逻辑与数据获取）

**职责**：调用 API、执行业务逻辑、缓存管理

```dart
// lib/services/home_service.dart
import 'package:dio/dio.dart';
import '../models/item.dart';
import '../api/api_client.dart';

class HomeService extends GetxService {
  final ApiClient apiClient = Get.find();

  // 缓存
  List<Item>? _cachedItems;

  Future<List<Item>> fetchItems({bool forceRefresh = false}) async {
    // 如果有缓存且不强制刷新，返回缓存
    if (_cachedItems != null && !forceRefresh) {
      return _cachedItems!;
    }

    try {
      // 调用 API 客户端
      final response = await apiClient.get('/api/items');
      
      // 解析响应（由 Retrofit 自动处理）
      final items = (response as List)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // 缓存数据
      _cachedItems = items;
      return items;
    } catch (e) {
      rethrow;
    }
  }

  Future<Item> getItemDetail(String itemId) async {
    return await apiClient.get('/api/items/$itemId');
  }
}
```

### Model 层（Domain 数据模型）

**职责**：纯数据定义，支持序列化/反序列化

```dart
// lib/models/item.dart
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
```

## 禁止事项

- ❌ **View 直接调用 API**：必须走 Service
- ❌ **Controller 包含 UI 逻辑**：UI 在 View 中
- ❌ **跨 Controller 调用**：通过 Get.find() 获取 Service
- ❌ **在 Model 中包含业务逻辑**：Model 只是数据容器
- ❌ **Controller 中的异步操作未处理异常**：必须 try-catch

## 生命周期管理

GetX Controller 自动管理生命周期：

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    // 页面初始化时调用
    print('Controller initialized');
    super.onInit();
  }

  @override
  void onReady() {
    // 页面准备就绪时调用（可以做一些延迟加载）
    print('Page is ready');
    super.onReady();
  }

  @override
  void onClose() {
    // 页面销毁时调用（必须释放资源、取消网络请求等）
    print('Controller disposed');
    super.onClose();
  }
}
```

## 常见模式

### 双向绑定

```dart
// View 层
Obx(() => Text('Count: ${controller.count.value}')),
ElevatedButton(
  onPressed: controller.increment,
  child: const Text('Increment'),
),

// Controller 层
final count = 0.obs;

void increment() {
  count.value++;
}
```

### 列表状态管理

```dart
// Controller 层
final items = <Item>[].obs;
final selectedIndex = (-1).obs;

void selectItem(int index) {
  selectedIndex.value = index;
}

// View 层
Obx(() => 
  ListView.builder(
    itemCount: controller.items.length,
    itemBuilder: (context, index) {
      return ListTile(
        selected: controller.selectedIndex.value == index,
        onTap: () => controller.selectItem(index),
        title: Text(controller.items[index].name),
      );
    },
  )
)
```
