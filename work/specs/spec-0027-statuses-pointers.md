---
id: spec-0027
task_ref: task-0021
status: approved
created: 2026-08-31T02:47:41Z
---

# spec-0027 — Machinery pointers follow the statuses split

- **Goal:** every comment and skill instruction that cites the status
  projection cites the chapter that now holds it —
  `product/stage-2-pull-requests/statuses.md` — instead of the Stage 1
  chapter it moved out of. A reader following any of these pointers
  today lands on a chapter that no longer draws the projection.

## Scope

In: doc pointers inside the machinery — script and workflow comments,
and the one skill instruction that cites the projection — plus their
template mirrors.

Out: any behaviour change (every edit is a comment or an instruction's
link — no code path moves); pointers that cite the Stage 1 chapter for
what still lives there (the vocabularies and the four dates stay in
`product/stage-1-tasks-and-specs/statuses.md`, and references to those
stand).

## Steps

1. Repoint the projection citations in
   `.writrun/scripts/stage-2-pull-requests/record_task_status.sh`,
   `flip_task_status.sh`, `apply_pr_event.sh`,
   `.writrun/skills/writrun-check-task-state/check_state.sh`,
   `.writrun/skills/writrun-create-task-and-spec/SKILL.md`,
   `.github/workflows/writrun-approve.yml`, and
   `.github/workflows/writrun-progress.yml` to
   `product/stage-2-pull-requests/statuses.md`.
2. For each, read the sentence around the pointer: one that cites the
   moved projection repoints; one that cites what stayed (values,
   dates) keeps its target.
3. `make template-sync` so the mirrored copies match.

## Acceptance criteria (EARS)

- When a machinery comment or skill instruction cites the status
  projection, it shall cite `product/stage-2-pull-requests/statuses.md`.
- When a machinery comment cites what remained in the Stage 1 chapter,
  it shall keep citing `product/stage-1-tasks-and-specs/statuses.md`.
- When the template mirrors are compared to the root files they copy,
  they shall be byte-identical.

## Edge cases

- A pointer whose surrounding sentence mixes both concerns (projection
  and vocabulary): cite the projection chapter, which links back to the
  vocabularies in its first line.

## Tests required

The existing suite green — the template-mirror unit test is the one
that can fail here; no new tests, since no behaviour changes.

## Definition of Done

- [ ] No machinery file cites the Stage 1 chapter for the projection.
- [ ] Template mirrors byte-identical; suite green.

## Proposed product changes

- none — the chapters themselves moved in the authoring change; this
  only repoints the machinery's citations.

## Proposed technical changes

- none — comments and instruction links only; no machinery behaviour or
  schema changes, and no technical chapter edits.

## Outcome

_(fill after execution)_
