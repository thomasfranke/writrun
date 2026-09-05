---
id: spec-0079
task_ref: task-0057
status: draft
created: 2026-09-05T13:48:52Z
---

# spec-0079 — A rename is a change the readers see

**References:** [task-0057](../tasks/task-0057-id-claims-unseen.md)

- **Goal:** a queue file that arrives by rename is read as what it is —
  a claim on the id it lands on, and a release of the id it left.

## Scope

In: the three filters that decide which files a change is judged to
have touched — `check_unique_ids.sh:130-131` (what this change claims),
`:181` (what another open pull request claims), and the two collection
loops in `mirror_issues.sh:272` and `:321`.

In: `check_unique_ids.sh:149-150`, the base-branch side. It is not a
rename reader, and it is the other half of the same false collision:
an id the base holds is not held any more once this change renames that
file away.

Out: `ql_next_id` and the mint.
[spec-0081](spec-0081-mirror-holds-id.md) has it, and the two are
independent — this one makes the readers see a rename that already
happened, that one stops a class of rename from being needed.

Out: `modified` for task files. The task loop excludes it deliberately
and for a reason its own comment gives: a task already on the authority
branch has a mirror the machinery keeps in step from forge events. This
spec adds one status to two loops, and removes none from either.

Out: whether renumbering a *merged* id is allowed at all. It is the act
report-0031's repair had to perform, and this spec makes the machinery
read it rather than bless it. `technical/schemas/task.md#task-schema`
already draws the line — a number a branch has not merged is not yet an
id — and moving that line by way of a bug fix would change a rule while
claiming to keep it.

**One blindness, three readers, one line each.** The report states it
in a sentence: *the machinery reads additions and modifications, and a
rename is neither.* Each reader spells the same assumption its own way.
`check_unique_ids.sh:130` asks git for `--diff-filter=A`;
`check_unique_ids.sh:181` asks the forge for
`select(.status == "added")`; `mirror_issues.sh:272` and `:321` filter
the forge's `status` field to `added` and to `added|modified`. All four
are the same sentence, and a renumber is invisible to all four.

**The false collision, reproduced.** A queue filename is an id plus a
subject slug, so renumbering changes the path — and git therefore pairs
it as a rename rather than a modification. Against a base holding
`report-0001-take-task.md`, a change that renames it to
`report-0002-take-task.md` and adds `report-0001-new-thing.md` produces:

```
A       work/reports/report-0001-new-thing.md
R100    work/reports/report-0001-take-task.md → work/reports/report-0002-take-task.md
```

`mine` collects the addition, so it claims `report-0001`. `held` is
`git ls-tree` of the base, which still lists `report-0001-take-task.md`.
The check refuses the change for colliding with a file this same change
moved out of the way. Nothing in either input can see the two halves are
one act, which is why the repair report-0031 describes had to be split
across two pull requests. The mirror image of the same blindness is the
pure renumber: `--diff-filter=A` returns nothing at all, the check
prints "This change adds no queue file — nothing claims an id", and the
id the rename lands on is never judged against anything.

**Two names, and each reader needs a different pair.** The forge
reports a rename with both a `filename` — the path after — and a
`previous_filename` — the path before.

- `check_unique_ids.sh` needs **both**, and needs them from both of its
  sources. From git: the destination is a claim, and the source is a
  release that must be subtracted from `held`. From the forge, for the
  *other* open pull requests: only the destination, because what is
  being asked there is which ids somebody else has taken, and a pull
  request that renames a file away has not released that id to anyone —
  it still holds it until it merges.
- `mirror_issues.sh` needs **both**, for two different writes. The
  destination is the id that must now have a mirror. The source is the
  id that no longer exists, whose mirror the orphan sweep at the bottom
  of the script is the right place to retire.

**A pure rename carries no patch, and that is the substantive decision
in this spec.** `mirror_issues.sh` reads a queue file's front matter and
title from the patch and from nowhere else, deliberately: the status is
a judgement, and a status the patch does not carry means "this diff says
nothing about where the report is". A renumber changes only the
filename, so the forge sends an empty patch, and a reader that keeps
that rule to the letter learns nothing about a file it can see. The
answer is not to relax the rule for every status — it is to say what a
rename *is*: the same file, at a new id. So a renamed queue file is read
from the checkout at its new path, which is on disk, and it is read as
an arrival — the id is new, the mirror does not exist, and everything
the mint needs is in the file. The patch-only rule keeps its whole
meaning for `modified`, which is where it was written for.

