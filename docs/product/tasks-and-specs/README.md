# Tasks and specs

```
       authoring
docs (human) → task (request) → spec (elaboration) → code (derived)
      ↑                                                    │
      └──────────── loop closure, same change ─────────────┘
```

Permanent documentation is written by a human, with human review. Everything
downstream of it is derived: the queue mechanics are agent work, and the
implementation goes to whoever takes the task — a developer or an agent,
same flow (flows 3 and 4). All of it is gated at specific, named points — never
gated by implication, never left to whoever is doing the work that day to
decide whether a checkpoint applies.

It is a loop, not a line. The last step feeds the first: a completed change
updates the permanent docs it was derived from, in the same change that
ships the behaviour. A pipeline that only runs forward produces docs that
were true once.

## The flow

1. **Docs** — [a product doc](../concepts/product-doc.md) or [a technical
   doc](../concepts/technical-doc.md) states what should be true. These two are
   the input the rest of the pipeline works from, not a record of what was
   already built. Writing a rule here is **authoring**, described below.
   [About](../concepts/about.md) sits alongside them as the shared context
   every reader starts from — it is permanent, and a change to it goes
   through this same pipeline, but no task originates from it: About says
   what the project *is*, and work originates from what the system *does*
   or *how it is built*.
2. **Task** — an agent (or a human) that finds work not yet tracked creates
   its [task](../concepts/task.md) first. A task never follows its own spec
   into existence.
3. **Spec** — a [spec](../concepts/spec.md) elaborates one task: scope, steps,
   acceptance criteria, and the Proposed-changes contract that names every
   permanent doc the completed work will touch.
4. **Code** — the derived artefact. It exists because a doc authorized it
   and a spec bounded it — never the other way around, and never without
   either.
5. **Back to the docs** — the same change that ships the code updates every
   permanent doc the spec's Proposed-changes sections named, and no other.
   This is **loop closure**, and it is the step that stops the input from
   going stale: without it, step 1 describes a system that no longer
   exists. Mechanically checked, not remembered — see
   [`writrun-check-spec-deltas`](../../../.writrun/skills/writrun-check-spec-deltas/SKILL.md).

## The flows are the source of truth for the mechanics

How the pipeline actually runs — step by step, with every actor named — is
the flows, and the human gates sit where the flows draw them: a rule
declared finished (flow 1), a spec assented to by the maintainer (flow 2),
every merge a maintainer performs (flows 2 and 5). Behind them all, a
permanent doc never merges on agent approval alone; the gates are named in
full in [`gates.md`](gates.md).

Flows 1–5 are the happy path — flow 1 drawn in
[`authoring.md`](authoring.md), flows 2–5 in
[`../pull-requests/`](../pull-requests/README.md). In the flow diagrams,
each node names who acts; only the human ones are decisions. The edge
cases reality produces are drawn separately — same gates — in
[`conflicts.md`](conflicts.md) and, at level `pull-requests`, in
[`review.md`](../pull-requests/review.md).

## This folder

True at **every level**. What the higher levels add lives beside it.

| File | Covers |
|---|---|
| [`statuses.md`](statuses.md) | task and spec status vocabularies, the four dates, what authorizes a task |
| [`authoring.md`](authoring.md) | flow 1, the two directions a permanent doc changes, declaring derived work, work found mid-flight |
| [`gates.md`](gates.md) | the four human gates |
| [`conflicts.md`](conflicts.md) | a spec amended after approval, a doc that moves ahead of the queue, a task blocked from outside |

| Level | Adds |
|---|---|
| [`pull-requests/`](../pull-requests/README.md) | branches, pull requests, CI, merge as assent |
| [`github-issues/`](../github-issues/README.md) | the GitHub Issues mirror |
