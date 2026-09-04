---
id: task-0043
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0059, spec-0060, spec-0061]
doc_ref: product/concepts/report.md#routing-upstream
origin: rule
priority: medium
depends_on: [task-0042]
milestone: null
created: 2026-09-04T06:25:47Z
queued: 2026-09-04T06:43:14Z
completed: null
merged: null
provenance: []
---

# Ship the cross-repository report channel

**References:** [product/concepts/report.md#routing-upstream](../../docs/product/concepts/report.md#routing-upstream) · [spec-0059](../specs/spec-0059-routed-status.md) · [spec-0060](../specs/spec-0060-report-intake.md) · [spec-0061](../specs/spec-0061-upstream-guidance.md)

The docs now state a channel the machinery does not run. A report can
end `routed` — sent to the repository that owns the defect — and an
issue can become a report on a maintainer's label
([intake](../../docs/product/stage-3-github-issues/intake.md)); today no
checker accepts the status, no workflow answers the label, and the kit
tells an adopter's agent nothing about where a methodology defect goes.

Make the channel real end to end: the fifth report end through the
machinery's vocabulary and the mirror's closes, the intake that turns a
labelled issue into a report file, and the kit's guidance for routing a
WritRun defect upstream with the user's authorization.

Why it matters: adopters are hitting WritRun defects now, and each one
recorded downstream is a finding this queue never sees — the loss the
report concept exists to end, happening one repository over.

Depends on task-0042 because the kit's agent flow lives where that
change puts it; the guidance half of this work lands in that file.
