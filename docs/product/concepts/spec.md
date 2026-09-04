# Spec

A spec is **the elaboration of one task**: scope, steps, EARS acceptance
criteria, edge cases, tests required, Definition of Done — everything a
[task](task.md) is not allowed to hold. A spec belongs to exactly one task
and has no order or priority of its own; it inherits both from that task.
An orphan spec — one with no task it elaborates — is a structural error, not
a shortcut.

## Lifecycle

`draft → approved → implemented`

- **draft** — written, typically by an agent, for an existing task. Nothing
  in draft status may be treated as authorized to implement yet.
- **approved** — the gate. Who operates it is an adopter decision, stated
  explicitly at the address that project's entry point carries or links
  (the kit's is `.writrun/gates.md`); this methodology's own default
  is that only a human moves a spec from draft to approved. An agent never
  self-approves, even when it also wrote the draft. **Content under an
  approval never changes silently**: when an approved spec must change —
  usually because the doc it derives from moved ahead of the queue, and
  the doc always wins — the amendment returns it to `draft` in the same
  change and passes this gate again.
- **implemented** — set when the task completes and the spec's **Outcome**
  section records what was actually built, including any divergence from
  the plan. An implemented spec is never edited afterward to match reality
  retroactively beyond that Outcome section — the divergence is the record,
  not something to be smoothed over.

## The doc-delta contract

Every spec carries two sections that close the loop between the ephemeral
work it describes and the permanent docs it will change:

```markdown
## Proposed product changes
- `product/<chapter>.md#<anchor>` — one line on what changes and why.
(or: "none — no behaviour change")

## Proposed technical changes
- `technical/<section>.md#<anchor>` — one line on what changes and why.
(or: "none — no machinery change")
```

This list is the **merge contract**: the diff that completes the task must
touch every path listed here, and must not touch any other permanent doc.
That is what turns "update the docs in the same change" from a habit some
contributors remember into something checked mechanically — see
[`writrun-check-spec-deltas`](../../../.writrun/skills/writrun-check-spec-deltas/SKILL.md) — instead
of trusted to whoever happens to be finishing the task.

**A promise names a document or a folder.** The per-path form names one
`.md` file, because what it points at is a rule under an anchor; the
folder form ends in a slash, is honoured by any change under it, and
declares everything under it. A file under `docs/` that is not a
document — a diagram, an image — carries neither a rule nor an anchor,
so naming it per path buys the loop nothing: it is declared by the
folder that holds it. **Keep those files in a folder of their own.**
Loose beside the chapters, the only folder that declares one is the
chapter's own, and a promise reaching that far declares every rule
beside it — the coarse form the per-path promise exists to avoid.

**A promise includes its mandatory companions.** Some documents never
change alone: a rule elsewhere makes touching one imply touching another,
and a promise that names the first without the second is not a smaller
promise — it is a wrong one, discovered at the worst possible time. The
named case is the dated decisions log: its chronology index is appended
whenever an entry is added, so a spec promising a decision entry promises
the index row with it. An incomplete promise is refused **where the spec
enters** — at creation or amendment, where fixing it is one edit — never
left for the completion gate, where it forces an amendment under a
finished branch and suspends the task
([Conflicts](../stage-1-tasks-and-specs/conflicts.md#a-spec-changes-after-its-approval)).

## Example

The spec for the task shown in [Task](task.md#example):

```yaml
---
id: spec-0011
task_ref: task-0005
status: draft
created: 2026-08-21T09:31:00Z
---

# spec-0011 — Search and replace across multiple files

- **Goal:** let a user find and replace text across every open `.md` file
  in one operation, instead of repeating the same edit file by file.

## Scope

The multi-file search UI and the replace-all execution path. Out of scope:
regex support, which stays single-file until a separate task asks for it.

## Steps

1. Extend the existing single-file search index to cover every open file.
2. Add a "replace all in open files" action, gated behind a confirmation
   that shows a preview of every match before it commits.

## Acceptance criteria (EARS)

- When a user searches with more than one file open, matches from every
  open file shall appear in one result list.
- When a user confirms replace-all, every previewed match shall be replaced
  and no unmatched text shall change.

## Edge cases

- Zero matches: the replace action stays disabled rather than running a
  no-op.
- A file that changes on disk between preview and confirm: the operation
  aborts that file and reports it, rather than overwriting an unseen edit.

## Tests required

Unit tests for the index merge; an integration test for the preview →
confirm → commit path, including the concurrent-edit abort case.

## Definition of Done

- [ ] Multi-file search and replace-all shipped behind the confirmation
      preview.
- [ ] Concurrent-edit abort case covered by a test.

## Proposed product changes
- `product/editor/search-and-replace.md#scope` — new chapter: multi-file
  search and replace, its confirmation step, and the concurrent-edit abort
  rule.

## Proposed technical changes
- `technical/editor/decisions.md` — new dated entry: why the index is
  extended rather than rebuilt per operation.

## Outcome
_(fill after execution)_
```

Two things this example makes concrete: **`doc_ref` in the task
resolves to exactly the anchor this spec proposes to create** — the task
didn't invent a path that the spec then has to reconcile — and **every
Proposed-changes entry is a path a reviewer can go check for real**, not a
description of intent.
