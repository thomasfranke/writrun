---
id: spec-0030
task_ref: task-0021
status: draft
created: 2026-08-31T03:18:55Z
---

# spec-0030 — The adoption kit carries the Stage 2 setup

- **Goal:** an adopter's agent finds the Stage 2 forge setup — the
  settings, the commands, and above all the owner-assent gate — inside
  the kit it was installed from, not only in this repository's docs.
  The gate travels with the automation: no kit copy exists in which an
  agent reads the commands without reading that it must present the
  changes and wait for an explicit yes.

## Scope

In: `template/WRITRUN.md` (the adoption guide) and the kit's
`AGENTS.md` skeleton, plus the template-mirror sync.

Out: the setup chapter itself
(`docs/product/stage-2-pull-requests/setup.md` — authored, stays the
source of truth; the kit points, never restates the commands); any new
skill (the chapter is agent-runnable as written; a skill is a later
decision if adopters ask for one).

## Steps

1. `template/WRITRUN.md`: the adoption walkthrough gains a Stage 2
   setup step that points at the setup chapter and states the gate in
   one line — the agent presents current → target values and applies
   only on the owner's explicit, in-session yes.
2. The kit's `AGENTS.md` skeleton: the human-gates table ships with the
   forge-settings row, so every adopting project starts with the gate
   named rather than having to rediscover it.
3. `make template-sync`; confirm the mirror test covers the touched
   files.

## Acceptance criteria (EARS)

- When an adopter reads the kit's guide at the Stage 2 step, it shall
  name the owner-assent gate before pointing at the commands.
- When the kit's `AGENTS.md` skeleton is grafted into a project, its
  gates table shall already carry the forge-settings row.
- When the template mirrors are compared to the root files they copy,
  they shall be byte-identical.

## Edge cases

- An adopter at Stage 1: the guide's step reads as skippable — the
  setup chapter itself already says nothing there conditions adoption.
- A project whose `AGENTS.md` was grafted before this change: nothing
  rewrites it; the gate reaches them through the setup chapter their
  agent reads when Stage 2 work begins.

## Tests required

The template-mirror unit test green over the touched kit files; no new
machinery, no new checks.

## Definition of Done

- [ ] Kit guide names the gate and points at the setup chapter.
- [ ] Kit `AGENTS.md` skeleton ships the forge-settings gate row.
- [ ] Template mirrors byte-identical; suite green.

## Proposed product changes

- none — the setup chapter was authored first; this change ships its
  pointer and gate inside the kit.

## Proposed technical changes

- none — kit files only; no schema, script or workflow behaviour
  changes.

## Outcome

_(fill after execution)_