## Steps

1. `check_unique_ids.sh`, the claim side: ask git for
   `--name-status --diff-filter=AR` instead of
   `--name-only --diff-filter=A`, and read the two-path form. An `A` row
   and a rename's destination both enter `mine`; a rename's source
   enters a new `released` list.
2. The base side: subtract `released` from `held` before the verdict, so
   an id whose only holder this change renamed away is not held. Do it
   by the id both sides are already normalised to, never by path
   equality — the point is that the path changed.
3. Keep the message the check prints on a real collision. Its advice —
   renumber this change's files — is what step 1 and step 2 make
   possible in one pull request instead of two.
4. `check_unique_ids.sh`, the other-pull-request side: widen the `--jq`
   to `select(.status == "added" or .status == "renamed") | .filename`.
   The destination only, for the reason above. Update the comment at
   `:161-165`, which says only the file list carries `status` and
   without it a modification would read as a claim — true, and now
   incomplete.
5. `mirror_issues.sh`, the file listing at `:95`: add
   `previous_filename` to the `--jq` tuple. Carry it as `-` where the
   forge sends nothing, and read it as a positional field, for the
   reason both loops below already carry `-` for: a tab is IFS
   whitespace, so an empty middle field collapses and shifts every field
   after it.
6. The task loop at `:272`: accept `renamed` beside `added`. Its comment
   — "a task file only ever arrives added, so its patch is the whole
   file" — is false for a rename and is rewritten with the rule step 8
   states.
7. The report loop at `:321`: accept `renamed` beside `added|modified`.
8. Where a row is `renamed`, read the file's front matter and title from
   the checkout at its new path rather than from the patch, and treat it
   as an arrival. Say why in the comment above the loop, next to the
   paragraph that states the patch-only rule: a rename carries no patch,
   and the file it names is the same file.
9. Give the orphan sweep the vacated id: a rename's `previous_filename`
   names an id this change removed, and its mirror is retired by the
   sweep that already retires a mirror whose file left the diff.
10. `make template-sync` — `.writrun/` is mirrored into `template/`.

## Acceptance criteria (EARS)

- When a change renames a queue file onto an id, the system shall treat
  that id as claimed by the change.
- When a change renames a queue file away from an id and claims that id
  for another file, the system shall not report a collision.
- When a change renames a queue file onto an id the base branch holds in
  a file the change does not rename, the system shall report a
  collision.
- When another open pull request claims an id by renaming a file onto
  it, the system shall count that id as claimed.
- When a pull request renames a queue file onto a new id, the mirror
  shall create an Issue for that id.
- When a pull request renames a queue file away from an id, the mirror
  shall retire the Issue that id held.
- When a renamed file carries no patch, the system shall read its front
  matter and title from the checkout at its new path.
- When a file is modified rather than renamed, the system shall read its
  front matter from the patch alone, exactly as it does today.
- When the forge sends no `previous_filename` for a row, the system
  shall read every other field of that row unshifted.

## Edge cases

- **A rename that changes the slug and not the id** —
  `report-0031-old-words.md` to `report-0031-new-words.md`. Source and
  destination are the same id, so the claim and the release cancel and
  the verdict is unchanged. The mirror sees an id it already has and
  does nothing. This is the case a path-equality subtraction would get
  wrong, which is why step 2 works on ids.
- **A rename out of the queue, or into it.** A queue file moved to
  `docs/`, or a file promoted into `work/reports/` from elsewhere. The
  `queue_id`/filename-shape guards in both scripts already refuse a path
  that is not a queue file, so one half of such a rename simply does not
  parse — a release with no claim, or a claim with no release, and both
  are correct.
- **A rename with content changes**, where the forge sends both a
  `previous_filename` and a patch. Read from the checkout, as step 8
  says: the file on disk is the change's own result and cannot disagree
  with its patch.
- **A rename git detects and the forge does not, or the reverse.**
  Rename detection is a similarity heuristic and the two implementations
  need not agree. The two readers are independent — one gates the pull
  request, one projects the mirror — and neither is the other's input,
  so a disagreement costs at worst the behaviour that stands today.
