# Task

A task is a **tracked unit of work**: what to do, when, what blocks it. It
holds no technical detail — scope, steps, and acceptance criteria belong to
its [spec](spec.md), not to the task itself. A task is the request; a spec
is its elaboration. The task always exists before its spec.

## Two invariants

- **Identity is never order.** A task's id (`task-005`) is permanent.
  Priority, sequencing, and status live in mutable front-matter fields, so
  reprioritising work never renames a file, and a deleted task's id is never
  reused.
- **No technical detail in the task body.** If a sentence in a task reads
  like an implementation step, an acceptance criterion, or an edge case, it
  belongs in the spec. A task that tries to also be its own spec breaks the
  separation the whole pipeline depends on.

## What earns a task

Work that justifies tracking: a behaviour change, a new subsystem, anything
a future reader might reasonably ask "why was this done" about. A typo or a
one-line fix is a commit, not a task — forcing trivial work through the
queue cheapens what the queue is for.

## Selection

An agent never picks a task by directory listing order, filename, or "the
one that looks easiest." The algorithm — resume any unfinished
`in-progress` task first, then filter to `pending`, exclude anything whose
`depends_on` isn't fully `completed`, sort by priority then by `created`
then by `id` — is specified in full in
[`technical/README.md`](../../technical/README.md#task-selection-algorithm),
not restated here.

## `blocked` vs. `depends_on`

Two different kinds of "can't start," and a task never uses one to mean the
other:

- **`depends_on`** — blocked by another task in this same queue. Resolves
  itself once that task's status is `completed`; no human judgement needed.
- **`status: blocked`** — blocked by something outside the queue entirely:
  an unanswered decision, an upstream release, a spike whose result could
  invalidate the plan. Requires a non-null `blocked_reason` stating what
  unblocks it.

## Example

A complete, schema-correct task — every field filled explicitly, because an
omitted field is never the same as an empty one:

```yaml
---
id: task-005
status: pending
blocked_reason: null
spec_ref: [spec-011]
doc_ref: product/editor/search-and-replace.md#scope
priority: high
depends_on: [task-003]
milestone: v0.1-core
created: 2026-08-21
completed: null
---

# Search and replace across multiple files

Allow a user to search and replace text across every open `.md` file at
once, not just the current one.

Full detail in spec-011.
```

Three details worth naming, because a hand-written task drifted on exactly
these while drafting this chapter:

- **`spec_ref` is always a list**, `[spec-011]`, even for a single spec —
  never the bare scalar `spec-011`. The relationship is 0..N; the syntax
  says so even when N happens to be 1.
- **`doc_ref` is a full path with an anchor, resolved relative to
  `docs/`** — `product/editor/search-and-replace.md#scope`, never a bare
  filename like `search-and-replace.md`. A bare filename can't be grepped
  back to reliably and doesn't say which part of the chapter the task
  actually concerns.
- **Every field is present**, including the ones that are `null` — an
  omitted `blocked_reason` and an explicit `blocked_reason: null` are not
  the same statement to a reader or a script.
