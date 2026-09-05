---
id: spec-0076
task_ref: task-0054
status: draft
created: 2026-09-05T12:57:21Z
---

# spec-0076 — The mirror labels from the branch that landed

**References:** [task-0054](../tasks/task-0054-six-review-findings.md)

- **Goal:** the mirror is labelled from what the authority branch
  holds, so a recording that failed to land leaves the mirror behind
  the queue rather than ahead of it.

## Scope

In: what `rederive_labels.sh` reads when `writrun-approve.yml`'s mirror
steps call it after a recording that did not land.

Out — and this is a **constraint, not a preference**: the
`!cancelled()` gate on both mirror steps does not move. The step's own
comment forbids moving it and cites decision 0060: `writrun-issues.yml`
and `writrun-progress.yml` both stand down for a merge, so skipping
these two leaves the merged close answering nothing — no Issue for a
task the merge added, an existing one left on `status:proposed` — and a
push made with `GITHUB_TOKEN` triggers no later run to heal it. Two
assertions in
`tests/integration/stage-3/merged_close/one_workflow_answers_it_test.sh`
hold the gate. A change that "fixes" this by gating on success
reintroduces the never-heals property decision 0060 exists to end.

Out: `writrun-progress.yml`'s `reflect`. It is a separate job with a
fresh checkout of `main`, so it already reads what landed. The
divergence is approve's alone.

Out: the recording's own failure modes. #199 is the change that made
them survivable; this is about what the mirror says afterwards.

### The fault

`rederive_labels.sh:466` calls `queue_file work/tasks`, which resolves
against the working tree. Both mirror steps run inside the recording
job, after the commit and push step, and the gate lets them run when
that step failed. The tree at that moment still carries the commit
`main` refused. The labeller therefore projects a queue state that
exists nowhere but this runner, and writes it onto the mirror.

**The direction is what makes it expensive.** Edge cases in spec-0067
say that after a failed recording the mirror stays faithful to the
queue — behind it, catching up when the recording next succeeds. A
mirror ahead of the queue is a different thing: it asserts a state
`main` refused, and the next successful recording has no reason to
revisit a label that already reads what it is about to write.

This is recorded as a divergence in
[spec-0067](spec-0067-recording-push-race.md)'s Outcome, on #199, which
also states why it was not fixed there: reading the landed branch is
behaviour that spec never scoped.

## Steps

1. Choose between two shapes, and say in the header which and why:
   have `rederive_labels.sh` read the landed branch explicitly, or have
   the workflow put the tree back to what `main` holds before the
   mirror steps run. The first is narrower and travels with the script;
   the second is one workflow line and leaves the script reading "the
   tree" as it says it does.
2. Implement it. If the script grows the notion of a ref to read from,
   `queue_file` and every reader beside it must take the same ref —
   two answers to "which tree" inside one pass is the divergence again,
   smaller.
3. Leave both `!cancelled()` gates and the merged-close ownership
   untouched.
4. Mirror into `template/` with `make template-sync`.

## Acceptance criteria (EARS)

- When the recording commit failed to land and the mirror steps run,
  the labeller shall derive every label from the authority branch as it
  stands, never from the runner's working tree.
- When the recording landed, the labels written shall be identical to
  those written today.
- When the labeller cannot read the authority branch, it shall say so
  and write no label, rather than falling back to the tree.
- When a merged close is processed, both mirror steps shall still run
  under `!cancelled()`.

## Edge cases

- **The push landed but the local ref is stale.** Reading a remote ref
  the runner has not fetched gives a tree older than the queue, which
  is the same class of wrong in the other direction. Fetch, or read the
  ref the push itself confirmed.
- **A task whose file exists only in the refused commit.** The
  labeller finds no file on the authority branch and takes its existing
  "no task file on this branch — nothing to derive from" path, which is
  the correct answer: there is no such task in the queue.
- **The mint step.** It runs before the labeller under the same gate
  and creates mirrors for tasks the merge added. A mirror minted for a
  task the refused commit carried is the same fault one step up, and
  the spec must say whether it is in this change or reported.
- **Stage below 3.** Both steps are already gated on the mirror being
  on; nothing here changes that.
- **`rederive_labels.sh`'s other caller.** `project_pr_tasks.sh` runs
  from a checkout of the authority branch where tree and branch agree,
  so it must be unaffected — which is the regression to test, not to
  assume.

## Tests required

- An integration case under `tests/integration/stage-3/`: a failed
  recording, then the mirror steps, asserting the label matches the
  authority branch and not the tree. This is the assertion the
  divergence is recorded against.
- A case asserting the labels after a *successful* recording are
  unchanged.
- A case asserting `project_pr_tasks.sh`'s path still labels correctly.
- The two existing `one_workflow_answers_it_test.sh` assertions must
  pass untouched — they are the guard on the constraint above.

## Definition of Done

- [ ] The labeller reads the authority branch, and its header says
      which shape was chosen and why.
- [ ] Both `!cancelled()` gates are byte-identical to today.
- [ ] `one_workflow_answers_it_test.sh` passes unchanged.
- [ ] The failed-recording case asserts the mirror is behind the queue,
      never ahead.
- [ ] The mint step's exposure is fixed here or reported.
- [ ] `template/` twins identical.

## Proposed product changes

- none — `product/stage-3-github-issues/labels.md` already states the
  rule this restores: the machinery re-labels the mirror from the queue
  as it then stands. The labeller was wrong about that rule, and being
  wrong about a rule is not a version of it.

## Proposed technical changes

- none — no chapter describes this pass, which is the answer
  spec-0065 and spec-0070 both gave for the same script.
  `distribution/` covers the kit, the checks and the release. No
  decisions entry either: `decisions/github-issues/0060` settled who
  owns the merged close, and this fixes what that owner reads without
  moving the ownership.

## Outcome

_(fill after execution)_
