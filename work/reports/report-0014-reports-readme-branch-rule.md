---
id: report-0014
status: fixed
task_ref: []
doc_ref: product/concepts/report.md
created: 2026-09-03T04:38:06Z
triaged: 2026-09-03T06:52:00Z
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

**Triage:** fixed, riding the change that was being reviewed when it was
found. The sentence now says what `concepts/report.md` says — the
`report/` prefix belongs to the `tracked` route alone, and the three
ends that create no work ride like the recording does.

`fixed` rather than `authored`: no rule was missing. The concept states
the rule, `AGENTS.md` states it, and the kit's copy — written in this
same change — states it correctly. One file disagreed with all three,
which is a defect against a written rule and, at one sentence, trivial
work: a typo is a commit.
