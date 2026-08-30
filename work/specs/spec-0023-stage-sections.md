---
id: spec-0023
task_ref: task-0020
status: approved
created: 2026-08-30T13:16:08Z
---

# spec-0023 — The settings file is sectioned by stage

- **Goal:** the settings file carries one top-level `stage` and one
  section per stage (`"stage_1"`, `"stage_2"`) holding the keys that
  stage's readers act on — the same rule that put the stage on folder
  names — and the two scripts read and check that shape with the same
  tools as today: line-based, no `jq`.

## Scope

In: the file's canonical shape; `read_setting.sh` addressing sectioned
keys as `stage_N.key`; `check_settings.sh` enforcing the two-level
canon; the one caller (`stage_gate.sh`) and the tests following;
`make template-sync`.

Out: the file's address (spec-0022); the new AI keys (spec-0024,
spec-0025) — this spec sections the keys that exist, `stage` at the
top and `pr_title_style` under `"stage_2"`. A section exists only when
it holds a documented key, so no empty `"stage_3": {}` placeholder.

## Steps

1. Rewrite `.writrun/settings.json` in the sectioned shape.
2. `read_setting.sh`: a bare key (`stage`) reads the top level; a
   dotted key (`stage_2.pr_title_style`) reads inside its section,
   tracked line-by-line (awk/sed, section state on the `"stage_N": {`
   and `}` lines). Defaults, absence-is-not-an-error, and exit codes
   keep today's contract. The legacy bridge (spec-0022) still reads an
   unmoved file flat — the bridge freezes the whole old contract, shape
   included.
3. `check_settings.sh`: canonical two-level shape — top level as today,
   a section opened by a two-space-indented `"stage_N": {` line, pairs
   inside at four spaces, closed by a two-space `}` line; every
   documented key present in its documented home; a documented key in
   the wrong section is a named fault.
4. Update `stage_gate.sh`'s call sites and the tests; sync the
   template.

## Acceptance criteria (EARS)

- When `read_setting.sh stage` runs, it shall print the top-level value.
- When `read_setting.sh stage_2.pr_title_style` runs, it shall print the
  value from inside the `"stage_2"` section.
- When the addressed key or the file is absent, `read_setting.sh` shall
  print the documented default and exit 0, as today.
- When the file deviates from the two-level canon — a pair outside its
  documented section, wrong indent, a third nesting level —
  `check_settings.sh` shall exit 1 naming each fault.
- When a settings file still holds `pr_title_style` at the top level,
  `check_settings.sh` shall fault it as homeless, naming the section it
  moved to.

## Edge cases

- A key name valid in two shapes (`stage` the scalar vs. `stage_2` the
  section): the reader tells them apart by the dot in the address, the
  check by the `{` on the line.
- A quoted value holding `{`, `}` or a dot must survive both scripts —
  the section state machine reads line shapes, never value content.
- The same key name in two sections is two keys; the address, not the
  name, is identity.

## Tests required

- Reader: top-level read, sectioned read, absent key, absent file,
  dotted address for a key the schema does not document (prints
  nothing, exit 0).
- Check: canonical file passes; each deviation in the criteria list is
  a named fault; the fault list is complete, not first-only.
- Gate: `stage_gate.sh` behaves identically before and after.

## Definition of Done

- [ ] The file is sectioned; both scripts speak the two-level canon;
      the callers follow.
- [ ] The legacy bridge still reads an unmoved flat file.
- [ ] Tests cover reader, check and gate; template synced; suite green.

## Proposed product changes

- none — the sectioned shape was authored first
  (`product/adoption.md` needs no change: it names the file, not its
  shape).

## Proposed technical changes

- none — the shape, the dotted address and the canon were authored
  first (`technical/README.md#settings`); this change makes them true.

## Outcome

_(fill after execution)_
