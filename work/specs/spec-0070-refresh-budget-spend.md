---
id: spec-0070
task_ref: task-0051
status: draft
created: 2026-09-04T19:27:29Z
---

# spec-0070 — The re-read is spent only where a miss can be staleness

**References:** [task-0051](../tasks/task-0051-refresh-budget-spend.md)

- **Goal:** the run's re-read budget is spent only where a miss can be
  staleness, and the path that can never miss on staleness stops paying
  for it.

## Scope

In: who may spend `rederive_labels.sh`'s re-read budget. The envelope
itself — two re-reads, one flat wait before each — stands as spec-0065
built it: report-0021 measured the gap at about four seconds, the six
the envelope reaches already covers it, and no entitled id has ever
missed inside it. Widening the reach would be motion no measurement
asked for, and it would move `WRITRUN_MIRROR_REFRESH_WAIT`'s meaning
under every suite and adopter that sets it.

Out: the shape of the retry. One shared re-read answering every id still
unresolved is [spec-0065](spec-0065-rederive-snapshot.md)'s decision and
it stands. The list is still re-read whole, the budget is still the
run's, and the miss is still what triggers it.

Out: `mirror_issues.sh` and the mint. What the mint reports is already
right, and `--minted` already carries it.

Out: making the envelope a key in `settings.json`. That file declares
what an adopting project *chooses*, and no adopter has a reason to
choose a different retry distance against the same forge. A constant
nobody varies is a constant, and one more key is one more thing to keep
true in two places.

**The guard is right because no caller mints without saying so — and
safe even where one someday does.** The cheap fix — skip the retry
where `minted` is false — is only correct if a miss on an id outside
the flag can never be a mirror this run created. Every caller was
read:

- `writrun-approve.yml`, the label step. Its own job holds the `mint`
  step, and it passes `--minted $MINTED_TASKS $MINTED_REPORTS`. It mints
  and it says so.
- `project_pr_tasks.sh:40`, reached only from `writrun-progress.yml`'s
  `reflect` job. It passes `$carried` and no flag. The job's one step is
  this script, and `mirror_issues.sh` appears nowhere in that workflow.
  It mints nothing and it claims nothing.
- `writrun-issues.yml`'s `mirror` job mints and never calls this script
  at all, so it is not a caller.

So there is no caller that mints and stays silent, and the guard breaks
none of them. But `.writrun/` is a distributed template, and a contract
enforced only by this repository's own wiring test is invisible to an
adopter who wires a minting caller with no flag — so the contract is
shaped to fail toward waste, never toward loss: **the saving is
declared, not assumed**. A run given no `--minted` flag at all keeps
today's answer, every miss entitled to the re-read; the flag, once
given, is the entitlement list, and empty means nobody. The caller
wired wrong tomorrow spends seconds it did not need to; it cannot
reproduce report-0021's minted-and-never-labelled, which is the one
outcome with no second event to correct.

**And it survives the one window where another job's mint could be
missed.** `writrun-issues.yml` mints for tasks a pull request's diff
*adds*, which by construction are not on the authority branch — this
pass reads no queue file for them and never reaches the lookup. Where a
concurrent mint could be missed at all, the miss lands on the
pull-request path, which runs again on the next event. That is the
asymmetry the whole policy rests on: **minted and never labelled is the
one outcome with no second event to correct it**, and it exists on the
merge path alone. Everything else is answered by the event after this
one.

**What this changes in spec-0065's acceptance, and why that is not a
retreat.** Two of that spec's own cases exercise the re-read with no
`--minted` at all
(`a_mirror_younger_than_the_read_is_found_test.sh`, the first and the
last), so narrowing the retry changes what it accepted rather than
fixing what it built. What those two cases are *about* is a mirror
younger than the read being found — and in every run that can happen,
the mirror is one the same job minted. The flag was absent because it
was not needed to reach the code path, not because a run without it is
the case worth holding. Both gain the flag and assert the same label and
the same read count; the last one gains the shape the approve line is
the only source of, since a report id reaches this script behind
`--minted` and nowhere else. The third case that changes is the one that
measured the wasted spend — three list reads for an id no mint claimed —
and it becomes one, which is the defect stated as a measurement.

