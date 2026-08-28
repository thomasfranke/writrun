---
id: task-0015
status: pending
blocked_reason: null
spec_ref: [spec-0012]
doc_ref: technical/README.md#task-schema
priority: medium
depends_on: []
milestone: null
created: 2026-08-28
completed: null
---

# Check that a doc_ref resolves

`check_front_matter.sh` validates a `doc_ref`'s shape — under `docs/`,
a `.md` path, optional anchor — and never checks that the file is there.
A task can point at a doc that does not exist and every check passes.

Splitting `pipeline.md` into folders is what exposed it: five tasks
pointed into a file that stopped existing, and nothing would have said so.
They were repointed by hand, which is exactly the step a check should make
unnecessary.
