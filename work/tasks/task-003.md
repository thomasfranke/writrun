---
id: task-003
status: pending
blocked_reason: null
spec_ref: []
doc_ref: technical/README.md#distribution
priority: medium
depends_on: []
milestone: null
created: 2026-08-23
completed: null
---

# Verify the adoption kit in a fresh repository

Copy `template/` into a brand-new repository and walk the adoption steps
in `WRITRUN.md` end to end, checking the kit's own promises: nothing of
the destination is overwritten, every path that lands is
WritRun-namespaced, the grafts (`AGENTS.md`, `docs/`) read correctly,
and the guide's instructions match what the copy actually contains.

Anything the walk-through contradicts is the finding — the kit or its
guide is corrected, never the walk-through.
