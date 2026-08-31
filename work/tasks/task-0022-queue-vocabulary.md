---
id: task-0022
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0028, spec-0031, spec-0032]
doc_ref: technical/README.md#task-schema
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T03:38:14Z
queued: 2026-08-31T04:04:03Z
completed: 2026-08-31T11:48:06Z
merged: 2026-08-31T12:55:41Z
---

# Make the queue navigable and origin-aware

**References:** [technical/README.md#task-schema](../../docs/technical/README.md#task-schema) · [spec-0028](../specs/spec-0028-clickable-refs.md) · [spec-0031](../specs/spec-0031-origin-field.md) · [spec-0032](../specs/spec-0032-reporting-rename.md)

The docs gave the queue's own files a richer voice and the generator
has not caught up. References are navigable by rule — a reader follows
a task to its docs and specs, and a spec to its task, by clicking —
yet the generated bodies still carry them as bare strings. A task now
records its origin, `rule` or `report`, projected as an `origin:`
label on its Stage 3 mirror — yet the generator writes no such field
and the mirror shows no such chip. And the third kind of change is
called reporting, on `report/` branches, while the shipped conventions
still say tracking on `queue/`.

Bring the generator, the checker, the mirror and the shipped
conventions up to the vocabulary the docs now state, and backfill the
existing queue so no file predates its own language.
