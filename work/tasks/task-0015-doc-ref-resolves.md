---
id: task-0015
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0012]
doc_ref: technical/README.md#task-schema
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-28T00:00:00Z
queued: 2026-08-29T18:51:36Z
completed: 2026-08-29T19:14:39Z
merged: 2026-08-29T21:00:41Z
---

# Check that a doc_ref resolves

**References:** [technical/README.md#task-schema](../../docs/technical/README.md#task-schema) · [spec-0012](../specs/spec-0012-doc-ref-resolves.md)

`check_front_matter.sh` validates a `doc_ref`'s shape — under `docs/`,
a `.md` path, optional anchor — and never checks that the file is there.
A task can point at a doc that does not exist and every check passes.

Splitting `pipeline.md` into folders is what exposed it: five tasks
pointed into a file that stopped existing, and nothing would have said so.
They were repointed by hand, which is exactly the step a check should make
unnecessary.
