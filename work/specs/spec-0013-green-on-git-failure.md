---
id: spec-0013
task_ref: task-0016
status: approved
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

(filled when the task completes)
