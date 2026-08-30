# Statuses, dates and what they mean

**Statuses.** These values and no others.

| | Values | Moved by |
|---|---|---|
| Task | `backlog` → `ready` → `in-progress` → `in-review` → `done` | the machinery, on the authority branch, from forge events — never by hand |
| Task | `blocked` (needs `blocked_reason`), from and back to `backlog` or `ready` | a person — no forge event knows *why* work cannot proceed |
| Task | `dropped` — terminal | a person — no forge event knows a task will never happen |
| Spec | `draft` → `approved` → `implemented` | `approved` by a human only; the rest by whoever does the work |

The five working states carry the vocabulary the wider community
already reads — the same columns GitHub Projects, Linear and Jira
converge on — so a contributor arriving from any tracker knows where a
task stands without learning a dialect.

**A task's status line has one writer, and `main` is the complete
mirror.** The working states are a projection of forge events onto the
authority branch, written there by the machinery as each event lands —
the queue is as current as the forge can make it:

| Forge event | Writes |
|---|---|
| the merge that creates the task | the file lands `backlog` |
| that same merge's recording commit approves its specs | `backlog → ready` |
| a later merge returns one of its specs to `draft` (amendment) | `ready → backlog` |
| the draft pull request opens, or reopens | `→ in-progress`, `taken_by` set |
| the pull request is marked ready for review | `in-progress → in-review` |
| the pull request is converted back to draft | `in-review → in-progress` |
| a review requests changes | `in-review → in-progress` — the ball is back with the worker |
| review is re-requested after the fixes | `in-progress → in-review` |
| the pull request closes unmerged | `→ ready`, `taken_by` cleared |
| the merge carries the task's `completed` date | `→ done`, `taken_by` kept |
| the merge carries its work without that date | `→ ready`, `taken_by` cleared — one spec of several is work taken, not finished |

Two invariants fall out. `in-progress` and `in-review` each mean **an
open pull request is working the task right now** — no open pull
request, no in-flight state. And a branch never edits the status line:
two writers on one line is a merge conflict by construction, and the
branch has nothing to say that a forge event does not already say
better.

**Transitions are a checked machine, not a suggestion.** The machinery
writes only the moves the tables above draw; an event arriving out of
order — a stale replay, a reopened pull request whose task is already
`done` — matches no legal edge and writes nothing. An echo is not an
error, and it is never allowed to march a task backwards.

`blocked` and `dropped` are the two human exceptions, for the same
reason in both directions: the forge can report what happened to a pull
request, never that the world outside the queue has stalled a task or
killed it. `blocked` names its reason and waits for a person to release
it; `dropped` is terminal — the queue's honest word for *this will not
happen*, so the file stops shadowing the backlog forever.

The worker still declares finishing — that is what the hand-written
`completed` date *is*. The machinery never decides a task is done; it
records, on the authority branch, a declaration the merge carried.

**Who took it is recorded the same way.** The task's `taken_by` field
carries the login of the pull request's author, written by the
machinery in the same commit as the `in-progress` flip. It is a record,
never an assignment: WritRun's own non-goals rule out reserving work,
so the field reports what the forge shows — including a newer pull
request superseding it — and entitles nobody. It clears whenever the
task returns to `ready`, and stays on `done`, as the record of who
completed the work.

**Dates.** A task carries four, and **who writes each is part of the
contract** — not a convention anyone may bend.

| Field | Records | Written by |
|---|---|---|
| `created` | the task was drafted | a person, on the branch |
| `queued` | the merge that brought it into the queue | the machinery, after that merge |
| `completed` | its work was finished | a person, on the branch |
| `merged` | the merge that took its work | the machinery, after that merge |

The split is not decoration. **A hand-written date cannot honestly record
a merge**: it would have to be typed before the event it claims to
describe, and would be wrong by however long review takes. So the two
halves answer different questions and neither substitutes for the other —
`completed` is when the worker finished, `merged` is when the project
took it. Where everything merges the same day they coincide; anywhere
else the gap between them *is* the review.

And four is the number — **no date per transition.** Every status flip
the machinery makes is a commit, so the task's own git history already
holds the full timeline, timestamped and captioned, for free. Lead
time, review time, time-in-queue: derive them from the log. A schema
field that restates git is bloat, and this sentence exists so nobody
adds one.

One state is **derived, never stored**: *proposed* — a task whose file
an open pull request adds and the authority branch does not hold yet.
It could not be stored even in principle: the merge that makes the task
real is the very commit that carries the file's own words onto the
authority branch, so the field would land already false. Everything
else the pipeline distinguishes is written where it happened.

**The merge of the pull request that creates a task is that task's
authorization.** Nothing else authorizes it, and nothing else needs to:
before that merge the file is not on the authority branch at all. That
absence is why a task carries no `draft` of its own the way a spec does —
a spec is `draft` *while already in the queue*, which is a state a task
never occupies. What a merged task might still be waiting on is covered
three ways that already exist: its spec's approval gate, `blocked` with
its reason, and `depends_on`.

## Criteria

- When a queue field records what a forge event did — a merge, a pull
  request opening, closing, or changing draftness — the machinery shall
  write it after that event, and a person shall not write it by hand.
- When the recording commit of the merge that creates a task approves
  its every spec, the machinery shall move the task `backlog → ready`
  in that same commit.
- When a merge returns a spec of a `ready` task to `draft`, the
  machinery shall move that task back to `backlog` in the same
  recording commit.
- When a draft pull request opens for a task, the machinery shall move
  it to `in-progress` and record the author's login in `taken_by`, in
  one commit.
- When a pull request working a task is marked ready for review, the
  machinery shall move the task to `in-review`; when it is converted
  back to draft, the machinery shall return it to `in-progress`.
- When a review on the pull request working a task requests changes,
  the machinery shall return the task to `in-progress`; when review is
  re-requested, the machinery shall move it back to `in-review`.
- When the pull request working a task closes unmerged, the machinery
  shall return the task to `ready` and clear `taken_by`.
- When a merge carries a task's work, the machinery shall move the task
  to `done` if the merge carries its `completed` date, and shall return
  it to `ready`, clearing `taken_by`, otherwise.
- When an event matches no legal transition for the status a task
  holds, the machinery shall write nothing.
- When a change on a branch moves a task between the machinery's five
  working states, the machinery shall reject the change; a hand-written
  move to or from `blocked`, or to `dropped`, it shall accept.
- When a queue file records a moment, it shall record it as a UTC
  timestamp, so that two entries made the same day remain orderable.
- When a change adds a queue file whose id the authority branch or
  another open pull request already claims, the machinery shall reject
  the change.
