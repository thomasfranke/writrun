---
id: task-0017
status: in-progress
blocked_reason: null
spec_ref: [spec-0014]
doc_ref: product/pipeline.md#flows-and-statuses
priority: medium
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
completed: null
---

# Stop a stale mirror from blocking a task's own

A mirror belongs to the pull request that introduced it. When the
machinery finds a mirror for a task but the current pull request does not
own it, it warns and stops — so the task ends up with no mirror at all,
and nothing ever creates one.

That refusal was the answer to two open pull requests claiming the same
id. `writrun check` now rejects that at the gate, so what is left is the
case the refusal handles badly: a mirror whose introducing pull request
no longer carries the task. It happens by ordinary means — a pull request
closed unmerged and reopened as a new one, or a re-derivation that drops
a task file and leaves the mirror behind. This repository has two such
mirrors right now, for ids no branch holds.

Decide what the machinery should do when the mirror it finds is nobody's,
and make a task's own mirror reachable again. A mirror somebody else
actively owns must still never be adopted.
