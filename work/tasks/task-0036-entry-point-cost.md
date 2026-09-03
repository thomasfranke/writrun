---
id: task-0036
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0052]
doc_ref: product/concepts/skill.md#why-a-skill-is-held-to-a-tighter-standard-than-a-doc
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-02T19:04:15Z
queued: 2026-09-02T19:18:49Z
completed: 2026-09-02T21:05:04Z
merged: null
provenance: []
---

# The entry point carries what every session needs and links the rest

**References:** [product/concepts/skill.md#why-a-skill-is-held-to-a-tighter-standard-than-a-doc](../../docs/product/concepts/skill.md#why-a-skill-is-held-to-a-tighter-standard-than-a-doc) · [spec-0052](../specs/spec-0052-entry-point-cost.md)

`AGENTS.md` is 12.4 KB and every session reads it before every task.
That is more than four of the five `SKILL.md` files put together, and
none of it is conditional: a session fixing a typo pays for the human
gates table, the completion checklist and the three-kinds matrix in
full.

`spec-0046` slimmed the five skills against exactly this arithmetic and
left the entry point out of scope by name. The rule it was applying now
exists as a rule, and it is owed by anything a session loads
unconditionally.

The move is the one `session_card.sh` already made for settings: a
session ran a script instead of re-reading the conventions for values.
Apply it here — the entry point states what every task needs and links
the rest, so a sentence only some tasks need is billed only to those
tasks.

What must not be lost: the entry point is the one file a session is
guaranteed to read, so anything a session must know *before* it knows
what it is doing has to stay. Deciding which sentences those are is the
spec's.
