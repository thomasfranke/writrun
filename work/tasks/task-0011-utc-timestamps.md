---
id: task-0011
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0008]
doc_ref: technical/README.md#front-matter-is-canonical
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
queued: 2026-08-28T14:28:08Z
completed: 2026-08-28T21:14:19Z
merged: 2026-08-28T21:23:57Z
provenance: []
---

# Record queue dates as UTC timestamps

**References:** [technical/README.md#front-matter-is-canonical](../../docs/technical/README.md#front-matter-is-canonical) · [spec-0008](../specs/spec-0008-utc-timestamps.md)

The schema now says every queue date is an RFC 3339 UTC timestamp spelled
with `Z`. The generator still writes bare dates, the canonical check
still accepts only bare dates, and every file in the queue holds one.

Move the generator, the check, and the queue itself to the new shape.
