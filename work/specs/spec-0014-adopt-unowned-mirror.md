---
id: spec-0014
task_ref: task-0017
status: implemented
created: 2026-08-28T00:00:00Z
---

# spec-0014 — Adopt an unowned mirror, never a live one

**References:** [task-0017](../tasks/task-0017-stale-mirror-blocks.md)

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

Done as specified. `mirror_issues.sh` now answers "whose mirror is this"
with three values instead of two — mine, a live pull request's, and
nobody's. `owner_of` reads the number out of the `| Introduced by | #N |`
line, `pr_is_open` asks the forge for that pull request's state, and
`adopt_mirror` rewrites the ownership line to the current pull request.
A mirror an open pull request owns is still refused untouched; everything
else — closed, merged, a number the forge does not know, or no line at
all — is adopted, relabelled by the pass that would have labelled a fresh
mirror, and reopened when it was closed.

Six cases in the mirror suite: the two refusal cases that already existed,
rewritten to declare their owner open, plus adoption of a stale mirror
(with the unknown-number edge folded in), of an unowned one, of a closed
one at merge, and a case pinning that this pull request's *own* mirror
takes none of the new path — no state read, no body rewrite, no
relabelling.

Three divergences:

- **The refusal's message changed, so two existing cases changed with
  it.** Step 4 asked the two events to be spelled apart, which the old
  wording ("id collision; not touching it") could not do once adoption
  existed — it named a cause that is no longer the reason to refuse. The
  refusal now names the pull request that is still open, and
  `id_collision_not_adopted_test.sh` and
  `foreign_tag_titled_mirror_not_adopted_test.sh` assert that instead.
  Both also had to declare `#99` open: with the forge silent about it,
  the mirror is stale by this spec's own rule and the refusal they exist
  for would never fire. That is the rule working, not a test weakened to
  fit it.

- **Reopening lives in the two branches that relabel, not in the
  adoption.** Step 3 lists reopening as part of adopting. Doing it there
  would reopen a mirror on a pull request that is closed unmerged, which
  the orphan sweep then closes again in the same run — churn that says
  two contradictory things to anyone watching the issue. So adoption
  rewrites the ownership line only; the open path reopens as it already
  did for its own mirrors, and the merge path gained the same reopen for
  an adopted mirror that was closed. The observable behaviour is what
  criterion 4 asks for.

- **An adopted mirror is relabelled even when it was already open.** The
  spec says "label it as the reconcile pass would have", and the pass
  only relabels a mirror it had to reopen. The labels on an adopted
  mirror were the previous owner's, derived from a pull request that no
  longer carries the task, so they are as stale as the ownership line —
  re-deriving them is the same act as taking the mirror over.
