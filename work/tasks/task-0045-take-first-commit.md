---
id: task-0045
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0064]
doc_ref: technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-04T15:18:22Z
queued: 2026-09-04T16:30:05Z
completed: 2026-09-04T16:51:55Z
merged: 2026-09-04T18:18:36Z
provenance:
  - {by: agent, model: claude-opus-5, login: thomasfranke}
---

# Give the take its first commit, so the draft pull request can open

**References:** [technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command](../../docs/technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command) · [spec-0064](../specs/spec-0064-take-first-commit.md)

`take_task.sh` cuts the branch, pushes it, and asks the forge for a
draft pull request. It never commits, so the branch it pushes is
identical to `origin/main` and GitHub refuses the pull request outright:
`No commits between main and task/NNNN-<slug>`. Every fresh take fails
at the second of the two halves
[take-task.md](../../docs/technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command)
says the script exists to keep together.

`--resume` does not recover it either. It is written for a branch that
never reached the forge, and refuses one that did — which is exactly
the state the failure leaves behind. The way out today is by hand: an
empty commit, a push, and `gh pr create --draft`.

Give the act a first commit of its own, so the push carries something
and the draft opens. Take the diagnostic with it: the summary is judged
against the declared style before the `[TASK-NNNN]` tag is prepended,
and the refusal prints an example carrying no tag — so a title that
already has one is refused by a message that reads as "your tag is
wrong" rather than "the tag is mine to add".

Why it matters: this is the taking act, and it is broken for every task
in the queue. A methodology whose one command for starting work fails
on every use teaches its adopters to work around it, and a worked-around
act stops being one act.
