---
id: spec-0014
task_ref: task-0017
status: approved
created: 2026-08-28T00:00:00Z
---

# spec-0014 — Adopt an unowned mirror, never a live one

## Scope

The ownership decision in `mirror_issues.sh`, and nothing else.

In scope: what happens after `issue_row_of` finds a mirror the current
pull request did not introduce. Out of scope: `reflect_progress.sh`,
which never consults ownership and must not start; the title lookup
itself; and the orphan sweep, which retires mirrors this pull request
*does* own and is a different question.

## Steps

1. Read the introducing pull request's number out of the mirror body's
   `| Introduced by | #N |` line. A body without one is unowned by
   construction — nobody wrote it, so nobody is working it.
2. Ask the forge for that pull request's state. **Open means live**: keep
   refusing, keep the warning, change nothing.
3. Anything else — closed, merged, or a number the forge does not know —
   means the mirror is stale. Adopt it: rewrite the ownership line to
   this pull request, reopen it if closed, and label it as the reconcile
   pass would have.
4. Say which of the two happened. "Adopted a stale mirror" and "refused a
   live one" are different events and a log that spells them the same
   way is how this went unnoticed.

## Acceptance criteria

- When the mirror found was introduced by a pull request that is still
  open, the system shall refuse it and shall not modify it.
- When the mirror found was introduced by a pull request that is no
  longer open, the system shall adopt it and shall not create a second
  mirror.
- When the mirror found carries no ownership line, the system shall
  adopt it.
- When a mirror is adopted while closed, the system shall reopen it.
- When the mirror found is this pull request's own, the system shall
  behave exactly as it does today.

## Edge cases

- The ownership line names a pull request number that does not exist —
  treated as stale, since nothing can be working it.
- Two stale mirrors for the same id: the first found is adopted and the
  sweep retires the rest, as it does for any mirror this pull request
  owns.
- A mirror introduced by *this* pull request in an earlier push, after
  the pull request was closed and reopened — already `is_mine`, and the
  reopen path already covers it.

## Tests required

One case per acceptance criterion, in the mirror suite, with the forge
stubbed as it already is. The stub gains a pull-request-state read.

## Definition of Done

- `make tests` green, including the new cases.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — `product/pipeline.md` already says the file is the authority and
the mirror is a projection; this makes the machinery honour it in a case
it currently gives up on.

## Proposed technical changes

none — nothing under `docs/technical/` describes the ownership line.

## Outcome

(filled when the task completes)
