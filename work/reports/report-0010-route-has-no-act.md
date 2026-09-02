---
id: report-0010
status: open
task_ref: []
doc_ref: technical/distribution.md#take_tasksh--the-taking-act-in-one-command
created: 2026-09-02T18:57:17Z
triaged: null
---

# Routing a report to the queue has no single act

**References:** [distribution.md](../../docs/distribution.md)

Taking a task is one command — `take_task.sh` — and
`distribution.md#take_tasksh--the-taking-act-in-one-command` explains
why: the act ends at the open draft pull request, not at the branch, so
a session doing it by hand stops halfway often enough to be worth
scripting.

Routing a report to `tracked` ends the same way — its pull request is
the assent — and has no equivalent. This run was: `git switch -c`,
`new.sh task --from-report`, fill the body, `new.sh spec`, fill the
spec, `git add`, commit, then each gate invoked by hand with its own
range. The two generator calls are documented together in
`writrun-create-task-and-spec`; the rest is assembled per session from
`AGENTS.md`'s kind table, which states *which* gates apply to a
reporting change but not how to run them.

Completing a task has `preflight.sh` for exactly that job — the gates,
in order, one command. A reporting change has the same gates minus
spec-deltas and no such entry point, so the range and `HEAD_REF`
arguments are re-derived each time. A wrong range is not a loud failure:
`check_state.sh` refuses an empty one, but only because that refusal was
written deliberately.

Observed while triaging report-0006. Not investigated: whether this is
one script, an argument to `preflight.sh`, or documentation gathered in
one place rather than three.