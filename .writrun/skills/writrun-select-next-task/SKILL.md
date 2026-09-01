---
name: writrun-select-next-task
description: Use this skill when picking what to work on next in a project that follows the WritRun methodology — when the user asks "what should I work on", "what's next", "pick up where we left off", or before starting any implementation work in a repo with a work/tasks/ folder. Also use at the start of any session in such a repo, before writing code, to check for resumable in-flight work.
---

# Select next task

Deterministic selection over `work/tasks/*.md`, independent of file order on
disk. Every agent that runs this skill on the same queue gets the same
answer — don't shortcut or reorder these steps.

## Steps

0. **Resume before selecting.** Read the front-matter of every task file.
   If any task is `in-progress` or `in-review` with no open pull request
   working it — the machinery keeps those two in step with the forge, so
   a lasting mismatch is work abandoned without the forge hearing about
   it — or its open pull request is this session's own, stop here and
   resume that task instead of selecting new work. One whose open pull
   request belongs to someone else is theirs, however stale: name it,
   never take it over on your own.

   **Resuming re-checks the authorization.** Read the resumed task's
   `spec_ref` against this checkout *and* against the open pull
   requests: a spec back in `draft` here, or one an open pull request
   proposes to change, means an amendment has suspended the task. The
   checkout alone cannot show the second — while the amendment rides an
   open pull request the files still say `approved` — so the union is
   the answer, and the lister below derives it for you. A suspended task
   is resumed by finishing or waiting out the amendment, never by
   implementing against a spec whose approval is in question
   (docs/product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request).

   Only proceed to step 1 if no resumable task exists.

1. Read the front-matter of every task in `work/tasks/`.
2. Keep only tasks with `status: ready`. (This excludes `backlog`,
   `blocked` and everything in flight or terminal automatically — do not
   add separate filters for them.)
3. Discard any task where `depends_on` lists a task that is not
   `status: done`.
4. Cross-check: every spec in `spec_ref` must be `status: approved` or
   `status: implemented`. From Stage 2 up the machinery wrote `ready`
   from exactly that fact, so a disagreement is a mismatch to surface
   loudly, not to silently resolve; at Stage 1 this step is the gate
   itself. A task with an empty `spec_ref` survives this step.
5. Sort what remains by `priority`: `high`, then `medium`, then `low`.
6. Break ties by `created` ascending, then by `id` ascending.
7. Take the first task. Before writing any code:
   - Read the task's own body.
   - Read every spec listed in its `spec_ref` (there may be zero, one, or
     several — read all of them).
   - Read the section of `doc_ref` it points to, if set — and read it
     **against the spec**, not just for context. The doc may have moved
     since the spec was approved; if the two now disagree, the doc wins
     and the spec is stale: do not implement either side. Surface the
     conflict — the spec is amended to match the doc, returned to `draft`
     in the same change, and re-approved before any code is written
     (docs/product/stage-1-tasks-and-specs/conflicts.md#when-the-doc-moves-ahead-of-the-queue).
   - If `spec_ref` is empty and the task body plus `doc_ref` do not
     add up to a sufficient brief, stop and ask the user whether to draft a
     spec first (see the `writrun-create-task-and-spec` skill) rather than guessing
     at scope.

## Output

State plainly which task was selected (or resumed) and why — the id, its
priority, and what it depends on if relevant. Then proceed with the work, or
with drafting its spec if step 7 called for that.

If every remaining task was discarded at step 4 — specs exist but none are
approved — say that, rather than reporting an empty queue. The two look
identical from the outside and need opposite responses: one is nothing to
do, the other is work waiting on a human.

## When a person asks what is available

They are choosing, not asking you to choose. Run the lister and show them
the result — do not pick one and present it as the answer:

```bash
bash .writrun/skills/writrun-select-next-task/list_tasks.sh
```

It prints what is eligible in algorithm order, what is in progress and must
be resumed first, and what is held back with the reason for each. Exit 0
means something is available, 1 means nothing is.

The order it prints is a suggestion to a person and binding on you. If they
pick the bottom of the list, that is a valid choice and not something to
push back on. If they pick something under **Held back**, that is a gate,
and the next section applies.

## Someone may already be on it

WritRun has no claim mechanism — reserving work is a tracker's job, not
this methodology's. The queue on `main` does say who has a task — the
machinery writes `in-progress` and `taken_by` the moment a draft pull
request opens — but there is a window of seconds before that recording
commit lands, and a checkout may be stale.

What the lister can see is work already **in flight** — an open pull request
for a task. Take that seriously: it is not a lock, and nothing stops two
people working the same task, but it is the one signal available in real
time. Without network access the lister says so rather than reporting a
task as free, and you should repeat that caveat when you report what you
took.

If the project assigns work through a tracker, follow that convention —
WritRun neither requires it nor reads it.

## When you are handed a specific task

A person naming the task to work on is not an out-of-order pick, and you do
not argue the sort at them. Steps 5–6 exist to make *your* choice
repeatable, not to rank what a human is allowed to want.

Check that task against steps 2–4 only. If it is eligible, take it and say
so. If it is not — `blocked`, a dependency still open, a spec still `draft`
— do not start: name the filter that excludes it and what would clear it.
Those three are gates, and being asked directly does not open them.

## Where step 0 can actually see

From Stage 2 up, `main` is the complete mirror: the machinery writes
`in-progress` onto it the moment a draft pull request opens, so an
in-flight task is visible on any current checkout. What step 0
distinguishes is whether the forge still shows an open pull request for
it — with one, the task is someone's (the In flight section); with
none, the flight state is stale and the task is resumable. Two places
the file cannot see:

- **The recording window** — a draft opened seconds ago, its commit not
  yet on `main`. The lister's forge query covers it.
- **A branch never pushed or pushed without a PR** — visible nowhere.
  This is the hiding place the taking flow closes by opening the pull
  request as a draft before the work starts; when resuming on a machine
  or repo you share, check `git branch` (and `git branch -r`) before
  concluding nothing is unfinished.
- **An amendment still riding an open pull request** — the specs on the
  authority branch read `approved` for the whole window it is open, so
  the files report a healthy queue while the task cannot move. The
  lister's forge query covers it; without one, say the pause could be
  hidden rather than reporting the task as advanceable.

## Never

- Never pick a task by directory listing order, filename, or "the one that
  looks easiest" — when *you* are choosing, only by the algorithm above.
- Never select a `blocked` or `backlog` task. If everything is blocked,
  dependency-gated, or waiting on approval, say so plainly instead of
  picking one anyway.
- Never skip step 0 — but know its reach (above): an abandoned
  `in-progress` task must be surfaced before anything new is picked up,
  and on a `main` checkout the place it shows is the In flight section or
  the branch list, not the task files.
- Never implement through a suspension. A task whose spec an open pull
  request proposes to return to `draft` waits for that pull request, and
  the wait is the correct outcome — not an obstacle to route around.
- Never implement an approved spec whose `doc_ref` section now
  contradicts it. The doc wins; the spec is amended through `draft` and
  re-approved — never quietly out-implemented, and never edited while it
  stays `approved`.
