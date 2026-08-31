---
id: spec-0033
task_ref: task-0021
status: implemented
created: 2026-08-31T04:52:10Z
---

# spec-0033 — The adopter's declarations get keys

- **Goal:** the three variants Adoption leaves open and orders declared
  — spec threshold, decisions shape, product layout — stop living in
  prose and get their keys: `stage_1.spec_required`
  (`always | when-warranted`), `stage_1.decisions_style`
  (`per-subsystem | chronological`), `stage_1.product_layout`
  (`by-concept | by-feature`). Values only, read by agents, enforced in
  shape by the checker like every other key.

## Scope

In: both settings files (root and template), `check_settings.sh`, the
skills that act on each declaration, tests, and the catch-up note.

Out: `id_prefix` (the fourth open variant — no key until an adopter
asks; YAGNI); any behaviour change in the machinery (the declarations
gate nothing mechanical — they inform agents); branch prefixes and
label names (constants of the methodology, per `AGENTS.md`).

## Steps

1. `.writrun/settings.json` gains the `stage_1` section with this
   repository's true values: `spec_required: when-warranted`,
   `decisions_style: chronological`, `product_layout: by-concept`.
   `template/.writrun/settings.json` ships the defaults
   (`when-warranted`, `per-subsystem`, `by-concept`).
2. `check_settings.sh`: three documented keys, their home `stage_1`,
   their vocabularies; everything else the checker already enforces
   (presence, shape, home) applies unchanged.
3. `writrun-create-task-and-spec`: the skill reads `spec_required` —
   `always` replaces the "does this task need a spec?" judgement with
   yes; `when-warranted` keeps today's guidance verbatim.
4. Skill and conventions text that tells an agent where decisions live
   or how product docs are organized points at the two declarations
   instead of assuming this repository's shape.
5. Sequencing with spec-0026 is free: landing together, the `stage_1`
   section never disappears between the conduct flags leaving and the
   declarations arriving.
6. Tests for the three keys' vocabularies and homes; `make
   template-sync`; remove the declarations half of the catch-up note in
   `technical/README.md#settings`.

## Acceptance criteria (EARS)

- When `read_setting.sh stage_1.spec_required` (or either other
  declaration) is asked of the canonical file, it shall print the value
  and exit 0.
- When a settings file carries a declaration with a value outside its
  vocabulary, or in another section, `check_settings.sh` shall reject
  it.
- When `spec_required` is `always`, the creation skill shall not offer
  the skip-the-spec judgement.
- When the settings file is absent, each declaration shall keep its
  documented default.

## Edge cases

- A stage-1-only adopter: all three keys are theirs — the section name
  says so; nothing in them assumes a forge.
- A project whose docs shape matches neither `product_layout` value:
  the key states the nearer truth and the project's prose carries the
  nuance — values, never reasoning.

## Tests required

Settings-suite cases for the three keys (present, homed, vocabulary);
creation-skill behaviour under `always`; template mirrors
byte-identical.

## Definition of Done

- [ ] Three keys live, checked, and read by the skills that act on them.
- [ ] Both settings files canonical; catch-up note gone; suite green.

## Proposed product changes

- none — Adoption already orders these variants declared and names the
  settings file as the address; this change mints the keys.

## Proposed technical changes

- `technical/README.md#settings` — remove the declarations half of the
  catch-up note once the keys exist and the checker knows them.

## Outcome

Built as specified: `stage_1` carries `spec_required`,
`decisions_style` and `product_layout`. `check_settings.sh` knows all
three — their home, their presence, their vocabularies — and
`read_setting.sh` documents each default (`when-warranted`,
`per-subsystem`, `by-concept`), which is the behaviour from before the
keys existed. The root file states this repository's true values:
`when-warranted`, `chronological`, `by-concept`.

`writrun-create-task-and-spec` reads `spec_required` at the top of "Does
this task need a spec?": `always` removes the judgement outright and
says so; `when-warranted` keeps the existing guidance verbatim.
`conventions/README.md` points at all three rather than letting an agent
infer this repository's shape from whichever folders it opened first.
The declarations half of the catch-up note is gone, and landing with
spec-0026 meant the `stage_1` section never disappeared between the
conduct flags leaving and the declarations arriving.

Divergence, one: **the kit does not ship the documented defaults.**
Step 1 asks `template/.writrun/settings.json` for `when-warranted`,
`per-subsystem`, `by-concept`. It ships `chronological` instead, because
`.writrun` is on the template mirror list — `make template-sync` copies
the root file byte for byte and a unit test holds it identical, so the
kit necessarily ships this repository's values. The condition predates
this change (`pr_title_style` already shipped as `bracketed` rather than
the documented `conventional` default) and honouring the promise would
mean teaching the sync to exclude a path, which is new machinery and
outside this scope. Recorded rather than worked around; a task deciding
whether the kit's settings file should leave the mirror is the fix.
