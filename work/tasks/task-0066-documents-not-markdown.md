---
id: task-0066
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0094]
doc_ref: technical/schemas/task.md#task-schema
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-13T23:40:57Z
queued: 2026-09-14T00:02:32Z
completed: null
merged: null
provenance: []
---

# A document under docs/ is one whatever its file format

**References:** [technical/schemas/task.md#task-schema](../../docs/technical/schemas/task.md#task-schema) · [spec-0094](../specs/spec-0094-documents-not-markdown.md)

Two gates read a file's extension as the answer to "is this
documentation", and the answer is wrong. `doc_ref` accepts only a `.md`
path, and a spec's **Proposed changes** promise only `.md` or a folder.
A project whose documentation includes a drawing, a payload shape or a
fixture cannot name one from a task, nor promise one from a spec.

Nothing about that was ever decided. `schemas/task.md` annotates
`doc_ref` as *"any path under `docs/`"*, the kit tells every adopter
*"everything under `docs/` counts as permanent input, shaped however
your stakeholders prefer"*, and the one place `.md` is written down is
decision `0065`, where it stood in for "is this a documentation path at
all" in a discussion entirely about repository-root paths. The proxy
outlived the question it answered.

It matters because the two gates now contradict each other, and a
project that took the kit at its word is caught between them: the
completion gate treats every file under `docs/` as permanent and demands
it be promised, while spec entry refuses the promise. The only way
through is promising the containing folder, which promises nothing about
which of five drawings changed — the loop the Proposed-changes sections
exist to close, left open.

Reported from `writrun-cli`, which holds sixteen screen drawings under
`docs/product/screens/` and derives work from them (report-0041,
issue #252).
