---
id: task-0019
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0016, spec-0017, spec-0018, spec-0019, spec-0020, spec-0021]
doc_ref: product/stage-1-tasks-and-specs/statuses.md#criteria
origin: rule
priority: high
depends_on: []
milestone: null
created: 2026-08-30T02:57:59Z
queued: 2026-08-30T03:47:10Z
completed: 2026-08-30T05:00:59Z
merged: 2026-08-30T13:07:01Z
provenance: []
---

# Task status on main is written by the machinery, from forge events

**References:** [product/stage-1-tasks-and-specs/statuses.md#criteria](../../docs/product/stage-1-tasks-and-specs/statuses.md#criteria) · [spec-0016](../specs/spec-0016-status-on-main.md) · [spec-0017](../specs/spec-0017-guard-status-line.md) · [spec-0018](../specs/spec-0018-stage-naming.md) · [spec-0019](../specs/spec-0019-taken-by-field.md) · [spec-0020](../specs/spec-0020-dropped-status.md) · [spec-0021](../specs/spec-0021-self-healing-readiness.md)

`main` is the complete mirror of the queue — that is the rule the docs
now state, and the system has not caught up. Today a task's
`in-progress` is written on the implementing branch and reaches `main`
only at merge, so between taking a task and merging it the authority
branch reports work as free that is already under way; only the Issues
mirror knows better, and only at Stage 3.

The rule assigns the whole working-status line to the machinery, moved
by forge events: the draft pull request opening, the pull request
closing unmerged, the merge. The worker's declaration of finishing is
the hand-written `completed` date; the status flip that records it on
`main` is the merge's. A branch never edits the status line, and the
checks must refuse one that does.

Bring the machinery, the checks, the skills and this repo's own
`AGENTS.md` up to that rule.
