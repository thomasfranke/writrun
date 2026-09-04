---
id: report-0027
status: open
task_ref: []
doc_ref: product/stage-2-pull-requests/statuses.md#criteria
created: 2026-09-04T17:51:19Z
triaged: null
---

# The close-without-merge survivor query still asks by head branch alone

**References:** [product/stage-2-pull-requests/statuses.md#criteria](../../docs/product/stage-2-pull-requests/statuses.md#criteria)

task-0047 makes a pull request carry every task its title tags, and the
in-flight half now asks the survivor question once per carried task. The
question itself did not widen with the reader: it still matches head
branch names only —

```
select(.headRefName | test("^task/0*${num}-"))
```

— so a task a pull request carries by title tag alone is never found as
a survivor for it.

Observed:

- PR #A on `task/0021-a`, titled `[TASK-0021][TASK-0022]`, is closed
  without merging.
- PR #B on `task/0021-b`, titled `[TASK-0021][TASK-0022]`, is open and
  works both.
- task-21 finds #B by its branch and is re-recorded from it.
- task-22 finds no open pull request whose *branch* is `task/0022-…`, so
  it is landed: `status: ready`, `taken_by: null` — while #B is in
  flight working it.

It does not heal at #B's next event: `ready` has no edge to `in-review`
in the table `flip_task_status.sh` holds, and `rework` needs
`in-review`. Only #B's merge cures it. In the window, selection can hand
task-22 to a second agent.

spec-0066 names the reach as left where it was — step 4 asked for the
question per task, not for what the question matches — and
`a_survivor_answers_for_one_task_test.sh` encodes the gap as expected
behaviour. Recorded rather than widened there, because widening it is
the same shape of change the spec put out of scope: the fix is to list
`headRefName` **and** `title` and filter both through `ql_carried_of`,
which is the helper the reader already uses.
