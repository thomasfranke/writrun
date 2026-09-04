---
id: report-0030
status: tracked
task_ref: [task-0053]
doc_ref: product/stage-1-tasks-and-specs/authoring.md
created: 2026-09-04T21:14:03Z
triaged: 2026-09-04T21:14:33Z
---

# The kind table has no cell for a spec that lands after its task

**References:** [product/stage-1-tasks-and-specs/authoring.md](../../docs/product/stage-1-tasks-and-specs/authoring.md) · [task-0053](../tasks/task-0053-late-spec-route.md)

Five pull requests — #191, #192, #193, #194 and #195 — each carry one
spec and the two-line `spec_ref` edit on its task, and nothing else.
Their tasks (task-0048 through task-0052) entered the queue earlier,
through #184's `tracked` route, with `spec_ref: []`: the specs were
drafted afterwards, on `report/` branches of their own.

No documented kind describes that shape. `AGENTS.md`'s table is
exhaustive on its three kinds, and each "PR states" cell misses:
an authoring PR states "the tasks and specs it created" (these created
no task), a reporting PR states "the report, the pair it adds, the rule
they derive from" (these add half a pair and no report), and an
implementing PR states "the spec(s) it implements" (these implement
nothing). The `tracked` route's own sentence in
[`authoring.md`](../../docs/product/stage-1-tasks-and-specs/authoring.md)
says "the `report/` branch presents the report, the task and the spec
together" — which #184 did not do and could not usefully have done:
five specs of roughly 250 lines each beside five reports and five tasks
would have been one merge assenting to everything at once.

The practice has support one step down:
`writrun-create-task-and-spec`'s own description anticipates "when an
existing task needs its spec drafted before implementation can start",
and names no branch kind for it. The spec-approval gate is intact
either way — each spec's `draft → approved` is still its own merge. So
the observation is a documentation gap, not a violation with a cost:
review flagged all five pull requests as matching no kind, and every
future spec-drafted-later pull request will be flagged the same way
until some rule states the shape.
