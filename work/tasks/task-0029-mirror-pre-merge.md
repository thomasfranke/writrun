---
id: task-0029
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0039]
doc_ref: product/stage-3-github-issues/labels.md#criteria
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-08-31T15:25:56Z
queued: 2026-08-31T15:32:42Z
completed: 2026-08-31T17:05:43Z
merged: null
---

# The mirror reads the queue as it was before the merge

**References:** [product/stage-3-github-issues/labels.md#criteria](../../docs/product/stage-3-github-issues/labels.md#criteria) · [spec-0039](../specs/spec-0039-merged-close-owner.md)

`labels.md` already says what should happen: *"When a recording commit
changes a task's stored status, the machinery shall re-label that task's
mirror from the queue as it then stands, rather than from the merge's own
diff."* It does not happen. Four mirrors on this repository right now
carry `status:backlog` for tasks the authority branch holds as `ready`,
with every spec they reference `approved` — #66 and #67 from one merge,
#70 and #71 from the next, the second pair predicted before it landed and
mislabelled exactly as predicted.

The mirror reconciliation reads the queue **as it was before the merge**.
Its job checks out without naming a ref, and on the event it answers that
resolves to the base branch at the merge base — so it sees the specs in
the state the merge was about to change, decides the task "merged with a
spec still draft", and keeps `backlog`. The sibling workflow that
projects carried tasks does name its ref, with a comment explaining
exactly why; the two disagree, and only one is right.

Two properties make this worse than a stale read. It **never heals**: the
correcting write is the recording commit, pushed with the Actions token,
and such a push triggers no workflow — there is no second event to fix
the label. And it is **selectively invisible**: a task with an empty
`spec_ref` has nothing to misread, so it lands correctly and hides the
defect. Every task born with a spec is wrong; every task born without one
is right. That is why this survived several merges unnoticed.

Correct the read, and settle the ordering it exposes: the recording
commit is pushed by a different workflow than the one that labels, so
naming the right ref without guaranteeing the label runs after the write
trades a defect that is always wrong for one that is sometimes wrong. Fix
the four standing mirrors as part of the change — a label nobody corrects
is the report's own subject.
