# Task selection

**How "what should I work on next" gets one answer, whoever asks.** The
algorithm the lister implements and every agent runs unchanged. One
chapter of [`README.md`](README.md), the technical router; read it when
picking up work.

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
   ([statuses](../product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request)).
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
([statuses](../product/stage-2-pull-requests/statuses.md)). The cross-check is
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
leaves it — [where step 0 can see](#where-step-0-can-see-and-where-it-cannot).

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

## Where step 0 can see, and where it cannot

From Stage 2 up the authority branch is the complete mirror, so an
in-flight task is visible on any current checkout. What step 0
distinguishes is whether the forge still shows an open pull request for
it: with one, the task is someone's; with none, the flight state is stale
and the task is resumable. Three things the files alone cannot show:

- **The recording window** — a draft opened seconds ago, whose commit is
  not yet on the authority branch. Only the forge query covers it.
- **A branch never pushed, or pushed without a pull request** — visible
  nowhere. This is the hiding place the taking flow closes by opening the
  pull request as a draft *before* the work starts; when resuming on a
  shared machine or checkout, the branch list is the last place to look.
- **An amendment still riding an open pull request** — the specs on the
  authority branch read `approved` for the whole window it is open, so
  the files report a healthy queue while the task cannot move
  ([statuses](../product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request)).
  The forge query covers it; without one, the pause is reported as
  possibly hidden rather than absent.

## `brief.sh` — step 7 in one call

Step 7 says to read the task's body, every spec in `spec_ref`, and the
section `doc_ref` anchors, before any code. By hand that is four to six
whole-file reads to reach one section of each, so it is a script:

```bash
bash .writrun/skills/writrun-select-next-task/brief.sh <task-id> \
  [task-dir] [spec-dir] [docs-dir]
```

The id resolves by **number**, at any width and with or without the
`task-` prefix — a person types `34`, the file says `task-0034`, and both
name the one file. The output is one header line (id, status, priority,
and each spec's id and status — the same cross-check step 4 makes, shown
rather than fetched), then each part behind a `== <path> ==` divider: the
task file whole, each `spec_ref` entry's file whole in list order, and
the `doc_ref` section last.

A `doc_ref` is written relative to `docs/`, so the file read is
`docs/<path>` and never `<path>` from the repository root. Its anchor
selects the section from the heading whose slug matches to the next
heading of the same or higher level; with no anchor the whole file is the
section. **Slugs are GitHub's own rule** — lowercase, spaces to hyphens,
backticks dropped, punctuation stripped except hyphens and underscores,
duplicate heading text taking `-1`/`-2` in document order — because that
is what every `doc_ref` in a queue already targets.

**A router stub is followed once.** Where the resolved section's whole
body is a single link line — the shape
[`technical/README.md`](README.md) takes for a section that moved to a
chapter — the reader follows it and prints the chapter's section, with
the divider naming both hops. A brief that looked complete while holding
one link is the failure that rule exists to prevent.

Exit codes: **0** the brief is complete; **1** the id resolves to no
task file, naming what was looked for; **2** the brief is partial — every
part that resolved is printed, and the ones that did not are named. An
empty `spec_ref` and a null `doc_ref` are answers, not failures: the
divider says so and the exit stays 0.

It is a reader — no git, no network, no writes, and no judgement.
Eligibility stays the lister's, and whether a `doc_ref` section now
contradicts its spec stays the reader's.

## The skill is the operational pointer

[`writrun-select-next-task`](../../.writrun/skills/writrun-select-next-task/SKILL.md)
is this chapter's operational half: `list_tasks.sh` implements steps 0–6
and prints what is eligible, what is in flight and what is held back;
`brief.sh` is step 7's mechanical form. The skill carries the commands
and how to read their output — the rules are here.
