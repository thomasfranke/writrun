---
id: spec-0093
task_ref: task-0065
status: implemented
created: 2026-09-08T16:49:02Z
---

# spec-0093 — The commit vocabulary moves into settings

**References:** [task-0065](../tasks/task-0065-layered-homes.md) · [technical/settings/schema.md#settings](../../docs/technical/settings/schema.md#settings) · [report-0040](../reports/report-0040-vocabulary-in-kit.md)

- **Goal:** `commit_types` and `commit_scopes` are settings the checks
  read; no kit script carries an embedded copy, so a refresh can no
  longer revert what a project declared.

## Scope

The two keys through the whole settings machinery — reader, validator,
card, this repository's own file, the seed — and the one consumer,
`check_observance.sh`. The default `commits.md` prose is spec-0092's;
independent of spec-0091.

## Steps

1. `read_setting.sh`: add `stage_2.commit_types` and
   `stage_2.commit_scopes` to the documented addresses, defaults the
   two lists `check_observance.sh:73-74` carries today.
2. `check_settings.sh`: the two keys are shape-checked (workflows
   parse them) — double-quoted strings of lower-case space-separated
   words in their documented home, refused anywhere else.
3. `check_observance.sh`: delete the embedded `TYPES=`/`SCOPES=`
   lines; read both through `read_setting.sh`.
4. `session_card.sh`: the card's commit-subject block renders the two
   vocabularies with their origin, like every other value.
5. This repository's `writrun/settings.json` declares both keys with
   today's values; the seed's cautious `settings.json` carries both
   keys too — every key present, always.

## Acceptance criteria (EARS)

- When a project declares `commit_types` or `commit_scopes`, the
  observance check shall judge titles and subjects against the
  declared words, and an update shall change nothing it judges.
- When neither key is declared, the check shall judge against the
  documented defaults — today's embedded lists, exactly.
- When either key holds anything but lower-case space-separated words
  in a double-quoted string, `check_settings.sh` shall refuse it by
  name.
- When the session card renders, both vocabularies shall appear with
  `declared` or `default` beside them.

## Edge cases

- A project whose `commits.md` override spells different words than
  its settings: the settings win — the check reads one address, and
  the prose is reasoning, not values
  ([schema](../../docs/technical/settings/schema.md#settings)).
- An empty string is a declaration of no vocabulary and is refused —
  a project wanting fewer types lists the ones it keeps.
- The bridge addresses (`.writrun/settings.json`,
  `.writrun/conventions/settings.json`) serve the new keys like any
  other — no special case.

## Tests required

- Unit: `read_setting.sh` answers both keys declared and default;
  `check_settings.sh` refuses a malformed list; observance refuses a
  type outside the declared list and accepts one inside it, with the
  vocabulary declared and with it defaulted.
- The observance suite's existing cases, green against the moved
  source.

## Definition of Done

- [ ] No `TYPES=`/`SCOPES=` in any kit script; the two keys flow
      reader → validator → card → check; suite green.

## Proposed product changes

- none — the rule was authored ahead
  ([adoption](../../docs/product/adoption.md#two-homes)).

## Proposed technical changes

- `technical/distribution/session-card.md` — the card's rendered
  shape gains the two vocabulary lines.

## Outcome

Done as planned: `commit_types` and `commit_scopes` are `stage_2` keys,
read through `read_setting.sh`, shape-checked by `check_settings.sh`,
rendered with their origin on the session card, and declared in both
this repository's settings and the seed's. The embedded
`TYPES=`/`SCOPES=` lines are gone.

**Two readers the spec did not name, both scraping the same lines.**
`take_task.sh` read all three vocabularies out of `check_observance.sh`
with `sed`, and `session_card.sh` did the same for two — so the check
was a de-facto data file for scripts that never said so. Both now read
the settings. `CATEGORIES` stays where it is and is still scraped: it is
the kit's tripwire against `Co-Authored-By: AI`, not a project's choice,
so it has no setting to move to.

**A locale bug the first shape check walked into.** `*[!a-z\ ]*` accepts
`docs Feat` under `en_US.UTF-8`, because a bracket *range* is collated
in the locale's order and every upper-case letter falls inside `a-z`
there. The test caught it — the case exists precisely to refuse that
shape. It reads `*[![:lower:]\ ]*` now, and the reason is a comment in
place, since the working version looks like the broken one.

The card's exit-3 path is gone with the scraping: it existed because a
card that could not find the vocabulary lines would look complete while
saying nothing. Absence is now a documented default like any other
value, marked `default` on the card.
