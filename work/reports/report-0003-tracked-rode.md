---
id: report-0003
status: authored
task_ref: []
doc_ref: product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not
created: 2026-09-02T01:28:18Z
triaged: 2026-09-02T01:28:18Z
---

# The tracked route rode a pull request and skipped its evaluation

**References:** [product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not](../../docs/product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not)

Observed on the merge of #94, in two Issue numbers side by side.
`report-0001` landed `open` and became **#96, an open Issue** wearing
`status:open` — recorded, visibly awaiting evaluation. `report-0002`
rode the same implementing pull request *already* `tracked`:
**#97 was born closed**, and `task-0032` entered the queue as
`status:ready` (**#95**) the moment the merge landed.

The difference between the two is the finding. For `report-0002`, the
question the open Issue exists to pose — *does this finding deserve
work?* — was never asked anywhere the flow could see it. The task
arrived `ready` with the same standing as one whose spec a human had
assented to, yet no act of assent had it as its subject: the merge that
carried it was about TASK-0031, and the report's triage was a passenger
nobody had to notice.

No rule stated where triage may land, so this was a gap, not a
violation. The `docs/` change this report rides writes the rule: the
recording exemption covers `open`, `fixed` and `declined` — the shapes
that create no work — and the `tracked` route always travels through a
reporting pull request of its own, whose squash-merge is the merit
assent.

`task-0032` itself stands: its merit was judged in session, by the
maintainer, in words — the gap was in the flow, not in that judgement.
