---
id: task-0052
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0071]
doc_ref: technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-04T18:30:55Z
queued: 2026-09-04T19:23:29Z
completed: 2026-09-05T10:36:11Z
merged: null
provenance:
  - {by: agent, model: claude-fable-5, login: thomasfranke, input: 0, output: 0, cache_read: 0, cache_write: 0}
---

# Give the take a recovery that works after the push

**References:** [technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command](../../docs/technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command) · [spec-0071](../specs/spec-0071-resume-after-push.md)

`take_task.sh` pushes the branch and then opens the draft. When the push
succeeds and the forge then refuses the pull request, the script names
the state it says it must never leave behind and prints a `--resume`
line to finish it — and that line is refused by `--resume`'s own guard,
because the push created the remote ref that guard reads.

Give the act a recovery for the half it can actually leave behind.

Why it matters: this is the one path where the take ends in the state it
declares unacceptable — a branch on the forge with no pull request — and
it is the only path whose printed recovery cannot run. task-0045 removed
the most common cause of a failed `gh pr create` (a branch with no
commits), so the path is reached less often; every other forge failure
still reaches it. `technical/distribution/take-task.md` also states that
a forge failure after the cut names the branch "kept local" and
`--resume`, "which finishes the act", and after the push neither half of
that sentence is true.
