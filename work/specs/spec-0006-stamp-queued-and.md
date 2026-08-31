---
id: spec-0006
task_ref: task-0009
status: implemented
created: 2026-08-28T00:00:00Z
---

# spec-0006 — Stamp queued and merged

**References:** [task-0009](../tasks/task-0009-stamp-queued-and.md)

## Scope

`queued` and `merged` become part of the generated shape and the
canonical contract, and the post-merge workflow stamps them.

In scope: `new.sh` (generates both as `null`), `check_front_matter.sh`
(requires both, each a UTC timestamp or `null`), a new
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
   validated by the same `check_date` the other two fields use — an RFC
   3339 UTC timestamp spelled with `Z`, or `null`. There is one date
   shape in this schema and these two fields are not an exception to it.
3. New `stamp_task_dates.sh <diff-range> <date>`: stamp `queued` on
   every task file the range **adds**, and `merged` on every task file
   the range moves **to `completed`**. Read the transition from the front
   matter at the range's two ends, never from the diff text — the same
   rule `check_state.sh` and `flip_approved_specs.sh` already follow,
   because a task body may quote a `status:` line. Only overwrite a field
   that is `null`: a date already recorded is history.
4. `writrun-approve.yml`: run it alongside the spec flip, with the merge
   commit's own time rather than today's —
   `TZ=UTC0 git show -s --format=%cd --date=format:%Y-%m-%dT%H:%M:%SZ` —
   and commit `work/` once for both. Not `%cs`, which is a bare date: the
   whole point of stamping from the commit is that the queue can be
   ordered, and two merges on one day would order no better than the
   bare-date scheme this schema replaced.
5. Back-fill every task already in the queue, in this same change. Use
   the **real** timestamps where the forge knows them — the merge that
   added each task file, and for a completed task the merge that took its
   work — and `null` only where no such merge exists yet. These are
   recoverable to the second from the commits themselves, so unlike the
   `created` migration there is nothing to normalize and no `T00:00:00Z`
   to invent. A field invented to satisfy a check would be worse than the
   gap it fills, so a moment that cannot be established stays `null` and
   says so.

## Acceptance criteria

- When `new.sh task` generates a task, the system shall write `queued`
  and `merged` as `null`.
- When a task file lacks either field, `check_front_matter.sh` shall
  report it malformed.
- When either field holds anything other than an RFC 3339 UTC timestamp
  spelled with `Z`, or `null`, the system shall report it malformed.
- When a merge adds a task file, the system shall stamp its `queued`
  with the merge commit's own timestamp, not the time the workflow ran.
- When a merge moves a task to `completed`, the system shall stamp its
  `merged` with the merge commit's own timestamp.
- When a field already holds a timestamp, the system shall leave it
  unchanged.
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

## Amendment history

**2026-08-28 — returned to `draft`, amended for the date shape.** The
schema moved after this spec was approved: every queue date is now an RFC
3339 UTC timestamp spelled with `Z`
(`technical/README.md#task-schema`, decision 0049), and task-0011
implemented it. This spec still specified `queued` and `merged` as
`YYYY-MM-DD` and stamped them with `git show -s --format=%cs`, which the
canonical check now rejects — so it could not be implemented as written,
in either direction: the doc wins over the spec, and the spec is amended
rather than out-implemented
(`product/pipeline.md#when-the-doc-moves-ahead-of-the-queue`).

Nothing else changed. The fields, their meaning, who writes each, and
every step's intent are untouched — only the shape of what gets written.
`spec-0008`'s Scope asked for exactly this, in advance: *"Anything a
concurrent change adds must be written in the new shape from the start
rather than migrated twice."*

## Outcome

Done as specified. `new.sh` writes both fields as `null` in the documented
order; `check_front_matter.sh` requires them and holds them to the one
date shape; `stamp_task_dates.sh` writes them from a merge range;
`writrun-approve.yml` runs it beside the flip and commits `work/` once for
both. Every task file in the queue was back-filled from the merge that
earned each date — 26 queue files canonical, and the stamps agree with the
forge to the second (task-0018 `2026-08-29T02:44:13Z`, task-0014
`...T17:15:35Z`, task-0012 `...T17:24:03Z`). Six tasks have `merged: null`
because no such merge exists yet, which is the honest value.

Four divergences, and the first is a correction to this spec:

- **`--date=format-local:`, not `--date=format:`.** Step 4 prescribes
  `TZ=UTC0 git show -s --format=%cd --date=format:%Y-%m-%dT%H:%M:%SZ`.
  `format:` renders a commit in **its own** timezone and `TZ` does not
  reach it, so that expression appends a literal `Z` to a local time. On
  this repository's merge of #44 it yields `2026-08-28T23:44:13Z` where
  the forge says `2026-08-29T02:44:13Z` — three hours wrong, and wrong in
  exactly the way 0049 exists to prevent, since a `Z` that is not UTC
  makes a lexicographic sort look chronological while being wrong for
  every entry that crossed an offset. `format-local:` reads `TZ`, so
  `TZ=UTC0` gives real UTC. The amendment that produced this spec was
  itself about this class of error and reached for the wrong spelling of
  the fix; the back-fill was redone with the right one.

- **The recording commit was retitled, and the convention with it.** Step
  4 makes one commit carry the flip *and* the stamps, which leaves
  `chore(specs): record approval from the merge` describing half of what
  it does. `COMMIT_TITLE` is now `chore(queue): record what the merge
  decided`, and `.writrun/conventions/commits.md` — which points at that
  variable and tells an adopter to keep the two in step — says so. Not a
  permanent doc, so the Definition of Done holds.

- **Three test fixtures and nine inline ones gained the fields.** The
  steps name the queue's own files; they do not mention that
  `pipeline_lib.sh`'s `task_file`, `mirror_lib.sh`'s `added_task` and
  `base_task`, and every hand-written task block in the `front_matter`
  suite are task front matter too. The moment the canonical shape requires
  a field, a fixture without it tests the wrong rejection — the `bare
  date` case would have failed for a missing field and still passed, which
  is a case that no longer proves what it claims.

- **A file missing the field is skipped, not repaired.** Step 3 says only
  overwrite a `null`; it does not say what to do with a field that is
  absent entirely. `stamp_task_dates.sh` reports it on stderr and moves
  on, because inserting a field is a shape decision and
  `check_front_matter.sh` is what owns the shape — a stamper that quietly
  fixed malformed files would hide exactly what the check exists to name.
