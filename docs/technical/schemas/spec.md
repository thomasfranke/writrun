# Spec

**The front matter and body shape of a spec file**, and the two Proposed-changes sections that close the loop. One chapter of [`schemas/`](README.md).

## Spec schema

```yaml
---
id: spec-0004
task_ref: task-0005                # a spec belongs to exactly one task
status: draft                      # draft | approved | implemented
created: 2026-08-20T16:02:00Z
---
```

A spec file is named `spec-NNNN-<subject>.md`, the same shape as a
task's — four-digit id plus an extremely short subject slug, fixed at
creation.

The `draft → approved` transition is a gate, and **who operates it is an
adopter decision, declared in `AGENTS.md`** — this methodology's own
`AGENTS.md` requires a human. An agent never self-approves a spec unless the
adopting project has explicitly written that policy down. `approved →
implemented` is mechanical: it happens when the task completes and the
Outcome section is filled.

A spec's body carries what a task's front-matter must not: scope, steps, EARS
acceptance criteria, edge cases, tests required, Definition of Done, and two
sections that close the loop between ephemeral and permanent docs:

```markdown
## Proposed product changes
- `product/coverage/ignore-patterns.md#pattern-with-no-match` — new rule: a
  pattern matching nothing warns and exits 0.
(or: "none — no behaviour change")

## Proposed technical changes
- `technical/engine/adapter.md` — document the new extension point.
- `technical/engine/decisions.md` — new dated entry: why warning over error.
(or: "none — no machinery change")

## Outcome
(filled when the task completes: what was actually built, anything that
diverged from the plan above, and why)
```

The **Proposed changes** sections are what a completed task is checked
against before merge — every listed path+anchor should appear touched in the
diff, and the diff shouldn't quietly touch a permanent doc that wasn't listed.
This turns "update the docs in the same PR" from a prose reminder into
something a script or a reviewing agent can verify mechanically.

