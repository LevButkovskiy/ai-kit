---
description: Run the applicable reviewers on uncommitted changes and report a combined verdict
---

Review the current uncommitted changes.

## Step 1: look at the diff

Run:

- `git status --short` — to see untracked and staged files
- `git diff HEAD --stat` and `git diff HEAD` — tracked changes
- for each untracked file listed by `git status`, read it directly

Untracked files are part of the change. A new service that has not been `git add`ed
is still a new service, and is often the most important thing to review.
If there are no tracked changes and no untracked files, say `No changes` and stop.

## Step 2: filter to reviewable files

Exclude only files matching this list. It is exhaustive — do not add categories to it,
and do not exclude a file because you judge it unimportant, non-code, config-only,
trivial, or "not application logic". If it is not on this list, it is reviewable.

- lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`)
- `*.tsbuildinfo`
- `dist/`, `build/`, `coverage/`, `node_modules/`
- files git reports as binary

Everything else — including config files, CI files, dotfiles, and one-line changes —
goes to the reviewers.

If nothing remains, report `No reviewable changes`, list what was excluded in one line,
and stop.

## Step 3: select reviewers

Based on the remaining files only:

- `reviewer` — always. This is not a judgement call. Run it even for a one-line change,
  even if the change looks trivial to you.
- `security-reviewer` — only if the remaining diff touches any of: HTTP routes or
  controllers, authentication or authorization, database queries, file handling,
  external API calls, environment or config values, logging of request data.
- `architecture-reviewer` — only if the remaining diff adds a new function, class,
  service, hook or component, or touches more than one package.

State which ones you selected and why, one line each.

## Step 4: run them

Invoke all selected reviewers **in parallel**, in a single message.
Instruct each: review the uncommitted changes, including untracked files.
List the untracked file paths explicitly in the instruction so they read them.
If a contract exists under `.claude/tasks/`, name its path in the instruction too.

## Step 5: combine

Wait for all of them. Then:

- Verdict is NEEDS_WORK if any reviewer returned NEEDS_WORK, otherwise PASS.
- Merge blockers. When two reviewers report the same line, keep one entry and note
  which reviewers raised it — agreement is a signal, not noise.
- Keep notes separate from blockers. Do not merge notes.
- If two reviewers contradict each other, present both and say they disagree.
  Do not pick a winner.
- Do not drop a finding because you disagree with it. Report it and, if you think
  it is wrong, add your objection as a note.
- Do not comment on individual reviewer results as they arrive. Wait for all of them, then report once.
- If a reviewer returned without a verdict line (PASS or NEEDS_WORK), ask it to finish
  its report before combining. Do not infer a verdict from its findings.

## Step 6: report

Line 1: `PASS` or `NEEDS_WORK — N blockers`.
Then blockers grouped by file, each as `path:line — problem — smallest fix [reviewer]`.
Then notes, one line each.
Then: `Reviewers run: <names>`.

Stop there. Do not fix anything. Do not commit. Do not ask whether to fix —
the user decides what to do with the report.
