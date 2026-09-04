---
id: spec-0058
task_ref: task-0042
status: approved
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
otherwise duplicate it, `docs/technical/distribution.md`, and the
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
- [ ] `distribution.md`, `WRITRUN.md` and `.writrun/README.md` describe
      the shipped shape.
- [ ] The three template guards pass; `preflight.sh` exits 0.

## Proposed product changes

- none — the rule was authored ahead of this task, in the change that
  created it
  ([adoption.md#the-entry-point-is-the-projects](../../docs/product/adoption.md#the-entry-point-is-the-projects)).

## Proposed technical changes

- `technical/distribution.md` — the graft paragraph becomes the
  pointer-and-ownership description; the collision list grows to three
  (`AGENTS.md` grafted, docs kept, `CLAUDE.md` kept); the kit inventory
  names the two new files and the exception `gates.md` shares with
  `settings.json`.

## Outcome

_(fill after execution)_
