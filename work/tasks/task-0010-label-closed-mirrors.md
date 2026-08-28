---
id: task-0010
status: pending
blocked_reason: null
spec_ref: [spec-0007]
doc_ref: product/github-issues/labels.md
priority: medium
depends_on: []
milestone: null
created: 2026-08-28
completed: null
---

# Label closed mirrors and re-derive after approval

Two label defects, both visible in the live issues.

A closed mirror keeps the last intermediate label it had, so an issue
closed as completed can read `status:in-review` — false, not merely
stale. A closed mirror should carry no `status:` label at all.

And `status:ready` is unreachable: the mirror derives it from the spec
statuses in the merged PR's diff, where they are still `draft`, because
the same merge is what approves them. Every task merged since then sits
on `status:pending` with its specs approved. The label must be
re-derived once the approval is recorded.
