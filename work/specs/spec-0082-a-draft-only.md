---
id: spec-0082
task_ref: task-0058
status: implemented
created: 2026-09-05T23:56:04Z
---

# spec-0082 — A draft-only change owes no derived work

**References:** [task-0058](../tasks/task-0058-a-draft-only.md)

- **Goal:** a change whose every permanent-doc path was never a rule in
  that change owes no derived-work declaration.

## Scope

In: `check_derived_work.sh`, and the one question it asks — which paths
under `docs/` count as permanent.

In: a reader for the marker, because two checks need it and task-0059 is
the second. It lands here, in this script, and 0059 moves it to a shared
place or copies it with a reason — that judgement belongs to whoever
writes 0059 against what it finds.

Out: `check_doc_shapes.sh`. A shown shape that does not match the schema
is a broken example whether or not the chapter is a rule, and letting one
rot until the chapter graduates moves the whole conference to the day
the marker is removed — the worst moment for it. The rule as authored
does not stand `check_doc_shapes.sh` down, and this spec does not either.

Out: `doc_ref` and **Proposed changes** paths — task-0059's, and named
there.

**The marker is read on both sides of the range, and the question is
"was this ever a rule in this change".** Reading only the version the
change lands would let a rule be withdrawn silently: add the line, and
the chapter stops being permanent with nothing shown to a reviewer.
Reading only the base would refuse the case the whole rule exists for —
a new chapter, born a draft. So both, and one sentence covers every
combination:

| Base | Head | Owes |
|---|---|---|
| absent | draft | no — born a draft, the primary case |
| draft | draft | no — a draft being written |
| draft | rule | **yes** — the marker was removed, which is authoring |
| rule | draft | **yes** — a rule withdrawn is a decision |
| rule | rule | **yes** — today's behaviour, unmoved |

**One non-draft path is enough.** A change touching a draft chapter and a
real one owes a declaration, for the real one. The check's answer is
about the change, not per file, so the draft paths drop out of the set
and whatever is left decides — including the empty set, which is the
"nothing to declare" the script already prints.

**The marker counts on the first line and nowhere else.** A chapter that
documents the marker names it in prose — `authoring.md` now does, twice —
and a reader that searched the file would mark the methodology's own docs
as drafts. This is the same failure `quoted_front_matter_is_not_a_status`
pins from the other direction, and it is why the read is positional.

## Steps

1. Derive the range's two ends the way the implemented-spec read below
   already derives them, rather than adding a second parse of `$RANGE`.
2. `is_draft <ref> <path>` — true when the file's first line at that ref
   is the marker. Absent file, absent ref and unreadable blob are all
   "not a draft", which is the answer that keeps the check strict.
3. Drop from `perm` every path that is a draft at **both** ends, and
   every added path that is a draft at the head end. Everything else
   stays.
4. Leave the `docs/writrun-instructions.md` exclusion exactly where it
   is: it is a different exemption with a different reason, and folding
   the two would make one list mean two things.
5. Keep both existing messages. "No permanent doc changed — nothing to
   declare." is what a draft-only change now prints, and it is already
   true of it.

**Capture before searching.** Reading a first line as
`git show … | head -1` or `| awk 'NR==1{exit}'` is the SIGPIPE shape this
suite has now been bitten by twice — the producer dies on the closed
pipe and `pipefail` turns a correct read into a failure. Read the blob
into a variable, then take its first line.

## Acceptance criteria (EARS)

- When a change adds a chapter whose first line is the marker and touches
  no other permanent doc, the system shall require no derived-work
  declaration.
- When a change edits a chapter that is a draft at both ends of the
  range, the system shall require no declaration.
- When a change removes the marker from a chapter, the system shall
  require a declaration.
- When a change adds the marker to a chapter that was a rule, the system
  shall require a declaration.
- When a change touches one draft chapter and one non-draft permanent
  doc, the system shall require a declaration.
- Where the marker appears anywhere but the first line, the system shall
  read the chapter as a rule.
