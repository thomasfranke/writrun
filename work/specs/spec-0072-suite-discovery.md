---
id: spec-0072
task_ref: task-0054
status: implemented
created: 2026-09-05T12:56:40Z
---

# spec-0072 — The suite discovers every case it claims to run

**References:** [task-0054](../tasks/task-0054-six-review-findings.md)

- **Goal:** every command that reports a green suite has run the suite,
  and two runs in one worktree cannot report each other's cases.

## Scope

In: `make test-integration`'s discovery, the `test-%` pattern rule's
discovery, and the file `tests/run.sh` tallies into.

In: this spec is implemented **first** of task-0054's six. The other
five are verified by running the suite, and until this lands a green
run from `make test-integration` is evidence of nothing.

Out: `tests/run.sh`'s own discovery. It walks with `find` and finds all
253 integration cases already; the fault is the tally it writes them
to, not the set it runs.

Out: `make test-unit`. Its one-level glob matches the unit tier's
layout exactly — 150 cases, 150 run — and widening it would be a change
with no defect behind it.

Out: the layout itself. Moving the stage folders up one level would fix
the glob by deleting the structure `tests/run.sh`'s header states, and
the next suite bound to a stage would reintroduce it.

**Two faults, one file each, independent.** They share a spec because
they share a consequence: a green result that was never earned. Neither
depends on the other, and either alone leaves the suite trustworthy in
one command and not the other.

### The discovery gap, measured

`make test-integration` globs `tests/integration/*/*_test.sh`. That
matches 57 case files, in `front_matter/`, `release/` and
`sync_template/`. It misses 196 — every case under `stage-1/`,
`stage-2/` and `stage-3/`, which is `apply_pr_event`,
`amendment_reference`, `record_provenance`, `read_usage`,
`provenance_rollup` and the whole of the Stage 3 mirror. 77% of the
integration tier does not run, and the target exits 0 having said
nothing about it.

The `test-%` pattern rule has the same shape one level over: its three
globs reach `tests/<name>/*_test.sh`, `tests/<name>/*/*_test.sh` and
`tests/*/<name>/*_test.sh`, so a suite directory nested two deep under
a tier is unreachable through it too. The explicit `test-unit` and
`test-integration` targets shadow the pattern for those two names, so
the gap is only visible when a tier name is passed to the pattern —
which is why it survived.

### The tally is a fixed path

`tests/run.sh` truncates `tests/.tally` at start and appends one
`case:<status>` line per case, then counts the file. Its comment
anticipates a *stale* tally left by an interrupted run and truncation
answers that. It does not anticipate a *concurrent* one: two runs in
the same worktree append to the same file, and each counts the other's
cases as its own. This session observed reported totals of 795 and 808
where the true count is 405. A green run is manufacturable by
overlapping two invocations, which is the property a test runner exists
not to have.

## Steps

1. Widen `test-integration`'s glob to reach the stage folders — the
   one-level and two-level forms both, since three suites still sit at
   the tier root. Keep the `[ -e "$f" ] || continue` guard: a glob that
   matches nothing expands to itself.
2. Widen the `test-%` pattern rule's globs by the same one level, so a
   suite directory two deep under a tier resolves. Leave the
   `found`/`no such suite` refusal intact — a name that matches nothing
   must still exit 3.
3. Make `tests/run.sh` tally into a path private to the run. Prefer
   `mktemp`, and keep the existing `rm -f` so the file does not outlive
   the run; the trap must remove it on an interrupted run too, which is
   what the truncation was standing in for.
4. Rewrite the tally comment. It currently explains truncation against
   staleness, and after step 3 truncation is not what protects the
   count.
5. Run `make test-integration` and `bash tests/run.sh` and compare the
   case counts. They must agree.

## Acceptance criteria (EARS)

- When `make test-integration` is run, the system shall execute every
  `*_test.sh` under `tests/integration/`, at every depth the tier uses.
- When `make test-<suite>` names a suite directory nested under a tier's
  stage folder, the system shall run that suite's cases.
- When `make test-<suite>` names nothing that exists, the system shall
  print `no such suite` and exit 3.
- When two invocations of `tests/run.sh` overlap in one worktree, each
  shall report only the cases it ran.
- When `tests/run.sh` is interrupted, it shall leave no tally file
  behind for a later run to read.

## Edge cases

- **A tier gains a fourth depth.** The globs fix the depths they list,
  so a suite three levels down would be missed again. `tests/run.sh`'s
  `find` would still run it, and the disagreement between the two
  counts is what surfaces it — which is why step 5 compares them rather
  than trusting either.
- **`mktemp` differs across platforms.** These scripts promise bash 3.2
  and macOS; `mktemp` with no template is not portable. Use the
  explicit-template form both BSD and GNU accept.
- **A case file that reads stdin.** The existing `< /dev/null` guard
  stays; nothing here changes how a case is invoked.
- **The 196 cases have never run under `make`.** Some may fail. A
  failure this step exposes is not this step's to fix — it is a finding
  with a report of its own, and the target going red is the correct
  result.

## Tests required

- A unit case asserting `make test-integration` and `bash tests/run.sh`
  report the same case count. This is the assertion that would have
  caught the glob, and it is cheap: both print their total.
- A unit case running two `tests/run.sh` invocations concurrently in
  one worktree and asserting each total is the true count, not the sum.
- A unit case asserting `make test-<stage-suite>` resolves a suite two
  levels down, and that an unknown name still exits 3.

## Definition of Done

- [ ] `make test-integration` runs 253 cases, not 57.
- [ ] `make test-<suite>` resolves a suite under a stage folder.
- [ ] `make test-<unknown>` still exits 3.
- [ ] Two overlapping `tests/run.sh` runs report their own totals.
- [ ] An interrupted run leaves no tally file.
- [ ] The tally comment states what now protects the count.
- [ ] Any case the widened glob exposes as failing is reported, not
      silenced.

## Proposed product changes

- none — no product rule describes the test runner. The suite is how
  this repository checks itself, not something it promises adopters:
  `technical/decisions/tasks-and-specs/0021-the-adoption-kit-is.md`
  states that an adopter has no `tests/run.sh` at all.

## Proposed technical changes

- none — no chapter states the runner's discovery.
  `distribution/checks.md` covers how the gate scripts are called, not
  how the suite finds its cases, and the layout is documented in
  `tests/run.sh`'s own header where the `find` that honours it lives.
  A second copy under `docs/` would be the two-rules-that-agree-today
  shape `conventions/prose.md` refuses.

## Outcome

Implemented first, as the task required, because every other spec here
is verified against the suite this one repairs.

Two faults, not one. `make test-integration`'s glob was one level deep
over a tier that uses two — cross-stage suites at the tier root, and
stage-bound suites under `stage-N/` — so it ran 57 of 253 cases and
exited 0 about the rest. `test-%` had the same blind spot one level
further down. Both now name every depth the layout uses, and the
comments say why there are two.

`tests/run.sh`'s tally was a fixed path under `tests/`, shared by every
invocation in the worktree: two overlapping runs appended to one file
and each counted the other's cases as its own. That is where the 795
and 808 totals came from against a true 405 — an artefact of the runner,
never a real count. The tally is now a private `mktemp` file with a trap
that removes it however the run ends, which is what the truncation was
standing in for. The template is explicit because bare `mktemp` is not
in BSD's dialect.

The suite went from 405 case files to 441 as a direct result — 36 cases
that had been passing silently, or not, for as long as the glob was
wrong. None of the newly reached cases failed, which is luck rather than
evidence, and the reason this spec ran first.

