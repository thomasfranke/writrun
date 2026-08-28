---
id: spec-0007
task_ref: task-0010
status: implemented
created: 2026-08-28T00:00:00Z
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
`product/pipeline.md#flows-and-statuses` first.

## Proposed technical changes

none — `technical/decisions/0048-a-label-names-a-place.md` carries the
dated entry already.

## Outcome

Built as planned, all four steps. Step 3's extraction became
`.writrun/scripts/rederive_labels.sh`: the same question
mirror_issues.sh asks of a pull request's diff, asked of the queue on
disk, which is why it is a script of its own rather than a branch inside
either caller. The suite went from 176 to 186 case files.

Four divergences:

- **Only a `pending` task is re-derived.** No criterion says what to do
  when a merge re-approves the spec of a task somebody is working — an
  amendment does exactly that. Deriving `ready` there would tell a
  worker's mirror it is free again, on the strength of an approval that
  changed nothing about who holds it. `in-progress` and what follows
  belong to `reflect_progress.sh`, which knows whether a pull request is
  open; the queue does not. The script says so and writes nothing.

- **The flipped spec files are passed in, not re-derived from the
  range.** Step 4 says "re-derive the label of every task whose specs
  that merge approved". Which specs those are is what
  `flip_approved_specs.sh` just decided, so the workflow captures its
  output rather than reading the range a second time — a second reading
  is a second chance to disagree with the first.

- **Nothing is committed or pushed by the re-derivation.** Step 4 says
  "push both in one commit", which reads as if the label were a file. It
  is not. The step is sequential and *after* the commit — because the
  script reads the queue from disk, and the flip is only in the queue
  once written there — so it cannot race the push it follows.

- **`base_spec` gained a status argument and `base_task` was added.** The
  mirror fixture could only write approved specs and no task files at
  all, because until now nothing read the queue from disk.

`writrun-approve.yml` also gains `issues: write`. It had `contents:
write` for the flip commit; a label is not a file, and the job could not
have written one.

Not verified end to end, and worth naming: this repository's own stale
mirrors — the closed ones still carrying `status:`, and the merged tasks
sitting on `status:pending` with approved specs — are **not** back-filled
here. Nothing in this spec proposes it, and the machinery only acts on
events from now on. They will correct themselves for any task that sees
another event, and stay wrong otherwise.
