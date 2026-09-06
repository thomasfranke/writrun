---
id: report-0036
status: tracked
task_ref: [task-0061]
doc_ref: null
created: 2026-09-06T02:51:22Z
triaged: 2026-09-06T03:24:39Z
---

# Eight more scripts carry the git_read clone the lib now retires

**References:** [task-0061](../tasks/task-0061-clone-family-retires.md)

While spec-0086 moved `git_read` and the range-ends parse into
`queue_lib.sh` for the three gates report-0035 named, a grep for the
remaining copies found the clone family wider than the review said:
eight more stage-2 scripts carry their own byte-similar `git_read` —
`check_amendment_reference.sh`, `check_promise_companions.sh`,
`check_promised_deltas.sh`, `check_queue_impact.sh`,
`check_recorded_approvals.sh`, `check_unique_ids.sh`,
`flip_approved_specs.sh`, `stamp_task_dates.sh` — and several of those
derive a `BASE` of their own beside it. At least one
(`check_amendment_reference.sh`) already sources `queue_lib.sh` for
`ql_fm_field`, so the boundary is not what keeps the copies alive.

spec-0086's scope named three scripts and this change held to it; the
eight stand as they were, one drift hazard per copy — the hazard
`queue_lib.sh`'s own header records as having bitten twice already.
