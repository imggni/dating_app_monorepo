# 代码风格统一

**核心约束（必须遵守）**
1. **Flutter/Dart**: 
   - 必须开启 `flutter_lints` 规范检查，代码提交前不能有 Warning 级别的警告。
   - 文件名/目录名严格使用 `snake_case`；类名使用 `PascalCase`；变量与方法名使用 `camelCase`。
   - 静态组件和不可变变量强制使用 `const` 和 `final`。
2. **Express/TypeScript**: 
   - 统一使用 `ESLint` + `Prettier` 格式化代码，保存时自动格式化。
   - 接口(Interface)命名不加 `I` 前缀，类型(Type)和类(Class)使用 `PascalCase`。
   - 必须使用严格模式 (`strict: true`)，严禁使用 `any` 类型。
3. **注释规范**: 
   - 复杂的业务逻辑必须添加清晰的单行/多行注释。
   - 导出的公共类和方法必须添加文档注释 (`///` 或 `/** ... */`)。