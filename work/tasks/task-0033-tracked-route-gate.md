---
id: task-0033
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0044]
doc_ref: product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-02T01:28:37Z
queued: 2026-09-02T05:35:07Z
completed: null
merged: null
provenance: []
---

# The tracked route is held to its own change

**References:** [product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not](../../docs/product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not) · [spec-0044](../specs/spec-0044-tracked-route-gate.md)

Make the machinery hold the rule the doc now states: the `tracked`
route travels through a reporting change of its own, never riding a
pull request that is about something else. Today the rule is prose —
nothing fails a `task/` or `docs/` branch that flips a report to
`tracked` and mints the task beside it, which is exactly how
`task-0032` entered the queue `ready` with no act of assent having it
as its subject ([report-0003](../reports/report-0003-tracked-rode.md)).

Why it matters: the queue is the set of things a human let in. A route
that can slip work into it as a passenger of an unrelated merge makes
every `ready` untrustworthy at the margin — the gate has to be a check
CI runs, not a memory agents keep.
