---
id: report-0028
status: tracked
task_ref: [task-0050]
doc_ref: technical/settings/titles.md#pr_title_style
created: 2026-09-04T17:51:21Z
triaged: 2026-09-04T18:30:52Z
---

# A fork pull request can claim every task its title lists

**References:** [technical/settings/titles.md#pr_title_style](../../docs/technical/settings/titles.md#pr_title_style) · [task-0050](../tasks/task-0050-bound-carried-claims.md)

`writrun-progress.yml` runs on `pull_request_target`, and its `gate` job
admits every `pull_request_target` event — a fork's included, by design,
since the workflow checks out the default branch and never the pull
request's tree. The `record` job holds `contents: write` and pushes the
status writes to `main`.

Both routes into the carried set are the pull request author's to write:
the head branch name always was, and after task-0047 the title is too.
So the kind of exposure is unchanged. The amount is not.

Before: a fork's pull request could claim the one task its head branch
spelled. After: it can claim every task its title lists, in one commit,
with `taken_by:` naming the fork author. `ql_carried_of` imposes no
ceiling on how many tags it will read, so

```
[TASK-0001][TASK-0002]…[TASK-0100] hi
```

moves a hundred tasks to `in-progress`. Only tasks already `done`,
`blocked` or `dropped` are out of reach, and only because the edge table
refuses them.

No ceiling is imposed as part of task-0047: a number picked in passing
is a rule, and this file is the observation rather than the decision.
What triage has to weigh is a sanity cap on the carried set for the
in-flight half, against the legitimate multi-task pull request the whole
change exists to serve.
