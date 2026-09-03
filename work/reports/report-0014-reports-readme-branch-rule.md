---
id: report-0014
status: open
task_ref: []
doc_ref: product/concepts/report.md
created: 2026-09-03T04:38:06Z
triaged: null
---

# The queue's own reports README misstates when a report branch is needed

**References:** [product/concepts/report.md](../../docs/product/concepts/report.md)

`work/reports/README.md` — this repository's own — tells an agent that
the `report/` prefix "is for a change that carries *only* reporting".
The concept says something narrower: recording rides whatever change is
already open, and the branch belongs to the `tracked` route alone,
because that is the route that puts work in the queue and needs its own
assent (`docs/product/concepts/report.md`, and the root `AGENTS.md`'s
"Except the `tracked` route, which never rides").

An agent reading the README literally would open a `report/` branch to
record a `fixed` or a `declined` — the cost the concept exists to avoid.

The kit's copy, added by task-0039, states the narrower rule correctly;
the root file it was modelled on did not get the same pass. Noticed while
diffing the two.
