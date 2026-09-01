---
id: spec-0038
task_ref: task-0028
status: implemented
created: 2026-08-31T14:48:56Z
---

# spec-0038 — An incomplete promise is refused where the spec enters

**References:** [task-0028](../tasks/task-0028-promise-companions.md)

- **Goal:** a spec whose promise adds a dated decisions entry but not
  the chronology index row is refused where the spec enters — the pull
  request that creates or amends it — so the omission that forced an
  amendment under a finished branch is caught where fixing it is one
  edit.

## Scope

In: the check, run by `writrun check` against the range's added or
modified specs; its fixture tests; the template mirror. The rule reads
one pair to start — a promised path under `docs/technical/decisions/`
matching a dated entry (`NNNN-*.md`) implies the decisions `README.md`
in the same promise — with the pair table written so a second pair is a
row, not a rewrite.

Out: `writrun-check-spec-deltas`, which stays the completion gate it is
— this check exists so that one fires less, not differently. Out: any
change to `new.sh`'s templates beyond what the check makes
self-explanatory; a template nudge can follow as trivial work if the
refusal message proves not to be enough.

## Steps

1. The check: for each spec file the range adds or modifies, parse the
   two Proposed-changes sections; if any promised path is a dated
   decisions entry and the decisions index is not also promised, fail
   naming the spec, the entry, and the missing companion.
2. Wire it into the check workflow beside its siblings.
3. `make template-sync`; tests.

## Acceptance criteria (EARS)

- When a changed spec promises a dated decisions entry and not the
  decisions index, `writrun check` shall exit non-zero naming the spec
  and the missing companion path.
- When the same promise carries both paths, the check shall pass.
- When a changed spec promises no decisions entry, the check shall not
  fire, whatever else it promises.
- When the promise section reads "none", the check shall not fire.

## Edge cases

- **A spec already on the authority branch with the incomplete
  promise**: out of reach — the check reads the range, and history is
  not re-judged. The completion gate still catches the stale case, as
  it did in the authoring case.
- **An amendment that fixes exactly this omission**: it modifies the
  spec, the check re-runs, and the amended promise passes — the check
  must not demand the index for a promise that now carries it.
- **A promise naming the index without an entry**: legal — appending a
  row alone is not the pattern this check reads.

## Tests required

Incomplete promise fails naming the companion; complete promise passes;
no-decisions promise ignored; "none" ignored; the fixture spec shapes
mirror the real pair from the authoring case. Mirror test.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] The pair table admits a second pair as one row.
- [ ] Template synced; suite green.

## Proposed product changes

- none — the rule was authored first
  (`product/concepts/spec.md#the-doc-delta-contract`); this change
  builds the refusal it states.

## Proposed technical changes

- none — decision 0059 records the case; the check implements a rule
  the product doc already carries.

## Outcome

Built as scoped: one new check, `check_promise_companions.sh`, wired into
`writrun check` and reading the specs the range adds or modifies. It
judges a promise's own internal completeness and nothing else — it never
looks at what the diff touched, which is the completion gate's question
and stays the completion gate's.

**The rule is a table.** One line per pair, `<entry-glob> <companion>`,
both repository-root relative — the shape promises are normalised to
before anything is compared. The first row is the pair the authoring case
named; a second pair is a line.

**The refusal names all three things.** The spec, the entry it promised,
and the companion it did not: `spec-0041 promises
technical/decisions/…/0062-….md and not
technical/decisions/README.md, which adding an entry implies`, followed by
the sentence saying where the cheap fix is and where the expensive one
would have been. The paths are printed relative to `docs/` — the shape a
spec writes, not the shape the table compares — because the fix is to
paste the named path into a Proposed changes section, and the
repository-root spelling pasted there normalises to `docs/docs/…` and is
refused again by the byte-identical message.

**Replayed against the case that authored the rule.** Run over the range
of #80 — the pull request that drafted spec-0041 — the check exits 1 and
names the missing index. Run over #84, the amendment that added it, it
exits 0. That is the whole point of the change, measured on the change
that caused it.

**Divergences.**

- **A step in the existing `deltas` job, not a job of its own.** The spec
  said "beside its siblings" and left the shape open. A job would have
  cost a second checkout of the same history to ask a cheaper question;
  as a step it runs immediately before the completion gate it exists to
  relieve, which is also the order the two fixes come in — one edit
  first, the amendment under a finished branch only if that was missed.
- **One row covers both `decisions_style` layouts.** `per-subsystem` puts
  a dated entry in a folder of the adoption level it concerns,
  `chronological` puts it in the log's root. These are two spellings of
  one pair, not two pairs, so the entry glob spans the path separator
  rather than the table carrying a row per declared layout — which would
  have made it read as one row per layout and defeated the property the
  spec asked for. The check reads no setting: the promise is a path, and
  the path is what is judged.
- **A second reader of the two Proposed-changes sections, not a shared
  one.** `check_deltas.sh` is a Stage 1 skill and must keep running with
  nothing but `work/` and git; this is workflow machinery under
  `.writrun/scripts/`. What they share is four lines of awk, and coupling
  them would have bought that at the price of a skill that stops working
  where it is promised to. Said in the code, beside the parser, so the
  duplication is a decision the next reader meets rather than finds.
- **The fixture helper grew rather than a new one appearing.**
  `spec_file` now takes any number of promised paths and routes each to
  the section the schema puts it in — `technical/…` under Proposed
  technical changes, everything else under Proposed product changes. A
  decisions entry is promised in the technical section in real life, and
  a fixture that could only promise one path in the product section could
  not have mirrored the authoring case at all. Every existing caller
  passes one product path and is unaffected.
- **Eight cases beyond the required list.** An unreadable range exits 3
  rather than passing on an empty read — the contract every gate here
  holds; a missing range exits 3 too, because 1 is this check's "a
  promise is incomplete" and a wiring bug reported in that code sends its
  reader to the spec instead of to the workflow; a spec path holding a
  space is read rather than word-split away; the chronological layout is
  exercised, because one glob covering two layouts is a claim that
  deserves a case; the pair a range inherited is left alone and the
  companion a range drops is not; and a folder promise is held to the
  pair from both sides.

**The range is read against its base, not on its own.** The spec's first
edge case — a spec already on the authority branch with the incomplete
promise is out of reach — is a property of the check, not of the diff
listing: `git diff --name-only` yields every spec the range *touches*,
which includes the completion pull request that only flips `approved` to
`implemented`. Judged there, this check would refuse a finished branch
with a message insisting the fix is one edit at exactly the moment it is
an amendment and a suspended task — the failure it exists to prevent,
caused by the check itself. So the promise is read at the merge base too,
and a pair is skipped only when *both* halves predate the range: an entry
the range added, or a companion the range removed, is still its doing.

**A trailing `/` means what the completion gate means by it.** The delta
contract reads a promised folder as covering everything beneath, so
promising the dated log's subfolder promises the entry that will land in
it and owes the index the same way naming the file would; and promising
the log's root covers the index itself. Both readings live in one
`promise_covers`, because two gates disagreeing about a trailing slash
would make the cheap one the more expensive of the two.

**Not done, as scoped.** No template nudge in `new.sh` — the spec left it
as trivial follow-up if the refusal message proves not to be enough, and
the message names the missing path outright.
