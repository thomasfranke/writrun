---
id: spec-0013
task_ref: task-0016
status: implemented
created: 2026-08-28T00:00:00Z
---

# spec-0013 — Stop reporting green when git failed

## Scope

A script that could not read its input says so and exits non-zero, instead
of reporting the empty result as a clean one.

In scope: `check_queue_impact.sh`, `check_derived_work.sh`,
`check_promised_deltas.sh`, `check_recorded_approvals.sh` and
`flip_approved_specs.sh` — each wraps its `git diff` in `|| true`, which
under `set -euo pipefail` swallows the whole pipeline's failure and yields
an empty variable. Also `check_state.sh`'s vacuous pass on a repository
with no second branch.

Out of scope: making any check *run* without git. A check that cannot run
should say so; teaching it to work anyway is a different change.

## Steps

1. Replace each `$(git … || true)` with the pattern `check_state.sh` and
   `check_deltas.sh` already use: capture stderr, and on failure print what
   git said and exit 3.
2. `flip_approved_specs.sh` is the dangerous one — it mutates and always
   exits 0, so a git failure silently records no approval. Same treatment.
3. `check_state.sh`: when the range resolves but selects no commits,
   distinguish "nothing changed" from "nothing could have changed". Report
   the empty range rather than printing OK on a check that read nothing.
4. Keep `check_queue_impact.sh` advisory — it is documented as never
   failing a change — but an advisory that could not look must say it did
   not look.

## Acceptance criteria

- When `git diff` fails, each of the five scripts shall print git's own
  error and exit 3.
- When `git diff` fails, no script shall print a message implying it
  looked and found nothing.
- When `flip_approved_specs.sh` cannot read its range, it shall mutate
  nothing and exit non-zero.
- When `check_state.sh` runs on a range selecting no commits, it shall
  report that the range was empty rather than that no transition was
  forbidden.
- When git succeeds and the diff is genuinely empty, every script shall
  behave exactly as it does today.

## Edge cases

- A range naming a branch that does not exist — the common case at level
  `docs`, where `main` may be the only ref.
- A repository with no commits at all.
- `check_queue_impact.sh` stays exit 0 by contract; its failure signal is
  the message, not the code.

## Tests required

One case per acceptance criterion, in each affected script's existing
suite directory.

## Definition of Done

- `make tests` green, including the new cases.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — no rule changes; this makes existing checks honest.

## Proposed technical changes

none.

## Outcome

Done as specified. Each affected script gains `git_read`, which captures
git's stderr and, on failure, prints what git said and exits 3. The
remaining `|| true`s are grep's and `git show`'s, where no match and a
file absent from the base are answers rather than failures — that
distinction is the whole point, so they are commented where they stand.

`check_state.sh` refuses a range selecting no commits, which is what made
this task high: without branches, `main...HEAD` is empty by construction
and it was printing OK having read nothing.

Cases sit in each script's own suite directory, and each asserts two
things rather than one — the exit code, and that the reassuring sentence
(`nothing to declare`, `No permanent doc changed`, `needs verifying`,
`nothing claims an id`) is **absent**. An exit code nobody reads is half
the guarantee; the message is the other half.

Four divergences:

- **`git_read` sets a variable instead of returning output**, and the
  comment says why: an `exit` inside `$( )` ends only the subshell, so
  `x=$(git_read …)` would leave the caller reading the empty value this
  whole change removes. The bug would have been reintroduced by the fix
  for it, in a shape that still looked correct.

- **The `merge-base` needed the same treatment, which no step names.**
  Four of the scripts resolve the range's base before reading the diff,
  and `BASE=$(git merge-base …)` under `set -e` killed the script at 128
  before any of this could speak. Step 1 addresses `git diff` only; a
  script that dies at 128 with git's raw error is less wrong than one
  that passes, but it is not what the criteria describe.

- **Two more scripts had the defect, and both were folded in.**
  `check_unique_ids.sh` is a gate: a failed read left its list empty,
  reading as "this change adds no queue file — nothing claims an id".
  That is the harm this spec exists to remove, in a script its Scope does
  not list. `stamp_task_dates.sh` is milder — a missed stamp, not a false
  pass — but a date the machinery owes and never wrote is invisible
  afterwards. Offered a tracking task or a fold-in, the maintainer chose
  the fold-in; it rides as its own untagged commit. **The spec's own
  count is wrong as a result: five in the Scope, seven in the tree.**

- **`check_queue_impact.sh` exits 3 on a failed read**, though its Scope
  line and step 4 keep it advisory. Staying exit 0 would have made the
  message the only signal, and this is the one script whose message
  nobody is required to read. The contract it keeps is "never fail a
  change over what it found"; failing over what it could not read is a
  different promise.
