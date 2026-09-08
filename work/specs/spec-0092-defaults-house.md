---
id: spec-0092
task_ref: task-0065
status: draft
created: 2026-09-08T16:48:59Z
---

# spec-0092 — The defaults house and the deferring stubs

**References:** [task-0065](../tasks/task-0065-layered-homes.md) · [product/adoption.md#two-homes](../../docs/product/adoption.md#two-homes)

- **Goal:** every text the kit answers on a project's behalf lives at
  `.writrun/defaults/<path>`, replaced whole by updates; the seed's
  `writrun/<path>` is a stub deferring to it; one resolver serves the
  winning file and names which home answered.

## Scope

The defaults texts, the stubs, the resolver, and the resolution rule
stated once in `.writrun/AGENTS.md`. Builds on spec-0091's rename —
the seed lives in `kit/writrun/`. The vocabulary values are
spec-0093's; this spec only stops the default prose from carrying
them.

## Steps

1. Create `.writrun/defaults/gates.md`: the table from today's seed
   with each TODO comment's default promoted to the cell's answer — a
   human at every gate, the forge paragraph kept.
2. Create `.writrun/defaults/conventions/` from today's seven seed
   files, rewritten as kit defaults: no adopter-voiced prose, no
   spelled vocabulary lists (spec-0093 — the default `commits.md`
   explains the two lists and points at `settings.json` for the
   words), the template-override addresses kept correct.
3. Write the resolver,
   `.writrun/scripts/stage-1-tasks-and-specs/resolve_doc.sh`: given a
   project-home path (`writrun/gates.md`,
   `writrun/conventions/commits.md`), print the file in force and its
   origin — the project's file and `declared` unless it is absent or
   its first line is exactly `/// writrun:default`, then
   `.writrun/defaults/<same relative path>` and `default`. Same
   output discipline as `read_setting.sh --origin`. A path with no
   default and no project file is a loud error, not an empty answer.
4. Reseed `kit/writrun/`: `settings.json` stays cautious and real;
   `gates.md` and the seven conventions become stubs — first line
   `/// writrun:default`, then one sentence: replace this file's
   content to override the kit's default of the same name. No
   resolved address in the stub.
5. State the resolution rule in `.writrun/AGENTS.md`, once, where the
   flow already points agents at gates and conventions — and route
   those pointers through it.
6. Update `WRITRUN.md` (the guide's "make the conventions your own"
   now says: overwrite the stub) and `.writrun/README.md`'s table with
   `defaults/`.
7. This repository's own `writrun/` keeps its files as whole
   overrides — its gate answers and conventions are its own; nothing
   here defers yet, and nothing needs to.

## Acceptance criteria (EARS)

- When a project-home file carries `/// writrun:default` as its first
  line, or does not exist, the resolver shall answer with the kit's
  default of the same name and origin `default`.
- When a project-home file carries any other content, the resolver
  shall answer with that file, whole, and origin `declared`.
- When an update replaces `.writrun/`, a correction to any default
  shall reach every project whose file defers, and no file under
  `writrun/` shall be written.
- When the seed lands in a fresh project, `writrun/` shall hold the
  cautious `settings.json` and deferring stubs, and nothing else.
- When a stub is read by a person, it shall say how to override and
  shall carry no path.

## Edge cases

- The marker below the first line is content, not deferral — the
  file is an override that happens to quote the marker, exactly as
  `writrun:draft` is positional.
- A deferring `gates.md` in a project that adopted before this change
  never occurs — their file has real content (the TODO skeleton), so
  it is an override, whole, and nothing changes for them. The TODO
  skeleton reading as "declared" is the compatible reading: it is what
  their file says today.
- `.writrun/defaults/` rides the existing mirror — `.writrun` is
  carried whole, so no mirror-list change.

## Tests required

- Unit: resolver answers `default` on marker, `default` on absence,
  `declared` on content, loud error on an unknown path.
- Unit: every file under `.writrun/defaults/` has a same-named stub in
  the seed, and every stub a same-named default — the two trees match.
- Integration: the sync carries `defaults/` into the kit unchanged.

## Definition of Done

- [ ] `.writrun/defaults/` holds gates.md and the seven conventions;
      the seed holds settings plus stubs; the resolver passes its
      suite; the rule is stated in `.writrun/AGENTS.md`.

## Proposed product changes

- none — the rule was authored ahead
  ([adoption](../../docs/product/adoption.md#two-homes),
  [gates](../../docs/product/stage-1-tasks-and-specs/gates.md)).

## Proposed technical changes

- `technical/distribution/README.md` — the router names the resolver
  beside the other per-script chapters.
- `technical/distribution/resolve.md` — new chapter: the resolver's
  contract, its two origins, and the loud unknown-path case.

## Outcome

_(fill after execution)_
