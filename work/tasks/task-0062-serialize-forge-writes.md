---
id: task-0062
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0088]
doc_ref: null
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-06T05:16:31Z
queued: 2026-09-06T05:28:53Z
completed: null
merged: null
provenance: []
---

# Concurrent forge events stop minting duplicate mirrors

**References:** [spec-0088](../specs/spec-0088-serialized-writers.md)

Make one pull request's forge-writing passes run one at a time, and
make the mirror reconciler treat a duplicate it meets as its own to
retire. Today two events one second apart — a push and the ready flip
that routinely follows it in an agent's flow — run the mirror pass
twice concurrently, each run misses the other's mint, and the tracker
gains two issues for one record. Nothing ever cleans the loser up.

It matters because the mirror exists to be the queue a person trusts
in a browser, and a duplicate is a lie in that view — two issues, two
statuses, one record. The same unserialized shape sits under the
progress pass, where the writes are queue statuses rather than
mirrors, so the window is not only cosmetic. Observed live as #234
and #235 (report-0038).
