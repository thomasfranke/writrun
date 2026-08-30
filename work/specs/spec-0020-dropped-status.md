---
id: spec-0020
task_ref: task-0019
status: implemented
created: 2026-08-30T03:22:07Z
---

# spec-0020 — The dropped status: a terminal state for work that will not happen

- **Goal:** the queue has an honest terminal word for *this will not
  happen* — hand-written like `blocked`, for the same reason: no forge
  event knows a task died. A `dropped` task stops shadowing the
  backlog, and its mirror closes as not planned.

## Scope

The value end to end: schema, checks, selection, mirror. No workflow
writes it — it is one of the two human exceptions to the
machinery-owned status line (`product/tasks-and-specs/statuses.md`).

- Schema: `dropped` joins the status set, terminal — no transition
  leaves it.
- `writrun-check-task-state`: accepts a hand-written move to `dropped`
  from any non-terminal state; rejects any move out of it, by hand or
  by echo (the transition machine of spec-0016 holds no edge leaving
  it).
- Selection: `dropped` is excluded exactly as `done` is — nothing to
  add beyond the value in the filter's vocabulary.
- Mirror: a recording of `dropped` on the authority branch closes the
  task's mirror as **not planned**, no `status:` label left behind.

## Steps

1. Add the value to the schema docs and the checks' vocabulary.
2. Check-task-state rules: accept in, reject out.
3. Mirror machinery: close-as-not-planned on `dropped`, reusing the
   close path the `done` flow already has.
4. Tests for each rule.

## Acceptance criteria (EARS)

- When a branch's diff moves a non-terminal task to `dropped`, the
  checks shall accept it.
- When any diff or event would move a task out of `dropped`, the
  machinery shall reject the diff, or write nothing for the event.
- When a `dropped` task lands on the authority branch, the stage-3
  machinery shall close its mirror as not planned, carrying no
  `status:` label.
- When the selection algorithm reads the queue, it shall exclude
  `dropped` tasks from every step, including resume.

## Edge cases

- Dropping a task with an open pull request: the human decision wins —
  the PR closing afterwards finds no legal edge (`dropped` has none)
  and writes nothing.
- A task dropped and later regretted: identity is never reused — a new
  task is created; the dropped file stays, history.
- `blocked_reason` on a dropped task: not required — `dropped` needs no
  justification field; the commit that drops it says why, where every
  other decision's why lives.

## Tests required

Check-tier tests: accept-in from each non-terminal state, reject-out,
reject an event against `dropped`; a mirror test for close-as-not-planned;
a selection test excluding `dropped`.

## Definition of Done

- [ ] All acceptance criteria hold, each with a test.
- [ ] `writrun check` and the full test suite pass.

## Proposed product changes

- none — the rule was authored first
  (`product/tasks-and-specs/statuses.md`,
  `product/github-issues/labels.md`); this change brings the machinery
  up to a doc that already states it.

## Proposed technical changes

- none — the value is already in the authored schema
  (`technical/README.md#task-schema`); this change builds the checks
  and mirror behaviour the doc already states.

## Outcome

Built as specified: `dropped` is in the schema and the checks'
vocabulary, reachable by hand from any non-terminal state and left by
nothing — `check_state.sh` rejects the exit, the transition machine
holds no edge out of it, `record_task_status.sh` never touches it, the
selection excludes it, and `rederive_labels.sh` closes its mirror as
not planned, stripping the status label. Divergence: the mirror close
rides `rederive_labels.sh` (now a 1:1 projection of the file, and
callable with task ids directly) rather than a new script.
