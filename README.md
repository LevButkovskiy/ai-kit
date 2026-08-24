[English](README.md) · [Русский](README.ru.md)

# ai-kit

Portable Claude Code configuration: commit gates, code reviewers, formatting.
One git repo, plugged into any project — no copying files between repositories.

## Requirements

- Claude Code
- `jq` — required by the hook scripts

## Install

In any project:

```
/plugin marketplace add LevButkovskiy/ai-kit
/plugin install ts-core@bulevo
```

Choose **User** scope — the kit applies to all your projects.
The marketplace only needs to be added once per machine.

Verify with `/hooks` — you should see hooks sourced from `Plugin Hooks`.

## What you get

**Automatic**
- Formats every edited `.ts/.tsx/.js/.jsx` file with prettier (skipped if prettier is not installed)
- Blocks `git commit` when the project's gates fail
- Blocks `git commit --no-verify`
- Blocks the agent from editing `.claude/gates.json`

**On demand**
- `/ts-core:review` — runs the applicable reviewers in parallel, reports one combined verdict
- `@reviewer` — correctness
- `@security-reviewer` — authorization, injection, secrets, data exposure
- `@architecture-reviewer` — duplication, boundaries, misplaced code

## Enabling gates in a project

Gates are off until the project defines them. Create `.claude/gates.json`:

```json
{
  "commands": [
    { "name": "types", "cmd": "pnpm typecheck" },
    { "name": "tests", "cmd": "pnpm test" }
  ]
}
```

- `name` — short and stable; it lands in `metrics.jsonl` and becomes your statistics
- `cmd` — any shell command; passes on exit code 0
- Order matters: the run stops at the first failure, so put fast checks first

Commit `gates.json`. Add `.claude/metrics.jsonl` to `.gitignore`.

Without this file the kit still formats and reviews — it just does not block commits.

## Metrics

Every gate run appends a line to `.claude/metrics.jsonl`:

```bash
# pass/fail ratio
jq -r .result .claude/metrics.jsonl | sort | uniq -c

# which gate fails most
jq -r 'select(.result=="fail") | .gate' .claude/metrics.jsonl | sort | uniq -c
```

## Updating the kit

```
/plugin marketplace update
/reload-plugins
```

Run this in any project after pushing changes to this repo.

## Auditing the kit

Open this repo in Claude Code and run `/self-audit`.
It fetches the current Claude Code docs and reports where this config diverges
from the documented schemas. Run it after a Claude Code update.

## Troubleshooting

**Hooks not firing** — `/hooks` to confirm they are registered, `claude --debug` to see
whether the script ran and what it returned. Most common cause on Windows: `jq` not on
the PATH of the Claude Code process.

**Gate always fails** — run the command from `gates.json` manually in the project root.
A gate that fails for reasons unrelated to the code is worse than no gate.

**Command not found after update** — `/plugin marketplace update` then `/reload-plugins`.

## Layout

```
.claude-plugin/marketplace.json   catalogue
plugins/ts-core/                  the plugin
  .claude-plugin/plugin.json      manifest
  hooks/hooks.json                hook wiring
  scripts/                        gate.sh, format.sh
  agents/                         reviewers
  commands/                       /ts-core:review
.claude/skills/self-audit/        audits this repo against current docs
```

## Conventions

Everything a model reads is in English: agent bodies, skill files, manifest
descriptions, hook messages. Russian only in this README and in code comments.