# Report

**The front matter and body shape of a report file**, and the routes its status records. One chapter of [`schemas/`](README.md).

## Report schema

```yaml
---
id: report-0001
status: open                       # open | tracked | authored | fixed | declined | routed
task_ref: []                       # the tasks triage produced; a list, always
doc_ref: null                      # the doc violated, or the doc the rule was written into
created: 2026-09-01T20:23:51Z
triaged: null                      # when triage decided; null while open
---
```

The shape above is
[`report-0001`](../../../work/reports/report-0001-conventions-scope.md), the
first one recorded here — the block is read against the same checker the
real files pass through, so a schema this chapter shows and a schema the
machinery accepts cannot part company.

A report file is named `report-NNNN-<subject>.md`, the same shape as a
task's and a spec's. Its id is minted by the same generator over the
same four views — the directory, the git history, every open pull
request, and every mirror the forge holds — and is never reused. The
fourth is the one that answers for a number whose file left with the
branch that made it
([0070](../decisions/tasks-and-specs/0070-the-mirror-is-the-fourth-view.md)).

`status` is the **route triage took**, not a lifecycle. `open` is the
only non-terminal value; the five others are the ways a report ends, and
they are the triage table's outcomes
([report](../../product/concepts/report.md#statuses--the-route-not-a-lifecycle)).
There is no `resolved`: whether the underlying work is done is the
task's status, reachable through `task_ref`, and a second copy of that
fact would need a second writer to stay true.

`routed` pairs with `triaged` exactly as the other four ends do — the
date is when the judgement was made — and what names its outcome is the
**upstream issue, in the body**: the report was sent to the repository
that owns the defect, so no field here can point at it, the way
`declined` keeps its reason in prose. `task_ref` stays empty on a
`routed` report — a task named here would claim work this queue never
gained — and the checker refuses one that is not. `doc_ref` is allowed
and rare: the doc that states the consumed thing's behaviour, when one
exists ([routing upstream](../../product/concepts/report.md#routing-upstream)).

`task_ref` is a list even with one element, like `spec_ref` — and it is
the **only** link between the two kinds. The task schema is unchanged:
nothing on a task points back at the report that produced it, and
finding that is a scan of `work/reports/`, which costs a grep and
touches no contract.

`doc_ref` is a path relative to `docs/` with an anchor, exactly as a
task's is. One fact under both routes — **the doc this observation is
answered by** — which reads as the violated rule for `tracked`, and as
the rule that had to be written for `authored`. Those are the same
sentence read before and after the rule existed, not two fields sharing
a name. It stays `null` when nothing documents the thing observed, which
is the common case for `fixed`: a typo violates no rule, and a report
that ends `fixed` usually names no doc at all. `declined` may name the
doc that says the behaviour was never a defect, and is otherwise `null`.

At Stage 3 a report is mirrored like a task — `writrun:report`, titled
`[REPORT-NNNN]`, `status:open` until triage closes it
([labels](../../product/stage-3-github-issues/labels.md#the-report-mirror)).
A pull request title never carries a `[REPORT-NNNN]` tag: that bracket
is how the machinery reads which tasks a pull request carries.

**The status line's writer is a human or an agent, at every stage.**
This is the one place `work/` departs from the task queue, whose status
line from Stage 2 has exactly one writer and it is the machinery — no
forge event corresponds to a judgement
([0064](../decisions/tasks-and-specs/0064-a-report-is-an-artefact.md)).

