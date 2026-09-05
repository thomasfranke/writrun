---
id: spec-0075
task_ref: task-0054
status: draft
created: 2026-09-05T12:57:12Z
---

# spec-0075 — The gate holds a task whose spec is still owed

**References:** [task-0054](../tasks/task-0054-six-review-findings.md)

- **Goal:** a task that lands with its spec still owed is held out of
  selection by a gate, not by an agent remembering the rule.

## Scope

In: a new rule in `.writrun/skills/writrun-check-task-state/check_state.sh`,
its entry in that skill's `SKILL.md`, its unit cases, and the
`template/` twins of all three.

Out: the rule itself. #202 authors it in
[`authoring.md#reporting--work-found-or-reported-mid-flight`](../../docs/product/stage-1-tasks-and-specs/authoring.md#reporting--work-found-or-reported-mid-flight):
a task whose spec is drafted later lands `status: blocked` with a
`blocked_reason` naming the spec owed, and is released from `blocked`
by the change that adds the spec. This spec enforces that sentence and
does not restate it.

Out: the release edge. `blocked → backlog|ready` by hand is already
legal under rule G, and #202 states when it is taken.

Out: any new front-matter field. A field that says "no spec is
warranted here" would settle the hard case below cleanly, and it is a
schema change — the authoring direction, and a change of its own.

**This spec depends on #202.** Before it merges there is no rule to
enforce, and a gate refusing a shape no doc names is a gate that will
be argued with rather than fixed.

### What passes today and should not

A `report/` pull request adds an `origin: report` task with `spec_ref:
[]`, leaves it `status: backlog`, and adds no spec. Every gate passes.
The merge moves it `backlog → ready`, because `apply_pr_event.sh`
promotes a task whose specs are approved *or which references none*. It
is then selectable, against a brief no spec has bounded.

The cost lands later and on someone else. An agent takes it and
implements what the body suggests. The spec is drafted mid-flight and
merges `approved`, and its **Proposed changes** become a completion
contract the work never targeted. `check_promised_deltas.sh` returns
MISSING for what the spec promised and UNDECLARED for what the change
touched, at the completion gate, with the work already done.

### The hard case, and how this rule survives it

`spec_ref: []` alone cannot tell "the spec is owed" from "no spec is
warranted". The project declares `spec_required: when-warranted`, so
the second is legitimate and common. `blocked_reason` is the only
carrier in the schema today, and it is the wrong one for a task that is
not stalled.

Three ways to resolve it were weighed.

- *Refuse every `origin: report` task that lands `backlog` with no
  spec.* Rejected. It refuses the legitimate case, and the only way
  past it would be writing `blocked` on a task nothing is blocking —
  teaching the queue's clearest status to mean two things.
- *Add a front-matter field that says no spec is warranted.* Rejected
  here, not on merit. It is the cleanest discriminator and it is a
  schema change, so it authors a rule rather than closing a loop; if
  the owner prefers it, this spec is the wrong vehicle and should be
  replaced rather than stretched.
- *Scope the rule to what the change declares, not to the file alone.*
  Taken. A reporting pull request already owes a statement of "the
  report, the pair it adds, and the rule they derive from"
  (`AGENTS.md`), so a pair that is deliberately half a pair is a thing
  the change already says out loud. Rule K is the precedent for the
  shape: two halves, one readable from the diff and one needing an
  input only the caller has, and a stand-down that announces itself.

**So rule L has two halves.** The **file half** runs everywhere and
needs nothing but the range: an `origin: report` task newly added with
`spec_ref: []` and `status: blocked` must carry a non-null
`blocked_reason`. A blocked task whose reason is null names nothing to
wait for, and no reader can release it. The **declaration half** is
Stage 2+ and needs the pull request's body: a newly added `origin:
report` task with `spec_ref: []` landing `backlog`, with no spec added
in the same change, is refused unless the change declares that none is
warranted. Where the body is unreadable — a local run, a detached HEAD
— the half stands down on stdout, exactly as rule K's branch half does,
and never passes quietly.

## Steps

1. Read rule K's implementation end to end. Its two-halves shape, its
   stand-down announcement and its stage condition are the pattern this
   follows, and diverging from them would give one file two ways of
   saying the same thing.
2. Add rule L to `check_state.sh`, with the header comment its siblings
   have: what it refuses, why the queue is worse without it, and why it
   is scoped to the declaration rather than to the file.
3. Decide and document the declaration's exact form — what a change
   writes to say no spec is warranted, and where `writrun check` reads
   it. It must be visible to a human reviewing the pull request, since
   its whole purpose is to make the choice explicit.
4. Add rule L to `SKILL.md`'s rule list, in place, with the same
   register as A through K.
5. Add the four cases below under `tests/unit/check_state/`.
6. Mirror into `template/` with `make template-sync`.
7. Record the refusal in `statuses.md`'s criteria, and the caller's
   obligation to pass the body in `checks.md` — the two doc changes
   this spec promises.

## Acceptance criteria (EARS)

- When a change adds an `origin: report` task with `spec_ref: []` and
  adds a spec whose `task_ref` resolves to it, the check shall pass.
- When a change adds an `origin: report` task with `spec_ref: []`,
  `status: blocked` and a non-null `blocked_reason`, and adds no spec,
  the check shall pass.
- When a change adds an `origin: report` task with `spec_ref: []`,
  `status: blocked` and a null `blocked_reason`, the check shall report
  FORBIDDEN.
- When a change adds an `origin: report` task with `spec_ref: []`,
  leaves it `backlog`, adds no spec, and declares nothing, the check
  shall report FORBIDDEN and name both ways out.
- When the change declares that no spec is warranted, the check shall
  pass on a `backlog` task with no spec.
- When the declaration cannot be read, the check shall say on stdout
  that the half stood down, and shall not pass quietly.
- When the task's `origin` is `rule`, the check shall not judge it —
  a rule-derived task's spec is the authoring change's to have created.

## Edge cases

- **A task that already existed.** Rule L reads newly added tasks only.
  A task the base branch holds with `spec_ref: []` is not this change's
  to answer for, and judging it would refuse every unrelated pull
  request that happens to touch the queue.
- **Several tasks in one change.** #184 landed five. Each is judged on
  its own, and the output names every one that fails rather than the
  first.
- **A spec added for a *different* task.** The pairing is `task_ref`
  resolving to this task, never "a spec file appeared in the diff".
- **A task blocked for a reason that is not a spec.** `blocked_reason`
  is free text and rule L does not parse it. The reason exists so a
  human can release the task; a check that graded its wording would be
  refusing English.
- **Stage 1.** The declaration half is Stage 2+, like E, F and K: a
  project with no pull requests has no body to read. The file half runs
  at every stage.
- **`spec_required: always`.** An adopter declaring it has no
  legitimate no-spec case, so the declaration would never be written
  and the rule reduces to "add the spec or block the task". Check the
  setting rather than assuming this project's answer.

## Tests required

- The four cases named in the acceptance criteria — pair, blocked with
  reason, blocked with null reason, and bare `backlog` — under
  `tests/unit/check_state/`.
- A case for the declaration form, passing a `backlog` no-spec task.
- A case asserting the stand-down prints when the declaration is
  unreadable, and that the exit is not a silent 0.
- A case asserting an `origin: rule` task with `spec_ref: []` is
  untouched by rule L.
- A case asserting a pre-existing task with `spec_ref: []` is untouched.

## Definition of Done

- [ ] Rule L is in `check_state.sh`, both halves, with the stand-down
      announcement.
- [ ] `SKILL.md`'s rule list carries L.
- [ ] All four brief cases pass, plus the four edge cases above.
- [ ] `template/` twins identical; `make template-sync` reports nothing
      to do.
- [ ] The legitimate no-spec task has a documented way through, and a
      test proving it.
- [ ] `statuses.md` and `checks.md` record the refusal and the caller's
      obligation.
- [ ] `preflight.sh` exits 0 on this change.

## Proposed product changes

- `product/stage-2-pull-requests/statuses.md#criteria` — a criterion
  for the refusal, beside the id-collision one it is shaped like: what
  the machinery rejects, and the two shapes that pass.

## Proposed technical changes

- `technical/distribution/checks.md#running-the-checks` — rule L's
  declaration half needs an input the caller supplies, and a caller
  that omits it gets a pass it did not earn. That is exactly the class
  of rule this chapter holds.

## Outcome

_(fill after execution)_
