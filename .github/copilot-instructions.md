# Copilot Instructions: Long-Running Task Harness

You are working in an IDE-first autonomous coding workflow.

## Primary Objective

Complete exactly one pending task per session while preserving repository stability and traceability.

## Required Flow

1. Read `AGENTS.md` and follow it strictly.
2. Run `./scripts/init-session.sh`.
3. Inspect `docs/task-list.json`; pick one highest-priority `passes: false` task.
4. Implement only that task.
5. Run validation commands relevant to changes.
6. Update only that task object in `docs/task-list.json`.
7. Append a handoff entry in `docs/progress.md`.
8. Commit with `type(task-<id>): summary`.

## Guardrails

- No multi-task implementations in one session.
- No destructive git commands.
- No silent task completion without validation.
- No broad formatting or unrelated refactors.

## Failure Handling

If blocked:
- Stop coding.
- Document blocker, evidence, and reproduction steps in `docs/progress.md`.
- Keep task `passes: false`.

## Definition of Done for a Task

A task can be marked as done only when:
- implementation is complete
- relevant checks pass
- no known critical regressions
- backlog and progress files are updated
