---
id: spec-0086
task_ref: task-0060
status: draft
created: 2026-09-06T02:23:50Z
---

# spec-0086 — One range parse, one field reader, one honest label

**References:** [task-0060](../tasks/task-0060-prerelease-fixes.md)

- **Goal:** the range's two ends are derived in one place, the
  front-matter field has one reader per signature, and every `git_read`
  label names the command it runs.

## Scope

In: `queue_lib.sh` — a shared range-ends helper and a shared `git_read`,
beside the readers already there for the reason already written in its
header: private clones of these helpers drifted before, and hid a
pipefail bug.

In: the three stage-2 gates that carry the clones —
`check_derived_work.sh` (`BASE`/`HEADREF`), `check_promise_paths.sh`
(`BASE` alone), `check_observance.sh` (`BASE`/`TIP`). Two already
source `queue_lib.sh`; the third starts to, the same one line.

In: the one lying label — `check_derived_work.sh`'s docs diff prints
`git diff --name-only <range> -- docs` on failure while running
`-c core.quotePath=false diff --name-only --no-renames`; someone
reproducing from the message runs a different command and can get a
different answer. Sweep the other labels for the same drift while
there.

Out: the stdin-reading `fm_field` inside `check_derived_work.sh` — a
different signature for a different shape (`git show |` pipelines), not
a clone of `ql_fm_field`; folding it means reshaping call sites for no
drift risk retired. Named here so the next review does not re-find it.

Out: any behaviour change. This spec is the refactor the two fixes
leave behind; every gate answers the existing suite identically.

**Ordering.** Implemented after spec-0084 in the same change: the
helper lifts the parse as 0084 leaves it, working-tree sentinel
included, so the shared copy is born correct rather than fixed after
the move. This is the point of the lift — the bare-ref bug had to be
fixed in one place out of three, and the next range-shape bug should
not get the same chance.

## Steps

1. `ql_range_ends <range>` in `queue_lib.sh`: the three-dot arm
   computes the merge-base (exiting 3, loudly, when it cannot — a base
   of "nothing" is an unanswered question, the line all three clones
   already draw), the two-dot arm splits, the bare arm sets the
   working-tree sentinel from spec-0084. It sets `QL_BASE` and
   `QL_HEADREF`; a caller that needs one end reads one end.
2. `ql_git_read <label> <git-args…>` beside it, `QL_GIT_OUT` out — the
   three bodies are already identical, including the never-in-a-
   substitution warning, which moves with them.
3. The three gates drop their private copies, source the lib where they
   do not yet, and map the lib's names onto their own
   (`TIP=$QL_HEADREF` where observance says TIP) — each script's
   semantics unmoved. `check_observance.sh` reads commits, so the
   sentinel never reaches it: `git log` against a working tree is
   nothing, and its bare arm keeps `HEAD` by asking for it explicitly
   if 0084's sentinel would otherwise land there.
4. Delete `fm_field` from `check_promise_paths.sh` and call
   `ql_fm_field` — same awk body, same `(field, file)` signature, pure
   deletion.
5. Rewrite the docs-diff label to spell `-c core.quotePath=false` and
   `--no-renames`; check every other `git_read` call site's label
   against its arguments and fix any other liar found.

## Acceptance criteria (EARS)

- When any of the three gates parses a range, the system shall derive
  its ends through `ql_range_ends` and no private copy shall remain.
- When git fails under any gate, the printed command shall be the one
  that failed, reproducible byte for byte.
- Where `ql_fm_field`'s signature is wanted, the system shall have
  exactly one definition of it.
- When the existing suite runs against the moved helpers, every gate
  shall give the answer it gave before the move.

## Edge cases

- **A range that is itself empty or malformed.** Whatever each clone
  does today, the helper does — this spec moves behaviour, it does not
  audit it. A tightening is its own change.
- **`check_observance.sh` and the sentinel.** Its bare-ref end must
  stay a commit; step 3 makes that explicit rather than incidental.
- **A future fourth caller.** Gets both ends and uses what it needs —
  the promise check already models needing one.

## Tests required

- Unit cases for `ql_range_ends`: three-dot, two-dot, bare, the open
  ends (`A..`, `...B`), and the merge-base failure exiting 3 — the
  shapes the three clones between them already answer, now pinned once.
- The full existing suite green, unchanged — the refactor's whole
  claim.

## Definition of Done

- [ ] One range parse, one `git_read`, sourced three times.
- [ ] `fm_field` in `check_promise_paths.sh` is gone.
- [ ] Every `git_read` label matches its arguments.
- [ ] The suite's answers are byte-identical to before this spec.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- none — no behaviour changes; the rules the three gates enforce are
  untouched.

## Proposed technical changes

- none — no technical chapter names `queue_lib.sh` or these scripts'
  internals; the lib's header is its own record, and `.writrun/`
  reaches `template/` through `make template-sync`.

## Outcome

_(fill after execution)_
