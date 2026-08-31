# Provenance

A task records **who did its work, and what that work cost**. That record is
the *provenance ledger*: a list of entries on the task itself, added as the
work happens and never rewritten. It answers two questions a
[task](task.md)'s other fields cannot — *what did this cost* and *what share
of it was done by an agent, under whose supervision*.

It is a record and nothing more. It reserves nothing, scores nobody, and
gates no decision.

## Two actors, and neither is the default

An entry names one of two actors: a **person** or an **agent**. Using an
agent is never assumed and never required — a task worked entirely by hand
records a person's entry with no model and no cost, and that is a **complete
record, not a missing one**. No check may read the absence of an agent entry
as a gap.

That symmetry is the whole reason the ledger can answer a question about
proportion. A share done by agents means something only because the share
done by people is written down beside it.

## Why the field naming the worker is not this record

A task already names whoever currently holds it, and that field is not a
ledger, for two reasons that no amount of reinterpretation fixes:

- **It is cleared, by design.** It empties every time a task returns to the
  queue — a pull request closed unmerged, a merge that carried some of the
  work but not its finish. A record that erases itself cannot be summed over
  a quarter.
- **It names the accountable person, not the worker.** On agent-driven work
  it carries the login of whoever opened the pull request — the human who
  ran the agent and answers for the result.

So that field answers the *supervision* half exactly, and can never answer
the *which agent* half. The ledger does not replace it; it records what the
other field was never holding.

## What an entry holds

Four things, and each earns its place by being a fact somebody can check:

- **The actor** — a person or an agent.
- **Which agent**, when it is one. Not "an AI" but the specific model, so
  the record survives the next model's arrival.
- **What it cost**, when there is a cost. Kept as the counts the platform
  reported, not as a converted sum of money — prices change, and a stored
  currency figure quietly becomes a lie about the past while stored counts
  stay true.
- **Who is accountable** — the person answering for the work, agent or not.

One task carries many entries, because one task is worked by many sessions,
sometimes several models, and sometimes several people. Entries accumulate;
an entry is never edited once written, and resumed work adds to the list
rather than replacing it.

## The commits carry the other half

Where a project has its agents credit themselves, each commit an agent
writes already names the model that helped write it. That is the second half
of the same record, and it needs no ledger: the commit history answers *what
share of the commits an agent worked on* directly, and keeps answering it in
any repository, on any agent platform.

The two halves are separate on purpose, and a project may run either without
the other. Credit in the commits is about what the history says. The ledger
is about what the queue says. Turning one off never silently turns off the
other.

## What this record does not claim

**It does not say what fraction of the code an agent wrote.** Agent-driven
work is reviewed, edited, and squashed by a person before it lands;
attributing lines after that is invention, and a precise-looking number
nobody can defend is worse for a stakeholder than an honest coarse one. The
ledger reports work and spend per task, and the commits report participation.
Neither is a line count, and no chapter here promises one.

It is also not a budget, an alert, or a gate. Nothing in it stops work,
warns anyone, or feeds a review. WritRun is
[not a project management tool](../../about.md), and this record does not
make it one: the repository answers when it is asked, from what was already
written down — the same way the history of status changes already yields
lead time without anyone tracking it.

## The adopter decides whether to keep it

The ledger is a **declared variant**, not part of the mandatory core
([Adoption](../adoption.md#mandatory-core-vs-documented-variant)). A project
states in its settings whether it keeps one, and a project that keeps none
records nothing and satisfies every check — the same as a project that uses
no agents at all.

A project that does keep one is making a commitment worth naming: the
accounting is only as true as the entries, and an entry nobody writes is a
task the quarter's answer silently omits.
