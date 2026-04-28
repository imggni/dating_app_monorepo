# Flutter + Dart 规则（精简，含Material3+GetX专项）

**核心约束（必须遵守）**
1. **框架版本**: 必须使用 `Flutter 3.22+` 和 `Dart 3.0+` 新特性。
2. **状态/路由**: 强制统一使用 `GetX`。严禁混用 `Provider` / `Bloc` / 原生 `Navigator`。
3. **网络与存储**: 强制 `Dio` + `retrofit`，禁原生 `http`；结构化数据用 `Hive`，敏感信息用 `flutter_secure_storage`，严禁 `shared_preferences`。
4. **架构设计**: 强制遵循 GetX 解耦模式，拆分为 `xxx_view.dart` (无状态)、`xxx_controller.dart`、`xxx_binding.dart`。
5. **命名规范**: 文件名/目录名用 `snake_case`，类名/枚举用 `PascalCase`，变量/方法用 `camelCase`。
6. **性能要求**: 静态组件必加 `const`，长列表必用 `ListView.builder` 或 `SliverList` 懒加载。
7. **组件库**: 必须使用 `Material 3` 设计规范与阿里 `iconfont` 库。

> 详情及第三方库选型（如 IM、录音、画板），请调用 `flutter-dev-specs` 技能获取。