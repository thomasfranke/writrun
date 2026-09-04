---
id: report-0026
status: tracked
task_ref: [task-0052]
doc_ref: technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command
created: 2026-09-04T17:37:18Z
triaged: 2026-09-04T18:30:55Z
---

# The resume hint names an act --resume refuses, when the forge fails after the push

**References:** [technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command](../../docs/technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command) · [task-0052](../tasks/task-0052-resume-after-push.md)

`take_task.sh` pushes the branch and then opens the draft. When the push
succeeds and `gh pr create` fails — a rate limit, a dropped connection,
branch protection — the script prints the state it says it must never
leave behind, and a hint:

```
gh pr create failed:
GraphQL: was submitted too quickly
task/0001-mirror-lag is pushed but has no pull request, which is the one
state this act must not leave behind.
Finish it with:
  bash .../take_task.sh task-001 --title "feat(ci): take it" --slug mirror-lag --resume
```

Running that line verbatim is refused:

```
REFUSED: task/0001-mirror-lag is already on the forge — what --resume
finishes is a branch that never reached it
```

`git push -u` created `refs/remotes/origin/<branch>`, and that reference
is what the `--resume` guard reads. So the one path where the act leaves
behind the state it names as unacceptable is the one path whose printed
recovery cannot run.

The same claim stands in the doc:
`technical/distribution/take-task.md` says "A forge failure *after* the
cut also exits 3, naming the branch kept local and `--resume`, which
finishes the act". After the push the branch is not kept local, and
`--resume` does not finish it.

Observed while reviewing task-0045, which gives the take its first
commit. That change removes the *most common* cause of a failed
`gh pr create` — a branch with no commits for the forge to open a pull
request against — so this path is reached less often than it was. It is
not closed: every other forge failure still reaches it.

Recorded rather than fixed there: spec-0064's Scope puts it out by name,
on the reasoning that widening the `--resume` refusal while the cause was
still present would paper over the cause. With the cause gone, what is
left is a hint and a doc sentence that describe an act the script
refuses.
