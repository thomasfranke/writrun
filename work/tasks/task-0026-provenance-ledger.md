---
id: task-0026
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0036]
doc_ref: product/concepts/provenance.md#what-an-entry-holds
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T14:23:35Z
queued: null
completed: null
merged: null
---

# A task records what its work cost and which agent did it

**References:** [product/concepts/provenance.md#what-an-entry-holds](../../docs/product/concepts/provenance.md#what-an-entry-holds) · [spec-0036](../specs/spec-0036-provenance-ledger.md)

A task can say who holds it and nothing about what its work cost. Two
questions a stakeholder is entitled to ask — *what did this feature cost*
and *what share of the work was done by an agent, under whose supervision*
— have no answer in this repository, and the field that looks like one is
not: it clears every time a task returns to the queue, and the login it
carries is the person accountable for the work rather than the agent that
did it.

The docs now describe the record that answers them: an append-only ledger
on the task, one entry per session that worked it, naming the actor, the
specific model when there was one, the counts the platform reported, and
who answers for it. Build it — the field, the settings key that decides
whether a project keeps one at all, and the rollup that turns a quarter of
entries into the two answers above.

The numbers are not hypothetical. An agent platform already records model
and token usage per message and stamps each with the git branch it ran on,
and this methodology's own branch convention puts the task id in that
branch name — so the join already exists, and a report over this
repository's own history returns its tasks with their models and counts
today. What is missing is not the data but a home for it that the
repository actually contains: that history sits in one vendor's directory
on one machine, absent from CI and from every other contributor, and a
methodology whose claim is that the repository answers cannot answer from a
file the repository does not hold. So the entry is written into the task
and the platform's data is what fills it in.

Three boundaries the work is held to. Using an agent is not obligatory: a
task worked by hand records a person's entry and that is a complete record,
not a gap. A project may keep no ledger at all and satisfy every check.
And the ledger decides nothing — it feeds no gate, no priority and no
review, or it becomes the tracker this methodology refuses to be.
