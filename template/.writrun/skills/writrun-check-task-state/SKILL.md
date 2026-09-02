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
   With no argument it defaults to `main...HEAD`. One rule — the
   `tracked` route's — is about which branch the change is on: it reads
   `HEAD_REF` when set (CI passes the head branch that way) and the
   checkout's own branch otherwise. On a detached HEAD with no
   `HEAD_REF` it says on stdout that it skipped, rather than passing
   quietly. Below Stage 2 that rule stands down without a word: the
   gate it holds the route to is a pull request's squash-merge, and a
   branchless project has none to hold it to.
2. Read the exit code:
   - **0 / "OK"** — no forbidden transition. Proceed.
   - **1** — a rule was violated; every violation prints with the fix.
   - **3** — usage error or `git diff` failed. Fix the invocation.

## What it rejects

| Output | Means |
|---|---|
| `FORBIDDEN: … draft -> approved` | The change approves its own spec. Approval is a human gate — leave the spec in `draft`. |
| `FORBIDDEN: … draft -> implemented` | Approval was skipped entirely. A spec is authorized to be implemented only once approved. |
| `FORBIDDEN: … moves X -> Y on a branch` | The five working states have one writer — the machinery, on the authority branch. Leave the status line; the forge writes it (Stage 2+). |
| `FORBIDDEN: … edits taken_by` | Same single writer. Who has a task is the forge's record, never a branch's claim (Stage 2+). |
| `FORBIDDEN: … -> blocked` / `blocked -> …` | `blocked` pairs with `backlog` and `ready` only — an in-flight task's blocker is visible on its pull request. |
| `FORBIDDEN: … dropped -> …` | `dropped` is terminal. New work is a new task. |
| `FORBIDDEN: … reaches 'tracked' on '…'` | The one route that puts work in the queue rode a change about something else. Route the report on its own `report/` branch; `fixed` and `declined` still ride anything. |
| `FORBIDDEN: … is born of a report on '…'` | Same rule, seen on the task: a task with `origin: report` travels with the report that justified it, on the `report/` branch whose merge is the assent. |
| `INCONSISTENT: … writes its completed date but … is 'X'` | The finishing declaration was written while a spec is not `implemented`. Fill that spec's Outcome in the same change. |
| `INCONSISTENT: … implements … last spec but leaves its completed date null` | The date is what the merge turns into `done` — write it in the same change. |
| `BROKEN: … resolves to no file` | A `spec_ref` entry points at a spec that does not exist. |

## Never

- Never resolve a `FORBIDDEN: draft -> approved` result by asking a human to
  approve the spec verbally and then writing the field anyway. The gate is
  satisfied by a recorded approval of the change, not by permission relayed
  through the agent that wanted it.
- Never resolve an `INCONSISTENT` result by blanking the `completed`
  date and shipping anyway — finish the spec's Outcome instead.
- Never resolve a `FORBIDDEN` status move by hand-editing `main`
  afterwards. The machinery writes that line from forge events; if it
  reads wrong, the event is what is missing.
- Never resolve a `FORBIDDEN: … reaches 'tracked'` result by moving the
  report to `fixed` instead. The two are different judgements: `fixed`
  says the change in hand ended it, and claiming that of a finding that
  still needs work loses the finding.
- Never resolve either `tracked` verdict by **renaming the head branch**
  to `report/…`. The check reads the branch name, so a rename does clear
  it — and clears nothing else: the prefix is how a reporting change is
  recognised, not what makes one, and a branch still carrying the
  implementation is the ridden merge the rule exists to stop. Move the
  report, the task and the spec to a change of their own. The rename also
  costs the ride it was taken for: `apply_pr_event.sh` recognises
  `task/NNNN-…`, so a task/ branch renamed away stops being recorded
  `in-progress` and `in-review` at all.
- Never skip the check because the change touched no code. A change that
  only edits front-matter is exactly what this check is for.
