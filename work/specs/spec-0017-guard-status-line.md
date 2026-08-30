---
id: spec-0017
task_ref: task-0019
status: draft
created: 2026-08-30T02:58:05Z
---

# spec-0017 — Guard the status line: branch-side flips rejected, finishing flow updated

- **Goal:** the local checks refuse what the rule forbids — a branch
  moving a task between the machinery's statuses — and the skills and
  `AGENTS.md` describe the flow the worker actually performs now: take
  without flipping, finish by writing the `completed` date, never the
  status.

## Scope

Everything local that still teaches or tolerates the old contract:
`writrun-check-task-state`, the skills' SKILL.md files, this repo's
`AGENTS.md`. The forge-side writing is spec-0016.

## Steps

1. `writrun-check-task-state`: reject a diff that moves a task between
   the machinery's five working states (`backlog`, `ready`,
   `in-progress`, `in-review`, `done`); accept a hand-written move
   between `blocked` and `backlog` or `ready` only (with
   `blocked_reason`), and to `dropped` from any non-terminal state;
   require, at
   finishing, the spec flipped to `implemented`, the Outcome filled, and
   the task's `completed` date written — in place of the old "task set
   to completed" rule. Reject a branch-side edit of `taken_by` too.
2. `writrun-select-next-task` SKILL.md: taking no longer writes any
   status; branch + draft PR is the whole act. Selection filters on
   `ready`; resume logic reads `in-progress`/`in-review` with no open
   pull request as abandoned work to resume.
3. `writrun-create-task-and-spec` SKILL.md, "When completing a task":
   drop "set the task's status to completed"; the worker writes the
   `completed` date, the merge writes `done`.
4. `AGENTS.md`: "Taking a task ends with its draft pull request open"
   loses the "set the task `in-progress`" step; "Picking work" reads
   `ready` where it read `pending` + approved specs; "Completing a
   task" step 4 becomes Outcome + spec `implemented` + `completed`
   date.
5. Tests for the new check-task-state rules.

## Acceptance criteria (EARS)

- When a branch's diff moves a task between the machinery's five
  working states, `writrun-check-task-state` shall exit non-zero and
  name the line.
- When a branch's diff edits a task's `taken_by`, the check shall exit
  non-zero.
- When a branch's diff moves a task between `blocked` and `backlog` or
  `ready`, with a `blocked_reason`, or to `dropped` from any
  non-terminal state, the check shall accept it; a hand move touching
  `blocked` from any in-flight state it shall reject, per the status
  table.
- When a finishing diff carries a spec flipped to `implemented` without
  the task's `completed` date, the check shall exit non-zero.
- When the selection algorithm meets a task `in-progress` with no open
  pull request working it, it shall surface the task as resumable
  rather than skip it silently.

## Edge cases

- Stage 1 (no forge): no forge events exist, so the machinery cannot
  write the line — at that stage statuses stay hand-moved, and the
  check's rejection applies from Stage 2 up, gated on the `stage`
  setting like the workflows are.
- A task abandoned with its PR: the forge already landed it back on
  `ready` or `backlog` (spec-0016); nothing local to clean.
- Historic diffs: the check judges the diff in front of it, never
  rewrites history — old commits that flipped statuses by hand stay
  valid history.

## Tests required

Unit tests for each new check-task-state rule (rejected flip, accepted
`blocked` flip, missing `completed` date, Stage-1 gating), in the
existing test tiers.

## Definition of Done

- [ ] All acceptance criteria hold, each with a test.
- [ ] No SKILL.md or `AGENTS.md` sentence still instructs a worker to
      write `in-progress` or `completed` status.
- [ ] `writrun check` and the full test suite pass.

## Proposed product changes

- none — the rule was authored first
  (`product/tasks-and-specs/statuses.md`,
  `product/pull-requests/taking.md`,
  `product/pull-requests/finishing.md`); this change brings the
  checks and skills up to a doc that already states it.

## Proposed technical changes

- none — the schema's who-writes note and the selection algorithm's
  resume step were authored first (`technical/README.md#task-schema`,
  `technical/README.md#task-selection-algorithm`); this change brings
  the checks and skills up to a doc that already states them.

## Outcome

_(fill after execution)_
