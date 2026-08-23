#!/bin/bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
CFG=.claude/gates.json
[ -f "$CFG" ] || exit 0

if ! command -v jq >/dev/null 2>&1; then
  echo "Commit gates are configured but jq is not installed." >&2
  exit 2
fi

LOG=.claude/metrics.jsonl
TS=$(date -Iseconds)
BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
log() { echo "{\"ts\":\"$TS\",\"branch\":\"$BR\",\"gate\":\"$1\",\"result\":\"$2\"}" >> "$LOG"; }

COUNT=$(jq '.commands | length' "$CFG")
for i in $(seq 0 $((COUNT - 1))); do
  NAME=$(jq -r ".commands[$i].name" "$CFG")
  CMD=$(jq -r ".commands[$i].cmd" "$CFG")
  if ! eval "$CMD" > /tmp/gate.out 2>&1; then
    log "$NAME" fail
    echo "Gate '$NAME' failed. Fix the errors below, then commit again:" >&2
    tail -25 /tmp/gate.out >&2
    exit 2
  fi
done

log all pass
exit 0