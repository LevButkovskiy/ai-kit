---
description: Turn a task description into a written contract, asking only what cannot be inferred from the code
---

Turn the user's task description into a contract. Write no application code in this command.

## Step 0: decide whether a contract is needed
If you could describe the resulting diff in one sentence, say so and stop.
Over-planning a trivial change wastes more than it saves. A contract is worth writing
when the approach is uncertain, the change spans several files, or the code is
unfamiliar to you.

## Step 1: read the codebase first
Explore what the task touches: existing modules, patterns, naming, test setup,
the scripts in package.json, and `.claude/gates.json` if present.

Anything you can answer by reading code, answer by reading code. Never ask about it.

## Step 2: find the real gaps
List what you cannot determine from the code, then keep only those where a different
answer would produce different code. Typical real gaps:

- who is allowed to do this, and whether it differs per role
- what happens on conflict, duplicate, or concurrent edit
- what the empty, error and loading states should be
- whether existing data needs migrating
- what must be logged or audited
- whether this is visible to other users

Discard any gap where a wrong guess is cheap to fix later.

## Step 3: ask
Ask the remaining questions in one message, numbered, at most five.
For each, state the default you will use if the user does not answer.
If there are no real gaps, say so and go to Step 4.

## Step 4: write the contract
Write to `.claude/tasks/<slug>.md`, where slug is derived from the task name.
Create the directory if it does not exist. Report the path you used.

    # Task: <name>

    ## Done when
    - [ ] <each gate command from .claude/gates.json, exit code 0>
    - [ ] <one checkable behaviour per line, phrased so it can be verified by running something>

    ## Decisions
    - <each answer from Step 3, one line>

    ## Boundaries
    Touch only: <paths>
    Do not touch: <paths>

Every line under "Done when" must be checkable by running a command or performing a
concrete action. "Works correctly" and "code is clean" are not acceptable.

## Step 5: confirm
Show the contract and ask the user to confirm or correct it.
Do not start implementing until they do.