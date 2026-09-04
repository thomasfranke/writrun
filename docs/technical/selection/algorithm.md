# The algorithm

**The steps that give "what should I work on next" one answer.** One chapter of [`selection/`](README.md).

## Task selection algorithm

Deterministic, independent of file layout on disk:

0. **Resume before selecting.** If any task has `status: in-progress` or
   `in-review` with no open pull request working it (the machinery keeps
   the two in step with the forge, so a lasting mismatch is work someone
   abandoned without the forge hearing about it), or whose open pull
   request is this session's own, resume it — do not pick new work
   while started work sits unfinished. An in-flight task whose open
   pull request is someone else's stays theirs, however stale: the
   lister names it as in flight rather than hiding it, and taking it
   over — closing or adopting their pull request — is a human decision,
   never the algorithm's. **Resuming re-checks the authorization**: read
   the resumed task's `spec_ref` against the authority branch *and*
   against open pull requests — an amendment may have suspended the task
   mid-flight, and the authority branch alone cannot show an amendment
   still riding an open pull request
   ([statuses](../../product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request)).
   A suspended task is resumed by finishing or waiting out the
   amendment, never by implementing against a spec whose approval is in
   question. Only when no resumable task exists does selection proceed.
1. Read the front-matter of every task.
2. Keep those with `status: ready` — `backlog`, `blocked` and the
   in-flight and terminal states are excluded here by construction, with
   no extra rule needed.
3. Keep those whose every `depends_on` entry has `status: done`.
4. Confirm every `spec_ref` entry holds `status: approved` or
   `implemented` — at Stage 2+ the machinery already wrote `ready` from
   exactly that fact, so this is a cross-check; at Stage 1, where
   statuses move by hand, it is the gate itself. A task with a spec
   still in `draft` is not authorized work: the approval gate has not
   been passed, so selecting it would hand an agent a brief nobody
   assented to. A task with an empty `spec_ref` passes this step by
   construction.
5. Sort by `priority` — `high`, then `medium`, then `low`.
6. Break ties by `created` ascending, then by `id` ascending.
7. Take the first. Read every entry in `spec_ref` (if any) and `doc_ref`
   (if set) before writing any code.

`ready` is stored, and steps 2–4 still agree by construction: the
machinery derives the flip from the same facts step 4 re-checks
([statuses](../../product/stage-2-pull-requests/statuses.md)). The cross-check is
deliberate — a stored status that could silently disagree with the facts
it summarizes is exactly what the old derive-don't-store rule feared, so
the algorithm keeps reading both and stops loudly on a mismatch.

**Steps 2–4 are eligibility; steps 5–6 are only order**, and the two bind
differently. The filters bind everyone: a task that is `blocked`,
dependency-gated, or whose spec is still `draft` is unavailable to anybody,
and no judgement overrides that — those are the gates, expressed as a
query. The sort binds agents only. It exists so repeated sessions reach the
same answer instead of each re-deriving one, not to claim the
highest-priority task is the only legitimate one. **A human may take any
eligible task, out of order, and bypasses nothing by doing so.** An agent
may not, because determinism is the whole property the sort provides.

Step 7 has to branch on an empty `spec_ref`: with no spec, the task's own body
plus `doc_ref` is the whole brief, and whether that's sufficient — or
whether the agent should stop and ask for a spec first — is a call this
methodology leaves to the adopting project, stated explicitly in its
`AGENTS.md`.


## What "active owner" means, and what `backlog` is not

Step 0 asks whether an `in-progress` task has an active owner, and the
answer is a project's to state. **A project whose sessions are one
agent's reads it as the session**: any `in-progress` task not started by
this session is resumable, and resuming it comes before selecting new
work. A project with several contributors reads it as the person the
forge names, which is what `taken_by` carries — the rule is the same
question with a different population.

**This is not the open-pull-request test below.** That one says whether
the flight state is still true; this one says whose it is, and only the
two together decide. So a one-agent project resumes a task whose pull
request is open, because the population it belongs to is the session
reading it, while a multi-contributor project names the same task and
leaves it — [where step 0 can see](visibility.md#where-step-0-can-see-and-where-it-cannot).

**A `backlog` task is not authorized work.** `ready` is written by the
machinery from the fact that every spec in `spec_ref` is `approved`, and
the algorithm cross-checks the two rather than trusting either alone. So
a `backlog` task has not passed the approval gate, and taking it is
taking work nobody assented to. When every task is held back that way the
answer is to say so — an empty Available list with a full Held back list
is a queue waiting on approvals, not a queue with nothing in it, and
reporting it as the second sends a session looking for work that does not
exist.

## Nobody claims a task

WritRun has no claim mechanism — reserving work is a tracker's job, not
this methodology's. The queue on the authority branch does say who has a
task: from Stage 2 the machinery writes `in-progress` and `taken_by` the
moment a draft pull request opens. But there is a window of seconds
before that recording commit lands, and a checkout may be stale, so the
queue is a record and never a lock.

What *is* visible in real time is work in flight — an open pull request
for a task. Nothing stops two people working the same task; that signal
is the only one there is, and it is taken seriously rather than treated
as permission. **Without network access, the answer says so** — a reader
that cannot reach the forge reports a narrow view rather than reporting a
task as free, and whoever acts on it repeats the caveat.

A project that assigns work through a tracker follows that convention on
top; WritRun neither requires one nor reads it.

