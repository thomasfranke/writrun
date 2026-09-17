---
id: task-0070
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0098]
doc_ref: product/concepts/spec.md#the-doc-delta-contract
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-17T19:41:34Z
queued: null
completed: null
merged: null
provenance: []
---

# The technical section names a chapter under docs/, wherever an author meets it

**References:** [product/concepts/spec.md#the-doc-delta-contract](../../docs/product/concepts/spec.md#the-doc-delta-contract) · [spec-0098](../specs/spec-0098-technical-section-doc.md)


A spec's **Proposed technical changes** section lists the chapters under
`docs/technical/` the completing diff will touch. The contract says so,
and both gates read it that way. Three shipped texts teach a different
reading: the template seeds the section with *"none — no machinery
change"*, the schema's example repeats that fallback beside a
`technical/…` path, and the skill asks for "real entries" with
`path/to/doc.md#anchor` as its only example — never saying the paths
are read relative to `docs/`, nor that the section names the chapters
and not the machinery they describe. An author who follows the word
writes code paths there. The promise gate refuses the branch; or, now
that it tests root-relative shape rather than extension, lets a path
with no repository-root counterpart through, to fail at the completion
gate under a finished branch.

Second, and the same shape one step later: both gates take a bullet
only when a backtick follows the dash. A bullet written as a markdown
link around the path is read as **no entry at all** — the promise gate
answers "nothing to judge" and passes, and the completion gate later
finds every touched document undeclared against an empty promise set.
A promise the gate cannot read is not an absent promise.

What to do: state the section's meaning where the author meets it —
the template's fallback line, the schema's example, the skill's
paragraph — and make the promise gate refuse a non-empty bullet under
either heading that it cannot read as a path, naming it.

It matters because the contract exists to be mechanical, and a
plausible wrong form that passes in silence defeats it at the most
expensive moment. Reported from `writrun-cli` (report-0044, issue
#267): eight specs drafted against the kit, five naming Go packages,
seven sitting on a silent pass until it was found by accident.
