---
id: task-0021
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0026, spec-0027]
doc_ref: product/adoption.md#three-stages
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T02:47:35Z
queued: null
completed: null
merged: null
---

# Move the agent's commit conduct and the status machinery's pointers to Stage 2

The docs now state that git begins at Stage 2: Stage 1 is the queue as
files and nothing else — tasks and specs generated from the docs,
statuses moved by hand, no forge and no git assumed. Two pieces of the
machinery still say otherwise. The settings file keeps the adopter's
word on the agent's commit conduct in a Stage 1 section, telling every
reader that commits belong to the entry stage. And the scripts,
workflows and skills that implement the status machinery still point
readers at the Stage 1 chapter for a projection that now lives in the
Stage 2 chapter.

Bring both up to the rule: the conduct flags live where commits begin,
and every machinery pointer names the chapter that actually holds the
status projection.
