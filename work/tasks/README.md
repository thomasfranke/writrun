# Tasks — the queue

**What is being worked on for this project itself.** One file per task, named
by id plus a tiny subject slug (`task-0001-adoption-kit.md`), never renamed,
never moved. Status, priority, and
dependencies live in front-matter — the full schema and the selection
algorithm are defined in
[`technical/README.md`](../../docs/technical/README.md#task-schema).

A task is the **request**: what to do, when, what blocks it. It holds no
technical detail — scope, steps, and acceptance criteria belong to its
spec(s) in [`specs/`](../specs/README.md). The task always exists before its
specs.

## What earns a task

Work that justifies tracking: a behaviour change, a new subsystem, anything a
future reader might ask "why was this done" about. A typo or a one-line fix
is a commit, not a task — see principle 6 in [`about.md`](../../docs/about.md).

## For agents

Do not choose work by reading this README or by directory listing order. Run
the [selection algorithm](../../docs/technical/README.md#task-selection-algorithm):
resume abandoned in-flight work first, then filter to `ready`, sort, and take the first. Read every
referenced spec and product anchor before writing code.
