# work — the queue

The ephemeral half of the repository: what is pending or what was
noticed, never what is true. `docs/` describes the system as it is
today; everything here describes changes in flight, and the
observations that feed them — shipped by WritRun's pipeline.

| | |
|---|---|
| [`tasks/`](tasks/README.md) | The requests — what to do, when, what blocks it. No technical detail. |
| [`specs/`](specs/README.md) | The elaborations — scope, steps, criteria, the doc-delta contract. Historical record once done. |
| [`reports/`](reports/README.md) | The observations — what was seen, and which way triage sent it. Commits to nothing. |

Tasks and specs are machine-managed through the flows (see
[Pipeline](../docs/product/stage-1-tasks-and-specs/README.md)):
created by `writrun-create-task-and-spec`, selected by
`writrun-select-next-task`, checked at completion by the two check
skills.

**Reports sit outside that pipeline on purpose.** Nothing selects one,
nothing completes one, and recording one rides whatever change is
already open rather than a branch of its own. The generator does not yet
mint them either — that is
[task-0031](tasks/task-0031-report-kind.md)'s job, and until it lands a
report is written by hand against the
[schema](../docs/technical/README.md#report-schema).

Statuses live in front-matter, never in folder position — nothing moves
between directories as work progresses.
