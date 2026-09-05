---
id: task-0051
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0070]
doc_ref: product/stage-3-github-issues/labels.md#criteria
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-04T18:30:54Z
queued: 2026-09-04T19:23:29Z
completed: 2026-09-04T21:34:01Z
merged: null
provenance:
  - {by: agent, model: claude-fable-5, login: thomasfranke, input: 0, output: 0, cache_read: 0, cache_write: 0}
---

# Spend the re-read budget only where a miss can be staleness

**References:** [product/stage-3-github-issues/labels.md#criteria](../../docs/product/stage-3-github-issues/labels.md#criteria) · [spec-0070](../specs/spec-0070-refresh-budget-spend.md)

`rederive_labels.sh` re-reads the mirror list when a lookup misses,
because the job that reads the list may have minted the mirror after
reading it. The re-read is spent on every miss, whatever named the id,
and the budget is the run's.

Spend it only where a miss can be staleness, and decide the envelope
with it.

Why it matters: it costs where nothing is wrong and runs out where
something is. `project_pr_tasks.sh` passes no `--minted` and mints
nothing, so a task whose mirror was never created pays two extra
paginated list reads and six seconds on *every* pull-request event, for
an answer the first read already gave. And on the approve path a miss
from `specs` or `scope` burns both re-reads in the first six seconds,
leaving an id the mint really did answer for no read of its own to
force — a red step produced by the budget policy of the change that
exists to prevent one.

The envelope belongs to the same decision: the gap observed was about
four seconds against a flat 3 + 3, and an overrun that used to be a
warning under a green job is now a failed step with no automatic second
chance.
