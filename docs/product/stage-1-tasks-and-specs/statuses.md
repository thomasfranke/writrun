# Statuses, dates and what they mean

**Statuses.** These values and no others.

| | Values | Moved by |
|---|---|---|
| Task | `backlog` → `ready` → `in-progress` → `in-review` → `done` | at Stage 1, a person or an agent, by hand, deliberately; from Stage 2 up, [the machinery, from forge events](../stage-2-pull-requests/statuses.md) — never by hand |
| Task | `blocked` (needs `blocked_reason`), from and back to `backlog` or `ready` | a person, at every stage — no event knows *why* work cannot proceed |
| Task | `dropped` — terminal | a person, at every stage — no event knows a task will never happen |
| Spec | `draft` → `approved` → `implemented` | `approved` by a human only; the rest by whoever does the work |

The five working states carry the vocabulary the wider community
already reads — the same columns GitHub Projects, Linear and Jira
converge on — so a contributor arriving from any tracker knows where a
task stands without learning a dialect.

**What each move means is the same at every stage; what changes is who
writes it.** At Stage 1 there is no machinery: whoever does the work
moves the status line, at the moment the thing it records happens — a
task moves to `ready` when its every spec is `approved` (or it
references none), to `in-progress` when someone starts it, to
`in-review` when the work is handed over for review, to `done` when the
work is taken. Each move is a deliberate act, and the four
[human gates](gates.md) still stand behind the two that need one. From
Stage 2 up, the same moves are written by the machinery, from forge
events, and a hand move between the working states becomes a violation
— that contract has [its own chapter](../stage-2-pull-requests/statuses.md).

`blocked` and `dropped` are the two human exceptions at every stage,
for the same reason in both directions: no event — a hand move or a
forge's — can report that the world outside the queue has stalled a
task or killed it. `blocked` names its reason and waits for a person to
release it; `dropped` is terminal — the queue's honest word for *this
will not happen*, so the file stops shadowing the backlog forever.

The worker declares finishing — that is what the hand-written
`completed` date *is*, at every stage. A task is never silently assumed
finished; the declaration is a recorded act.

**Who took it is recorded, never reserved.** The task's `taken_by`
field carries the login of whoever is working the task. It is a record,
never an assignment: WritRun's own non-goals rule out reserving work,
so the field reports and entitles nobody. At Stage 1 the worker writes
it when they start and clears it if they stop; from Stage 2 up the
machinery owns it, exactly as it owns the status line.

**It is a pointer, not a history.** Because it clears every time the task
returns to the queue, it cannot say what the work cost or which agent did
it — that is the [provenance ledger](../concepts/provenance.md)'s record,
kept only by a project that declares one.

**Dates.** A task carries four, and **who writes each is part of the
contract** — not a convention anyone may bend.

| Field | Records | Written by |
|---|---|---|
| `created` | the task was drafted | a person, by hand |
| `queued` | the merge that brought it into the queue | the machinery, from Stage 2 up; at Stage 1 it stays `null` |
| `completed` | its work was finished | a person, by hand |
| `merged` | the merge that took its work | the machinery, from Stage 2 up; at Stage 1 it stays `null` |

The split is not decoration. **A hand-written date cannot honestly record
a merge**: it would have to be typed before the event it claims to
describe, and would be wrong by however long review takes. So the two
halves answer different questions and neither substitutes for the other —
`completed` is when the worker finished, `merged` is when the project
took it. At Stage 1 the machinery's two stay `null`, and that is not a
gap: the events they record are forge events, and without a forge there
is no event to record. Where everything merges the same day, `completed`
and `merged` coincide; anywhere else the gap between them *is* the
review.

And four is the number — **no date per transition.** What a task was
doing between its dates is the queue's history to answer, not extra
schema fields: from Stage 2 up every status flip is a commit, and even
at Stage 1 the file's own history holds the timeline for whoever keeps
one. A schema field that restates history is bloat, and this sentence
exists so nobody adds one.

**A task in the queue is authorized by the act that put it there.** At
Stage 1 that act is the human review the [gates](gates.md) require;
from Stage 2 up it is [the merge of the pull request that creates
it](../stage-2-pull-requests/statuses.md). Either way, a task carries no
`draft` status of its own the way a spec does: what a queued task might
still be waiting on is covered three ways that already exist — its
spec's approval gate, `blocked` with its reason, and `depends_on`.

## Criteria

- When a task's status changes, it shall move only along the edges the
  table above draws — no invented value, and no skipped gate.
- When a project is at Stage 1, a person or an agent shall move the
  working states by hand, deliberately, and each move shall record a
  fact that has already happened — never an intention.
- When a task's every spec is `approved` — or it references none — the
  task shall move `backlog → ready`, whoever writes it.
- When a spec of a `ready` task returns to `draft`, the task shall
  return to `backlog`, whoever writes it.
- When a task moves to `blocked`, the move shall carry a
  `blocked_reason`, and only a person shall move it there or back.
- When a task will never happen, a person shall move it to `dropped`,
  and the move shall be terminal.
- When a task's work is finished, the worker shall write its
  `completed` date by hand; no machinery shall decide a task is done.
- When a project is at Stage 1, the `queued` and `merged` dates shall
  stay `null` — they record forge events, and no hand-written value
  shall stand in for one.
- When a queue file records a moment, it shall record it as a UTC
  timestamp, so that two entries made the same day remain orderable.
- When a new queue file is created, its id shall be one no existing
  task or spec has ever used — an id is never reused, even after a
  deletion.