**The envelope stands, and it does not jitter.** Two re-reads, three
flat seconds apart, reach six seconds past the first read against a gap
report-0021 measured at about four — and no entitled id has ever missed
inside that reach. The defect measured is spend on ids that could never
be stale, not reach on the ones that could, so the guard is the whole
fix and the schedule stays what spec-0065 built. Jitter is refused
deliberately. It exists to break a herd, and there is no herd here —
the merged close has one owner and the other two workflows stand down
for it (`decisions/github-issues/0060`), so one run reads one list with
nothing to contend against. Jitter would buy nothing and cost the one
thing this pass needs: a failure that reproduces.

## Steps

1. Make `resolve_mirror` ask whether the id is entitled before it
   spends anything: where a `--minted` flag was given, a miss on any id
   outside it is the answer, returned from the list in hand. `minted`
   reads an id string and `resolve_mirror` holds a number, so the
   membership test moves into a number-taking helper both call, with
   `unresolved` converting as it does today.
2. Make the absence of the flag mean what it means today: every miss
   entitled, the unconditional re-read unchanged. The saving is
   declared, never assumed — the failure mode of a caller wired without
   the flag must be waste, not a mirror lost.
3. `project_pr_tasks.sh:40` gains the empty flag — `--minted` with
   nothing behind it, its truthful declaration: it mints nothing, so
   nobody is entitled and each list costs one read.
4. Say the contract in `rederive_labels.sh`'s header, where the open
   question is: a caller that mints and labels in one job names its
   mints behind `--minted`; a caller that says nothing buys the
   unconditional re-read. The paragraph naming report-0029 as open goes
   with it.
5. Give `project_pr_tasks.sh`'s header the other side of that contract:
   it mints nothing and says so, so every miss it sees is a finding
   about the repository, answered from one read and healed by the next
   event if it was not.
6. Update the `--minted` paragraph in `writrun-approve.yml`'s label
   step, and gate the flag on the mint having succeeded: on
   `steps.mint.outcome != 'success'` the step passes no flag, so every
   miss is entitled again and a mirror the mint created before it
   failed is still found and labelled — the healing today's
   unconditional re-read provides, kept on the one path with no second
   event. The flag carried one thing — what a miss means — and now
   carries two: it is also who may pay to ask again.
7. Change the three cases named in **Tests required** below, and add
   the ones the new policy is owed.
8. `make template-sync` — `.writrun/` and `.github/workflows/` are
   mirrored into `template/`.

## Acceptance criteria (EARS)

- When a lookup misses on an id this run's mint answered for, the system
  shall re-read that id's mirror list and retry, within the run's budget
  for that list.
- When a `--minted` flag was given and a lookup misses on an id it does
  not cover, the system shall report it missing from the list already
  in hand, and shall neither re-read nor wait.
- When a run is given `--minted` with nothing behind it, the system
  shall read each list it needs exactly once.
- When a run is given no `--minted` flag at all, the system shall
  entitle every miss to the re-read, exactly as it does today.
- When a miss on an id no mint claimed comes before a miss on an id the
  mint answered for, the system shall leave the whole budget to the
  second.
- When the system spends a re-read on a list, it shall wait and spend
  as spec-0065 built it — the flat wait, at most two per list.
- When `WRITRUN_MIRROR_REFRESH_WAIT` is set, the system shall wait that
  many seconds before each re-read, and shall wait not at all where it
  is zero.
- When an id the mint answered for stays unresolved after that list's
  budget is spent, the system shall exit non-zero naming that id.
- When every id resolves from the first read, the system shall re-read
  nothing and wait not at all.

## Edge cases

- **A run declaring no minted ids and a task whose mirror was never
  created** — the `project_pr_tasks.sh` path, on every pull-request
  event, behind its empty flag. One list read, the notice, exit 0. That
  is the whole saving, and it is the case report-0029 measured.
- **A mirror minted by another workflow between this run's read and its
  lookup.** Reachable only outside the mint's own path, where the miss
  is a notice on a path the next pull-request event runs again. No
  outcome is left uncorrected, which is what the merge path cannot say.
- **The mint step failed and the label step ran anyway** — the
  `!cancelled()` reading `writrun-approve.yml` takes deliberately. A
  failed mint's outputs are empty, and an empty entitlement here would
  be the loss this spec must not ship: a mirror the mint created before
  it failed, on the one path with no second event, missed by a first
  read the forge has not caught up to and never asked about again —
  today's unconditional re-read finds and labels exactly that mirror.
  So step 6 gates the flag on the mint's own outcome: the failed mint
  passes no flag, every miss is entitled, and the pre-failure mirror is
  still healed. The job is red from the mint either way.
