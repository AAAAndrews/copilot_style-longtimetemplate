#!/usr/bin/env bash
set -euo pipefail

echo "[init] workspace: $(pwd)"

echo "[init] git status"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --short --branch
  echo "[init] recent commits"
  git --no-pager log --oneline -10 || true
else
  echo "[init] not a git repository yet"
fi

echo "[init] checking required docs"
for f in AGENTS.md docs/task-list.json docs/progress.md; do
  if [[ -f "$f" ]]; then
    echo "  ok: $f"
  else
    echo "  missing: $f"
  fi
done

echo "[init] next pending task"
if [[ -f docs/task-list.json ]]; then
  if command -v jq >/dev/null 2>&1; then
    jq -r '.tasks[] | select(.passes == false) | "- \(.id) [\(.priority)] \(.title)"' docs/task-list.json | head -n 3 || true
  else
    echo "  jq not found; run ./scripts/select-next-task.sh for fallback parsing"
  fi
fi

echo "[init] done"
