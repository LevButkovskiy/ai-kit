#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[[ "$FILE" =~ \.(ts|tsx|js|jsx)$ ]] || exit 0
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
[ -d node_modules/prettier ] || exit 0

OUT=$(npx --no-install prettier --write "$FILE" 2>&1)
if [ $? -ne 0 ]; then
  echo "prettier failed on $FILE:" >&2
  echo "$OUT" >&2
  exit 2
fi
exit 0