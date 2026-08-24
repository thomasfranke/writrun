---
name: writrun-check-task-state
description: Use this skill before opening a pull request in a project that follows the WritRun methodology, or when verifying that a change's task and spec status transitions are legal — when the user asks to check task state, validate a lifecycle transition, or confirm a PR is not approving its own spec. Rejects the transitions the human gates exist to prevent.
---

# Check task state

Verifies the task and spec status transitions a diff makes against the
lifecycle. Complements [`writrun-check-spec-deltas`](../writrun-check-spec-deltas/SKILL.md),
which checks *which files* a change touched; this one checks *what states*
it moved them through.

## Why this is a script, not a prompt

The gate it enforces is `draft → approved` — the one transition an agent is
never allowed to make, including on a spec it drafted itself. Asking the
same agent whether it respected that gate is asking the wrong party. Path
and state comparison in a diff is objective, so it is checked by
[`check_state.sh`](check_state.sh).

## Steps

1. Run it against the range that represents the change:
   ```bash
   bash .writrun/skills/writrun-check-task-state/check_state.sh main...HEAD
   ```
   With no argument it defaults to `main...HEAD`.
2. Read the exit code:
   - **0 / "OK"** — no forbidden transition. Proceed.
   - **1** — a rule was violated; every violation prints with the fix.
   - **3** — usage error or `git diff` failed. Fix the invocation.

## What it rejects

| Output | Means |
|---|---|
| `FORBIDDEN: … draft -> approved` | The change approves its own spec. Approval is a human gate — leave the spec in `draft`. |
| `FORBIDDEN: … draft -> implemented` | Approval was skipped entirely. A spec is authorized to be implemented only once approved. |
| `INCONSISTENT: … completed but … is 'X'` | A task is being completed while one of its specs is not `implemented`. Fill that spec's Outcome in the same change. |
| `BROKEN: … resolves to no file` | A `spec_ref` entry points at a spec that does not exist. |

## Never

- Never resolve a `FORBIDDEN: draft -> approved` result by asking a human to
  approve the spec verbally and then writing the field anyway. The gate is
  satisfied by a recorded approval of the change, not by permission relayed
  through the agent that wanted it.
- Never resolve an `INCONSISTENT` result by reverting the task to
  `in-progress` and shipping anyway — finish the spec's Outcome instead.
- Never skip the check because the change touched no code. A change that
  only edits front-matter is exactly what this check is for.
