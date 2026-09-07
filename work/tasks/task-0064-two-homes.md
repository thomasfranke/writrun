---
id: task-0064
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0090]
doc_ref: docs/product/adoption.md#two-homes
origin: rule
priority: high
depends_on: []
milestone: null
created: 2026-09-07T03:49:03Z
queued: null
completed: null
merged: null
provenance: []
---

# Move the adopter's files out of the kit's home

**References:** [docs/product/adoption.md#two-homes](../../docs/docs/product/adoption.md#two-homes) · [spec-0090](../specs/spec-0090-two-homes-migration.md)

Give the adopter's answers a home of their own. Today the project's
files — `settings.json`, `gates.md`, `conventions/` — live inside
`.writrun/`, the folder an update replaces, and ownership is per-file,
stated in a README a reader has to trust. Move them to `writrun/`, the
project's home, and leave `.writrun/` wholly the kit's — so an update
replaces one folder entire, a removal deletes it, and nothing the
project wrote is ever in the blast radius. Every kit script, workflow
and doc that names the old addresses follows.
