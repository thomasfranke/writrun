---
id: spec-0058
task_ref: task-0042
status: implemented
created: 2026-09-03T23:37:15Z
---

# spec-0058 — Reshape the kit's entry point into a pointer

**References:** [task-0042](../tasks/task-0042-entry-point-pointer.md)

- **Goal:** the kit's claim on the adopting project's `AGENTS.md` shrinks
  to a four-line pointer; the flow moves to a kit-owned
  `.writrun/AGENTS.md` an update replaces whole; the four human gates
  move to an adopter-owned `.writrun/gates.md` an update never touches;
  Claude Code gets a one-line `CLAUDE.md` shim; the `writrun:begin` /
  `writrun:end` markers and the "yours" lines disappear.

## Scope

The kit (`template/`), the mirrored `.writrun/` at this repository's
root, this repository's own entry point where the new files would
otherwise duplicate it, `docs/technical/distribution/kit.md`, and the
template guards.

Out of scope by name: a `writ update` command — none exists; this change
states the semantics one will obey. Shims for vendors other than Claude
Code — Codex and Antigravity read `AGENTS.md` at the root natively, so
they are documented, not shipped.

## Steps

1. **`.writrun/AGENTS.md`** (new, kit-owned, lands in `template/` via the
   mirror): the flow that today sits between the markers in
   `template/AGENTS.md` — picking work, creating tasks and specs, taking,
   reports, completing, the settings pointer — unchanged in substance.
   It opens by stating its ownership: WritRun's file, replaced whole on
   update, never edited in place; the project's answers live in
   [`gates.md`](gates.md); humans read `WRITRUN.md` at the root instead.
   The gates table and the derivation default leave this file — where
   the flow needs them it links `gates.md`.
2. **`.writrun/gates.md`** (new, adopter-owned): the four human gates
   table with its TODO defaults, the forge-settings row and its warning,
   and the derivation default — the "yours" content, whole. This
   repository's root copy carries this repo's real answers (moved from
   `AGENTS.md`); the template ships the TODO skeleton, so `gates.md`
   joins `tests/template_exceptions.txt` beside `settings.json`.
3. **`template/AGENTS.md`** shrinks to: the title, one TODO paragraph
   for the project's own instructions, and the pointer —

   ```markdown
   ## WritRun

   This project tracks its work with WritRun. Before touching `work/`,
   `docs/`, or any task, spec, or report, read and follow
   [`.writrun/AGENTS.md`](.writrun/AGENTS.md).
   ```

   The pointer is a markdown link, never an `@` reference — Claude Code
   imports recursively, and an `@` here would load the whole flow into
   every session through the shim.
4. **`template/CLAUDE.md`** (new): exactly the import line `@AGENTS.md`.
   It is the third named collision point: an existing `CLAUDE.md` keeps
   itself, and the guide instructs adding the line instead.
5. **This repository's root**: the gates table moves from `AGENTS.md` to
   `.writrun/gates.md`; the root `AGENTS.md` keeps what is this repo's
   own (reading order, the three-kinds matrix, the Never list) and drops
   nothing else — it gains a line naming where the gates live.
6. **Kit prose**: `template/WRITRUN.md` and `.writrun/README.md`
   describe the new shape — the README's ownership table gains
   `AGENTS.md` (WritRun, replaces whole) and `gates.md` (the project,
   never touches); the guide's vendor note states that Codex and
   Antigravity read `AGENTS.md` at the root, that Antigravity caps a
   rules file at 12,000 characters — one more reason the entry point
   stays short — and that Claude Code reads `CLAUDE.md`, which the shim
   answers.
7. **Mirror**: `make template-sync` after the root `.writrun/` changes;
   `mirrors_root_test.sh` stays green with `gates.md` excepted.
8. **Guards**: `prose_names_what_the_kit_ships_test.sh` reads
   `.writrun/AGENTS.md` where it read the entry point's flow section; a
   new unit test holds the shape — the template entry point names
   `.writrun/AGENTS.md` and carries no `writrun:begin`, and
   `template/CLAUDE.md` is exactly the import line.

## Acceptance criteria (EARS)

- When the kit lands in a project with an existing `AGENTS.md`, the
  graft shall add the pointer section and nothing else.
- When an update refreshes the kit, every file it replaces shall be
  WritRun-owned whole, and `.writrun/gates.md` and
  `.writrun/settings.json` shall emerge unchanged.
- When an agent follows the pointer, `.writrun/AGENTS.md` shall carry
  every flow instruction the old graft carried, and shall reach the
  project's answers only through `gates.md`.
- When a project already has a `CLAUDE.md`, the kit shall not overwrite
  it, and the guide shall instruct adding `@AGENTS.md` to it.
- When the template guards run against an entry point that regrows a
  marker or drops the pointer, they shall fail.

