# The session card

**Every per-session value on one card**, rendered and never decided. One chapter of [`distribution/`](README.md).

## `session_card.sh` — the settings, rendered

Everything an agent obeys per session that is a *value* — the stage, the
conduct flags, the title style, the vocabularies, the constants — on one
~30-line card:

```bash
bash .writrun/scripts/stage-1-tasks-and-specs/session_card.sh
```

It computes nothing and decides nothing. Every line comes from
`settings.json` through `read_setting.sh` (defaults included, and marked
as defaults by its `--origin` flag), from `check_observance.sh`'s
`TYPES=`/`SCOPES=` lines — the machine half of the vocabulary, and the
half the door enforces — or is a methodology constant the contract
already fixes. An adopter who edited the vocabulary in
`conventions/commits.md` but not the script sees the script's list, which
makes the drift visible instead of ambient.

Exit 0 always, including with no settings file — pre-adoption is a state,
not an error — except **3** when the vocabulary lines cannot be found,
because a card missing them would look complete while stating nothing
about what a title may say. The card replaces reading, so its length is
part of its contract: growing is regressing.

