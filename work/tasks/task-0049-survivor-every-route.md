---
id: task-0049
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0068]
doc_ref: product/stage-2-pull-requests/statuses.md#criteria
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-04T18:30:51Z
queued: 2026-09-04T19:23:29Z
completed: 2026-09-05T10:33:44Z
merged: 2026-09-05T13:14:38Z
provenance:
  - {by: agent, model: claude-fable-5, login: thomasfranke, input: 20, output: 109852, cache_read: 2165364, cache_write: 34608}
---

# Ask the survivor question by every route a pull request carries a task

**References:** [product/stage-2-pull-requests/statuses.md#criteria](../../docs/product/stage-2-pull-requests/statuses.md#criteria) · [spec-0068](../specs/spec-0068-survivor-every-route.md)

`apply_pr_event.sh` reads every task a pull request carries — the head
branch's and every `[TASK-NNNN]` tag in the title. The
close-without-merge survivor query did not follow: it still asks the
forge for open pull requests whose *branch* names the task, so a task
another pull request carries by title tag alone is never found as a
survivor for it.

Make the question reach as far as the reader does.

Why it matters: the task with an unseen survivor is landed — `ready`,
`taken_by: null` — while an open pull request is working it. It does not
heal at that pull request's next event, for the same reason report-0023
describes: `ready` has no edge to `in-review`. So the window closes only
at merge, and selection can hand the task out again inside it.
