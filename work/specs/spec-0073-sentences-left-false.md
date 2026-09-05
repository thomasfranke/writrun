---
id: spec-0073
task_ref: task-0054
status: approved
created: 2026-09-05T12:56:54Z
---

# spec-0073 — Three sentences three changes left false

**References:** [task-0054](../tasks/task-0054-six-review-findings.md)

- **Goal:** three sentences that three merged changes leave false say
  what is true, and none of them says more than that.

## Scope

In: three statements, in three files, each falsified by a change that
could not have fixed it — the correction was outside that spec's
declared deltas, so touching it would have returned UNDECLARED at the
delta gate.

Out: the behaviour any of the three describes. Every one of these is a
sentence catching up to code that already shipped or is about to. A
change here that also moved behaviour would be two kinds in one
([`authoring.md#two-ways-a-permanent-doc-changes`](../../docs/product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes)).

Out: `checks.md` line 54's sentence about `apply_pr_event.sh` having no
fallback with neither `PR_HEAD_REF` nor `PR_TITLE` set. It is true
before and after `PR_NUMBER` joins the enumeration, and rewriting a
true sentence beside a false one is how the false one's correction
stops being reviewable.

**This spec depends on #200 and #202.** Two of the three sentences are
true today and become false when those merge. Implementing before then
would write a doc ahead of the code, which is authoring, not loop
closure.

### 1. The `PR_*` enumeration omits `PR_NUMBER`

`docs/technical/distribution/checks.md`, lines 38-41, names the
pull-request event data a workflow step passes: "`PR_HEAD_REF`,
`PR_TITLE`, `PR_AUTHOR`, `PR_DRAFT` and `PR_MERGED` reach
`apply_pr_event.sh` and its siblings that way." After #200 that
enumeration is short by one. `apply_pr_event.sh:18-19` documents
`PR_NUMBER` in its own env block, and `.github/workflows/writrun-progress.yml`
passes `${{ github.event.pull_request.number }}` at lines 87 and 107,
mirrored in `template/`.

The omission matters in the paragraph's own terms. That paragraph
exists to name the silent-miswiring hazard: a name the caller never
sets, or the callee never reads, and neither is loud. An empty
`PR_NUMBER` makes the own-row drop at `apply_pr_event.sh:200` a no-op,
and per spec-0068's Edge case "The closing pull request in its own
`open` listing" that *widens* the self-survivor strand — on a lagging
listing the closing pull request claims every tag-carried task, not
only the one its head branch spells. The paragraph would be naming a
hazard while omitting the name it is now most expensive to miswire.

### 2. `new.sh`'s refusal restates a rule #202 changes

`.writrun/skills/writrun-create-task-and-spec/new.sh:448`, and its
`template/` twin at the same line, print "its pull request presents the
report, the task and the spec together" when refusing an `origin:
report` task creation off a `report/` branch. #202 authors the route
where the spec lands later, so the sentence states an absolute the rule
no longer holds.

**This is a stale string, not a gate.** The branch check fires on task
creation only, never on spec creation, so the late-spec route already
works and prints nothing. Nothing about the refusal's condition moves;
one sentence of its explanation does.

### 3. The refusal clause names one class of three

`docs/product/stage-2-pull-requests/statuses.md:158` reads: "When the
machinery cannot land a write it owes — the authority branch refused it
— it shall report the failure, and never report success over a queue it
left unwritten." After #199 there are three ways the write fails to
land: the remote refused it, the remote was never reached, and the
rebase conflicted.

**The obligation is unchanged and is satisfied in all three.** Only the
em-dash clause over-narrows, by naming one class as though it were the
set. A criterion that enumerates its trigger wrongly is read by the
next author as the boundary of the rule.

## Steps

1. Add `PR_NUMBER` to the enumeration in `checks.md`, and say in the
   same paragraph what an empty one costs — the own-row drop becomes a
   no-op, which is the widening spec-0068's edge case describes. Leave
   line 54 alone.
2. Rewrite `new.sh:448`'s sentence to state the route as #202 leaves
   it: the reporting pull request presents the report and the task, and
   the spec either with them or in a pull request of its own. Apply the
   identical edit to `template/.writrun/skills/writrun-create-task-and-spec/new.sh`.
3. Replace the em-dash clause in `statuses.md`'s criterion with one that
   covers all three classes, or with none — the obligation reads
   cleanly without an enumeration, and an absent list cannot go stale.
4. Run `make template-sync` and confirm it reports nothing to do: the
   twin was edited in step 2, not left for the mirror.

## Acceptance criteria (EARS)

- When `checks.md` enumerates the `PR_*` names a workflow step passes,
  it shall name every one `apply_pr_event.sh` reads, `PR_NUMBER`
  included.
- When `new.sh` refuses an `origin: report` task creation off a
  `report/` branch, its explanation shall state the route #202
  authors, and the refusal's condition shall not change.
- When `statuses.md` states the machinery's obligation on a write it
  cannot land, the sentence shall not name one failure class as though
  it were the set.
- When `new.sh` and its `template/` twin are compared, they shall be
  byte-identical.

## Edge cases

- **#200 or #202 does not merge.** Then the sentence it would falsify
  is true, and the corresponding step must not ship. Check both before
  implementing; a doc corrected ahead of the code is the authoring
  direction, refused here by construction.
- **`checks.md` is one of the kit's mirrored files.** It is not — the
  mirror covers `.writrun/`, and `docs/` is this repository's. Only
  step 2 has a twin.
- **The delta gate on this change.** Two `docs/` paths are touched and
  both are promised below; `new.sh` is not under `docs/`, so it is
  invisible to `check_deltas.sh` and is held by the Definition of Done
  instead.

## Tests required

- A unit case asserting the `PR_*` enumeration in `checks.md` lists
  every `PR_` name `apply_pr_event.sh` reads. A doc sentence that
  enumerates a code contract is the kind that goes stale silently, and
  this is the assertion that would have caught it.
- The existing `template/` byte-identity case covers step 2's twin; no
  new case is needed for it.
- No test for step 3. It is prose about an obligation three integration
  cases already assert behaviourally.

## Definition of Done

- [ ] `checks.md` names `PR_NUMBER` and says what an empty one costs.
- [ ] `checks.md` line 54's sentence is unchanged.
- [ ] `new.sh:448` and its `template/` twin state the late-spec route,
      identically.
- [ ] The branch check's condition is unchanged.
- [ ] `statuses.md`'s criterion no longer names one refusal class as
      the set.
- [ ] `make template-sync` reports nothing to do.
- [ ] `check_deltas.sh` exits 0.

## Proposed product changes

- `product/stage-2-pull-requests/statuses.md#criteria` — the criterion
  on a write the machinery cannot land stops naming one failure class
  as though it were all three.

## Proposed technical changes

- `technical/distribution/checks.md#running-the-checks` — the `PR_*`
  enumeration gains `PR_NUMBER`, and the paragraph says what an empty
  one costs.

## Outcome

_(fill after execution)_