- **A rename chain within one change** — `0001` to `0002` to `0003`
  across two commits of the same branch. The range is read end to end,
  so git reports one rename and the intermediate id was never claimed.
- **A pull request that renames a queue file it added on its own
  branch.** Against the base there is no rename at all: the file is
  simply added at its final name, which is today's behaviour and the
  reason the prescribed repair works.
- **A rename on a fork's pull request.** Nothing new: the forge reports
  it the same way, and both readers already handle a fork's rows.
- **The orphan sweep and a rename inside one pull request's history.**
  A file added, then renumbered, on the same branch: the mirror the
  first push created is the one the vacated id names, and retiring it is
  correct — the id it mirrors is gone.

## Tests required

- `base_branch_holds_the_id_rejected_test.sh` must pass unchanged: an id
  the base holds, in a file this change leaves alone, still collides.
  This is the case a careless subtraction breaks.
- New, and the case report-0031 names: a change that renames
  `report-0001-take-task.md` to `report-0002-take-task.md` and adds
  `report-0001-new-thing.md` exits 0. Built as the reproduction above,
  so a regression reads as the same diff.
- New: a pure renumber onto an id the base already holds elsewhere is a
  collision — the claim a rename makes is judged like any other, not
  merely exempted.
- New: a rename that changes only the slug is neither a claim nor a
  release, and the verdict is unchanged.
- New, beside `another_open_pr_claims_the_id_rejected_test.sh`: another
  open pull request that claims an id by renaming onto it collides.
- `modifying_an_id_is_not_claiming_it_test.sh` and
  `no_queue_file_added_passes_test.sh` pass unchanged.
- Mirror side, new: a renamed report file mints a mirror for its new id,
  and the mirror of the id it vacated is retired in the same run.
- Mirror side, new: a renamed task file mints a mirror for its new id.
- Mirror side, new: a row the forge sends with no `previous_filename` is
  read with every field in place — the empty-field shift, pinned before
  a refactor can reintroduce it.
- `added_report_gains_proposed_mirror_test.sh`,
  `added_task_gains_proposed_mirror_test.sh`,
  `modified_task_file_not_mirrored_test.sh` and
  `a_proposed_report_triaged_later_is_closed_test.sh` pass unchanged —
  this change adds a status to two filters and moves nothing else.
- `tests/mirror_lib.sh` gains the ability to stub a `renamed` row with a
  `previous_filename` and an empty patch. Named here because none of the
  mirror cases above can be written without it.

## Definition of Done

- [ ] A renumber and the claim it frees land in one pull request, and
      the check passes.
- [ ] An id the base holds and this change does not move still collides.
- [ ] An id another open pull request claims by rename collides.
- [ ] A renamed queue file, of either kind, gets a mirror for the id it
      lands on.
- [ ] The mirror of the id a rename vacated is retired.
- [ ] A renamed file's front matter is read from the checkout; a
      modified file's is still read from the patch alone.
- [ ] No row is misread when the forge sends no `previous_filename`.
- [ ] `mirror_issues.sh`'s comment no longer says a task file only ever
      arrives added.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- `product/stage-2-pull-requests/statuses.md#criteria` — the criterion
  reads "when a change **adds** a queue file whose id the authority
  branch or another open pull request already claims". Two corrections,
  both stated as what the rule always meant: a change claims an id by
  adding a file *or by renaming one onto it*, and an id the same change
  renames away is not one the authority branch still holds. This is a
  reader corrected to the rule's intent rather than a new rule — the
  word `adds` was written before a renumber was a thing the machinery
  had to read — and a reviewer who disagrees should say so here, because
  the alternative is that this widening belongs on an authoring branch
  of its own.

## Proposed technical changes

- `technical/schemas/task.md#task-schema` — the paragraph that says a
  number an unmerged branch claims is not yet an id, and renumbering it
  costs nothing, gains the half that makes it operable: the machinery
  reads a renumber as one act, so freeing an id and claiming it is one
  change and not two.
- No decisions entry. This closes readers against a rule already
  written, in the direction that rule already points; a dated entry for
  every reader corrected to an existing rule would turn the log into a
  bug list. Where the criterion above is judged a widening rather than a
  correction, the entry that widening owes is the reviewer's call to
  ask for, and it belongs to the product change, not to this fix.

## Outcome

_(fill after execution)_
