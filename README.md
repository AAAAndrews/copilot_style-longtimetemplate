# IDE Agent Harness for Copilot and Cursor

This repository provides a practical long-running agent workflow for IDE-based agents.

The design borrows core ideas from long-horizon agent harnesses:
- explicit environment bootstrap
- strict one-task-per-session execution
- machine-readable task backlog
- progress handoff notes between sessions
- frequent commits for rollback and traceability

It is adapted for GitHub Copilot Chat and Cursor Agent mode (not Claude Code CLI).

## Goals

- Keep each agent session small, testable, and recoverable.
- Avoid unfinished partial changes across context windows.
- Make project state easy to rehydrate in a fresh chat.

## Repository Structure

- `.github/copilot-instructions.md`: Copilot-specific operating instructions.
- `.cursor/rules/agent-workflow.mdc`: Cursor rule file with the same workflow contract.
- `AGENTS.md`: universal workflow and checklists for any IDE agent.
- `docs/architecture.md`: project architecture and constraints template.
- `docs/task-list.json`: machine-readable task backlog and completion state.
- `docs/progress.md`: chronological handoff log between sessions.
- `scripts/init-session.sh`: get bearings, run baseline checks.
- `scripts/select-next-task.sh`: suggest next pending task by priority.

## Recommended Session Loop

1. Run `./scripts/init-session.sh`.
2. Read `docs/progress.md` and recent git commits.
3. Select one task from `docs/task-list.json` with `passes: false`.
4. Implement only that task.
5. Validate with lint, tests, and build.
6. Update `docs/task-list.json` for that task only.
7. Append a short handoff entry to `docs/progress.md`.
8. Commit with a focused message.

## Usage with Copilot Chat

- Open this folder in VS Code.
- In Copilot Chat, ask the agent to follow `AGENTS.md` and complete the next pending task.
- Keep approval mode enabled unless you explicitly want fully automated changes.

## Usage with Cursor Agent

- Open this folder in Cursor.
- Ensure `.cursor/rules/agent-workflow.mdc` is active.
- Ask the agent to run the same loop: one task per run, full validation, progress update, commit.

## Notes

- This starter is intentionally generic. Replace architecture and tasks with your real project spec before coding.
- Prefer JSON for backlog state to reduce accidental structural edits.
