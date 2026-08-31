---
id: spec-0035
task_ref: task-0025
status: implemented
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

Shipped as amended. The key is `agent_coauthor` in both settings files,
the present-always list, the value check, the documented default and the
observance messages; a file still spelling `credit_ai` is refused naming
the new key. The `true` direction judges the pull request: when the body
declares agent work, every commit that is not the machinery's owes a
model-naming trailer, and a category name is refused. Suite 257 case
files, 0 failed.

**The amendment is the outcome.** Step 3 said to reuse the committer
identity to decide whose commit it is, and that identity answers a
different question — it knows the forge's bot from everyone else. Nothing
in what the check receives separates an agent's commit from a person's:
on this platform an agent commits under whoever ran it, same name and
same email. Every signal that exists is per-branch, so the unit became
the pull request, `check_observance.sh` reads the body's credit line as
the declaration, and a person's commit on a declared-agent branch is
asked for the trailer too. That cost is stated in the edge cases rather
than discovered by whoever hits it.

**Where the implementation went past the amendment.**

- **Bare family names join the refused vocabulary.** `Claude`, `GPT` and
  `Copilot` are refused alongside `AI` and `an agent`: a family is not a
  model, and the record exists to survive the next model's arrival. The
  amendment listed the category words and this widens the list by the
  same argument.
- **A merge commit owes no trailer**, and this was found by the check
  running on its own pull request: it faulted the branch's own merge of
  `main` and the synthetic merge the forge builds to test every pull
  request. A merge's message is composed by git, and the work it joins
  already carried whatever credit it owed in the commits that did the
  writing. The spec's principle already covers it — the flag reaches what
  an agent *wrote*, which is why the machinery's recording commit is
  exempt — but the mechanism is different: two parents rather than a
  committer identity. Named here because it is a judgement made during
  implementation, not one the spec settled.

  Its first version was wrong in a way one merge cannot show: the
  exemption is a membership test over a list, and a newline-separated
  list behaves exactly like a space-separated one until there are two
  entries. It passed here and faulted in CI, where the forge stacks its
  own synthetic merge on the branch's. The case that guards it now builds
  two.
- **A value outside the vocabulary judges nothing**, and says so, the way
  the title check already treats a `pr_title_style` it does not know.
  `check_settings.sh` is where that fault is named; faulting honest
  commits for a fault in another file would be the wrong door.
- **The doc's promised anchor gained two paragraphs, not one sentence.**
  The amendment removed a claim; what replaced it had to say why the
  per-commit unit is unavailable, or the next reader re-derives the same
  dead end.
- **Every trailer is read, not the first one.** A commit that credits a
  person and a model carries two, and the first version stopped at line
  one — so `Co-Authored-By: an AI` passed with a human above it and
  faulted with the human below. A verdict decided by line order is not a
  rule anyone can obey, and the arrangement that passed is the one an
  agent reaching for a category would write, since its own line goes
  last. The obligation is that *a* trailer names a model, so every
  trailer is asked and each category found is named.
- **The rename got a reader bridge, not only a checker fault.** Step 2
  named `check_settings.sh`; the file it refuses is one the reader still
  has to read meanwhile, exactly as decision 0053's `level` bridge does.
  Without it a settings file spelling `credit_ai: false` read as absent,
  the default `true` applied, and a deliberate opt-out inverted into an
  obligation — `check_observance.sh` flipping from forbidding credit to
  demanding trailers. The rename fault's own sentence promises the value
  carries over; this is where the promise is kept.

**What no check reaches, stated plainly.** An agent that credits itself
nowhere — no body line, no trailers — passes. That is the same blind spot
`auto_commit` has: absence is not evidence, and a check that guessed
would fault honest work to catch nothing.
