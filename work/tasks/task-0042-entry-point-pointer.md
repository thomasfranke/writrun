---
id: task-0042
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0058]
doc_ref: product/adoption.md#the-entry-point-is-the-projects
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-03T23:37:10Z
queued: 2026-09-04T05:16:06Z
completed: null
merged: null
provenance: []
---

# Bring the kit up to the minimal entry-point rule

**References:** [product/adoption.md#the-entry-point-is-the-projects](../../docs/product/adoption.md#the-entry-point-is-the-projects) · [spec-0058](../specs/spec-0058-entry-point-pointer.md)

The kit grafts ~125 lines of WritRun flow into the adopting project's
`AGENTS.md`, between markers an update has to respect, around lines
marked "yours" an update has to preserve. That puts kit-owned prose and
adopter-owned answers in one file, and every `writ update` has to merge
them apart again.

[The entry point is the project's](../../docs/product/adoption.md#the-entry-point-is-the-projects)
now states the rule: the graft is a pointer and nothing else; the flow
lives in a file the kit owns and an update replaces whole; the
adopter's answers live in files an update never touches. The kit does
not obey it yet.

Bring the kit up to the rule: the template's entry point, the file the
pointer names, the home the four human gates move to, the vendor shim
for agents that read a different entry file, and the update semantics
the ownership split makes trivial. The mirror guards compare what the
kit ships against what its prose names, so the kit's own prose moves in
the same change.
