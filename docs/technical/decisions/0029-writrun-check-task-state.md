# `writrun-check-task-state` runs after the completion statuses are set, not before.

**2026-08-22**

Every rule it has is about a transition — `draft →
approved`, `draft → implemented`, a task reaching `completed` — and those
transitions are exactly what filling the Outcome and setting the statuses
produces. Run before that step and the diff contains none of them, so the
script exits 0 having read nothing: not a wrong answer, a vacuous one,
which is worse because it looks like a clean result. `writrun-check-spec-deltas`
is indifferent to the same ordering, since `work/tasks/` and `work/specs/`
are not permanent docs and touching them does not change its verdict, so
it sits immediately after the work, where a forgotten doc update is caught
soonest. The two therefore sit on either side of the status change rather
than together.
