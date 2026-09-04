---
id: spec-0066
task_ref: task-0047
status: implemented
created: 2026-09-04T16:20:20Z
---

# spec-0066 — The in-flight half reads every carried tag, through the helper that already does

**References:** [task-0047](../tasks/task-0047-carried-tags-inflight.md)

- **Goal:** every task a pull request carries moves with its forge
  events, not only the one its branch is named after.

## Scope

In: `apply_pr_event.sh`, and the `record` job that calls it.

Out: the merge half (`record_task_status.sh`) and the mirror projection
(`project_pr_tasks.sh`). Both already read every tag through
`ql_carried_of` and both are correct — which is what makes this a
divergence between three readers of one question rather than a missing
feature.

Out: `flip_task_status.sh`, which takes one task and should. The loop
belongs to the caller that knows how many there are.

Out: `take_task.sh:226`, which composes one tag into the title. Taking
one task and adding the second tag by hand is how a multi-task pull
request is made today, and whether the take should compose several is a
separate question this must not answer by accident.

**One helper, not a second parser.** `ql_carried_of` exists, is used by
two other callers, dedupes, and is documented as "the task ids whose
work a pull request carries". Writing a second title parser inside
`apply_pr_event.sh` would give the same question two answers that agree
until one is edited.

**The widening is deliberate and is named here.** Reading the title
means a pull request on a non-`task/` branch whose title carries a tag
now moves that task, where today it exits with "names no task branch".
That is what `titles.md` states the tag is *for*, and both other readers
already behave that way. The guard moves from "is the branch a task
branch" to "does this pull request carry any task", which is the
question actually being asked.

## Steps

1. Source `queue_lib.sh` in `apply_pr_event.sh` and replace the
   `PR_HEAD_REF` regex at `:43-47` with `ql_carried_from_env`.
2. Exit 0 with a message when the carried set is empty — the same no-op
   the branch guard gives today, phrased for the new question.
3. Loop every event's write over the carried set, `flip_task_status.sh`
   once per task.
4. Make the close-without-merge survivor query per task: a survivor for
   one carried task says nothing about another.
5. Add `PR_TITLE: ${{ github.event.pull_request.title }}` to the
   `record` job's env in `writrun-progress.yml`, beside the
   `PR_HEAD_REF` already there. The `reflect` job passes both already.
6. `make template-sync` — the script and the workflow are both mirrored.

## Acceptance criteria (EARS)

- When a pull request whose title carries several `[TASK-NNNN]` tags
  raises an event, the system shall apply that event's write to every
  task carried, in one commit.
- When the head branch names a task the title does not tag, the system
  shall carry that task too.
- When the same task is named by both the branch and a title tag, the
  system shall write it once.
- When a pull request carries no task by either route, the system shall
  exit 0 without writing, naming that nothing is carried.
- When a pull request closes unmerged, the system shall ask about a
  surviving pull request per carried task, and land only those with no
  survivor.

## Edge cases

- **`PR_TITLE` is absent or empty**, on an event that does not carry it.
  The branch's own id still resolves, so the behaviour degrades to
  today's rather than to nothing.
- **A tag naming a task that does not exist.** `flip_task_status.sh`
  answers for one id already; the loop must not let one unresolvable id
  abandon the ids after it.
- **A tag naming a task no legal edge applies to** — already `done`, a
  stale replay. Writes nothing for that id and continues, per the
  checked-machine rule in `statuses.md`.
- **A title written by a fork.** Both arguments to `ql_carried_of` are
  documented as a fork's to write, and only digits survive — the reason
  the helper is the right home for this.
- **Ordering.** Two writes in one commit, so no reader sees a half-moved
  queue.

## Tests required

- An `apply_pr_event` integration case with a two-tag title: both tasks
  move on `opened`, in one commit.
- A case where the branch names one task and the title tags another:
  both carried.
- A case where branch and tag name the same task: one write.
- A case with no branch id and no tag: exit 0, nothing written.
- A close-unmerged case with a survivor for one of two carried tasks:
  one lands, one keeps its in-flight state and its `taken_by`.
- The existing single-task cases must pass unchanged — this widens the
  set, it does not change the writes for one task.

## Definition of Done

- [ ] `apply_pr_event.sh` reads the carried set through
      `ql_carried_from_env`.
- [ ] `writrun-progress.yml`'s `record` job passes `PR_TITLE`.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] `statuses.md`'s criteria say every carried task.
- [ ] The sequence in
      [report-0022](../reports/report-0022-carried-tags-inflight.md) —
      a draft opening on `[TASK-0003][TASK-0005]` — moves both.

## Proposed product changes

- `product/stage-2-pull-requests/statuses.md#criteria` — the criteria
  say "a task" where a pull request may carry several. They gain the
  set: the event's write reaches every task the pull request carries.
  This is loop closure, not a new rule — `technical/settings/titles.md`
  already states that the tag is how the machinery learns which tasks a
  pull request carries; the product criteria were written before a
  multi-task pull request existed to test them.

## Proposed technical changes

