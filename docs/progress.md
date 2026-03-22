# 进度日志

本文件用于 IDE Agent 的会话交接记忆。

## 记录模板

- 日期：YYYY-MM-DD HH:MM
- 任务：T000 - 标题
- 摘要：
- 变更文件：
- 验证结果：
- 风险/阻塞：
- 建议下一任务：

---

- 日期：2026-03-22 00:00
- 任务：BOOTSTRAP - 工作流初始化
- 摘要：新增 Copilot/Cursor IDE Agent 工作流文件，包含任务/进度模板与辅助脚本。
- 变更文件：README.md, AGENTS.md, .github/copilot-instructions.md, .cursor/rules/agent-workflow.mdc, docs/architecture.md, docs/task-list.json, docs/progress.md, scripts/init-session.sh, scripts/select-next-task.sh
- 验证结果：Shell 脚本语法检查通过。
- 风险/阻塞：项目技术栈尚未最终确定。
- 建议下一任务：T001
