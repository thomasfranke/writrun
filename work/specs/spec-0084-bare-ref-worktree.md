---
id: spec-0084
task_ref: task-0060
status: implemented
created: 2026-09-06T02:23:38Z
---

# spec-0084 — The draft filter reads the working tree the bare-ref shape diffs

**References:** [task-0060](../tasks/task-0060-prerelease-fixes.md)

- **Goal:** every range shape the derived-work gate accepts asks the
  draft question of the same content its diff reported.

## Scope

In: `check_derived_work.sh` — the range-ends derivation and the two
per-path probes that read them. Nothing else in the script moves.

In: `tests/integration/stage-2/derived_work/` — the vacuous
draft-deletion scenario, the deleted-rule case the suite never had, and
the working-tree cases this fix creates.

Out: the sibling range parses in `check_promise_paths.sh` and
`check_observance.sh` — spec-0086 lifts all three after this spec lands
the semantics, so the helper copies a parse that is already right.

Out: `check_promise_paths.sh`'s read-the-checkout choice for spec
bodies — deliberate, recorded in decision 0071, and not this bug.

**The bug is a disagreement between the diff and the probes.** The diff
names the paths; the probes decide whether each was ever a rule in this
change. #225 wrote the probes against `BASE:` and `HEADREF:` blobs,
which is right for every shape whose diff compares two commits — and
wrong for the one shape whose diff compares a commit to the working
tree:

| Shape | The diff compares | The probes read | Agree? |
|---|---|---|---|
| `A...B` | merge-base ↔ `B` | `BASE:`, `B:` | yes |
| `A..B` | `A` ↔ `B` | `A:`, `B:` | yes |
| `A` | `A` ↔ **working tree** | `A:`, `HEAD:` | **no** |

A chapter that exists only in the working tree resolves at neither ref,
is a rule at neither end, and leaves `perm` in silence — the dropped
path that turns a refusal into a pass, the failure the script's own
comments call its worst. Confirmed empirically: a staged new rule
chapter under `docs/`, `check_derived_work.sh main`, exit 0 where the
pre-#225 script exited 1. The same mismatch exempts a working-tree-only
marker removal — graduation, the change authoring.md says derives its
work like any other, judged a draft at both refs.

**The head end of the bare shape is the working tree, so say so.** An
empty `HEADREF` is the sentinel — `ql_doc_is_draft` already has a
checkout mode for exactly the no-ref case, and the existence probe
becomes `[ -f ]`. The sentinel must never be interpolated into a
`ref:path`: `git cat-file -e ":$f"` reads the *index*, which is neither
end of this diff and silently a third answer.

## Steps

1. In the `case "$RANGE"` arm for the bare shape, set `HEADREF=""` —
   the working tree — instead of `HEAD`. The two-dot and three-dot arms
   keep their defaults: `git diff A..` compares commits, and stays
   commit-probed.
2. In the per-path loop, branch the head probe on the sentinel: with a
   ref, today's `git cat-file -e` + `ql_doc_is_draft "$f" "$HEADREF"`;
   without one, `[ -f "$f" ]` + `ql_doc_is_draft "$f"`.
3. The base probe is untouched — `BASE` is always a real ref in every
   arm.
4. Rewrite the deletion scenario in
   `a_draft_chapter_owes_nothing_test.sh` so the draft exists at the
   base of the range — committed where the base ref can see it — and
   dies on the head side. Today the file is created, edited and deleted
   entirely on the feature branch, `git diff main...HEAD -- docs` is
   empty, and the case passes under any implementation of the check.
5. Add the case the suite never had: deleting a rule chapter refuses
   without a declaration and passes with one — the "this spec must not
   make deletion cheaper than it was" edge spec-0082 named and nothing
   enforces.

## Acceptance criteria (EARS)

- When the gate is run with a bare ref and the working tree adds a rule
  chapter the ref does not hold, the system shall require a
  declaration.
- When the gate is run with a bare ref and the working tree only adds
  or edits draft chapters, the system shall require no declaration.
- When the gate is run with a bare ref and the working tree removes the
  marker from a chapter, the system shall require a declaration.
- When the gate is run with any two-commit shape, the system shall
  answer exactly as it does today.
- When a change deletes a rule chapter, the system shall require a
  declaration, and the suite shall prove it.
- When a change deletes a draft chapter visible at the range's base,
  the system shall require no declaration, and the diff the test hands
  the check shall be non-empty.

## Edge cases

- **A path deleted in the working tree only.** The diff reports it,
  `[ -f ]` says no, the head end is a rule in no sense — the base
  decides, so a deleted rule still owes and a deleted draft is free.
  The sentinel gives this for nothing.
- **Staged versus unstaged.** `git diff <ref>` shows both against the
  working tree; the checkout read covers both. No index probe exists,
  and none may: the index is a third state this check never compares.
- **`A..` and `...B` open ends.** They default to `HEAD` and their
  diffs compare commits — the sentinel is the bare arm's alone.
- **The unprobeable-path refusal.** The `"`-prefix exit-3 stays exactly
  as it is; a working-tree path git quotes is refused, not dropped, the
  same line the check already draws.

## Tests required

- The three bare-ref working-tree cases above: new rule refused,
  draft-only passed, marker removal refused — the first being the
  regression, pinned so it cannot return.
- The rewritten deletion scenario, with an assertion that the diff it
  hands the check is non-empty — the vacuity is the bug being fixed, so
  the test proves its own scenario real.
- The new deleted-rule case, refusing bare and passing declared.
- Every existing case in `tests/integration/stage-2/derived_work/`
  passes unchanged.

## Definition of Done

- [ ] The bare-ref shape probes the working tree it diffs.
- [ ] Every two-commit shape answers as before.
- [ ] The deletion scenario exercises the deletion path it names.
- [ ] A deleted rule owes a declaration, and a test holds it to that.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- none — `product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet`
  already states the rule; this returns the machinery to it after #225
  fell short of one range shape.

## Proposed technical changes

- none — no technical chapter describes `check_derived_work.sh`
  (spec-0082 established this); its contract lives in its own header,
  and `.writrun/` reaches `template/` through `make template-sync`.

## Outcome

Implemented as specified. The bare arm sets the empty-`HEADREF`
sentinel, the head probe branches on it — `git cat-file`/blob read with
a ref, `[ -f ]`/checkout read without — and the base probe is
untouched. The deletion scenario now fast-forwards the draft onto main
and deletes it from a fresh `withdrawal` branch, with an assertion that
the diff the check is handed really carries the path; the deleted-rule
case exists and refuses bare, passes declared. Every existing
derived-work case answers as before.

Two things the Steps did not anticipate. The working-tree cases must
`git add` the chapters they create: `git diff <ref>` reports a new file
only once the index knows it, so an untracked chapter is invisible to
the diff and the probes alike — invisible to both ends equally, which
is the agreement this spec restores, and the tests say so where they
stage. And the `case "$RANGE"` arm the Steps edited in place lives in
`queue_lib.sh` by the end of the same change — spec-0086 lifted it,
sentinel included, as its own Ordering paragraph said it would.
