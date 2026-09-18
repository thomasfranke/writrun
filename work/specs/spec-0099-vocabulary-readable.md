---
id: spec-0099
task_ref: task-0071
status: implemented
created: 2026-09-17T19:46:12Z
---

# spec-0099 — One home for the vocabulary, and a flag that reads it

**References:** [task-0071](../tasks/task-0071-vocabulary-readable.md)


- **Goal:** A closed key's allowed values are printed by
  `read_setting.sh --vocabulary`, from the one home the checker also
  reads, and the schema's table cannot drift from it.

## Scope

- `.writrun/scripts/stage-2-pull-requests/queue_lib.sh` — the
  vocabularies move here, one function answering "the values of this
  address": the four lists `check_settings.sh` carries today, plus the
  stage numbers and the boolean pair, addressed by the key's address the
  way `default_for` addresses defaults.
- `.writrun/scripts/stage-2-pull-requests/check_settings.sh` — reads
  the vocabularies from the shared home; its refusals are unchanged.
- `.writrun/scripts/stage-2-pull-requests/read_setting.sh` — gains
  `--vocabulary`, exclusive with `--origin`.
- `tests/unit/settings/` — a case reading the Values column of
  `docs/technical/settings/schema.md` against the shared home.

`.writrun/` is carried whole by `tests/kit_mirrors.txt`; the kit copies
come from `make kit-sync`.

**Out of scope.** No new key, no new value, and no judgement in the
reader: an address the schema does not document prints nothing with the
flag exactly as it does without it, and exit 0 is kept — the reader's
posture is that it reads.

## Steps

1. Add the shared vocabulary function to `queue_lib.sh`, keyed by
   address (`stage`, `stage_2.pr_title_style`, …). A free-form key
   answers empty.
2. Point `check_settings.sh` at it and delete the four `*_STYLES`-style
   variables; the boolean and stage lists go the same way.
3. Add `--vocabulary` to `read_setting.sh`: values one per line in the
   schema's order; nothing for a free-form or undocumented address; a
   usage error, exit 3, when both flags are given.
4. Write the table test: parse the Values column of `schema.md` for
   each `/`-separated closed vocabulary and assert it equals the shared
   home's answer, key by key, so a value added on either side alone
   fails.
5. Extend the reader's header and the schema chapter's one-reader
   sentence with the flag — documentation of the change, not an addition
   to it.
6. `make kit-sync`.
7. Record the decision: the vocabulary is read where the value is read.

## Acceptance criteria (EARS)

- When `read_setting.sh <address> --vocabulary` is run for a closed key,
  it shall print that key's allowed values, one per line, in the
  schema's order, and exit 0.
- When it is run for `commit_types` or `commit_scopes`, it shall print
  nothing and exit 0.
- When it is run for an address the schema does not document, it shall
  print nothing and exit 0.
- When both `--vocabulary` and `--origin` are given, it shall print
  usage and exit 3.
- When a value is added to the schema's table and not to the shared
  home, or the reverse, the unit suite shall fail naming the key.
- When `check_settings.sh` judges a value, its refusals shall be
  unchanged, read from the shared home.

## Edge cases

- **`stage` prints numbers**, `1` `2` `3`, not the words a card renders;
  the flag prints what the file accepts.
- **Booleans are a vocabulary** — `true` then `false` — so a porcelain
  can render a toggle from the same call it renders a select from.
- **The table's Values column mixes forms.** `1` / `2` / `3` is a
  vocabulary; *"lower-case words, space-separated"* is a shape. The test
  reads a cell as a vocabulary only when every alternative is a
  backticked literal, and treats the rest as free-form — which must then
  answer empty.
- **A bridge-carried file** (the two old addresses) changes nothing
  here: the vocabulary is the key's, not the file's.

## Tests required

- `tests/unit/read_setting/`: the four closed keys, the two free-form
  keys, an undocumented address, the flag clash.
- `tests/unit/settings/`: the table-to-home case; the existing
  `check_settings` cases green through the shared home.
- The kit mirror unit test passes with no new exception.

## Definition of Done

- [ ] `check_settings.sh` carries no vocabulary of its own.
- [ ] `read_setting.sh --vocabulary` answers every documented key as the
      rule states.
- [ ] The schema's table and the shared home are held together by a
      test.
- [ ] `make kit-sync` leaves the kit byte-identical, no new entry in
      `tests/kit_exceptions.txt`.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- none — no product chapter changes; the rule is technical and already
  written in `technical/settings/schema.md#the-vocabulary-is-readable`
  by the change this task derives from.

## Proposed technical changes

- `technical/settings/schema.md#settings` — the one-reader sentence
  names the flag beside `--origin`.
- `technical/decisions/tasks-and-specs/0079-the-vocabulary-is-read-where-the-value-is.md`
  — the record: why the lists leave the checker for the shared home, and
  why a free-form key answers empty rather than with a shape word.
- `technical/decisions/README.md` — the index gains the record's line.

## Outcome

Built as planned, in the four places the scope named, with one shape
decided inside the plan rather than by it.

**The home answers on one line; the reader prints one per line.** The
rule asks for one value per line, and the checker's refusals are `case`
patterns over a space-separated list — `case " $vocab " in *" $val "*`.
`ql_vocabulary` therefore returns the space-separated form both the
checker and a `case` want, and `read_setting.sh --vocabulary` is what
turns it into lines. One home, one transformation, and neither side
carries the other's shape.

**The checker's per-key vocabulary cases are gone, not rewritten.**
`stage`, `pr_title_style`, the five booleans and the three stage-1
declarations each had a `case` arm doing the same four lines; the value
is now judged once, before the `case`, by the key's documented address.
What stays in the `case` is what is not a vocabulary: the two rename
refusals and the shape check the two free-form keys get.

**The address is the documented one, even for a homeless key.** A key
found in the wrong section is refused for its address and, if its value
is also outside its vocabulary, for that too — the same two refusals it
drew before, because the vocabulary is looked up by where the schema
says the key lives rather than by where the file put it.

**The table test reads a cell as a vocabulary only when every
alternative is a backticked literal.** That is what separates
`` `true` / `false` `` from *"lower-case words, space-separated"*
without a list of free-form keys to keep in step. Two guards sit beside
the comparison: the row count, so a parser that silently matched
nothing cannot agree with an empty home, and an assertion that
`commit_types` is read as free-form — the half of the parse with no
other signal.
