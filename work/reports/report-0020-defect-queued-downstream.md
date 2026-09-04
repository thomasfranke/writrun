---
id: report-0020
status: authored
task_ref: []
doc_ref: product/concepts/report.md#routing-upstream
created: 2026-09-04T06:25:22Z
triaged: 2026-09-04T06:26:30Z
---

# An adopter's WritRun defect was recorded in the adopter's own queue

**References:** [product/concepts/report.md#routing-upstream](../../docs/product/concepts/report.md#routing-upstream)

A project implementing WritRun hit a defect in WritRun itself, and the
session recorded the report in the consuming project's own
`work/reports/` — a queue whose triage cannot act on a methodology
defect, and one no WritRun maintainer reads. The finding is waiting
where nobody who can fix it will ever be prompted to look.

The agent followed the only instruction it had: the kit's recording
section names exactly one destination, the local `work/reports/`, and
no file the kit ships says where a defect of the methodology itself
goes. The concept side matches — `concepts/report.md` triages every
report to an end inside the same repository.

**Triage:** no rule said where an upstream defect goes; the rule was
written — `routed`, and the intake that receives it — in the change
this report rides.
