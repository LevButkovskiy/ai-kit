---
description: Run the applicable reviewers on uncommitted changes and report a combined verdict
---

Review the current uncommitted changes.

## Step 1: look at the diff
Run `git diff HEAD --stat` and `git diff HEAD`.
If there are no changes, say so and stop.

## Step 2: decide which reviewers apply
- `reviewer` — always.
- `security-reviewer` — only if the diff touches any of: HTTP routes or controllers,
  authentication or authorization, database queries, file handling, external API calls,
  environment or config values, logging of request data.
- `architecture-reviewer` — only if the diff adds a new function, class, service,
  hook or component, or touches more than one package.

State which ones you selected and why, in one line each.

## Step 3: run them
Invoke all selected reviewers **in parallel**, in a single message.
Give each the same instruction: review the uncommitted changes.
Do not review the code yourself. Do not pre-filter what you send them.

## Step 4: combine
Wait for all of them. Then:
- Verdict is NEEDS_WORK if any reviewer returned NEEDS_WORK, otherwise PASS.
- Merge blockers. When two reviewers report the same line, keep one entry and
  note which reviewers raised it — agreement is a signal, not noise.
- Keep notes separate from blockers and do not merge them.
- If a reviewer's finding contradicts another's, present both and say they disagree.
  Do not pick a winner.

## Step 5: report
Line 1: `PASS` or `NEEDS_WORK — N blockers`.
Then blockers grouped by file, each as `path:line — problem — smallest fix [which reviewer]`.
Then notes, one line each.
Then: `Reviewers run: <names>`.

Stop there. Do not fix anything. Do not commit. Do not ask whether to fix —
the user decides what to do with the report.