---
id: report-0042
status: tracked
task_ref: [task-0067]
doc_ref: product/concepts/report.md#routing-upstream
created: 2026-09-13T23:39:56Z
triaged: 2026-09-13T23:41:04Z
---

# The kit does not say a routed issue waits for a maintainer's label

**References:** [product/concepts/report.md#routing-upstream](../../docs/product/concepts/report.md#routing-upstream) · [task-0067](../tasks/task-0067-routed-issue-waits.md)

`concepts/report.md#routing-upstream` states what becomes of a routed
observation: *"the issue waits for a maintainer's label, becomes a report
there, and is triaged by the project that can merge the fix."* The kit
ships no sentence to that effect, so the agent doing the routing never
learns it.

What an adopting agent reads is `kit/.writrun/AGENTS.md`, under *When the
defect is WritRun's*. It ends:

> End the local report `routed`, its body naming the issue it became. A
> refused or unanswerable ask […] leaves the report `open`, where a
> person can route it by hand.

`routed` is the last word, and it reads as arrival. Nothing says the
issue writes nothing upstream until someone with triage rights applies
`writrun:report`, nor that the local `routed` records a *submission*
rather than an entry in the upstream queue.

The chapter that would say it is not in the kit: `kit/docs/` carries
three files — `product/README.md`, `technical/README.md` and
`writrun-instructions.md` — and none of them is `concepts/report.md`.

## Evidence

Observed on issue #252 of this repository, now `report-0041`. An agent in
`thomasfranke/writrun-cli` routed a methodology defect upstream and did
it correctly: the title states the observation, the body carries the
evidence and `v0.0.07` from `.writrun/VERSION`, and it reproduced the
three headings of `.github/ISSUE_TEMPLATE/writrun-report.yml` without
being asked to. Every instruction the kit gives was followed.

The issue then sat unlabelled from `2026-09-13T23:23:53Z` until a human
opened the link by hand and asked what it was — at which point the label
minted the report in twelve seconds. Nothing in between was wrong; the
instruction simply stops one step before the reader needs it.

Its local counterpart, `report-0038` on `writrun-cli`, is not on that
project's `main` — it lives on the branch of its PR #129, still open. The
issue links it at `blob/main/…`, which answers 404. Recorded here as part
of the same observation, not as a second one.

**Triage:** tracked → task-0067. The rule exists and the shipped copy
omits it, so this is a defect rather than a question — what the kit
should say is already written in `concepts/report.md#routing-upstream`,
and the work is carrying it across the mirror boundary.
