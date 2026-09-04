---
id: task-0046
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0065]
doc_ref: product/stage-3-github-issues/labels.md#criteria
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-04T15:22:24Z
queued: 2026-09-04T16:30:18Z
completed: null
merged: null
provenance: []
---

# Make the label pass see the mirrors its own job just minted

**References:** [product/stage-3-github-issues/labels.md#criteria](../../docs/product/stage-3-github-issues/labels.md#criteria) · [spec-0065](../specs/spec-0065-rederive-snapshot.md)

`rederive_labels.sh` reads the mirror list once, at startup, and answers
every id in the run from that one snapshot. When the same job minted
those mirrors seconds earlier, the snapshot does not hold them yet: six
task mirrors on `writrun-cli` were created, reported `no mirrored
Issue.`, and left with no `status:` label at all. The workflow reported
success.

The cut in what the snapshot saw follows creation order exactly, and the
last id in the argument list — processed nine seconds after the failures
— succeeded, because its visibility had been decided at snapshot time
rather than at processing time. The ids were all passed correctly; the
read was early.

Make the lookup survive a mirror younger than the snapshot, and make the
failure loud where it cannot be true: an id this job minted has a
mirror by construction, so reporting it missing is a defect and not a
finding.

Why it matters: `labels.md` already states that a recording commit
re-labels the mirror from the queue as it then stands. Minted and never
labelled is the one outcome with no second event to correct it — the
comment in `writrun-approve.yml` says so, and guards a different path to
it. Nothing comes back for these mirrors, so a silent miss is permanent
drift between the queue and what a person reads in Issues.
