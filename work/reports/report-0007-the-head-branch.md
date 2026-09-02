---
id: report-0007
status: authored
task_ref: []
doc_ref: technical/distribution.md#running-the-checks
created: 2026-09-02T13:11:55Z
triaged: 2026-09-02T21:12:00Z
---

# The head branch reaches CI under two names

**References:** [technical/distribution.md#running-the-checks](../../docs/technical/distribution.md#running-the-checks)

The same value — the head branch of the pull request — now reaches two
scripts under two different environment variable names.

`writrun-progress.yml` and `writrun-approve.yml` pass it as
`PR_HEAD_REF`, alongside `PR_TITLE`, `PR_AUTHOR`, `PR_DRAFT` and
`PR_MERGED`; `apply_pr_event.sh`, `queue_lib.sh` and
`project_pr_tasks.sh` read that name. `writrun-check.yml` now passes it
as `HEAD_REF`, which is what `check_state.sh` reads — the name spec-0044
specified and the name that shipped.

Observed while implementing spec-0044: the plumbing was written from the
spec, and the existing `PR_HEAD_REF` convention was found afterwards, in
the neighbouring workflows. Nothing is broken — each script reads the
name its own caller sets, and the tests pin both — but an adopter
copying one workflow's `env:` block into the other's step gets a rule
that silently never fires, because an unset `HEAD_REF` falls back to the
checkout, which in CI is a detached HEAD.

The asymmetry has a defensible reading: `PR_*` is the prefix the Stage 2
*workflow-step* scripts use for pull-request event data, and
`check_state.sh` is a skill an agent also runs locally, where there is
no pull request. Whether that is the rule or an accident is what triage
decides.

**Triage:** the defensible reading is the rule, and it is now written —
`technical/distribution.md#running-the-checks` gains it, beside the two
caller rules already there. That section exists for exactly this shape
of hazard: a rule about how a gate is *called*, where a wrong call
passes.

One claim above is half wrong and is corrected here rather than left
standing. An unset `HEAD_REF` does not always give "a rule that silently
never fires". `check_state.sh` falls back to the checkout's own branch
name, and when even that is unreadable it prints three lines naming the
skip — "Rule K skipped — no branch name is readable" — because a check
that silently drops a rule it could not run is the failure mode worse
than the rule not existing. Two things survive the correction, both
narrower than the original claim. The announcement rides a check that
still exits 0, so it is a log line on a green run. And it fires only on a
detached HEAD: on an attached one the fallback hands rule K the branch
the runner happens to sit on, which for a `main` or `pr-NNN` checkout is
a name the rule judges silently, and wrongly.

`authored` rather than `tracked`: nothing is broken, so there is no work
to queue. The convention existed only in the heads of whoever last read
the workflows, which is why it was rediscovered twice — once writing
spec-0044, once triaging this. Writing it down is the whole remedy.
