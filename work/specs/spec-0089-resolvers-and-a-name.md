---
id: spec-0089
task_ref: task-0063
status: implemented
created: 2026-09-06T05:30:36Z
---

# spec-0089 — The last resolvers fold, and the stranger stops wearing the family's name

**References:** [task-0063](../tasks/task-0063-fold-leftovers.md)

- **Goal:** no resolver clone stands outside `queue_lib.sh`, and the
  one deliberately different field reader carries a name that says so.

## Scope

In: `preflight.sh`'s `task_num` and `task_file`. The first is a
byte-clone of `ql_task_num`; the second asks `ql_task_file`'s question
with a body that has already drifted (a glob loop against the lib's
`find` pipeline — same answer today, two places for tomorrow's bug).
The script already sources the lib, so the fold is deletion plus two
call-site renames.

In: `mirror_issues.sh`'s `fm_field <front-matter> <name>` — renamed to
`fm_first`, after what it actually does: the first line naming the
field wins, over delimiter-stripped front-matter text assembled so a
patch's fields beat the base file's. Six call sites and one comment
rename with it. The semantics move nowhere: this is a rename, the
difference it advertises already exists.

In: the no-survivors test grows the resolver family — the `task_num`
sed body and a `task_file` glob loop join the patterns it refuses
outside the lib, so the next resolver clone fails a test instead of
waiting for a review.

Out: `rederive_labels.sh`'s `queue_file` — it resolves ids inside an
extracted `$QUEUE_ROOT` tree with its own prefix argument, a different
question from `ql_task_file`'s working-tree lookup; folding it means
teaching the lib about extraction roots, a reshaping with no drift
retired. Named so the next sweep does not re-find it as an oversight.

Out: any behaviour change. Every caller answers as before; the suite
is the witness.

## Steps

1. Delete `task_num` and `task_file` from `preflight.sh`; the call
   sites read `ql_task_num` and `ql_task_file`. The comment that
   already defers to the lib ("whose rule this is") goes with the
   bodies it excused.
2. Rename `fm_field` to `fm_first` in `mirror_issues.sh` — definition,
   six call sites, and the comment naming the first-line-wins rule.
3. The no-survivors test pins the resolver bodies outside the lib, the
   same way it pins the field reader's awk body.
4. `make template-sync`.

## Acceptance criteria (EARS)

- When any script resolves a task number or file, the system shall do
  so through `queue_lib.sh`, and no private resolver body shall remain
  under `.writrun/scripts/`.
- When a reader searches `.writrun/scripts/` for `fm_field`, the
  system shall present exactly one family: the lib's two doors.
- When the existing suite runs, every script shall give the answer it
  gave before this spec.

## Edge cases

- **`task_file`'s glob loop vs the lib's `find`.** Both return the
  first file whose id-number matches; the orders can differ only when
  two files share a number, which `check_unique_ids.sh` exists to
  refuse — so the swap is observable only in a state the gates forbid.
- **A `fm_field` mention in prose.** Comments that describe the lib's
  reader keep the lib's names; only the stranger and its own comment
  rename.

## Tests required

- The no-survivors test extended to the resolver family, red against
  the pre-fold `preflight.sh` by construction.
- The full existing suite green, unchanged.

## Definition of Done

- [ ] `preflight.sh` defines no resolver; call sites read the lib.
- [ ] `mirror_issues.sh` has no `fm_field`; `fm_first` answers there.
- [ ] The no-survivors test refuses resolver clones.
- [ ] The suite's answers are byte-identical to before this spec.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- none — no rule changes.

## Proposed technical changes

- none — decision 0072 already carries the rule this closes out; the
  scripts' internals live in their own comments, and `.writrun/`
  reaches `template/` through `make template-sync`.

## Outcome

Implemented as specified. `preflight.sh` defines no resolver —
`task_num` and `task_file` are deleted with the comment that excused
them, the one external call site reads `ql_task_file`, and the source
line's comment now names the resolvers beside the reader it already
credited. `mirror_issues.sh` carries no `fm_field`: definition, six
call occurrences and the first-line-wins comment all read `fm_first`,
and nothing else in the file spoke the old name.

The no-survivors test grew the two resolver patterns (the `task_num`
sed body, the queue glob loop), each excluding the lib, and was run
red against the pre-fold `preflight.sh` before the fold was trusted —
both patterns fired on it, none after. Its case name widened to say
what it now refuses. No divergence from the plan; `queue_file` in
`rederive_labels.sh` untouched, as scoped.

The ledger entry carries no token counts, for task-0062's recorded
reason: the platform's usage log attributes by a branch this worktree's
transcript never names, so `read_usage.sh` proposes nothing and the
entry states what is known.

Full suite green; `make template-sync` run.
