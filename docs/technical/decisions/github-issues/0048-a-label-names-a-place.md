# a label names a place in the pipeline, so a closed mirror has none.

**2026-08-28**

Two defects in the mirror's labels, found by reading the live issues
rather than the code.

**A closed mirror kept its last label.** `reflect_progress.sh` closes an
Issue without relabelling, and `mirror_issues.sh` retires one the same
way, so the label froze at whatever intermediate step came last: issue #5
closed as completed reading `status:pending`, issue #10 closed as
completed reading `status:in-review`. Not merely stale — false. Every
label in the vocabulary names a place *inside* the pipeline, and a closed
mirror is out of it. So a closed mirror carries none, and the close plus
its reason is the terminal state — recorded by the forge instead of
remembered by a script. Rejected: a `status:done` label, which duplicates
what `stateReason` already distinguishes (completed vs not planned) and
adds one more thing to keep in sync.

**`status:ready` had become unreachable**, and
[0043](../pull-requests/0043-the-merge-is-this.md) is what made it so. `mirror_issues.sh`
derives "ready" from the spec statuses *in the merged pull request's
diff*, where they are still `draft` — because the same merge is what
approves them, and `writrun approve` writes that flip afterwards, in a
push that triggers no workflow. So every task merged after 0043 landed on
`status:pending` and stayed there with its specs approved: exactly what
task-0006 and task-0008 showed. Reading the diff is right for what a
merge *carried* and wrong for what it *caused*. The machinery re-derives
the label once the approval is recorded, from the queue as it then
stands. Rejected: having the mirror read the base tree instead of the
diff, which races the approve workflow's own push — the re-derivation is
sequential in that workflow instead, so there is nothing to race.
