---
id: spec-0035
task_ref: task-0025
status: approved
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
   (commits and body); add the `true` direction over commits only.

   **The unit judged is the pull request, not the commit** — this is the
   amendment. The step as approved said to reuse "the existing
   committer-identity resolution" to decide whose commit it is, and that
   resolution answers a different question: it knows the forge's bot from
   everyone else, and nothing distinguishes an agent's commit from a
   person's. On the platform this repository runs on, an agent commits
   under the human who ran it — same name, same email. The check receives
   `PR_TITLE` and `PR_BODY` and no identity at all.

   So the declaration is read where one exists: **the pull request body.**
   At `true` the flag obliges a credit line there, and that line is the
   pull request saying an agent worked it. When the body carries it, every
   commit in the range that is not the machinery's must carry a
   model-naming `Co-Authored-By:` trailer; when nothing declares agent
   work anywhere, there is nothing to judge and the check says so.

   What this catches is partial compliance — the agent that trailered
   three commits of five, or wrote the body line and none of the trailers.
   What it cannot catch is an agent that credits itself nowhere, which is
   the same blind spot `auto_commit` has and for the same reason: absence
   is not evidence.

   **The model is named specifically, not as a category.** The trailer's
   name is refused when it is, in whole, one of a small vocabulary —
   `AI`, `an AI`, `agent`, `bot`, `assistant`, `LLM`, `model` and the
   articled forms. This is a tripwire, not a proof: a name written to
   evade it evades it, exactly as `check_settings.sh`'s core-rule stems
   do, and what it catches is the honest attempt reaching for a category
   because nobody said not to.
4. `commits.md` and `prs.md`: restate the contract as a shape, including
   that an agent on a platform appending no credit **writes** the trailer.
5. `make template-sync`.
6. Rename the tests carrying the old word and add the new direction's.

## Acceptance criteria (EARS)

- When `agent_coauthor` is `true` and the pull request body carries a
  credit line, `writrun check` shall exit non-zero naming any commit in
  the range, other than the machinery's own, that carries no
  `Co-Authored-By:` trailer naming a model.
- When `agent_coauthor` is `true` and the pull request body carries no
  credit line, `writrun check` shall judge no commit for an absent
  trailer, and shall say that nothing declared agent work.
- When a `Co-Authored-By:` trailer names a category rather than a model,
  `writrun check` shall exit non-zero naming the trailer.
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
- **A person's commit on an agent's branch.** It faults, and that is the
  cost of this amendment paid in the open. The spec as approved said the
  direction is judged per-commit and never per-branch; per-commit needs a
  signal that does not exist, so the unit is the pull request and a human
  commit on a declared-agent branch is asked for the trailer too. The
  cheap answer is to trailer it — the trailer names who helped write the
  change, and on a branch an agent worked, it did. The alternative
  considered and rejected was a settings key listing agent identities:
  it delivers the per-commit judgement exactly, and it asks every adopter
  to maintain a list whose omission silently switches the gate off.
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

- `technical/README.md#observance-is-checked-where-it-leaves-a-trace` —
  the `true` direction's unit is the pull request, and the sentence
  saying "which commits are an agent's is the same committer-identity
  question the skip above already answers" goes with the amendment: that
  question has no answer in the data the check receives. The rest of the
  section — the key, its default, the `false` direction — was authored
  first and stands.

## Amendment — 2026-08-31

Returned to `draft` under an open pull request. **#81 is the suspended
pull request, and this amendment is what suspends it**; the two name each
other by hand, because the machinery that would derive the pause is
spec-0037's and is not implemented yet
([statuses](../../docs/product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request)).
The task cannot advance until this is re-approved.

What changed: step 3's unit, the two `true`-direction acceptance
criteria, the per-commit edge case, the category-name decision the
approved text left to the implementer, and the Proposed technical
changes, which were `none` and can no longer be — the amendment makes one
sentence of `#observance-is-checked-where-it-leaves-a-trace` false, so
the implementation must correct it and the promise list has to say so.

What did not change: the rename, the migration reject, the `false`
direction, and the conventions — all of which are already implemented on
#81 and are untouched by this.

## Outcome

_(fill after execution)_