- **The re-read itself fails** — no network, a rate limit. Still spent,
  and the id stays unresolved, exactly as spec-0065 decided.
- **Both lists stale in one run.** The budgets are per list, so the
  worst case is two full envelopes. It is reached only by a run that is
  about to exit 1, where the seconds are the cheaper half.
- **A report id behind `--minted` and no task id.** Membership is per
  kind, so the report list's budget is spendable and the task list's is
  never touched — the lazy fetch spec-0065 protected stays protected.
- **`--minted` with two empty values behind it**, the merge that
  recorded nothing. No id is entitled, and the `have_work` check still
  returns before the forge is asked anything.
- **An adopter who set `WRITRUN_MIRROR_REFRESH_WAIT`.** Untouched: the
  wait keeps its name, its meaning and its default — one flat wait
  before each re-read, zero meaning none.

## Tests required

- `a_mirror_younger_than_the_read_is_found_test.sh`, first case: the id
  the re-read finds moves behind `--minted`. Same label written, same
  two list reads — the case now states the condition the re-read exists
  for rather than merely reaching it.
- The same file's last case, the report: `o/r report-0003` becomes
  `o/r --minted report-0003`, which is the only shape a report id ever
  reaches this script in. Same two reads of the report list, and the
  task list still never fetched.
- The same file's other two cases stand unchanged: the fourteen-mirror
  replay already names every id behind the flag, and the all-resolve
  case already re-reads nothing.
- `an_id_the_job_minted_cannot_be_missing_test.sh`, third case: gains
  the empty flag, and a miss on an id no mint claimed costs one list
  read, not three. Same notice, same exit 0.
- New: a run where a miss on an id nobody minted comes before a miss on
  an id the mint answered for — the second still resolves, from the
  first re-read.
- New: a run given no flag at all, with a miss: the re-read is spent,
  as today — the declared-not-assumed contract's fail-open half, pinned
  so a refactor cannot quietly flip it.
- New, and about wiring rather than a script: the approve label step
  names its mints behind `--minted` only where the mint succeeded, and
  passes no flag where it failed; `project_pr_tasks.sh` declares its
  empty flag. It belongs beside `one_workflow_answers_it_test.sh`'s
  assertions, which already read the approve workflow's step order this
  way — and the contract fails open where nothing asserts it, which is
  the reason the wiring case may live in this repository alone.

## Definition of Done

- [ ] Where a `--minted` flag is given, only an id it covers can spend
      a re-read; where none is given, every miss still can — the saving
      is declared, never assumed.
- [ ] The envelope is spec-0065's, unmoved: two re-reads per list, the
      flat wait, none of it where the unit is zero.
- [ ] The two spec-0065 cases that exercised the re-read with no
      `--minted` name the entitlement, and the case that measured a
      non-minted miss declares the empty flag and measures one read.
- [ ] A wiring case holds "a mint that succeeded names its mints, a
      mint that failed passes no flag".
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] The path report-0029 measured — a pull-request event on a task
      whose mirror was never created — costs one list read and no
      `sleep`.
- [ ] The sequence in
      [report-0021](../reports/report-0021-rederive-labels-sh.md) still
      labels all fourteen.

## Proposed product changes

- none — the rule this pass keeps is unchanged.
  `product/stage-3-github-issues/labels.md#criteria` requires the
  machinery to re-label a task's mirror from the queue as it then
  stands, and that is as true after this change as before it. How long
  the pass waits for the forge to admit a mirror it just created is not
  a rule about what a label means; putting a retry distance in that
  chapter is the second copy that disagrees later.

## Proposed technical changes

- none — no technical chapter describes this pass, which is the answer
  spec-0065 gave and for the same reason. `distribution/` covers the
  kit, the checks and the release. The reasoning lives in
  `rederive_labels.sh`'s header, which this change rewrites, and
  `.writrun/` is mirrored into `template/` by `make template-sync` — a
  Step above, not a promise here. No decisions entry either:
  `decisions/github-issues/0060` settled who owns the merged close, and
  this tunes a retry inside that owner rather than moving the ownership.

## Outcome

_(fill after execution)_