## Edge cases

- A project with no `AGENTS.md`: the template's file is the start —
  title, TODO paragraph, pointer.
- A project whose `CLAUDE.md` already imports other files: the added
  `@AGENTS.md` line coexists; import depth (four hops) is not reached,
  because the pointer inside `AGENTS.md` is a link, not an import.
- Antigravity's 12,000-character cap applies to what it reads as rules —
  the entry point after the graft sits far under it; the flow file is
  read by tools on demand and never counts.
- This repository after the move: `.writrun/AGENTS.md` speaks the
  kit-generic flow while the root `AGENTS.md` keeps the repo-specific
  rules; where the two would state one rule, the root file links instead
  ([prose](../../.writrun/conventions/prose.md): say it once).

## Tests required

- `tests/unit/template/mirrors_root_test.sh` — green with `gates.md` in
  the exceptions list.
- `tests/unit/template/prose_names_what_the_kit_ships_test.sh` — its
  prose list updated to read `.writrun/AGENTS.md`.
- New: `tests/unit/template/entry_point_is_a_pointer_test.sh` per
  step 8.
- The full suite in the background, per this project's practice.

## Definition of Done

- [ ] The kit ships the pointer entry point, `.writrun/AGENTS.md`,
      `.writrun/gates.md` (TODO skeleton) and the `CLAUDE.md` shim; no
      marker survives anywhere in the kit.
- [ ] This repository's gates live in `.writrun/gates.md` and the root
      `AGENTS.md` names that address.
- [ ] `distribution/kit.md`, `WRITRUN.md` and `.writrun/README.md` describe
      the shipped shape.
- [ ] The three template guards pass; `preflight.sh` exits 0.

## Proposed product changes

- none — the rule was authored ahead of this task, in the change that
  created it
  ([adoption.md#the-entry-point-is-the-projects](../../docs/product/adoption.md#the-entry-point-is-the-projects)).

## Proposed technical changes

- `technical/distribution/kit.md` — the graft paragraph becomes the
  pointer-and-ownership description; the collision list grows to three
  (`AGENTS.md` grafted, docs kept, `CLAUDE.md` kept); the kit inventory
  names the two new files and the exception `gates.md` shares with
  `settings.json`.

## Outcome

Built as planned, steps 1–8: the flow moved whole into
`.writrun/AGENTS.md` (mirrored into the kit), the gates into
`.writrun/gates.md` — this repository's answers at the root, the TODO
skeleton in the kit, the file excepted from the mirror beside
`settings.json` — the template entry point shrank to title, TODO and
the four-line pointer, the `CLAUDE.md` shim shipped as exactly the
import line, and `kit.md`, `WRITRUN.md` and `.writrun/README.md` now
describe the shipped shape. The two amended guards and the new
`entry_point_is_a_pointer_test.sh` pass.

Three divergences. The DoD's "no marker survives anywhere in the kit"
overreached: the PR body template keeps its own `writrun:begin` pair —
a different mechanism with a live reader (`writrun check` locates the
`## Derived work` heading through it) — so what disappeared is the
graft markers, which had no reader left. The taking act itself exposed
a defect recorded as report-0019: `take_task.sh` commits nothing, so a
fresh take always fails to open its draft on the forge's
no-empty-pull-request rule; this take finished by hand. And the flow
file points at `docs/technical/settings/` for the schema — the address
the foldering created — where the old graft named the router.

Review of the open pull request found five defects inside this spec's
scope, corrected here. The shipped `gates.md` skeleton was missing the
`tracked` row, so an adopter filling every TODO still met the stall the
flow's own "a gate `gates.md` leaves unnamed is a question" rule
describes. The flow file described taking and completing by hand while
the kit ships `take_task.sh` and `preflight.sh` for both, which left it
contradicting the root `AGENTS.md`; it now names them, and the root file
says which of the two governs here. Its human-routing line pointed at a
root `WRITRUN.md` this repository does not have, and `.writrun/README.md`
claimed a root pointer this repository does not carry — both now state
what the kit grafts rather than asserting a file. "Never code from the
task title alone" left the kit with the entry point's old reading order
and returned to the flow's completion step. The new guard read only for
markers, so it passed a relative `@./` import and any amount of regrown
flow under the claim; it now reads the claimed section for size, tables
and sub-headings, and carries the negative cases that prove it bites.

One finding is recorded and not applied: the forge-row rationale stands
in this chapter, in the root `gates.md` and in the kit's, which
[prose](../../.writrun/conventions/prose.md)'s "say it once" would have
link instead. The kit cannot link — it ships without WritRun's product
chapters — and the root copy is the worked example of a filled-in
skeleton, so removing it there would make the example diverge from what
an adopter's file has to hold. Left whole in both, deliberately.
