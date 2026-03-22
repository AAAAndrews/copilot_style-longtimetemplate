# AGENTS Workflow Contract

This file defines the required behavior for any coding agent working in this repository.

## Non-Negotiable Rules

1. Work on exactly one task per session.
2. Never mark a task complete without running validation.
3. Leave the repo in a merge-ready state at session end.
4. Always write a progress handoff entry before finishing.
5. Commit focused changes with a descriptive message.

## Session Start Checklist

1. Run `pwd` and confirm workspace root.
2. Run `./scripts/init-session.sh`.
3. Read `docs/progress.md`.
4. Read `docs/task-list.json`.
5. Review recent commits: `git log --oneline -20`.
6. Pick highest-priority task with `passes: false`.

## Execution Policy

- Scope: implement only the selected task.
- If blocked, write blocker details in `docs/progress.md` and stop.
- Do not refactor unrelated modules.
- Keep diffs small and reversible.

## Validation Policy

Run project validation commands relevant to the task, typically:
- lint
- unit tests
- integration or e2e checks if impacted
- build

If any command fails:
- either fix within the same task scope
- or record blocker and do not mark task as complete

## Task Backlog Editing Rules

For `docs/task-list.json`:
- modify only the selected task object
- allowed fields to update: `passes`, `notes`, `updated_at`
- never delete tasks
- never reorder tasks unless explicitly requested

## Session End Checklist

1. Confirm working tree is intentional.
2. Update selected task state in `docs/task-list.json`.
3. Append a handoff entry in `docs/progress.md`:
   - date-time
   - task id and title
   - what changed
   - validation results
   - known risks
   - next suggested task
4. Commit all intended changes.

## Commit Message Format

Use one of:
- `feat(task-<id>): <short summary>`
- `fix(task-<id>): <short summary>`
- `chore(task-<id>): <short summary>`
- `docs(task-<id>): <short summary>`

## Suggested Prompt Snippets for IDE Agents

- "Follow AGENTS.md. Run init checklist, pick next pending task, implement only that task, validate, update docs/task-list.json and docs/progress.md, then commit."
- "Follow AGENTS.md. Do not start new tasks if current task fails validation."
