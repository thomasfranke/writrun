---
id: task-0013
status: in-progress
blocked_reason: null
spec_ref: [spec-0010]
doc_ref: technical/README.md#task-schema
priority: high
depends_on: []
milestone: null
created: 2026-08-28
completed: null
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
