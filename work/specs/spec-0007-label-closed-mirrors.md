---
id: spec-0007
task_ref: task-0010
status: approved
created: 2026-08-28
---

# spec-0007 — Label closed mirrors and re-derive after approval

## Scope

A closed mirror loses its `status:` label, and a task's label is
re-derived after the merge that records its specs' approval.

In scope: `reflect_progress.sh` and `mirror_issues.sh` (both close
paths), and `writrun-approve.yml`, which already commits the approval
flip and gains the re-derivation as a step after it. Out of scope: the
label vocabulary itself, and the `proposed` label — that is task-0008,
whose change lands in the same two scripts but in different places
(the creation-time decision, not the close path).

## Steps

1. `reflect_progress.sh`: when a merge completes a task, strip the
   `status:` label as part of closing the Issue, rather than leaving the
   last one in place.
2. `mirror_issues.sh`: same for the mirrors it retires when a pull
   request closes unmerged.
3. Extract the "what label does this task deserve now" decision so it can
   run from the queue on disk, not only from a pull request's diff — the
   two callers ask the same question of different inputs.
4. `writrun-approve.yml`: after committing the flip, re-derive the label
   of every task whose specs that merge approved, and push both in one
   commit. Sequential in the same job, so it cannot race its own push.
5. A mirror that is already closed is not reopened to relabel it: the
   strip happens as part of closing, never afterwards.

## Acceptance criteria

- When a merge completes a task, the system shall close its mirror
  carrying no `status:` label.
- When a pull request closes unmerged and its mirrors are retired, the
  system shall leave them carrying no `status:` label.
- When a mirror is closed, the system shall keep every non-`status:`
  label it holds.
- When a merge records the approval of a task's specs, the system shall
  label that task `status:ready`.
- When a merge records an approval but a spec of that task is still
  `draft`, the system shall label it `status:pending`.
- When a merge records no approval, the system shall re-derive no label.

## Edge cases

- A task whose mirror is closed and whose specs are approved by the same
  merge: closing wins, and no label is written.
- A mirror carrying a hand-added non-`status:` label — kept, both on
  close and on re-derivation.
- A task with an empty `spec_ref`: approved by construction, so it
  re-derives to `status:ready`.

## Tests required

One case per acceptance criterion, in the `reflect_progress` and
`mirror_issues` suites.

## Definition of Done

- `make tests` green, including the new cases.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — the authoring change stated both rules in
`product/pipeline/statuses.md` first.

## Proposed technical changes

none — `technical/decisions/0048-a-label-names-a-place.md` carries the
dated entry already.

## Outcome

(filled when the task completes)
