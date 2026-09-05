---
id: report-0032
status: tracked
task_ref: [task-0054]
doc_ref: product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes
created: 2026-09-05T12:56:15Z
triaged: 2026-09-05T12:56:31Z
---

# Six open pull requests carry findings they could not fix in place

**References:** [product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes](../../docs/product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes) · [task-0054](../tasks/task-0054-six-review-findings.md)

A review of the six pull requests open on 2026-09-05 — #199, #200,
#201, #202, #203 and #204 — found six things none of them could fix
where they stood. Each is either outside the reviewed spec's declared
deltas, or a different kind of change from the one the pull request
carries.

**Three sentences a merged change will leave false.** `checks.md`
enumerates the `PR_*` names that reach `apply_pr_event.sh` and omits
`PR_NUMBER`, which #200 adds and reads at `apply_pr_event.sh:200`.
`new.sh:448` still says a reporting pull request "presents the report,
the task and the spec together", which #202 falsifies. `statuses.md`'s
criterion names one refusal class — "the authority branch refused it" —
where after #199 there are three.

**The tab-collapse hazard #200 fixed stands in two sibling readers.**
`check_amendment_reference.sh:210` and `check_unique_ids.sh:198` read
the same interpolated-tab listing positionally. spec-0068 put both out
of scope by name, and its own lines 34-43 say a shared reader in
`queue_lib.sh` is what ends the class.

**Nothing enforces the rule #202 authors.** After it, a task whose spec
is drafted later must land `blocked` with a `blocked_reason` naming the
spec owed. A `report/` pull request that adds an `origin: report` task
with `spec_ref: []` and leaves it `backlog` passes every gate today and
lands `ready` at merge.

**`writrun-approve.yml` labels the mirror from the working tree.**
`rederive_labels.sh:466` calls `queue_file work/tasks`. After a failed
recording that tree still carries the commit `main` refused, so the
mirror ends up ahead of the queue. spec-0067's Outcome records this as
a divergence, on #199.

**A title edited after the recording never re-records.**
`writrun-progress.yml:31` carries no `edited` trigger. That is the
cause of the stranded-in-flight close #204 had to work around, and
`project_pr_tasks.sh` still exits 1 on an over-ceiling `closed` event,
so `reflect` goes red and the mirror labels stay stale.

**`make test-integration` runs 57 of the suite's 253 integration cases
and exits 0.** Its glob is `tests/integration/*/*_test.sh`, one level
deep; 196 cases live two levels down under `stage-1/`, `stage-2/` and
`stage-3/`. `tests/run.sh` separately appends every result to one fixed
`tests/.tally`, truncated only at start, so two overlapping runs in one
worktree inflate each other — observed here as 795 and 808 against a
true 405.

**Triage:** all six are work rules already standing authorize →
task-0054, specs 0072-0077.
