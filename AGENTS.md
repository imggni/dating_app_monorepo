## Cursor AI Agent 配置（本仓库）

本仓库已将 `.github/` 下的开发规范迁移为 Cursor 可用规则：`.cursor/rules/*.mdc`。

### Agents（可选）

- `.cursor/agents/feat.md`：功能开发（全栈）
- `.cursor/agents/fix.md`：缺陷修复（最小侵入）
- `.cursor/agents/review.md`：代码审查（只输出意见，不写文件）
- `.cursor/agents/context7-docs.md`：官方文档对照（避免过时/幻觉 API）

### 规则入口

- `core.mdc`：全局规范（总是生效）
- Flutter（按需生效）：
  - `flutter-architecture.mdc`
  - `flutter-networking.mdc`
  - `flutter-storage-state.mdc`
  - `flutter-widgets.mdc`
- Backend（按需生效）：
  - `backend-architecture.mdc`
  - `backend-api-contracts.mdc`
  - `backend-validation-security.mdc`
  - `backend-prisma.mdc`
  - `backend-error-handling.mdc`
  - `backend-testing.mdc`

### Source of truth

如规则内容与实现有冲突，以 `.github/instructions/**` 与 `.github/copilot-instructions.md` 为准。

