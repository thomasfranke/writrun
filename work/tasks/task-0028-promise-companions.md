---
id: task-0028
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0038]
doc_ref: product/concepts/spec.md#the-doc-delta-contract
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T14:48:47Z
queued: 2026-08-31T15:04:28Z
completed: 2026-09-01T17:55:00Z
merged: null
provenance: []
---

# A promise that adds a decisions entry promises the index

**References:** [product/concepts/spec.md#the-doc-delta-contract](../../docs/product/concepts/spec.md#the-doc-delta-contract) · [spec-0038](../specs/spec-0038-promise-companions.md)

The case that authored this rule began five days before it surfaced: a
spec promised a dated decisions entry and not the index row that adding
an entry implies, and the omission stayed invisible through approval and
the whole implementation, until the completion gate refused a finished
branch. Fixing it there cost an amendment under an open pull request and
a suspended task; fixing it at the spec's entry would have cost one
edit, before anyone assented to anything.

The docs now state the rule: a promise includes its mandatory
companions — some documents never change alone, and a promise naming
the first without the second is not smaller, it is wrong. Build the
check that refuses an incomplete promise where the spec enters, at
creation or amendment, with the decisions log and its chronology index
as the named pair it starts from.
