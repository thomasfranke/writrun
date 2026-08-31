---
id: task-0010
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0007]
doc_ref: product/stage-3-github-issues/labels.md
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
queued: 2026-08-28T14:14:59Z
completed: 2026-08-28T21:33:48Z
merged: 2026-08-28T21:38:03Z
---

# Label closed mirrors and re-derive after approval

**References:** [product/stage-3-github-issues/labels.md](../../docs/product/stage-3-github-issues/labels.md) · [spec-0007](../specs/spec-0007-label-closed-mirrors.md)

Two label defects, both visible in the live issues.

A closed mirror keeps the last intermediate label it had, so an issue
closed as completed can read `status:in-review` — false, not merely
stale. A closed mirror should carry no `status:` label at all.

And `status:ready` is unreachable: the mirror derives it from the spec
statuses in the merged PR's diff, where they are still `draft`, because
the same merge is what approves them. Every task merged since then sits
on `status:pending` with its specs approved. The label must be
re-derived once the approval is recorded.
