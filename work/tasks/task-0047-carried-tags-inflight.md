---
id: task-0047
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0066]
doc_ref: technical/settings/titles.md#pr_title_style
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-04T16:20:11Z
queued: 2026-09-04T16:38:34Z
completed: 2026-09-04T16:51:36Z
merged: 2026-09-04T18:19:00Z
provenance:
  - {by: agent, model: claude-opus-5, login: thomasfranke}
---

# Move every task the pull request carries, not only the branch's

**References:** [technical/settings/titles.md#pr_title_style](../../docs/technical/settings/titles.md#pr_title_style) · [spec-0066](../specs/spec-0066-carried-tags-inflight.md)

`apply_pr_event.sh` resolves the task it moves from the head branch
alone. A branch name holds one id, so a pull request carrying two tasks
moves one of them: the second stays `ready` for the whole time its work
is in flight, and its mirror faithfully says so.

The machinery already has one answer to "which tasks does this pull
request carry" — `ql_carried_of`, which reads the branch *and* every
`[TASK-NNNN]` tag in the title. The merge half and the mirror
projection both use it. The in-flight half does not, and the `record`
job is never even handed the title to read.

Bring the in-flight half to the same helper the other two readers
already use, and hand the job the title it needs.

Why it matters: `titles.md` states the consequence exactly — a title
without its tag "reduces a multi-task pull request to reporting one
task, silently". Silently is the whole problem. A task the queue shows
as `ready` while someone is working it is an invitation for a second
person to take it, and nothing in the queue, the mirror or the checks
says otherwise until the merge lands and the disagreement disappears
along with the evidence.
