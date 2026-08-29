---
id: task-0013
status: completed
blocked_reason: null
spec_ref: [spec-0010]
doc_ref: technical/README.md#task-schema
priority: high
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
queued: 2026-08-28T14:37:44Z
completed: 2026-08-28T00:00:00Z
merged: 2026-08-28T20:14:25Z
---

# Keep queue ids unique across open pull requests

The schema now says an id is unique across the queue and every open pull
request. The generator mints from one branch's view, so two branches cut
from the same `main` claim the same number — which has already happened
here — and nothing rejects it at merge.

Teach the generator to look at open pull requests, and `writrun check`
to refuse an id somebody else already claims.

Priority is high because the cost lands on whoever merges second, after
the work is done, and grows with how many changes are in flight.
