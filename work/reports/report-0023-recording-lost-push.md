---
id: report-0023
status: open
task_ref: []
doc_ref: null
created: 2026-09-04T17:08:58Z
triaged: null
---

# The recording commit is pushed once, and a concurrent recording loses it

Three draft pull requests were opened seconds apart — #173, #174, #175,
for task-0045, task-0046 and task-0047. Two tasks moved to
`in-progress`. task-0047 stayed `ready`, `taken_by: null`, with its
pull request open, and nothing since has corrected it.

The three `writrun-progress` runs fired at 16:42:00, 16:42:03 and
16:42:04Z. The third failed. Its `Commit` step composed the write,
rebased, and was rejected on push:

```
[main 2a030ee] chore(queue): record what the forge just did
 1 file changed, 2 insertions(+), 2 deletions(-)
git pull --rebase origin main
  Current branch main is up to date.
git push origin HEAD:main
  ! [remote rejected] HEAD -> main (cannot lock ref 'refs/heads/main':
    is at 388c36b7fbe37c2709ff81a5194ffae7f26158a3
    but expected 55a311fe9827c8f25bad85e978dcd946577fda16)
error: failed to push some refs to
##[error]Process completed with exit code 1.
```

The step already carries the guard, and its comment states the intent —
"Another recording may have landed between checkout and here. Rebase
onto it rather than force: this is an addition to the branch's history,
never a replacement of it." The rebase ran and reported `main` up to
date. The push, 1.2 seconds later, found `main` at a commit that
arrived in between. The guard is a single pass: rebase once, push once,
exit non-zero.

The window is the gap between the rebase and the push, so a second
recording landing inside it loses the first. That is what happened
here: 388c36b is the run at 16:42:03 recording task-0046.

**No second event corrects it.** The later `ready_for_review` event for
#175 ran at 17:05:37Z and succeeded, writing nothing: from `ready` there
is no legal edge to `in-review`, and the transition machine correctly
declines to march a task forward from a state it should not be in
(`product/stage-2-pull-requests/statuses.md`). So the recording is lost
and the next event is the one that hides it.

Downstream the mirror is faithful to the file: task-0047's Issue carries
`status:ready` while #175 is open and ready for review.

Evidence: https://github.com/thomasfranke/writrun/actions/runs/33896597991
