---
name: writrun-select-next-task
description: Use this skill when picking what to work on next in a project that follows the WritRun methodology — when the user asks "what should I work on", "what's next", "pick up where we left off", or before starting any implementation work in a repo with a work/tasks/ folder. Also use at the start of any session in such a repo, before writing code, to check for resumable in-progress work.
---

# Select next task

Deterministic selection over `work/tasks/*.md`, independent of file order on
disk. Every agent that runs this skill on the same queue gets the same
answer — don't shortcut or reorder these steps.

## Steps

0. **Resume before selecting.** Read the front-matter of every task file.
   If any task has `status: in-progress` and its owner is not the current
   session (single-agent projects: any `in-progress` task at all, since
   there is only one possible owner), stop here and resume that task
   instead of selecting new work. Only proceed to step 1 if none exists.

1. Read the front-matter of every task in `work/tasks/`.
2. Keep only tasks with `status: pending`. (This excludes `blocked` tasks
   automatically — do not add a separate filter for them.)
3. Discard any task where `depends_on` lists a task that is not
   `status: completed`.
4. Discard any task where `spec_ref` lists a spec that is not
   `status: approved` or `status: implemented`. A draft spec has not passed
   the approval gate, so the task is not authorized work — leave it. A task
   with an empty `spec_ref` survives this step.
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

WritRun has no claim mechanism — reserving work is a tracker's job, not this
methodology's, and `work/tasks/` cannot carry the answer anyway: a task
someone started an hour ago stays `pending` in `main` until their pull
request merges.

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

In a pull-request workflow, `in-progress` rides on the worker's branch and
reaches `main` only at merge — normally as `completed` already. The one
exception that does land on `main` is a partial merge: a PR that
implemented one spec of several without completing the task leaves it
`in-progress` there, and step 0 sees it like any other file. Otherwise, on
a clean `main` checkout, step 0 finds nothing by construction. Know where
the signal really lives:

- **Your own working copy** — step 0 fires when you are on the work branch,
  or in a project that commits to `main` directly without PRs.
- **Someone else's unfinished work with a PR open** — the lister's
  **In flight** section, not step 0.
- **A branch never pushed or pushed without a PR** — visible nowhere.
  This is the hiding place a project closes by opening the pull request
  as a draft when the task is taken, before the work starts; where that
  is the rule, a taken task always has a PR to be seen through. When
  resuming on a machine or repo you share, check `git branch` (and
  `git branch -r`) before concluding nothing is unfinished.

## Never

- Never pick a task by directory listing order, filename, or "the one that
  looks easiest" — when *you* are choosing, only by the algorithm above.
- Never select a `blocked` task. If every `pending` task is blocked or
  dependency-gated, say so plainly instead of picking one anyway.
- Never skip step 0 — but know its reach (above): an abandoned
  `in-progress` task must be surfaced before anything new is picked up,
  and on a `main` checkout the place it shows is the In flight section or
  the branch list, not the task files.
- Never implement an approved spec whose `doc_ref` section now
  contradicts it. The doc wins; the spec is amended through `draft` and
  re-approved — never quietly out-implemented, and never edited while it
  stays `approved`.
