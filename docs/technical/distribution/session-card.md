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
as defaults by its `--origin` flag), or is a methodology constant the
contract already fixes.

**The two commit vocabularies render like any other value**, origin
included: `commit_types` and `commit_scopes` are settings
([schema](../settings/schema.md#settings)), so the card shows what the
project declared and marks a list nobody declared as the default. It
read them out of `check_observance.sh`'s source while the check carried
them embedded — a card built by parsing a script states what that script
happens to say, which is not the same claim, and the drift it was meant
to make visible is the one the settings address removed.

Exit 0 always, including with no settings file — pre-adoption is a state,
not an error. The card replaces reading, so its length is
part of its contract: growing is regressing.

