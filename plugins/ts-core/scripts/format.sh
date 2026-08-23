#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[[ "$FILE" =~ \.(ts|tsx|js|jsx)$ ]] || exit 0
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
[ -d node_modules/prettier ] && npx --no-install prettier --write "$FILE" >/dev/null 2>&1
exit 0