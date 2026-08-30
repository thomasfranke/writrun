---
id: task-0009
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0006]
doc_ref: technical/README.md#task-schema
priority: medium
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
queued: 2026-08-28T14:10:59Z
completed: 2026-08-29T17:34:12Z
merged: 2026-08-29T17:38:35Z
---

# Stamp queued and merged on the task

The schema now says a task carries four dates and that two of them —
`queued` and `merged` — are the machinery's to write, after the merge
each records. Nothing writes them yet, and nothing requires them.

Add both to the generated shape and the canonical check, and have the
post-merge workflow stamp them: `queued` on the merge that brings a task
into the queue, `merged` on the merge that takes its work.
