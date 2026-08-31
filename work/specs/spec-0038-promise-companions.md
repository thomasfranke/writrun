---
id: spec-0038
task_ref: task-0028
status: draft
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

_(fill after execution)_
