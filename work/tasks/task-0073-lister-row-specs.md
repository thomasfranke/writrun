---
id: task-0073
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0101]
doc_ref: technical/selection/visibility.md#a-row-carries-what-the-lister-read-to-place-it
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-17T19:53:15Z
queued: null
completed: null
merged: null
provenance: []
---

# Every task row carries its specs and their status

**References:** [technical/selection/visibility.md#a-row-carries-what-the-lister-read-to-place-it](../../docs/technical/selection/visibility.md#a-row-carries-what-the-lister-read-to-place-it) · [spec-0101](../specs/spec-0101-lister-row-specs.md)


`visibility.md` now says every task row the lister prints carries the
specs it resolved to place the task, each with its status, as one token
immediately before the row's free text — `spec-0002:approved`,
comma-joined for several, `no-spec` for none. The lister computes
exactly that to decide `ready` and drops it at the printf.

What has to exist: the token on every task row — resume, available, in
flight, held back — and the skill's description of the rows saying so.

It matters because a reader built on the lister can say a task's id,
priority and section and cannot say what authorized it, the one fact
the placement derives from. A porcelain drawing "task-0002 — available,
spec-0002 approved" against v0.0.08 had to choose between a second
reader of the queue's front matter and leaving the pane unbuilt, and
left it unbuilt (report-0047, issue #270).
