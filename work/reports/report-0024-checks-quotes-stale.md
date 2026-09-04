---
id: report-0024
status: fixed
task_ref: []
doc_ref: technical/distribution/checks.md#running-the-checks
created: 2026-09-04T17:09:01Z
triaged: 2026-09-04T18:40:00Z
---

# checks.md quotes a no-op line apply_pr_event.sh no longer prints

**References:** [technical/distribution/checks.md#running-the-checks](../../docs/technical/distribution/checks.md#running-the-checks)

`distribution/checks.md` quotes a line `apply_pr_event.sh` prints, to
make a point about a miswired workflow being indistinguishable from an
ordinary one:

> an unset `PR_HEAD_REF` exits 0 printing `head '' names no task branch
> — nothing to record`, the line every pull request that is not a task
> branch legitimately prints

task-0047 rewrote that guard: the script now asks whether the pull
request carries any task rather than whether the branch is a task
branch, and prints `head '' and title '' carry no task — nothing to
record`. The paragraph's argument survives the change untouched — the
hazard is that the miswired case and the legitimate case print the same
line, and they still do. The quoted string is what went stale.

Noticed while implementing task-0047, and left alone deliberately:
spec-0066 promises no technical delta, and `check_deltas.sh` refuses any
unpromised path under `docs/`, so the promise and the fix could not both
be honoured in that change. The promise won.

Fixed once task-0047 had merged, in a change of its own. The quote is
the current line, and the paragraph gains the consequence of the wider
guard: two names rather than one is a wider way to be miswired, since
the step goes quiet if either is copied wrong.
