---
id: spec-0006
task_ref: task-0009
status: draft
created: 2026-08-28T00:00:00Z
---

# spec-0006 — Stamp queued and merged

## Scope

`queued` and `merged` become part of the generated shape and the
canonical contract, and the post-merge workflow stamps them.

In scope: `new.sh` (generates both as `null`), `check_front_matter.sh`
(requires both, each a date or `null`), a new
`.writrun/scripts/stamp_task_dates.sh` carrying the logic the suite can
execute, and `writrun-approve.yml`, which already commits to the base
branch after a merge and gains this as a second thing to write in the
same commit — **and every task file already in the queue**, which must
gain both fields in this same change: the moment the canonical check
requires them, a file without them is malformed, so back-filling is not
a courtesy but the thing that keeps the queue passing its own check.

Out of scope: `created` and `completed`, whose meanings and authorship do
not change.

## Steps

1. `new.sh`: emit `queued: null` and `merged: null` in the generated
   front matter, in the documented order — `created`, `queued`,
   `completed`, `merged`.
2. `check_front_matter.sh`: add both to the task field list, each
   validated as `YYYY-MM-DD` or `null`.
3. New `stamp_task_dates.sh <diff-range> <date>`: stamp `queued` on
   every task file the range **adds**, and `merged` on every task file
   the range moves **to `completed`**. Read the transition from the front
   matter at the range's two ends, never from the diff text — the same
   rule `check_state.sh` and `flip_approved_specs.sh` already follow,
   because a task body may quote a `status:` line. Only overwrite a field
   that is `null`: a date already recorded is history.
4. `writrun-approve.yml`: run it alongside the spec flip, with the merge
   commit's own date (`git show -s --format=%cs`) rather than today's,
   and commit `work/` once for both.
5. Back-fill every task already in the queue, in this same change. Use
   the **real** dates where the forge knows them — the merge that added
   each task file, and for a completed task the merge that took its work
   — and `null` only where no such merge exists yet. A field invented to
   satisfy a check would be worse than the gap it fills, so a date that
   cannot be established stays `null` and says so.

## Acceptance criteria

- When `new.sh task` generates a task, the system shall write `queued`
  and `merged` as `null`.
- When a task file lacks either field, `check_front_matter.sh` shall
  report it malformed.
- When either field holds something other than a date or `null`, the
  system shall report it malformed.
- When a merge adds a task file, the system shall stamp its `queued`
  with the merge's date.
- When a merge moves a task to `completed`, the system shall stamp its
  `merged` with the merge's date.
- When a field already holds a date, the system shall leave it unchanged.
- When a merge neither adds a task nor completes one, the system shall
  stamp nothing.
- When this change lands, every task file already in the queue shall
  carry both fields, and `check_front_matter.sh` shall pass the queue.

## Edge cases

- One merge that both adds a task and completes another — each gets only
  the field its own transition earned.
- A task added already `completed` in the same merge (a tracked task
  shipped with its work): both fields land at once, correctly.
- A task body quoting `status: completed` at column 0 — not a transition.

## Tests required

One case per acceptance criterion, in a new `stamp_dates` suite
directory plus the existing `front_matter` and `new` suites.

## Definition of Done

- `make tests` green, including the new cases.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — the authoring change stated the rule and its table in
`product/pipeline.md#flows-and-statuses` first.

## Proposed technical changes

none — the same authoring change covered the schema in
`technical/README.md`.

## Outcome

(filled when the task completes)
