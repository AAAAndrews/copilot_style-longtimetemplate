#!/usr/bin/env bash
set -euo pipefail

file="docs/task-list.json"

if [[ ! -f "$file" ]]; then
  echo "未找到任务文件: $file"
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  jq -r '
    .tasks
    | map(select(.passes == false))
    | sort_by((.priority == "high") | not, (.priority == "medium") | not, .id)
    | .[0]
    | if . == null then "NO_PENDING_TASK" else "\(.id)\t\(.priority)\t\(.title)" end
  ' "$file"
  exit 0
fi

# 无 jq 的兜底解析：输出第一个 passes=false 的任务。
awk '
  BEGIN { id=""; title=""; passes="" }
  /"id"[[:space:]]*:/ && id=="" {
    gsub(/[",]/, "", $0); split($0, a, ":"); gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[2]); id=a[2]
  }
  /"title"[[:space:]]*:/ && title=="" {
    line=$0; sub(/^[^:]*:[[:space:]]*"/, "", line); sub(/",?[[:space:]]*$/, "", line); title=line
  }
  /"passes"[[:space:]]*:/ {
    if ($0 ~ /false/) {
      print id "\tunknown\t" title;
      exit 0
    }
    id=""; title=""
  }
  END {
    if (NR > 0) {}
  }
' "$file"
