---
id: report-0007
status: open
task_ref: []
doc_ref: technical/README.md
created: 2026-09-02T13:11:55Z
triaged: null
---

# The head branch reaches CI under two names

**References:** [technical/README.md](../../docs/technical/README.md)

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
