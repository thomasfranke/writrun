---
id: task-0068
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0096]
doc_ref: product/stage-3-github-issues/intake.md#submitted-and-not-yet-a-report
origin: rule
priority: high
depends_on: []
milestone: null
created: 2026-09-14T00:30:49Z
queued: 2026-09-14T00:41:35Z
completed: null
merged: null
provenance: []
---

# A submitted observation is marked, and named where work is picked

**References:** [product/stage-3-github-issues/intake.md#submitted-and-not-yet-a-report](../../docs/product/stage-3-github-issues/intake.md#submitted-and-not-yet-a-report) · [spec-0096](../specs/spec-0096-submitted-before-report.md)

`intake.md` now names the state between an issue arriving and a
maintainer labelling it, and says what should happen in it: the
submission carries `writrun:submitted`, and the marked set is named in
the lister beside the open reports it will become. None of that is built
yet.

Two halves, and neither is worth landing without the other — a marker
nobody reads changes nothing, and a reader with nothing marked shows an
empty section. What has to exist: the two submission routes applying the
marker, the lister naming the marked-but-unmirrored set, and the intake
removing the marker when it mints the file.

It matters because the gap has already cost a finding. Issue #155 was
routed here from `writrun-cli` on 2026-09-04, carried no `writrun:`
label ever, and was closed by hand; no report was born from it and its
evidence never left the issue. The defect reached the queue only because
the same thing was seen locally that morning and written down as
`report-0019`. Issue #161 the same day was intaken correctly — the
difference between them is that somebody remembered, and this
methodology already treats memory as the thing not to build on
(`report-0043`).
