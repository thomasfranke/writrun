# Specs — the detail of one change

**Historical record — not a description of the present.** One file per spec,
named by id (`spec-001.md`). A spec belongs to exactly one task (`task_ref`)
and inherits its order and priority from it; specs have no sequence of their
own. The full schema is in
[`technical/README.md`](../../docs/technical/README.md#spec-schema).

A spec is the **elaboration** of a task's request: scope, steps, EARS
acceptance criteria, edge cases, tests required, Definition of Done — and the
two **Proposed changes** sections that list exactly which permanent docs the
change will touch. That list is the merge contract: the completing diff must
touch everything listed and nothing permanent that isn't.

## Lifecycle

`draft → approved → implemented`

- **draft** — written (typically by an agent) for an existing task.
- **approved** — the gate. In this repo, approval is human — see
  [`AGENTS.md`](../../AGENTS.md). An agent never self-approves.
- **implemented** — set when the task completes and the **Outcome** section
  records what was actually built, including any divergence from the plan.

An implemented spec is never edited to match reality retroactively beyond its
Outcome section — divergence is documented, not erased. The permanent docs
describe the present; the spec preserves what was intended and what happened.
