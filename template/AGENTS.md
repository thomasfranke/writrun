# AGENTS.md — entry point for AI agents

<!-- TODO: one paragraph — what this project is and where its docs live. -->

Read in this order, stopping as soon as you have what the task needs:

1. [`docs/about.md`](docs/about.md) — what this project is. Always read.
2. [`docs/product/README.md`](docs/product/README.md) and
   [`docs/technical/README.md`](docs/technical/README.md) — the rules and
   the machinery. <!-- TODO: adjust if your docs/ takes another shape. -->
3. The specific task and its referenced specs/anchors — never code from
   the task title alone.

<!-- TODO: your project's own agent instructions live above this line. -->

## WritRun — working the queue

<!-- writrun:begin
     This section is WritRun's flow. Graft it whole into an existing
     AGENTS.md; tooling may refresh what sits between these markers on
     `writ update` — except the lines marked "yours", which survive every
     refresh. Flows: the README of the WritRun repository. -->

### Picking work

Use the [`writrun-select-next-task`](.writrun/skills/writrun-select-next-task/SKILL.md)
skill. A task is available only when it is `pending` **and** every spec in
its `spec_ref` is `approved`.

### Creating tasks and specs

Use the
[`writrun-create-task-and-spec`](.writrun/skills/writrun-create-task-and-spec/SKILL.md)
skill — it covers id assignment, front-matter, when a spec is warranted,
and the Proposed changes sections. A queue file touched by hand — a body
edited, a status flipped — must pass
[`writrun-check-front-matter`](.writrun/skills/writrun-check-front-matter/SKILL.md)
before it is committed.

### Human gates

<!-- yours: this table is the project's own answers; it survives updates. -->

| Transition | Who |
|---|---|
| Writing or changing anything under `docs/` | <!-- TODO — default: human writes or reviews before merge --> |
| An authored rule is finished, so derivation may start | <!-- TODO — default: the human declares it --> |
| Spec `draft → approved` | <!-- TODO — default: human only, recorded via the approved PR --> |
| Task with empty `spec_ref` and insufficient brief | <!-- TODO — default: stop and ask for a spec --> |
| Changing repository/forge settings (Actions permissions, rulesets, merge methods) | <!-- TODO — default: the owner assents in session, per set of changes --> |
| Everything else | Agent, autonomously. |

**The forge row is not optional the way its answer is.** Repository
settings live outside the repository — no diff, no review, no merge gate
sees them — so an agent applying one is acting where nothing can catch
it afterwards. Whoever the project names, the agent presents current →
target values first and applies only on an explicit yes.

### Deriving work

When derivation runs (a rule authored, or work discovered), present the
derived tasks and specs in the session before opening the PR, unless the
declaration says to open directly.
<!-- yours: keep, invert, or drop this default — it is the project's. -->

### Completing a task

1. Implement against the approved spec.
2. Update every permanent doc listed in the spec's **Proposed changes** —
   in the same change; touch nothing permanent that isn't listed.
3. Run `writrun-check-spec-deltas` (exit 0), fill the spec's **Outcome**,
   set spec `implemented` and task `completed`, run
   `writrun-check-task-state` (exit 0), open the PR.

Commit messages, branch names, PR titles, and task/spec style:
[`.writrun/conventions/`](.writrun/conventions/README.md).

<!-- writrun:end -->
