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
  once, and "run preflight until exit 0" replaces orchestrating three
  skills by hand.

## Scope

In scope: `preflight.sh` in
`.writrun/scripts/stage-1-tasks-and-specs/`; `AGENTS.md`'s completion
steps pointing at it; its contract in `technical/distribution.md`;
unit tests; template sync.

Out of scope: the three checks themselves — `preflight.sh` calls
`check_front_matter.sh`, `check_deltas.sh` and `check_state.sh`
unmodified and adds no rule of its own. CI keeps calling the
individual scripts; this is the local, in-session form.

## Steps

1. `preflight.sh [task-id[,task-id…]] [diff-range]` — task ids
   default to the `task-NNNN` marker in the branch name; range
   defaults to `origin/main...HEAD`, after a `git fetch origin main`
   (offline: a loud line, then the local ref — a stale base is named,
   never silent, because the state gate reads transitions against it).
2. In order, stopping at the first failure and reprinting that
   check's own output verbatim under a line naming the stage:
   a. `check_front_matter.sh` on every `work/` file the range touches;
   b. `check_deltas.sh` with the union of the tasks' `spec_ref` lists
      and the range — skipped with a loud line when every list is
      empty;
   c. `check_state.sh` on the range.
3. The vacuous-pass trap, encoded: when a named task's `completed` is
   still null, print that the state gate ran *before* the completion
   edits and does not stand for them — the run still reports, the
   warning rides the summary either way.
4. All green → `PREFLIGHT OK` naming range and specs; exit 0. A
   failing stage exits with that check's own code.
5. `AGENTS.md` completion steps 3–5 collapse to running this until
   exit 0; contract in `technical/distribution.md`; unit tests;
   `make template-sync`.

## Acceptance criteria (EARS)

- When all three checks pass, `preflight.sh` shall print one summary
  and exit 0.
- When a check fails, it shall stop there, reprint that check's
  output, and exit with that check's code — later checks unrun.
- When no task id is given and the branch carries none, it shall exit
  3 asking for one explicitly.
- When the named tasks' `spec_ref` lists are all empty, the delta
  stage shall be skipped with a line saying so.
- When a named task's `completed` is null, the summary shall carry the
  before-completion warning.
- When `origin` cannot be fetched, it shall say it is reading a
  possibly stale base and continue.

## Edge cases

- A branch carrying several tasks — the comma list; the delta stage
  passes the union, which is `check_deltas.sh`'s own multi-spec
  contract.
- A reporting or docs branch (no task marker) — usable with explicit
  ids or none; with none it runs front matter and state only.
- Run from a subdirectory — it re-roots to the repository top first.

## Tests required

Unit, `tests/unit/preflight/`: ordering (a front-matter failure
leaves deltas and state unrun), id inference from branch name, the
comma list, empty-`spec_ref` skip, the completed-null warning, the
offline note, exit-code propagation per stage.

## Definition of Done

- [ ] `preflight.sh` with the contract above; `AGENTS.md` completion
      steps name it.
- [ ] Unit green; template synced; full suite green.

## Proposed product changes

- none — the gates and their order are unchanged; this encodes them

## Proposed technical changes

- `technical/distribution.md` — the script's contract joins the
  operational half.

## Outcome

_(fill after execution)_
