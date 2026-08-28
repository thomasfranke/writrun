---
id: task-0012
status: pending
blocked_reason: null
spec_ref: [spec-0009]
doc_ref: technical/README.md#task-schema
priority: low
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
completed: null
---

# Take the subject slug as an argument

The convention now says whoever creates a queue file chooses its subject
slug, and that deriving it from the title is only the fallback. The
generator offers no way to pass one.

Give `new.sh` a `--slug`, keep the derivation for when it is absent, and
say in the skill that choosing is the default.