- When no permanent doc changed after the drafts are dropped, the system
  shall print what it prints today for a change touching no permanent
  doc.

## Edge cases

- **A draft chapter deleted.** Head has no file, base has a draft. Never
  a rule in this change, so nothing is owed — deleting something the
  project was not held to costs no declaration.
- **A rule chapter deleted.** Base is a rule, head is absent: a rule
  withdrawn, and it owes a declaration exactly as it does today. This
  spec must not make deletion cheaper than it was.
- **A draft chapter renamed.** Both ends are drafts under different
  paths. The path the diff reports at each end is the path read at that
  end; a rename that also removes the marker owes a declaration on the
  strength of the head end.
- **A file whose first line is the marker with trailing spaces.** Matched
  after trimming: a line the editor touched is the same declaration.
- **A marker in a fenced block on line 1.** Impossible — a fence opens
  the block, so the marker is on line 2 at the earliest and does not
  count. The chapter above shows the marker inside a fence for exactly
  this reason.
- **`docs/writrun-instructions.md` carrying the marker.** Already
  excluded by name for its own reason; the marker adds nothing and takes
  nothing away.

## Tests required

- A change adding one draft chapter and nothing else passes with no
  declaration in the body.
- The same chapter edited on a later push still passes.
- Removing the marker refuses without a declaration, and passes with one.
- Adding the marker to a chapter that was a rule refuses without a
  declaration.
- A draft chapter beside a real doc change refuses without a declaration
   — the mixed diff, which a per-file answer would get wrong.
- A marker on line 2, and a marker inside a fence, are both read as a
  rule.
- Every existing case in `tests/integration/stage-2/derived_work/` passes
  unchanged: no diff without a marker changes its answer.

## Definition of Done

- [ ] A draft-only change needs no declaration.
- [ ] Removing the marker, adding it to a rule, and deleting a rule all
      still owe one.
- [ ] The mixed diff owes one.
- [ ] The marker is read at the first line only, at both ends of the
      range, through a captured blob and never through a closing pipe.
- [ ] No existing derived-work case changes its answer.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- none — `product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet`
  already states this rule and its criteria; this task is the machinery
  catching up to a doc that was authored first, which is what authoring
  is.

## Proposed technical changes

- none — no technical chapter describes `check_derived_work.sh`. Its
  contract lives in its own header, which the Steps above rewrite, and
  `.writrun/` is mirrored into `template/` by `make template-sync`.

## Outcome

Implemented as specified, with one deliberate departure on where the
reader landed.

The range's two ends are derived once, in the `case "$RANGE"` block the
implemented-spec read already had — moved above the permanent-doc filter
and given a `HEADREF` beside the existing `BASE`. No second parse.

The filter asks per path whether the chapter was a rule at either end,
which is the table's five rows plus the two it left implicit: a deleted
draft is free, a deleted rule is not. Written as two explicit `if` blocks
rather than an `&&` chain, because under `set -e` a command failing after
the final `&&` exits the script.

**The marker reader landed in `queue_lib.sh`, not in this script.** The
Scope said it lands here and task-0059 decides where it belongs; both
tasks were worked in one change, so that decision was available at once
and taking it early avoided writing a helper in order to move it. The
boundary it revealed is real and is recorded in spec-0083's Outcome:
`check_derived_work.sh` and `check_promise_paths.sh` are stage-2 scripts
beside `queue_lib.sh` and now source it — neither sourced anything
before — while `check_front_matter.sh` is a skill, standalone so it runs
at every adoption stage, and carries its own four lines with the reason
written above them.

**The blob is captured before its first line is taken.** `git show` into
a variable, then `${blob%%$'\n'*}`, then a trailing-whitespace trim. Not
`| head -1`: that closes the pipe, git dies on SIGPIPE and `pipefail`
turns a correct read into a failure — the shape this suite has now been
bitten by twice, once in `queue_lib`'s own cases and once in
`harness.sh`, where it failed an assertion that had actually matched.
