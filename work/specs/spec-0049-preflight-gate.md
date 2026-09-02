---
id: spec-0049
task_ref: task-0034
status: draft
created: 2026-09-02T06:02:31Z
---

# spec-0049 — preflight.sh runs the completion gates in order

**References:** [task-0034](../tasks/task-0034-session-cost.md)

- **Goal:** the completion gates run as one command in their required
  order — front matter, then deltas, then state — so the ordering that
  today lives in prose warnings ("run it **after** step 4") is encoded
  once, and "run preflight until exit 0" replaces orchestrating the
  three checks by hand.

## Scope

In scope: `preflight.sh` in
`.writrun/scripts/stage-1-tasks-and-specs/`; `AGENTS.md`'s completion
steps pointing at it; its contract in `technical/distribution.md`;
unit tests; template sync.

Out of scope: the checks themselves — `preflight.sh` calls
`check_front_matter.sh`, `check_promised_deltas.sh` (which derives
the specs the range moved to `implemented` and runs `check_deltas.sh`
on exactly that set) and `check_state.sh` unmodified and adds no rule
of its own. These are the same three calls CI's `writrun-check.yml`
makes, so the local gate and CI render the same judgement on the same
branch — preflight is the in-session form of it, never a different
rule.

## Steps

1. `preflight.sh [task-id[,task-id…]] [diff-range]` — task ids
   default to the `task-NNNN` marker in the branch name, and none
   resolving is not an error (a reporting or docs branch carries
   none); range defaults to `origin/main...HEAD`, after a
   `git fetch origin main` (offline: a loud line, then the local ref
   — a stale base is named, never silent, because the state gate
   reads transitions against it).
2. In order, stopping at the first failure and reprinting that
   check's own output verbatim under a line naming the stage:
   a. `check_front_matter.sh` — its own whole-queue sweep, the only
      interface it has and the same call CI makes; the range plays
      no part in this stage;
   b. `check_promised_deltas.sh` with the range — it derives the
      specs the range moved to `implemented` and runs
      `check_deltas.sh` on exactly that set, CI's own selection;
      when none moved, its "authoring change, deltas not applicable"
      line prints and the stage passes loudly, not silently;
   c. `check_state.sh` on the range.
3. The vacuous-pass trap, encoded: when a named or inferred task's
   `completed` is still null, print that the run precedes the
   completion edits and does not stand for them — the delta stage's
   not-applicable line above is that same fact seen mechanically;
   the warning rides the summary either way.
4. All green → `PREFLIGHT OK` naming the range and the specs the
   delta stage checked; exit 0. A failing stage exits with that
   check's own code, printed under the stage's name — attribution is
   the named line, not the number. Preflight's *own* failures (a
   malformed argument, an explicit task id resolving to no file)
   exit 4, a code no stage uses, so a caller retrying on preflight's
   word never mistakes a stage's exit 3 for preflight asking for
   different arguments.
5. `AGENTS.md`'s completion sequence becomes: implement, update the
   promised docs, make the completion edits (today's step 4 —
   Outcome, `status: implemented`, the task's `completed` date —
   which stays in prose because it is edits, not a check), then run
   preflight until exit 0. Today's steps 3 and 5 are the collapse;
   step 4 is untouched, and the "after step 4" ordering the prose
   warned about is what the delta stage's derivation now enforces
   mechanically (nothing flipped → not applicable, loudly). Contract
   in `technical/distribution.md`; unit tests; `make template-sync`.

## Acceptance criteria (EARS)

- When all three checks pass, `preflight.sh` shall print one summary
  and exit 0.
- When a check fails, it shall stop there, reprint that check's
  output under the stage's name, and exit with that check's code —
  later checks unrun.
- When the range moved no spec to `implemented`, the delta stage
  shall pass with `check_promised_deltas.sh`'s own not-applicable
  line — the same verdict CI renders on the same branch.
- When a named or inferred task's `completed` is null, the summary
  shall carry the before-completion warning.
- When `origin` cannot be fetched, it shall say it is reading a
  possibly stale base and continue.
- When preflight's own input is unusable — a malformed argument, an
  explicit task id resolving to no file — it shall exit 4, a code no
  stage uses.

## Edge cases

- A branch carrying several tasks — the comma list widens the
  completion warning; the delta stage needs no ids at all, deriving
  its spec set from the range (`check_promised_deltas.sh`'s own
  contract, whose one call then applies `check_deltas.sh`'s
  multi-spec union).
- A reporting or docs branch (no task marker) — all three stages
  still run: the sweep, the not-applicable delta line, the state
  read; only the completion warning has nothing to attach to.
- Run from a subdirectory — it re-roots to the repository top first.

## Tests required

Unit, `tests/unit/preflight/`: ordering (a front-matter failure
leaves deltas and state unrun), id inference from branch name, the
comma list, the no-implemented-spec delta line, the completed-null
warning, the offline note, exit-code propagation per stage, the
exit-4 own-failure code distinct from every stage's.

## Definition of Done

- [ ] `preflight.sh` with the contract above; `AGENTS.md`'s
      completion sequence names it, its step 4 kept.
- [ ] Unit green; template synced; full suite green.

## Proposed product changes

- none — the gates and their order are unchanged; this encodes them

## Proposed technical changes

- `technical/distribution.md` — the script's contract joins the
  operational half.

## Outcome

_(fill after execution)_
