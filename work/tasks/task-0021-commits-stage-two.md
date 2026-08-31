---
id: task-0021
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0026, spec-0027, spec-0028, spec-0029, spec-0030, spec-0031, spec-0032]
doc_ref: product/adoption.md#three-stages
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T02:47:35Z
queued: null
completed: null
merged: null
---

# Catch the machinery up with the restaged docs

The docs restaged the methodology and the machinery has not caught up.
Git begins at Stage 2 now — Stage 1 is autogen of tasks and specs from
the docs, as files, statuses by hand — yet the settings file still
keeps the agent's commit conduct in a Stage 1 section, and the status
machinery's comments still point at the Stage 1 chapter for a
projection that moved to Stage 2's. Queue references are navigable by
rule, but the generated bodies still carry them as bare strings.
Protection of the authority branch became a recommendation bounded by
the forge, with the owner-assent gate on settings, and the workflow
comments still explain themselves by an unprotected main. The third
kind of change is called reporting, on `report/` branches, and the
shipped conventions still say tracking on `queue/`. And a task now
records its origin — `rule` or `report` — projected as a label on its
mirror, while the generator writes no such field and the mirror shows
no such chip.

Bring every piece up to the rules the docs now state, and carry the
same guidance into the adoption kit, so an adopter's agent — and the
CLI to come — finds the machinery agreeing with the docs it reads.
