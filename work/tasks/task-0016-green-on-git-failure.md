---
id: task-0016
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0013]
doc_ref: product/stage-1-tasks-and-specs/gates.md
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
queued: 2026-08-29T18:51:36Z
completed: 2026-08-29T19:09:57Z
merged: 2026-08-29T20:55:56Z
provenance: []
---

# Stop reporting green when git failed

**References:** [product/stage-1-tasks-and-specs/gates.md](../../docs/product/stage-1-tasks-and-specs/gates.md) · [spec-0013](../specs/spec-0013-green-on-git-failure.md)

Five scripts absorb a failed `git diff` into an empty result and exit 0.
The output is indistinguishable from an honest "nothing matched":
`check_recorded_approvals.sh` announces that no approval needs verifying,
`check_derived_work.sh` that there is nothing to declare — while the
command that would have told them otherwise never ran.

Two of the five are gates. A gate that passes because git failed is worse
than no gate: it reports a guarantee it did not check.

Priority is high because level `tasks-and-specs` makes it reachable. Without
branches, `main...HEAD` is empty by construction, so `check_state.sh`
prints OK having read nothing.
