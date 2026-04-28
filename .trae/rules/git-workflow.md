# Git 分支/提交规范

**核心约束（必须遵守）**
1. **分支模型**: 
   - `marster`: 生产环境主分支，保持随时可发布状态。
   - `develop`: 开发主干分支。
   - `feature/*`: 功能开发分支，从 `develop` 检出。
   - `bugfix/*`: 问题修复分支。
2. **提交规范 (Commit Message)**: 遵循 Angular 规范。
   - `feat`: 新功能
   - `fix`: 修复 Bug
   - `docs`: 文档修改
   - `style`: 代码格式调整（不影响逻辑）
   - `refactor`: 重构代码
   - `test`: 添加/修改测试用例
   - `chore`: 构建过程或辅助工具变动
   - 示例：`feat(im): 增加聊天消息撤回功能`
3. **合并要求**: 合并到 `main` 和 `develop` 必须通过 Pull Request (PR)，禁止直接 push。