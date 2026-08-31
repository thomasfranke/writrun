# The status machinery

What Stage 2 adds to [statuses](../stage-1-tasks-and-specs/statuses.md): the
working states stop being hand-moved and become **a projection of forge
events onto the authority branch**, written by the machinery as each
event lands. The vocabulary, the gates and the two human exceptions
(`blocked`, `dropped`) do not change — what changes is the writer.

**A task's status line has one writer, and `main` is the complete
mirror.** The queue is as current as the forge can make it:

| Forge event | Writes |
|---|---|
| the merge that creates the task | the file lands `backlog` |
| that same merge's recording commit approves its specs — or finds it has none to approve | `backlog → ready` |
| a later merge returns one of its specs to `draft` (amendment) | `ready → backlog` |
| the draft pull request opens, or reopens | `→ in-progress`, `taken_by` set |
| the pull request is marked ready for review | `in-progress → in-review` |
| the pull request is converted back to draft | `in-review → in-progress` |
| a review requests changes | `in-review → in-progress` — the ball is back with the worker |
| review is re-requested, on a pull request already marked ready | `in-progress → in-review` |
| the pull request closes unmerged | `→ ready` or `backlog`, per its specs; `taken_by` cleared |
| the merge carries the task's `completed` date | `→ done`, `taken_by` kept |
| the merge carries its work without that date | `→ ready` or `backlog`, per its specs; `taken_by` cleared — one spec of several is work taken, not finished |

Two of those edges land, not follow: a task **leaving flight** is not
assumed back to the state it left. The machinery re-derives the resting
state from the specs as they stand — `ready`, or `backlog` if one has
meanwhile returned to `draft` — because an amendment may have landed
while the work was in flight, and no edge interrupts flight to say so.
What does happen while flight is interrupted is its own rule, below.
And when more than one pull request works a task, **the newest event
wins**: a close that leaves another pull request open re-derives the
in-flight state and `taken_by` from that survivor, and a pull request
opening for a task already in flight refreshes `taken_by` the same way.

Two invariants fall out. `in-progress` and `in-review` each mean **an
open pull request is working the task right now** — no open pull
request, no in-flight state. And a branch never edits the status line:
two writers on one line is a merge conflict by construction, and the
branch has nothing to say that a forge event does not already say
better.

**Transitions are a checked machine, not a suggestion.** The machinery
writes only the moves the table above draws; an event arriving out of
order — a stale replay, a reopened pull request whose task is already
`done` — matches no legal edge and writes nothing. An echo is not an
error, and it is never allowed to march a task backwards.

**`taken_by` is the machinery's here.** It carries the login of the
pull request's author, written in the same commit as the `in-progress`
flip. Still a record, never an assignment: it reports what the forge
shows — including a newer pull request superseding it — and entitles
nobody. It clears whenever the task returns to `ready`, and stays on
`done`, as the record of who completed the work — which is exactly why it
is a pointer and not a history. What accumulates instead, in a project
that declares one, is the
[provenance ledger](../concepts/provenance.md#why-the-field-naming-the-worker-is-not-this-record).

**The machinery's two dates come alive.** `queued` and `merged` — at
Stage 1 left `null` — are written here, by the machinery, after the
merge each records. And every status flip the machinery makes is a
commit, so the task's own git history holds the full timeline,
timestamped and captioned, for free: lead time, review time,
time-in-queue are derived from the log, never stored.

One state is **derived, never stored**: *proposed* — a task whose file
an open pull request adds and the authority branch does not hold yet.
It could not be stored even in principle: the merge that makes the task
real is the very commit that carries the file's own words onto the
authority branch, so the field would land already false.

**The merge of the pull request that creates a task is that task's
authorization.** Nothing else authorizes it, and nothing else needs to:
before that merge the file is not on the authority branch at all.

## An amendment under an open pull request

The amendment flow assumes it runs early — the doc read against the spec
before any code is written. It can also be forced at the other end: the
completion gate refusing a finished branch because the promise list was
wrong, which is as late as the pipeline goes
([Conflicts](../stage-1-tasks-and-specs/conflicts.md#a-spec-changes-after-its-approval)).
The same steps run, but now they run under an open pull request, and
"net status unchanged" stops describing a no-op and starts describing a
silence.

**No status moves, and that is correct.** The in-flight state belongs to
the task's own pull request's events and to no other merge: an amendment
landing under an in-flight task says nothing about that work, and a task
pulled back to `ready` would read as free while somebody's pull request
stays open — a worse lie than the silence. This has always been the
recording machinery's behaviour; it is stated here as the rule it was
already keeping.

**But the task is suspended, and the suspension is derived — never
stored.** From the moment the amendment is cut until its re-approval
lands, the task cannot advance: a spec whose approval is in question
authorizes nothing, so the work waits. Like *proposed* above, this state
is read, not written: on the authority branch, an in-flight task with a
spec back in `draft`; on the forge, an open pull request proposing to
return an in-flight task's spec to `draft`. The union matters — during
the amendment's open window the authority branch still shows the spec as
it was approved, so the forge's half is not an optimization but the only
place the pause is visible at all. It is the same union that already
defines the queue for id assignment. The lister names a task in this
condition as paused, beside the pull request that suspended it, and the
selection algorithm's resume step waits on the re-approval instead of
implementing through it. A stored marker was rejected for the same
reason *proposed* is never stored: written late or cleared late, it
lies (decision 0059).

**The two pull requests name each other.** The real dependency runs
between two pull requests — the work waits on the amendment — and the
queue has no field for that relation because the forge already holds it.
The amendment's body names the pull request it suspends; the suspended
pull request's body names what it waits on. From Stage 2, `writrun
check` fails an amendment that touches an in-flight task's spec without
naming that task's open pull request — the cross-reference is checked,
never trusted to prose discipline.

## Criteria

- When a queue field records what a forge event did — a merge, a pull
  request opening, closing, or changing draftness — the machinery shall
  write it after that event, and a person shall not write it by hand.
- When the recording commit of the merge that creates a task approves
  its every spec — or finds it references none — the machinery shall
  move the task `backlog → ready` in that same commit.
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
  re-requested on a pull request already marked ready, the machinery
  shall move the task back to `in-review`.
- When a task leaves flight — its pull request closed unmerged, or its
  work merged without the `completed` date — the machinery shall land
  it on `ready`, or on `backlog` if any of its specs is `draft`, and
  clear `taken_by`.
- When a pull request working a task closes while another open pull
  request still works it, the machinery shall re-derive the in-flight
  state and `taken_by` from the newest surviving pull request instead
  of landing the task.
- When a merge carries a task's work and its `completed` date, the
  machinery shall move the task to `done`.
- When an event matches no legal transition for the status a task
  holds, the machinery shall write nothing.
- When a change on a branch moves a task between the machinery's five
  working states, the machinery shall reject the change; a hand-written
  move to or from `blocked`, or to `dropped`, it shall accept.
- When a change adds a queue file whose id the authority branch or
  another open pull request already claims, the machinery shall reject
  the change.
- When a merge returns a spec of an in-flight task to `draft`, the
  machinery shall not move that task's status — flight belongs to the
  task's own pull request's events, and to no other merge.
- When a pull request returns a spec of an in-flight task to `draft`,
  `writrun check` shall fail it unless its body names that task's open
  pull request.
- When a task is in flight and any spec in its `spec_ref` is not
  `approved` or `implemented` — on the authority branch, or in an open
  pull request's proposal — the lister shall name the task as paused,
  beside the pull request that suspended it.
