---
applyTo: "dating_app/lib/widgets/**/*.dart, dating_app/lib/views/**/widgets/**/*.dart"
---

# Flutter Widget 与组件规范

## Widget 分类

### StatelessWidget（无状态）

用于纯展示组件：

```dart
// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
```

### StatefulWidget（有状态）

仅当需要本地状态时使用（大多数情况使用 GetX）：

```dart
// lib/widgets/counter_widget.dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

**推荐**：优先使用 GetX Obx，避免 StatefulWidget

## 组件命名规范

- 组件名称：大驼峰 PascalCase：`UserCard`, `LoginForm`, `MessageList`
- 文件名称：小写 + 下划线：`user_card.dart`, `login_form.dart`
- 常用后缀：`Widget`、`Card`、`List`、`Form`、`Dialog` 等

## 可复用组件设计

### 通用组件库结构

```
lib/widgets/
├── buttons/
│   ├── custom_button.dart
│   └── social_login_button.dart
├── cards/
│   ├── user_card.dart
│   └── message_card.dart
├── inputs/
│   ├── text_input.dart
│   └── phone_input.dart
├── dialogs/
│   └── confirm_dialog.dart
└── common/
    ├── loading_overlay.dart
    └── empty_state.dart
```

### 示例：可复用卡片组件

```dart
// lib/widgets/cards/user_card.dart
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String avatar;
  final String bio;
  final VoidCallback onTap;

  const UserCard({
    Key? key,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Image.network(
                avatar,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // 内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bio,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 页面级组件（内嵌小组件）

页面内的私有组件写在同一文件或单独的 `widgets/` 子目录：

```dart
// lib/views/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'widgets/item_list.dart';     // 页面内组件
import 'widgets/filter_bar.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          FilterBar(onFilterChanged: controller.applyFilter),
          ItemList(items: controller.items),
        ],
      ),
    );
  }
}

// lib/views/home/widgets/item_list.dart
class ItemList extends StatelessWidget {
  final List<Item> items;
  
  const ItemList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemTile(item: items[index]),
    );
  }
}
```

## 状态反馈组件

### 加载状态

```dart
// lib/widgets/common/loading_overlay.dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

// 使用
Obx(() => LoadingOverlay(
  isLoading: controller.isLoading.value,
  child: YourContent(),
))
```

### 空状态

```dart
// lib/widgets/common/empty_state.dart
class EmptyState extends StatelessWidget {
  final String message;
  final String? imagePath;
  final VoidCallback? onRetry;

  const EmptyState({
    Key? key,
    required this.message,
    this.imagePath,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            Image.asset(imagePath!, height: 100),
          const SizedBox(height: 16),
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 错误状态

```dart
// lib/widgets/common/error_state.dart
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## 性能优化

### const Constructor

尽可能使用 const 构造函数：

```dart
// ❌ 不推荐
class MyWidget extends StatelessWidget {
  final String title;
  
  MyWidget({Key? key, required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) => Text(title);
}

// ✅ 推荐
class MyWidget extends StatelessWidget {
  final String title;
  
  const MyWidget({Key? key, required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) => const Text('Title');
}
```

### 避免不必要的重建

```dart
// ❌ 错误：每次都重建
Obx(() => Column(
  children: [
    Text(controller.name.value),
    LargeWidget(),  // 不必要的重建
  ],
))

// ✅ 正确：只更新需要变化的部分
Column(
  children: [
    Obx(() => Text(controller.name.value)),
    LargeWidget(),  // 不重建
  ],
)
```

## 主题适配

```dart
// lib/widgets/themed_button.dart
class ThemedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ThemedButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
```
