---
id: task-0074
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0102]
doc_ref: product/stage-3-github-issues/labels.md#the-report-mirror
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-18T17:12:19Z
queued: 2026-09-18T17:29:05Z
completed: null
merged: null
provenance: []
---

# A report's mirror closes on the merge that lands its triage, never on the diff that proposes it

**References:** [product/stage-3-github-issues/labels.md#the-report-mirror](../../docs/product/stage-3-github-issues/labels.md#the-report-mirror) · [spec-0102](../specs/spec-0102-mirror-waits-for-merge.md)

The one state a report's mirror exists for is `open` — the Issue that
prompts somebody to read a report before it rots. That state goes
missing for as long as a pull request proposing the triage stays open:
the mirror closes the moment a diff carries a terminal status, and the
merge that makes the status true has not happened yet.

The two channels then disagree. The lister, reading the authority
branch, lists the report under *Open reports*; the forge shows its
Issue closed and out of the pipeline. Issues #268 and #269 — the
mirrors of report-0045 and report-0046 — closed *completed*
twenty-two seconds after the pull requests triaging them opened, and
stayed closed while those sat in review.

The same window is already answered twice. A task proposed by an open
pull request is mirrored as proposed, and nothing closes before the
merge; a report *born* in a diff is mirrored the same way. Only a
report whose **triage** is in flight is answered differently, and
nothing says why.

What to do: while a pull request only proposes a triage, hold the
report's mirror at what the authority branch says, and let the merge
that lands the status close it. State the rule where the mirror's
states are defined — the table there covers a report's birth and is
silent on its triage.

It matters because the window the mirror goes missing in is exactly
the one where a maintainer is reviewing the triage that closed it, and
because it is bounded by nothing: a pull request left open neither
merges nor closes, and only a close reconciles the mirror back.
