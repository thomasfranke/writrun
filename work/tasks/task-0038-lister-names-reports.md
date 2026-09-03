---
id: task-0038
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0054]
doc_ref: product/concepts/report.md#the-mirror-shows-what-is-waiting
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-02T19:43:36Z
queued: 2026-09-02T20:33:07Z
completed: 2026-09-02T20:58:15Z
merged: 2026-09-03T01:53:15Z
provenance: []
---

# An open report is named where a session looks for work

**References:** [product/concepts/report.md#the-mirror-shows-what-is-waiting](../../docs/product/concepts/report.md#the-mirror-shows-what-is-waiting) · [spec-0054](../specs/spec-0054-lister-names-reports.md)

A session asked what to work on, was told `Nothing is available.`, and
would have stopped there — while four reports sat `open`, waiting for
someone to decide what became of them. They were found by listing the
directory by hand.

`open` is the one report state that asks something of a person, and the
concept says outright why that matters: a file nobody is prompted to
open is a file that rots, which would leave reports worse than the
conversation they replaced. At Stage 3 the Issues mirror carries that
ask. It carries it to whoever reads the forge — and a session reads the
repository, so for the reader most likely to act, the ask is made
through a channel nobody opens.

The empty queue is not a rare state; it is what a finished milestone
leaves behind, and it is exactly when the findings deserve attention
most.

Name every open report where work is picked, at every stage. What must
not follow from that: a report becoming selectable. It is not work, it
never enters the ordering, and it must not change what the exit code
means — the boundary matters more than the feature, and the spec is
where it gets drawn.
