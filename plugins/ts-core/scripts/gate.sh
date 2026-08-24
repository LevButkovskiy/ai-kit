#!/bin/bash
# Runs project-defined gates before allowing a commit.
# Config: .claude/gates.json in the project. No config = no gates.
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
CFG=.claude/gates.json
[ -f "$CFG" ] || exit 0

if ! command -v jq >/dev/null 2>&1; then
  echo "Commit gates are configured but jq is not installed." >&2
  exit 2
fi

ROOT=$(pwd)

# Changed paths relative to ROOT — works for one repo or several side by side.
collect_changes() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -c core.quotePath=false status --porcelain | sed 's/^...//; s/^.* -> //'
    return
  fi
  find . -maxdepth 3 -name .git -not -path '*/node_modules/*' 2>/dev/null | while read -r g; do
    d=$(dirname "$g"); d=${d#./}
    (cd "$d" && git -c core.quotePath=false status --porcelain \
      | sed 's/^...//; s/^.* -> //' | sed "s|^|$d/|")
  done
}

CHANGED=$(collect_changes)
[ -n "$CHANGED" ] || exit 0

matches() {
  local n i pat p
  n=$(echo "$1" | jq 'length')
  [ "$n" -eq 0 ] && return 0
  for ((i = 0; i < n; i++)); do
    pat=$(echo "$1" | jq -r ".[$i]")
    pat=${pat%/}; pat=${pat%'**'}; pat=${pat%/}
    while IFS= read -r p; do
      case "$p" in "$pat"/* | "$pat") return 0 ;; esac
    done <<< "$CHANGED"
  done
  return 1
}

LOG=.claude/metrics.jsonl
TS=$(date -Iseconds)
BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")
log() { echo "{\"ts\":\"$TS\",\"branch\":\"$BR\",\"gate\":\"$1\",\"result\":\"$2\"}" >> "$LOG"; }

RAN=0
COUNT=$(jq '.commands | length' "$CFG")
for ((i = 0; i < COUNT; i++)); do
  NAME=$(jq -r ".commands[$i].name" "$CFG")
  CMD=$(jq -r ".commands[$i].cmd" "$CFG")
  DIR=$(jq -r ".commands[$i].cwd // \".\"" "$CFG")
  WHEN=$(jq -c ".commands[$i] | .when // (if .cwd then [.cwd] else [] end)" "$CFG")

  matches "$WHEN" || continue
  RAN=1

  if ! (cd "$ROOT/$DIR" && eval "$CMD") > /tmp/gate.out 2>&1; then
    log "$NAME" fail
    echo "Gate '$NAME' failed. Fix the errors below, then commit again:" >&2
    tail -25 /tmp/gate.out >&2
    exit 2
  fi
done

if [ "$RAN" -eq 1 ]; then log all pass; fi
exit 0