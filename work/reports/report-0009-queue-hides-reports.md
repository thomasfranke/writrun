---
id: report-0009
status: open
task_ref: []
doc_ref: technical/selection.md#task-selection-algorithm
created: 2026-09-02T18:57:16Z
triaged: null
---

# An empty task queue reads as no work while reports wait

**References:** [technical/selection.md#task-selection-algorithm](../../docs/technical/selection.md#task-selection-algorithm)

`list_tasks.sh` printed `Nothing is available.` and exited 1 with every
task `done` — while four reports sat `open`: 0001, 0006, 0007, 0008.
Nothing in the session's entry path named them. They were found by
listing `work/reports/` by hand.

The lister reading only `work/tasks/` is deliberate and documented
(`work/reports/README.md`: "Do not select work from this directory").
The observation is not about that boundary. It is that the two facts —
"no task is available" and "four findings are waiting to be evaluated" —
are never brought together anywhere a session looks. `AGENTS.md` covers
the neighbouring case in prose, telling a session that finds every task
held back to say so rather than report an empty queue; the empty-queue-
with-open-reports case has no such sentence, and the empty queue is the
state a finished milestone leaves behind.

At Stage 3 the open Issues carry the ask, which is where the concept
places it. Below that stage, and for an agent session that reads the
repository rather than the forge, `open` is a state that asks something
of a person through a channel the session does not read.

Observed while triaging report-0006, on the first run through the
`tracked` route. Not investigated: whether the answer is the lister
naming the count, `AGENTS.md` gaining the sentence, or nothing at all
because Stage 3's mirror is the intended channel.