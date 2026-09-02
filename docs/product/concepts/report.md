# Report

**What was observed.** A bug someone hit, a gap an agent found, a
"that's wrong but not now" noticed halfway through unrelated work. One
file per report in [`work/reports/`](../../../work/reports/README.md),
named by id plus a tiny subject slug (`report-0003-mirror-lag.md`),
never renamed, never moved.

A report is the cheapest thing this methodology asks anyone to write,
and that is deliberate. Everything else in `work/` is a commitment — a
task says work will happen, a spec says how. **A report commits to
nothing.** It says only that something was seen, and that seeing it was
worth a file.

## Two invariants

- **A report is never worked.** It is *triaged*, and triage ends it. What
  gets worked is the task triage produced, if it produced one.
- **A report records; a task plans.** The moment a report starts
  carrying scope, steps or a plan, it has become a task wearing the
  wrong front matter — and `work/` has grown a second queue nobody
  selects from.

## What earns a report

Anything you would otherwise mention in a conversation and lose. The bar
is far below a task's on purpose: a task needs work that justifies
tracking, a report needs only an observation that justifies remembering.

The bar it does have: a report states what was **observed**, not what
should be done about it. "The mirror shows `backlog` for four tasks
`main` holds as `ready`" is a report. "Fix the mirror to read the merged
ref" is a task with no task file.

## Statuses — the route, not a lifecycle

A report has one non-terminal state and four ends, and the four are the
routes [triage](../stage-1-tasks-and-specs/authoring.md#reporting--work-found-or-reported-mid-flight)
can take:

| Status | Means | What names the outcome |
|---|---|---|
| `open` | recorded, not yet triaged | — |
| `tracked` | a task now carries the work | `task_ref` |
| `authored` | no rule stated what "correct" was; a rule was written | `doc_ref` |
| `fixed` | a trivial change handled it | the git history |
| `declined` | not a defect, or not worth acting on | the body says why |

**There is no `resolved`, and the omission is the design.** Whether the
underlying problem is fixed is the *task's* status, one hop away through
`task_ref`. Copying it here would put one fact under two writers, and
the copy would start drifting the day someone updated one of them. What
a report knows and nothing else does is which of the four ends above it
came to rest on.

A report is never reopened. The same thing happening again is a second
observation, so it is a second report — ids are never reused, and a
recurrence that shares a file loses the date of the first sighting.

### Declining is the agent's, and is reversible by a second report

`declined` is the one end that produces nothing, and it is still the
agent's to write without asking — triage is not a human gate
([gates](../stage-1-tasks-and-specs/gates.md)). What makes that safe is
that declining destroys nothing: the file stays, the body carries the
reason, and at Stage 3 the mirror closes as *not planned*, which is
where a person sees the judgement and can disagree with it.

Disagreeing does not reopen the report — nothing reopens one. It records
a second one, or writes the task the first should have produced. The
first report keeps its date and its reasoning, which is what makes the
disagreement legible later.

**Who writes the status is a human or an agent, always.** This is the
one place `work/` differs from the task queue, where from Stage 2 the
status line has exactly one writer and it is the machinery. No forge
event corresponds to "this was triaged": the judgement is the point, and
a merge cannot make it.

## The mirror shows what is waiting

At [Stage 3](../stage-3-github-issues/labels.md#the-report-mirror) a
report appears in GitHub Issues as `[REPORT-NNNN]`, beside the task
mirrors, carrying `writrun:report` and `status:open`. Triage closes it —
completed when it was acted on, not planned when it was `declined`.

This is not decoration. `open` is the one state that asks something of a
person, and a file nobody is prompted to open is a file that rots, which
would leave this concept worse than the conversation it replaced.

**The mirror is one channel and not the only one.** At every stage, the
task lister names every report still `open` in a section of its own —
so the ask reaches the session picking work, which is the reader most
likely to act on it, without waiting for anyone to remember a `grep`.
Naming is not selecting: an open report enters no ordering and moves no
exit code, and what the section asks for is triage
([selection](../../technical/selection.md#an-open-report-is-named-never-selected)).

What the open Issue asks for is the **evaluation**, never the fix: read
the report, choose its route. Work enters the queue only when the
`tracked` route's own pull request is merged — the section below draws
the line.

## Recording rides any change — routing to the queue does not

A report may be added in **any** change — an implementing branch, an
authoring branch, a branch that is mostly about something else. The
one-kind-per-change rule does not reach it.

That is an exemption, and it is the reason the feature works at all.
Findings arrive while you are busy with something else; that is what
makes them findings. A note that costs its own branch, its own pull
request and its own review is a note nobody writes, and the observation
goes back to being lost in a conversation — which is the state this
concept exists to end.

**The exemption covers what creates no work.** Recording (`open`) rides,
and so do the three ends that leave the queue untouched: `authored`,
whose outcome is the rule the change it rides writes, `fixed`, whose
whole outcome is the change it rides, and `declined`, which produces
nothing and closes the mirror where a person can see the judgement and
disagree with it.

**The `tracked` route never rides.** It is the one route that puts work
in the queue, and what enters the queue passes a gate: deriving a task
from a report is a reporting change on its own `report/` branch, whose
pull request presents the report, the task and the spec together — and
the maintainer's squash-merge of *that* pull request is the assent that
the finding deserves the work
([authoring](../stage-1-tasks-and-specs/authoring.md#reporting--work-found-or-reported-mid-flight)).
A `tracked` flip riding an unrelated pull request would mint a task that
arrives `ready` at merge with nobody ever having weighed it: the mirror
is born closed, the queue gains an item, and the evaluation the open
Issue exists to invite has silently never happened.

## Example

```markdown
---
id: report-0003
status: tracked
task_ref: [task-0031]
doc_ref: product/stage-3-github-issues/labels.md#criteria
created: 2026-09-01T14:02:11Z
triaged: 2026-09-01T14:40:03Z
---

# The mirror shows backlog for tasks main holds as ready

Four Issues right now — #66, #67, #70, #71 — carry `status:backlog`
while the authority branch has those tasks `ready`, every spec they
reference `approved`.

Noticed while working task-0026; not investigated further. `labels.md`
already states the behaviour that is missing, so this is a defect
against a documented rule rather than a question about what should
happen.

**Triage:** defect against `labels.md#criteria` → task-0031.
```
