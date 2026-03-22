#!/usr/bin/env bash
set -euo pipefail

echo "[init] 工作目录: $(pwd)"

echo "[init] git 状态"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --short --branch
  echo "[init] 最近提交"
  git --no-pager log --oneline -10 || true
else
  echo "[init] 当前目录还不是 git 仓库"
fi

echo "[init] 检查必需文档"
for f in AGENTS.md docs/task-list.json docs/progress.md; do
  if [[ -f "$f" ]]; then
    echo "  存在: $f"
  else
    echo "  缺失: $f"
  fi
done

echo "[init] 下一个待办任务"
if [[ -f docs/task-list.json ]]; then
  if command -v jq >/dev/null 2>&1; then
    jq -r '.tasks[] | select(.passes == false) | "- \(.id) [\(.priority)] \(.title)"' docs/task-list.json | head -n 3 || true
  else
    echo "  未找到 jq；可运行 ./scripts/select-next-task.sh 使用兜底解析"
  fi
fi

echo "[init] 完成"
