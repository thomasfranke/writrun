---
id: task-0035
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0051]
doc_ref: product/concepts/spec.md#the-doc-delta-contract
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-02T18:52:17Z
queued: null
completed: null
merged: null
provenance: []
---

# A promised path resolves where the spec is written

**References:** [product/concepts/spec.md#the-doc-delta-contract](../../docs/product/concepts/spec.md#the-doc-delta-contract) · [spec-0051](../specs/spec-0051-promise-resolves.md)

A path in either **Proposed changes** section is read relative to
`docs/` — the schema says so, and `check_deltas.sh` prefixes every
bullet with it. A spec that writes a repository-root path instead
promises something no diff can ever touch, and nothing says so until the
completion gate runs against a finished branch.

That has now happened twice, and both times the fix arrived at the
expensive end. `spec-0041` promised the decision file without its index
and was refused on #83, costing an amendment under an open pull request
with the task suspended. `spec-0044` promised five repository-root paths
— every one of them normalising to a `docs/…` path that does not exist —
and was caught only because a person read
[report-0005](../reports/report-0005-delta-doc-paths.md), by no check at
all.

The rule this violates is already written: a promise is refused **where
the spec enters**, at creation or amendment, where fixing it is one
edit. `check_promise_companions.sh` is that gate and holds exactly one
named pair; it says nothing about whether a promised path resolves at
all. Extend the early gate to read that — so the two instances above
would have been refused at the spec, not at the branch.

One judgement the spec must settle rather than assume: a spec
legitimately promises a doc its own change creates, so "resolves" cannot
simply mean "the file exists today".
