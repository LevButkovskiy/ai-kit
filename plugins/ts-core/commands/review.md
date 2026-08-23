---
description: Run the applicable reviewers on uncommitted changes and report a combined verdict
---

Review the current uncommitted changes.

## Step 1: look at the diff
Run `git diff HEAD --stat` and `git diff HEAD`.
If there are no changes at all, say `No changes` and stop.

## Step 2: filter to reviewable files
Exclude from consideration: lockfiles, build artifacts, `*.tsbuildinfo`, `dist/`,
`build/`, `coverage/`, `.gitignore`, generated files, and anything git reports as binary.

If nothing remains, report `No reviewable changes`, list what was excluded in one line,
and stop. Do not report PASS — nothing was reviewed.

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
Give each the same instruction: review the uncommitted changes.
Do not review the code yourself. Do not pre-filter what you send them.
Do not summarise the diff for them — they read it themselves.

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

## Step 6: report
Line 1: `PASS` or `NEEDS_WORK — N blockers`.
Then blockers grouped by file, each as `path:line — problem — smallest fix [reviewer]`.
Then notes, one line each.
Then: `Reviewers run: <names>`.

Stop there. Do not fix anything. Do not commit. Do not ask whether to fix —
the user decides what to do with the report.