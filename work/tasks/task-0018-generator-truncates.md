---
id: task-0018
status: pending
blocked_reason: null
spec_ref: [spec-0015]
doc_ref: technical/README.md#task-schema
priority: high
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
completed: null
---

# The generator's view of open pull requests stops at 100 files

An id is unique across the queue and every open pull request, and the
generator consults the forge to honour it. The question it asks returns
at most 100 files per pull request, silently — so a pull request larger
than that hides every queue file it adds beyond the cut.

This is not hypothetical: it happened while this task was being written.
A 168-file pull request was open, claiming two tasks and two specs, and
the generator saw none of them and minted an id already taken. Twice.

The check that runs in CI reads the same list a page at a time and is
not affected, so a collision is still caught before it merges. The cost
is a renumber late instead of a correct id early — which is most of what
the rule exists to prevent.

Priority is high because the failure is silent and grows with the size
of whatever else is in flight.
