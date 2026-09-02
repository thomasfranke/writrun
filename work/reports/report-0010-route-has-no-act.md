---
id: report-0010
status: declined
task_ref: []
doc_ref: technical/distribution.md#take_tasksh--the-taking-act-in-one-command
created: 2026-09-02T18:57:17Z
triaged: 2026-09-02T21:12:00Z
---

# Routing a report to the queue has no single act

**References:** [technical/distribution.md#take_tasksh--the-taking-act-in-one-command](../../docs/technical/distribution.md#take_tasksh--the-taking-act-in-one-command)

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

**Triage:** declined. The central claim is false, and the measurement
behind it was of a session that did not reach for the tool.

`preflight.sh` is the entry point this report says does not exist. Run
with no arguments on a `docs/` branch it prints all three stages, names
the change ("No spec reached 'implemented' — authoring change, deltas
not applicable"), and stops on the third — verified on the branch that
carries this triage. It also derives what the report says is re-derived
each time: it runs `git fetch origin main` itself and composes
`origin/main...HEAD`, and it calls `check_state.sh` without `HEAD_REF`,
because outside CI that script already reads the branch name from the
checkout. The reporting route needs no arguments at all. The by-hand
invocations that produced this report were avoidable by reading
`distribution.md#preflightsh--the-completion-gates-in-order`.

What survives is the smaller half: there is no single command that
composes the branch, mints the pair and opens the pull request, the way
`take_task.sh` does for taking. That is a convenience, not a defect. The
two generator calls sit together in `writrun-create-task-and-spec`, the
route runs rarely, and every gate after them is one command. A script
earns its place when the by-hand path is error-prone; here it is
three commands and a gate.

Declining destroys nothing. The file stays, this reasoning is on it, and
a second observation reopens the question if the route turns out to cost
more than this says.
