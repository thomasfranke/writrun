---
id: task-0041
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0057]
doc_ref: technical/schemas.md#front-matter-is-canonical
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-03T04:06:37Z
queued: 2026-09-03T04:18:32Z
completed: 2026-09-03T04:29:28Z
merged: 2026-09-03T19:11:11Z
provenance:
  - {by: agent, model: claude-sonnet-5, login: thomasfranke}
---

# The state check reads task files by id, never by directory

**References:** [technical/schemas.md#front-matter-is-canonical](../../docs/technical/schemas.md#front-matter-is-canonical) · [spec-0057](../specs/spec-0057-readme-not-a-task.md)

`check_state.sh` selects the files it judges by the directory they sit
in — `work/tasks/*.md` — so the queue's own `README.md` is read as a
task. It has no front matter, its status reads empty, and the rule that
refuses a task born outside `backlog` refuses it. Reported in
[report-0013](../reports/report-0013-queue-readme.md).

Make the selection read the id the filename carries, which
`schemas.md#front-matter-is-canonical` already fixes as the `task-NNNN`
prefix of `task-NNNN-<subject>.md`. The check judges tasks; a file that
is not one should not reach the rules that judge them.

**This is reachable only on a first adoption**, which is why it survived
this long: this repository's own READMEs entered the tree before Stage 2
existed and never appear as added in a pull request range. An adopter's
first pull request carries all three, so every project adopting the kit
at Stage 2 or above meets it — the kit refusing its own scaffolding, on
the one change where the adopter has nothing to compare it against.

The sibling globs over `work/specs/` and `work/reports/` have the same
shape and did not refuse the observed diff; whether they are corrected
with this one is the spec's to decide, not this task's to assume.
