---
id: task-0048
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0067]
doc_ref: product/stage-2-pull-requests/statuses.md#criteria
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-04T18:30:49Z
queued: 2026-09-04T19:23:29Z
completed: null
merged: null
provenance: []
---

# Hold the recording push against a concurrent one

**References:** [product/stage-2-pull-requests/statuses.md#criteria](../../docs/product/stage-2-pull-requests/statuses.md#criteria) · [spec-0067](../specs/spec-0067-recording-push-race.md)

The recording step composes its write, rebases onto `main`, and pushes —
once. A second recording landing in the gap between the rebase and the
push makes the push fail, and the write is lost. Nothing retries it, and
no later event of that pull request recovers it: from `ready` there is
no legal edge to `in-review`, so the next event succeeds writing
nothing and hides the loss.

Close that gap. The guard's intent is already stated in the step —
"rebase onto it rather than force" — and it is right; what it lacks is
another attempt when the race it anticipates actually happens.

Why it matters: this is not hypothetical. Three drafts opened seconds
apart on 2026-09-04, and task-0047 stayed `ready` with `taken_by: null`
while its pull request was open and ready for review — for the whole
time its work was in flight. A queue that silently forgets a take is a
queue that can hand the same work to a second agent, and the mirror
repeats the wrong answer faithfully.
