---
id: task-0059
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0083]
doc_ref: product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet
origin: rule
priority: low
depends_on: [task-0058]
milestone: null
created: 2026-09-05T23:55:56Z
queued: 2026-09-06T00:06:51Z
completed: null
merged: null
provenance: []
---

# Nothing points into a draft chapter

**References:** [product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet](../../docs/product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet) · [spec-0083](../specs/spec-0083-nothing-points-into.md)

Nothing may point into a draft chapter: a task's `doc_ref` naming one is
derivation from a rule the project has not made, and a spec listing one
in **Proposed changes** is a promise to change a chapter no task was
allowed to be born from. Two readers already resolve those paths and both
would accept a draft today.

Make each of them refuse it, and say why in the refusal.

It matters because the marker's whole claim is that the queue does not
know the chapter exists. A `doc_ref` that resolves into a draft breaks
that claim quietly — the task looks derived, the reviewer sees a
reference that resolves, and only the marker one file away says the rule
behind it was never made.
