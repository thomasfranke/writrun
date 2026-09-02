---
id: report-0008
status: open
task_ref: []
doc_ref: product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not
created: 2026-09-02T14:00:50Z
triaged: null
---

# The report/ prefix is a name, not a property

**References:** [product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not](../../docs/product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not)

Rule K — shipped by task-0033 — decides whether a change may route a
report to `tracked` by prefix-matching the head branch against
`report/`. That is the whole test. Nothing checks the converse: that a
change on a `report/` branch carries *only* reporting.

So the gate is clearable by renaming. A contributor whose implementation
pull request is refused can rename its head branch to `report/…`, and the
`tracked` flip rides again beside the implementation — the exact failure
[report-0003](report-0003-tracked-rode.md) recorded, arrived at through
the check instead of around it.

Observed while reviewing the branch that implemented spec-0044; not a
regression, since before rule K nothing was checked at all. Two things
make it less than free, and both are worth writing down:

- The rename is a deliberate act, and `writrun-check-task-state`'s Never
  list now names it. That is a rule an agent keeps, not one the door
  holds — which is the distinction task-0033 existed to close.
- It silently costs the ride it was taken for. `apply_pr_event.sh`
  matches `task/[0-9]*` and exits 0 on anything else, so a `task/` branch
  renamed away stops being recorded `in-progress` and `in-review`
  entirely — `ql_carried_of`'s `[TASK-NNNN]` title fallback covers the
  merge-time move, not the in-flight events. The queue would go quiet
  about a task that is being worked, and nothing says why.

What a real check would read is the diff, not the name: a `report/`
change touches `work/reports/`, the `work/tasks/` and `work/specs/` files
the route mints, and nothing else. Whether that is worth a rule — and
whether the silent stop in `apply_pr_event.sh` is a second finding or the
same one — is triage's answer.
