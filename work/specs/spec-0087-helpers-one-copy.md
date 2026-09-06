---
id: spec-0087
task_ref: task-0061
status: draft
created: 2026-09-06T03:25:16Z
---

# spec-0087 — The last private copies fold into the shared reader

**References:** [task-0061](../tasks/task-0061-clone-family-retires.md)

- **Goal:** every stage-2 script reads its range, its git output and its
  front-matter fields through `queue_lib.sh`, and no private copy of
  those three helpers is left anywhere.

## Scope

In: the twenty-one private copies spec-0086 left standing, across nine
scripts. `git_read` — `check_amendment_reference.sh`,
`check_promise_companions.sh`, `check_promised_deltas.sh`,
`check_queue_impact.sh`, `check_recorded_approvals.sh`,
`check_unique_ids.sh`, `flip_approved_specs.sh`, `stamp_task_dates.sh`.
The range-ends parse — the same eight less `check_queue_impact.sh`,
which parses no range. The stdin `fm_field` — `check_derived_work.sh`,
`check_promise_companions.sh`, `check_promised_deltas.sh`,
`check_recorded_approvals.sh`, `flip_approved_specs.sh`,
`stamp_task_dates.sh`.

In: one addition to `queue_lib.sh` — `ql_fm_field_in <field>`, the same
awk reading stdin, with `ql_fm_field <field> <file>` delegating to it.
One awk body, two entry points.

**This reverses a scope call spec-0086 made, and says so.** That spec
put the stdin `fm_field` out of scope because it was a different
signature from `ql_fm_field`, one copy, and folding it meant reshaping
call sites. Two of those three are no longer true: the copies number
six, and a stdin-form helper reshapes no call site at all —
`| fm_field status` becomes `| ql_fm_field_in status`. What remains
true is that the signature differs, which is why the lib grows an entry
point rather than the call sites growing a temp file.

In: the standing rule the folds have been standing in for. The
one-copy principle lives today in `queue_lib.sh`'s header — a comment
nothing derives from and no gate reads — and the family was
under-counted twice because each fold's scope was what a review
enumerated. This spec promises the decision entry that makes it a rule,
the same incident-to-rule shape 0005 (POSIX awk) and 0012 (the test
suite) took.

Out: any behaviour change. Every script answers the existing suite
identically; this is spec-0086's fold finished, not extended.

Out: the `A..B` inconsistency the fold makes visible. The private
parses keep the range's left end only and read the new side from the
checkout, so on `A..B` they compare `A` against a working tree that is
not `B`. `QL_BASE` reproduces that exactly, so the fold is pure — and
correcting it is a behaviour change with its own spec. Named here so
the next review does not read the silence as an oversight.

## Steps

1. `ql_fm_field_in <field>` in `queue_lib.sh`, reading stdin;
   `ql_fm_field` becomes `ql_fm_field_in "$1" < "$2"`. The header's
   one-copy note gains the reason this pair exists: two shapes ask the
   same question, and `git show |` is the shape a caller cannot avoid
   when the blob may legitimately be absent.
2. The eight `git_read` scripts source `queue_lib.sh` where they do not
   yet — six of them start to — and drop their private copy for
   `ql_git_read`/`QL_GIT_OUT`. The never-in-a-substitution warning is
   already in the lib; the copies' own comments go with the copies.
3. The seven range parses become `ql_range_ends "$RANGE"` with
   `BASE=$QL_BASE` beside it. `QL_HEADREF` goes unread in all seven —
   none of them has a head end today, and inventing one is the
   behaviour change step 3 is not making.
4. The six `fm_field` definitions are deleted and their call sites read
   `ql_fm_field_in` — a rename, nothing else.
5. Every label carried into `ql_git_read` is checked against the
   arguments beside it, the sweep spec-0086 ran over three scripts, now
   over eight. A label that names a different command is fixed.
6. `technical/decisions/pull-requests/0072-a-shared-helper-has-one-copy.md`
   — a helper two stage-2 scripts need has one copy, in `queue_lib.sh`;
   the general form is the primitive and wrappers are one line; the
   `ql_` prefix marks what is shared. Rejected, with the history that
   rejects them: per-script self-containment (the original state —
   three incidents: the two the lib's header records, and spec-0084's
   bug found in one copy of three) and a scripts-wide lib across
   stages (nothing shares across stages yet; coupling with no client).
   `decisions/README.md` gains the chronology row.
7. `make template-sync`, so `.writrun/` and `template/` stay byte-identical.

## Acceptance criteria (EARS)

- When any stage-2 script parses a range, derives a git read, or reads
  a front-matter field, the system shall do so through `queue_lib.sh`,
  and no private definition of `git_read`, the range parse, or
  `fm_field` shall remain under `.writrun/scripts/`.
- When git fails under any of the eight scripts, the printed command
  shall be the one that failed, reproducible byte for byte.
- When a caller pipes a blob that does not exist, the system shall
  behave as it does today — an empty field, never a failed run.
- When the existing suite runs against the folded scripts, every script
  shall give the answer it gave before the fold.

## Edge cases

- **`check_queue_impact.sh` parses no range.** It takes `git_read`
  only; giving it `ql_range_ends` because its siblings have one would
  add a derivation nothing reads.
- **The two scripts already sourcing the lib.** `check_amendment_reference.sh`
  and `check_unique_ids.sh` source it for `ql_fm_field` and still carry
  private copies beside it — the deletion is all they need, and the fact
  that they compiled this way is the drift hazard stated plainly.
- **`check_derived_work.sh` is not in the report's eight.** It carries
  no `git_read` — spec-0086 folded that one — and a stdin `fm_field`
  the same spec left. It joins this scope through the third family, not
  the first.
- **A blob absent at `BASE`.** Five call sites read `git show BASE:… |`
  under `2>/dev/null` because a file new in the range has no blob
  there. `ql_fm_field_in` reads stdin and judges nothing, so the
  pipeline keeps its meaning.

## Tests required

- A unit case for `ql_fm_field_in`: a field present, a field absent, a
  body line spelling the field at column 0, and empty input — the
  invariants `ql_fm_field` already pins, through the other door.
- A unit case asserting no private `git_read`, range parse or
  `fm_field` definition survives under `.writrun/scripts/` — the
  regression this spec exists to make impossible to reintroduce
  quietly. It pins the three known names; a future clone under a new
  name is what the decision entry exists to refuse.
- The full existing suite green, unchanged — the fold's whole claim.

## Definition of Done

- [ ] `ql_fm_field_in` exists and `ql_fm_field` delegates to it.
- [ ] No `^git_read()`, `^fm_field()` or private range parse remains
      under `.writrun/scripts/`.
- [ ] Every `ql_git_read` label in the eight matches its arguments.
- [ ] Decision 0072 recorded, chronology row appended.
- [ ] The suite's answers are byte-identical to before this spec.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- none — no rule changes; every gate enforces exactly what it enforced.

## Proposed technical changes

- `technical/decisions/pull-requests/0072-a-shared-helper-has-one-copy.md`
  — new entry: the one-copy principle leaves `queue_lib.sh`'s header
  comment and becomes a standing rule, per step 6.
- `technical/decisions/README.md` — append 0072's row to the
  chronology.

## Outcome

_(fill after execution)_
