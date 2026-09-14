---
id: task-0067
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0095]
doc_ref: product/concepts/report.md#routing-upstream
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-13T23:41:04Z
queued: 2026-09-14T00:02:32Z
completed: null
merged: null
provenance: []
---

# The kit says what a routed issue waits for

**References:** [product/concepts/report.md#routing-upstream](../../docs/product/concepts/report.md#routing-upstream) · [spec-0095](../specs/spec-0095-routed-issue-waits.md)

An agent routing a methodology defect upstream is told to open the
issue and end the local report `routed`. It is not told what happens
next, because the chapter that says so — `concepts/report.md`, *"the
issue waits for a maintainer's label"* — is not among the three files
the kit ships under `docs/`.

The kit's own instruction should carry that sentence: that the issue
writes nothing upstream until someone with triage rights applies
`writrun:report`, and that `routed` therefore records a submission
rather than an entry in the upstream queue.

It matters because `routed` is the last word the instruction gives, and
it reads as arrival. An agent reports the finding delivered, its user
believes the upstream queue has it, and both are wrong in the same
direction — the one direction where nobody looks again. The methodology
already treats "a file nobody is prompted to open" as the failure worth
building against; this is that failure with the prompt aimed at a reader
who was never told to expect it.

Reported from issue #252, where the routing was executed correctly and
the issue still sat unlabelled until a person opened the link by hand
(report-0042).
