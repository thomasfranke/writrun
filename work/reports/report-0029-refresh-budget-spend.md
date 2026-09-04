---
id: report-0029
status: tracked
task_ref: [task-0051]
doc_ref: product/stage-3-github-issues/labels.md#criteria
created: 2026-09-04T17:59:56Z
triaged: 2026-09-04T18:30:54Z
---

# The re-read budget is spent on ids whose absence is already the answer

**References:** [product/stage-3-github-issues/labels.md#criteria](../../docs/product/stage-3-github-issues/labels.md#criteria) · [task-0051](../tasks/task-0051-refresh-budget-spend.md)

task-0046 makes `rederive_labels.sh` re-read the mirror list when a
lookup misses, on the reasoning that a miss is not a conclusion: the
same job may have minted the mirror after the list was read. The re-read
is spent on *every* miss, whatever named the id, and the budget is the
run's — two per list, three seconds apart.

Two things follow that the change did not weigh.

**The wasted spend.** `project_pr_tasks.sh:40` calls the script with
`$carried` and never passes `--minted`; that is the `writrun-progress.yml`
path, and it fires on every pull-request event. Nothing mints in that
job, so a task in `work/tasks/` whose mirror was never created pays, on
every pull-request event, two extra paginated `gh api` reads of the whole
Issue list and six seconds of `sleep` — for an answer the first read had
already given. The new
`an_id_the_job_minted_cannot_be_missing_test.sh:33` asserts exactly that
cost (`forge_told_times "after the re-reads are spent" 3`).

**The wrong id spending it.** On the `writrun-approve.yml` path the
argument order is `specs`, `scope`, `--minted …`. A miss coming from
`specs` or `scope` burns both re-reads in the first six seconds of the
job. The list is shared, so a `--minted` id looked up later still sees
the freshest read — but it has no read of its own left to force. In a
long job (fourteen tasks, several `gh` calls each) that id is answered
from a list already tens of seconds old, and a miss there is not a
notice: `unresolved` sets `FAILED` and the step exits 1. The failure
mode the change exists to remove can be produced by the change's own
budget policy.

The two are one question, which is why they are recorded together: what
the envelope should be, and who is entitled to spend it. The cheap guard
is to skip the retry where `minted` is false — a miss there is a finding
about the repository, not a symptom of staleness. It is not folded into
task-0046 because two of that spec's own acceptance cases exercise the
re-read with no `--minted` at all
(`a_mirror_younger_than_the_read_is_found_test.sh`, the first and last
cases), so narrowing it is a change to what the spec accepted rather
than a defect in what it built.

The envelope belongs to the same decision. The gap observed in
report-0021 was about four seconds against a flat 3 + 3, under two times
over, with no jitter — and where it used to overrun into a warning and a
green job, it now overruns into a red step with no automatic second
chance, since pushes made with `GITHUB_TOKEN` trigger no workflow runs.
Widening it alone would only make the budget above more expensive to
waste, so it is left as the spec set it.
