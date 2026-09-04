---
id: spec-0066
task_ref: task-0047
status: draft
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

_(fill after execution)_