- none — `technical/settings/titles.md#pr_title_style` already states
  the contract this makes the script keep, down to the failure it
  names. A second statement beside the script is the copy that
  disagrees later.

## Outcome

Built as planned, steps 1–6. `apply_pr_event.sh` sources `queue_lib.sh`
and reads its carried set from `ql_carried_from_env`; the branch regex
is gone. Every event's write runs once per carried task through a
`flip_all` helper, and the close-without-merge arm asks the
survivor question per task against one `gh pr list`. The `record` job of
`writrun-progress.yml` now passes `PR_TITLE` beside `PR_HEAD_REF`, and
`make template-sync` mirrored both files. `statuses.md`'s criteria gain
the set. The sequence report-0022 saw half-recorded is the first case
of the new `every_carried_task_moves_test.sh`.

**The empty-carried message changed wording, and one existing case
changed with it.** Step 2 asked for the no-op "phrased for the new
question", so the guard now prints `head '...' and title '...' carry no
task — nothing to record`. `a_foreign_branch_is_no_task_test.sh`
asserted the old string and was updated. The spec's "existing
single-task cases must pass unchanged" holds where it was aimed — no
write for one task changed — and that case asserts the guard's wording,
not a write.

**A permanent doc now quotes a line the script no longer prints, and
was deliberately left alone.**
`docs/technical/distribution/checks.md` quotes the old message verbatim
to make its point about a miswired workflow looking ordinary. The point
survives the rewording exactly; the quote does not. Proposed technical
changes says "none", and `check_deltas.sh` reports any `docs/` path
outside the promise list as UNDECLARED, so honouring the promise and
fixing the quote in this change are mutually exclusive. The promise
won. The stale quote sits in that chapter's paragraph on the `PR_*`
names, and it is a line of loop closure for a later change rather than
a rule that is now wrong.

**One shipped sentence went stale where a gate did allow the fix.**
`writrun-check-task-state`'s SKILL.md warned that renaming a branch to
`report/…` "stops recording a renamed branch's task at all" — true of
the branch reader, false of this one. A skill is not a permanent doc in
this vocabulary and no check reads it as one, so it was corrected to
name both routes rather than left to mislead every session that loads
it.

**The survivor query still matches on head branch names only.** A pull
request that carries a task by title tag alone is invisible to
`test("^task/0*N-")`, so it would not be found as a survivor for that
task. Step 4 asked for the question to be asked per task, not for its
reach to change, and widening it is a different question about a
different reader — left where the spec left it, and recorded as
report-0027 rather than only in this paragraph.

Two details the spec left to the build. Each flip is wrapped so a
non-zero exit is reported and the tasks after it still move — the edge
cases asked for that guarantee, and the flip's own exit-0 answers for
an unresolvable id and a stale replay are a contract, not a reason to
skip the guard. And `tests/pipeline_lib.sh` gained `task_field`: a
multi-task run writes several files, and only the files say what each
task became.

**Three things review changed, after the build.**

*Going on was passing.* The wrapper above reported the failure and
returned zero, and the script ended `exit 0` — so a write that genuinely
failed produced a green run, and the caller committed and pushed the
half-applied event. Before this spec the flip ran bare under `set -e`
and a failure was loud, which makes the wrapper a regression rather than
a gap. The exit is remembered now and the script ends on it: the loop
still completes, and the run is red. The cost of getting this wrong is
not abstract — a carried task left `ready` with its work in flight has
no edge back to `in-review`, so nothing later in the pull request heals
it. `a_failed_write_is_not_a_green_run_test.sh` holds it.

*One question, one call.* The survivor query sat inside the loop, so a
pull request carrying six tags asked the forge the same list six times —
and no two of those answers could differ. The listing is hoisted and the
filter moved to the reader. `--limit` is now given with it: `gh`'s
default page is 30 and the filter is client-side, so a survivor below
that line came back invisible, and an invisible survivor lands a task
whose work is still open — the failure the query exists to prevent,
produced by the query itself. That half was there before this spec; it
is fixed here because the same line was being rewritten.

*And `task_field` read the whole file.* It took its field with
`sed -n "s/^field: *//p" | head -n1`, where the queue's own reader stops
at the closing `---`. Harmless against today's fixtures, whose bodies
are one heading — and a trap for the first case that needs a realistic
body, since a `status:` at column 0 in prose would make the assertion
lie. It reads the front matter now, by the same rule `ql_fm_field`
holds, inlined rather than sourced: a fixture asserting through the
script under test would agree with it by construction.

**And one thing review found that is recorded, not fixed.** This runs on
`pull_request_target`, so a fork's pull request reaches it, and the
title is the fork's to write — as the head branch always was. The kind
of exposure is unchanged; the amount is not. A fork could claim the one
task its branch spelled, and can now claim every task its title lists,
in one commit, with `taken_by:` naming its author. No ceiling is imposed
here: a number picked in passing is a rule, and this spec is not the
place to write one. The script's header says so plainly, and
report-0028 carries the question to triage.
