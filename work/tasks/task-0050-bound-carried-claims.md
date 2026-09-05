---
id: task-0050
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0069]
doc_ref: technical/settings/titles.md#pr_title_style
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-04T18:30:52Z
queued: 2026-09-04T19:23:29Z
completed: 2026-09-05T10:36:25Z
merged: null
provenance:
  - {by: agent, model: claude-fable-5, login: thomasfranke}
  - {by: agent, model: claude-opus-5, login: thomasfranke}
---

# Bound what a pull request title may claim

**References:** [technical/settings/titles.md#pr_title_style](../../docs/technical/settings/titles.md#pr_title_style) · [spec-0069](../specs/spec-0069-bound-carried-claims.md)

`writrun-progress.yml` runs on `pull_request_target`, so a fork's pull
request reaches the recording, and both routes into the carried set —
the head branch and the title — are the author's to write. Nothing bounds
how many tasks a title may name.

Decide what a pull request may claim, and hold it to that.

Why it matters: the kind of exposure is not new — a fork could always
claim the one task its branch spelled — but the amount is. A single fork
pull request titled `[TASK-0001]…[TASK-0100]` now moves a hundred tasks
to `in-progress` with `taken_by:` naming its author, in one commit
pushed to the default branch. What has to be weighed is a ceiling
against the legitimate multi-task pull request the carried set exists to
serve, which is why this is a task and not a number chosen in passing.
