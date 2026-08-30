# work — the queue

The ephemeral half of the repository: what is pending, never what is
true. `docs/` describes the system as it is today; everything here
describes changes in flight — shipped by WritRun's pipeline.

| | |
|---|---|
| [`tasks/`](tasks/README.md) | The requests — what to do, when, what blocks it. No technical detail. |
| [`specs/`](specs/README.md) | The elaborations — scope, steps, criteria, the doc-delta contract. Historical record once done. |

Files here are machine-managed through the flows (see
[Pipeline](../docs/product/stage-1-tasks-and-specs/README.md)):
created by `writrun-create-task-and-spec`, selected by
`writrun-select-next-task`, checked at completion by the two check
skills. Statuses live in front-matter, never in folder position — nothing
moves between directories as work progresses.
