---
id: task-0024
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0041]
doc_ref: technical/README.md#task-schema
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T13:50:34Z
queued: 2026-08-31T15:04:48Z
completed: null
merged: null
---

# The shapes the docs show are held to the schema

**References:** [technical/README.md#task-schema](../../docs/technical/README.md#task-schema) · [spec-0041](../specs/spec-0041-doc-shapes.md)

A schema is enforced where the machinery reads it and nowhere else, so
every shape the prose *shows* is unheld — and three of them have fallen
behind the shape they claim to teach.

`product/concepts/task.md` prints an example task whose front matter no
generator would write and no checker would accept: no `origin`, no
`queued`, no `merged`, and `created: 2026-08-21` as a bare date, which
`check_front_matter.sh` rejects outright — it takes `YYYY-MM-DDTHH:MM:SSZ`
and nothing else. `concepts/spec.md` carries the same bare date. Both
chapters exist to teach the shape; a reader who copies what they show
gets a file the first check refuses. The schemas in
`technical/README.md` are current, so the two halves of the same
contract now disagree, and the half a newcomer reads first is the wrong
one.

The adoption kit drifts the same way, for a structural reason: the
mirror test holds `.writrun/` and the workflows byte for byte, and
everything else under `template/` — the `AGENTS.md` an adopter's agent
reads first, its `WRITRUN.md`, its `docs/` and `work/` chapters — is
held by nothing. So `template/AGENTS.md` still gates availability on
`pending`, a status the vocabulary retired; still tells the agent to
"set spec `implemented` and task `completed`", inviting the one write
the status machinery forbids from Stage 2 up; and the kit's queue
chapters still name files `task-001.md` and `spec-001.md` when the
generator writes four digits and a subject slug. The copies of those
chapters in this repository were corrected; the shipped ones were not,
and nothing noticed.

Bring the four documents up to the shape they describe, and give the
class of defect a guard: the shapes prose shows are read by the same
checker that reads the real files, and the kit's documents are held to
the vocabulary the schema currently states — so the next retired word
fails a run instead of shipping to an adopter.

A parallel authoring change (`docs/provenance-ledger`) grows the schema
these examples are held to: task front matter gains `provenance: []`, so
the corrected example in `concepts/task.md` carries that line too. The
same change puts a front-matter *fragment* in `technical/README.md` — a
`provenance:` block showing entries alone, no full file around it — so
the guard this task adds must say what it does with fragments, or it is
born failing the doc that was authored beside it.
