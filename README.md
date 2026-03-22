# Copilot/Cursor IDE Agent 长流程工作模板

这个仓库提供了一套可直接落地的、面向 IDE Agent 的长流程开发工作流。

整体设计借鉴了 long-running agent harness 的关键思想：
- 显式环境初始化
- 严格单会话单任务
- 机器可读的任务清单
- 会话之间可交接的进度记录
- 高频小步提交，便于回滚与追踪

本模板专为 GitHub Copilot Chat 与 Cursor Agent 模式适配，而不是 Claude Code CLI。

## 目标

- 让每次 Agent 会话都短小、可验证、可恢复。
- 避免跨上下文窗口留下半成品改动。
- 让新会话可以快速恢复项目上下文。

## 仓库结构

- `.github/copilot-instructions.md`: Copilot 专用执行说明。
- `.cursor/rules/agent-workflow.mdc`: Cursor 规则文件，与 AGENTS 契约保持一致。
- `AGENTS.md`: 面向任意 IDE Agent 的统一工作契约与检查清单。
- `docs/architecture.md`: 项目架构与约束模板。
- `docs/task-list.json`: 机器可读任务清单与完成状态。
- `docs/progress.md`: 会话交接日志（按时间追加）。
- `scripts/init-session.sh`: 会话启动检查脚本。
- `scripts/select-next-task.sh`: 按优先级建议下一个任务。

## 建议会话循环

1. 运行 `./scripts/init-session.sh`。
2. 阅读 `docs/progress.md` 与近期 git 提交。
3. 在 `docs/task-list.json` 中选择一个 `passes: false` 的任务。
4. 只实现该任务。
5. 运行 lint、tests、build 等验证。
6. 仅更新该任务对象。
7. 在 `docs/progress.md` 追加交接记录。
8. 用聚焦提交信息完成提交。

## Copilot Chat 使用方式

- 在 VS Code 打开本目录。
- 在 Copilot Chat 中要求 Agent 严格遵循 `AGENTS.md` 完成下一个任务。
- 非必要不要关闭审批模式，避免误操作。

## Cursor Agent 使用方式

- 在 Cursor 打开本目录。
- 确认 `.cursor/rules/agent-workflow.mdc` 已生效。
- 指示 Agent 按同一循环执行：单任务、全验证、写进度、再提交。

## 说明

- 该模板默认是通用骨架，正式开发前请先替换成你的真实架构与任务拆解。
- 任务状态建议放在 JSON 中，能减少结构被误改的概率。
