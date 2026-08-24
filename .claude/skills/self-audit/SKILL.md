---
name: self-audit
description: Audits this kit's Claude Code configuration against current official docs. Use when the user asks to audit the kit, check whether config is up to date, or after a Claude Code update.
disable-model-invocation: true
---

# Self audit

Audit this repository's Claude Code configuration against the **current** official
documentation. Never rely on training data for schema details — schemas change often.

## Step 0: environment

Run `claude --version` and record it.
Ask the user to run `/doctor` and share the output.
If it reports installation or config-integrity problems, stop and report those —
schema auditing is pointless on a broken install.

## Step 1: fetch current docs

Fetch `https://code.claude.com/docs/llms.txt` to get the documentation index.
From it, fetch at least these pages:

- hooks reference — events, handler fields, matcher rules, exit codes
- sub-agents — frontmatter fields
- skills — frontmatter fields
- plugins reference and plugin marketplaces — manifest schemas

## Step 2: inventory local config

Read every one of these that exists in this repo:

- `.claude-plugin/marketplace.json`
- `plugins/*/.claude-plugin/plugin.json`
- `plugins/*/hooks/hooks.json`
- `plugins/*/agents/*.md` — frontmatter only
- `plugins/*/skills/*/SKILL.md` — frontmatter only
- `.claude/skills/*/SKILL.md` — frontmatter only

## Step 3: compare schemas

For each field used locally, check against the fetched docs:

- Field no longer documented → likely removed or renamed
- Field documented with a different type or different allowed values
- Required field missing
- Version requirement stated in the docs that the version from Step 0 does not meet

## Step 4: verify behavioural assumptions

Some constraints are not visible in a schema. Check the docs for:

- Which events support blocking, and what exit code 2 does per event
- Which events support `matcher`, and which ignore it silently
- Which events honour the `if` field
- Whether a handler type is supported on the events where it is used

Flag any hook that relies on a capability the docs say that event does not have.

## Step 5: check the scripts

For each script referenced by `hooks.json`:

- The referenced path exists
- Its exit codes match what the docs say that event honours
- Any placeholder it uses (`${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PROJECT_DIR}`) is
  still documented with the same meaning

## Constraints

- Do not edit any file. Report only.
- Cite the doc page for every finding.
- Report only divergence. Say nothing about checks that pass.
- If a doc page cannot be fetched, say so explicitly rather than falling back to memory.
- Report the recorded version even when nothing else is wrong.

## Output

Line 1: `Claude Code <version> — OK` or `Claude Code <version> — N issues found`.

Then, per issue:
`file:field — what the docs now say — suggested change`
Mark an issue `[version]` when the docs state a minimum version above the one from Step 0.

Then, separately:
`New since last audit:` — capabilities in the docs this config could use.
Include an item only if it fixes a real gap in this config or replaces something that
does not currently work. Do not list alternatives to mechanisms that already work,
and do not list capabilities you judge irrelevant to this config.
