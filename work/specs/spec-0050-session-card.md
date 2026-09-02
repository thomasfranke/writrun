---
id: spec-0050
task_ref: task-0034
status: approved
created: 2026-09-02T06:02:32Z
---

# spec-0050 — session_card.sh renders the settings an agent obeys

**References:** [task-0034](../tasks/task-0034-session-cost.md)

- **Goal:** everything an agent obeys per session that is a *value* —
  the stage, the conduct flags, the title style, the vocabularies, the
  constants — rendered as one ~30-line card by a script, so the
  conventions files are opened for their reasoning, not re-read every
  session for data `settings.json` states in 333 bytes.

## Scope

In scope: `session_card.sh` in
`.writrun/scripts/stage-1-tasks-and-specs/`; one flag on
`read_setting.sh` — `--origin`, printing `declared` or `default`
beside the value, since today the script prints a defaulted value
and a declared one identically and the card must tell them apart;
`AGENTS.md` naming the card as the session-start read; its contract
in `technical/distribution.md` and one line in
`technical/settings.md` (the card as the file's rendered view); unit
tests; template sync.

Out of scope: any new source of truth — the card computes nothing and
decides nothing; every line is read from `settings.json` (via
`read_setting.sh`, defaults included — its `--origin` flag is this
spec's one script change, and a second parser of the file stays
out), from `check_observance.sh`'s `TYPES=`/`SCOPES=` lines (the
machine half of the vocabulary, single source), or is a methodology
constant the contract already fixes.

## Steps

1. `session_card.sh` prints, in order: the stage; the four
   `stage_2` flags each with its one-line operational meaning
   ("auto_commit: true — commit without asking"); `pr_title_style`
   with one example title per PR kind (implementing, authoring,
   reporting) rendered in the declared style; the commit-subject
   constant with the two vocabularies; the three branch prefixes and
   the task-tag shape; the three `stage_1` declarations
   (`spec_required`, `decisions_style`, `product_layout`) and
   `provenance_ledger`.
2. Sources: settings via `read_setting.sh`, each key read for its
   value and its `--origin` — absent files or keys print the
   documented defaults, and the flag is what lets the card mark a
   default as one; vocabularies extracted from
   `check_observance.sh`'s two assignment lines — extraction failing
   is a loud exit 3, never a silently shorter card.
3. `AGENTS.md`: the card joins the session start — run it instead of
   re-reading the conventions for values; open a conventions file when
   the card leaves a *why* question.
4. Contract in `technical/distribution.md`; the settings chapter
   gains the one line naming the card; unit tests;
   `make template-sync`.

## Acceptance criteria (EARS)

- When settings declare values, the card shall print those values and
  render the example titles in the declared style.
- When `settings.json` or a key is absent, the card shall print the
  documented default marked as such, and exit 0 — pre-adoption is a
  state, not an error.
- When the vocabulary lines cannot be found in
  `check_observance.sh`, the card shall exit 3 naming the file — a
  card missing its vocabularies must not look complete.
- When the card prints, it shall fit in ~30 lines — it replaces
  reading, so growing is regressing.

## Edge cases

- An adopter who edited the vocabularies in `commits.md` prose but not
  the script — the card shows the script's lists, which is what the
  door enforces; the drift becomes visible instead of ambient.
- `stage: 1` — the stage-2 flags still print (they bind from Stage 2;
  the card says so in their line).
- A future settings key the card does not know — ignored; the card
  states its own version of the truth, `check_settings.sh` owns
  completeness.

## Tests required

Unit, `tests/unit/session_card/`, against fixture settings files:
each style's example rendering, flags false, absent file → defaults
marked, vocabulary extraction, the loud exit 3, the line-count
bound; and for `read_setting.sh --origin`: a declared key, a
defaulted key, an absent file.

## Definition of Done

- [ ] `session_card.sh` with the contract above; `AGENTS.md` names it
      at session start.
- [ ] Unit green; template synced; full suite green.

## Proposed product changes

- none — machinery only; no rule changes reach

## Proposed technical changes

- `technical/distribution.md` — the script's contract joins the
  operational half.
- `technical/settings.md` — one line: the card is the file's rendered
  view; `--origin` joins the reader's documented contract.

## Outcome

_(fill after execution)_
