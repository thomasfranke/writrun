---
id: task-0012
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0009]
doc_ref: technical/README.md#task-schema
origin: rule
priority: low
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
queued: 2026-08-28T14:32:41Z
completed: 2026-08-29T17:17:21Z
merged: 2026-08-29T17:24:03Z
provenance: []
---

# Take the subject slug as an argument

**References:** [technical/README.md#task-schema](../../docs/technical/README.md#task-schema) · [spec-0009](../specs/spec-0009-chosen-slug.md)

The convention now says whoever creates a queue file chooses its subject
slug, and that deriving it from the title is only the fallback. The
generator offers no way to pass one.

Give `new.sh` a `--slug`, keep the derivation for when it is absent, and
say in the skill that choosing is the default.
