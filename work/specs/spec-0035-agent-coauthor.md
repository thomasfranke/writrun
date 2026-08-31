---
id: spec-0035
task_ref: task-0025
status: draft
created: 2026-08-31T14:24:45Z
---

# spec-0035 — The agent's credit names its model, checked in both directions

**References:** [task-0025](../tasks/task-0025-agent-coauthor.md)

- **Goal:** the adopter's word on agent self-credit names an artifact
  instead of a source, and is named for what it does. `credit_ai` becomes
  `agent_coauthor`; `true` obliges a `Co-Authored-By:` trailer naming the
  model on every commit an agent makes, plus a credit line in the pull
  request body; and `check_observance.sh` gains the `true`-direction check
  the old definition made impossible.

## Scope

In: the key's name, its documented default, its value check, its
present-always membership; the `true`-direction commit check in
`check_observance.sh`; the reasoning in `.writrun/conventions/commits.md`
and `prs.md`; the template mirror; the tests that carry the old word.

Out: the provenance ledger and `provenance_ledger` (spec-0036 — the two
halves are independent by design). Out: the pull request **body** at
`true` — a trailer has a fixed shape and a fixed place, a body's credit
line has neither, so that half stays instruction-bound and is stated as
such rather than guessed at. Out: authorship and committer identity, which
stay git configuration; and commit signing, which is unrelated.

## Steps

1. Rename the key in `.writrun/settings.json`, `check_settings.sh`
   (present-always list and value check) and `read_setting.sh` (documented
   default `true`).
2. `check_settings.sh`: a file spelling `credit_ai` is refused naming
   `agent_coauthor` — the reject message is the whole migration path, as
   [0055](../../docs/technical/decisions/tasks-and-specs/0055-conduct-flags-live-in-stage-2.md)
   established for the last move.
3. `check_observance.sh`: keep the `false` direction as it stands
   (commits and body); add the `true` direction over commits only, faulting
   an agent's commit with no model-naming `Co-Authored-By:` trailer.
   Reuse the existing committer-identity resolution — the same one that
   skips the machinery's recording commit — to decide whose commit it is.
4. `commits.md` and `prs.md`: restate the contract as a shape, including
   that an agent on a platform appending no credit **writes** the trailer.
5. `make template-sync`.
6. Rename the tests carrying the old word and add the new direction's.

## Acceptance criteria (EARS)

- When `agent_coauthor` is `true` and a commit written by an agent carries
  no `Co-Authored-By:` trailer naming a model, `writrun check` shall exit
  non-zero naming that commit.
- When `agent_coauthor` is `true` and a commit was written by a person,
  `writrun check` shall not fault it for the absent trailer.
- When `agent_coauthor` is `false` and any commit or the pull request body
  carries platform credit, `writrun check` shall exit non-zero — unchanged
  from today.
- When a settings file spells `credit_ai`, `check_settings.sh` shall exit 1
  naming `agent_coauthor`.
- When the key holds anything but `true` or `false`, `check_settings.sh`
  shall exit 1 naming the fault.
- When the key is absent, `read_setting.sh` shall print `true`.

## Edge cases

- **The machinery's recording commit** is not an agent's action and is
  skipped in both directions, by committer identity and never by subject —
  the identity is the forge's, the subject is a variable the adopter is
  invited to edit.
- **A trailer naming a category, not a model** (`Co-Authored-By: AI`)
  satisfies the regex and defeats the purpose. The check reads the trailer
  for a model identifier, and this is the criterion most likely to need a
  judgement call about strictness — decide it explicitly rather than by
  what the regex happens to allow.
- **A person's commit on an agent's branch**, and the reverse: authorship
  is per-commit, so the direction is judged per-commit and never per-branch.
- **Stage 1**: no workflow runs, so neither direction is checked; the
  contract stays instruction-bound there, as every conduct flag does.
- **A commit that predates the flip**: nothing rewrites history, and the
  check reads the pull request's own commits, never `main`'s past.

## Tests required

`check_settings.sh`: boolean passes, other values fault, the old spelling
faults naming the new one, missing key faults. `read_setting.sh`: absent
key and absent file print `true`. `check_observance.sh`: the `false`
direction unchanged; the `true` direction faults an agent's untrailered
commit, passes a trailered one, and passes a person's commit — that last
one is the test that proves absence is not read as disobedience. The
mirror test proves `template/` carries all of it.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] No `credit_ai` survives outside the two append-only decision entries.
- [ ] Conventions state the contract as a shape; template synced; suite
      green.

## Proposed product changes

- none — the rule was authored first
  (`product/concepts/provenance.md#the-commits-carry-the-other-half`); this
  change brings the machinery up to a doc that already states it.

## Proposed technical changes

- none — the key, its default and its two-directional check were authored
  first (`technical/README.md#agent_coauthor`,
  `#observance-is-checked-where-it-leaves-a-trace`).

## Outcome

_(fill after execution)_
