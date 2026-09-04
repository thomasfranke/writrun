---
id: report-0019
status: tracked
task_ref: [task-0045]
doc_ref: null
created: 2026-09-04T05:30:14Z
triaged: 2026-09-04T15:18:22Z
---

# A fresh take opens no pull request — the branch has no commits

**References:** [task-0045](../tasks/task-0045-take-first-commit.md)

Taking task-0042, `take_task.sh` cut the branch from `origin/main`,
pushed it, and failed to open the draft: GitHub refuses a pull request
with no commits between the branches (`GraphQL: No commits between main
and task/0042-entry-point-pointer`). The script never commits, so every
fresh take reaches the forge in exactly that state — the act it exists
to keep whole always fails at its second half. `--resume` then refuses
too: it finishes a branch that never reached the forge, and this branch
had. Worked around by hand: an empty commit, push, `gh pr create
--draft`. Also observed on the same take: the composed title is judged
against the declared style *before* the script prepends the
`[TASK-NNNN]` tag, so passing a title that already carries the tag is
refused with an example that shows no tag — easy to misread as "tags
are wrong" rather than "the tag is mine to add".
