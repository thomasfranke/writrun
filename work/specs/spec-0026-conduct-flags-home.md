---
id: spec-0026
task_ref: task-0021
status: draft
created: 2026-08-31T02:47:40Z
---

# spec-0026 — Conduct flags live in stage_2

- **Goal:** `auto_commit` and `credit_ai` move from the settings file's
  `stage_1` section to `stage_2`, so the file says what the docs now
  say: git begins at Stage 2, and Stage 1 carries no git-conduct choice
  because there is no git action for one to govern.

## Scope

In: the settings file's shape and its checker, the addresses the two
conventions files read the flags through, the test fixtures that spell
the old shape, the catch-up note the technical doc carries until this
lands, and a dated decision entry recording why the placement moved —
with its row in the decisions chronology.

> **Amended 2026-08-31, returned to `draft`.** The original promised
> the decision entry and not the index row it is never added without,
> so `writrun-check-spec-deltas` reported the row as an undeclared
> permanent-doc change and the completion gate could not pass. The
> promise now names the file. Nothing else about the change moved.

Out: the flags' semantics (unchanged, including precedence over the
platform's autonomy mode); `auto_pr` and `pr_title_style` (already in
`stage_2`); the `stage` key and its values; any stage renumbering.

## Steps

1. `.writrun/settings.json`: move `auto_commit` and `credit_ai` into the
   `stage_2` section; drop the now-empty `stage_1` section (a section
   exists only when it holds a documented key). Same in
   `template/.writrun/settings.json`.
2. `.writrun/scripts/stage-2-pull-requests/check_settings.sh`: the two
   keys' documented home becomes `stage_2`; a key found in a `stage_1`
   section is rejected with a message naming `stage_2` as its home; a
   file with no `stage_1` section passes.
3. `.writrun/conventions/commits.md` and `prs.md`: the headings and
   `read_setting.sh` addresses become `stage_2.auto_commit` and
   `stage_2.credit_ai`.
4. Test fixtures that write a `stage_1` section
   (`tests/integration/stage-2/settings/*`,
   `tests/unit/check_state/stage_one_hand_moves_are_legal_test.sh`)
   move to the new shape; one test covers the old home being rejected
   by name.
5. `docs/technical/README.md#settings`: remove the catch-up note.
6. Add `docs/technical/decisions/tasks-and-specs/0055-conduct-flags-live-in-stage-2.md`
   recording the move and what it corrects in decision 0054's placement
   rationale.
7. `make template-sync` so the mirrored copies match.

## Acceptance criteria (EARS)

- When `read_setting.sh stage_2.auto_commit` or
  `read_setting.sh stage_2.credit_ai` is asked of the canonical settings
  file, the script shall print the value and exit 0.
- When a settings file carries `auto_commit` or `credit_ai` in a
  `stage_1` section, `check_settings.sh` shall reject it and name
  `stage_2` as the key's home.
- When a settings file carries no `stage_1` section, `check_settings.sh`
  shall not reject it for the absence.
- When the settings file is absent, every key shall keep its documented
  default, unchanged by this move.

## Edge cases

- A settings file carrying both an old-home and a new-home copy of the
  same flag: rejected — one address per key, and the checker already
  refuses a homeless key.
- Adopters mid-migration: none exist yet (swoop and TOM are not
  migrated), so no legacy acceptance is owed; the reject-with-the-name
  message is the whole migration path.

## Tests required

The settings suite (`tests/integration/stage-2/settings/`) green on the
new shape, plus the new old-home-rejected case; the check-state unit
suite green with its fixture on the new shape.

## Definition of Done

- [ ] Both flags read from `stage_2` and nowhere else; `stage_1` section gone from both settings files.
- [ ] Old home rejected by name; full test suite green.
- [ ] Catch-up note removed; decision entry added; template mirrors byte-identical.

## Proposed product changes

- none — the rule was authored first (`product/adoption.md#three-stages`,
  `product/stage-2-pull-requests/README.md`); this change brings the
  machinery up to it.

## Proposed technical changes

- `technical/README.md#settings` — remove the catch-up note once the
  flags actually live in `stage_2`.
- `technical/decisions/tasks-and-specs/0055-conduct-flags-live-in-stage-2.md`
  — new dated entry: why the conduct flags moved home, superseding
  decision 0054's `stage_1` placement rationale.
- `technical/decisions/README.md` — append 0055's row to the chronology
  table. A decision entry is not added without it
  ([0045](../../docs/technical/decisions/tasks-and-specs/0045-one-decision-per-file.md):
  the table is the chronology the folders do not carry, appended
  whenever an entry is), and the delta check reads paths rather than
  intent, so the row has to be promised by name.

## Outcome

_(fill after execution)_
