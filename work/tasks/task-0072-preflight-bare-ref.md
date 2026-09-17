---
id: task-0072
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0100]
doc_ref: technical/distribution/preflight.md#a-bare-ref-reaches-the-working-tree
origin: rule
priority: high
depends_on: []
milestone: null
created: 2026-09-17T19:49:54Z
queued: 2026-09-17T20:07:59Z
completed: null
merged: null
provenance: []
---

# Preflight takes a bare ref, and its warning reads what the stages read

**References:** [technical/distribution/preflight.md#a-bare-ref-reaches-the-working-tree](../../docs/technical/distribution/preflight.md#a-bare-ref-reaches-the-working-tree) · [spec-0100](../specs/spec-0100-preflight-bare-ref.md)


`preflight.md` now says its two arguments are told apart by what a task
list looks like, so a bare ref is a range and reaches the working tree
as it does in every stage-2 gate — and that the completion warning reads
`completed` at the range's head, the end the stages read. Neither is
true of the script: an argument without `..` is taken as a second task
list and refused, and the warning reads the file from the checkout
whatever the range.

What has to exist: the classification by task-id shape, the bare shape
handed through to stages 2 and 3 unchanged, and the warning reading the
same end they do.

It matters because the two halves make one silent pass. A flow that
writes the completion edits and commits nothing — `writrun finish` is
one — can only hand preflight a two-ended range, whose head has none of
them; the warning, reading the checkout, sees a completed date and
stays quiet; and `PREFLIGHT OK` prints over the one change the gates
exist to judge. Every completion that client cut was vouched for that
way (report-0046, issue #269).
