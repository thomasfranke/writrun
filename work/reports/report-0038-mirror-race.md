---
id: report-0038
status: tracked
task_ref: [task-0062]
doc_ref: null
created: 2026-09-06T05:16:13Z
triaged: 2026-09-06T05:16:31Z
---

# Two forge events one second apart minted two mirrors for one report

**References:** [task-0062](../tasks/task-0062-serialize-forge-writes.md)

Issues #234 and #235 both mirror report-0037, both created at
2026-09-06T05:01:19Z. The push that carried the report and the
`gh pr ready` that followed it landed within a second of each other on
PR #233, and `writrun-issues.yml` runs on both events (`synchronize`,
`ready_for_review`) with no `concurrency` group — two runs searched
for an existing REPORT-0037 mirror, neither saw the other's mint, and
both created one. The merge's own pass then adopted #235
(`status:open`, body relinked to `main`) and left #234 standing as it
was minted (`status:proposed`, body pinned to the head SHA).

The lookup is by title search with no lock and no uniqueness on the
forge's side, and `mirror_issues.sh` already names this failure shape
for a different cause — "a lookup that only knows the new shape does
not report a miss — it mints a second mirror for a task that already
has one" (its comment on pre-rule titles). The race reaches the same
end through time instead of shape, and nothing in the reconciler
closes a duplicate it finds later.

Of the kit's four forge-writing workflows only `writrun-intake.yml`
declares `concurrency`; `writrun-issues.yml`, `writrun-progress.yml`
and `writrun-approve.yml` do not — and the progress pass writes queue
statuses, where the same two-events-one-second shape would race two
status writers rather than two mirror mints.

Observed on this repository's own tracker; #234 was closed by hand as
the duplicate, with a comment naming this report.
