---
id: spec-0037
task_ref: task-0027
status: draft
created: 2026-08-31T14:48:55Z
---

# spec-0037 — The suspension is derived and named everywhere it is read

**References:** [task-0027](../tasks/task-0027-amendment-suspends.md)

- **Goal:** the suspension the docs now describe is derived and named at
  every point where the queue is read — the lister, the resume step, and
  the check on the amendment itself — with no new field, no new status,
  and no write to any task file.

## Scope

In: `list_tasks.sh` (the In-flight section names a paused task beside
its suspending pull request); the `writrun-select-next-task` skill (the
resume step re-checks authorization against the authority branch and the
open pull requests); the amendment gate in `writrun check` (a pull
request returning an in-flight task's spec to `draft` fails unless its
body names that task's open pull request); the template mirror; tests.

Out: any write to task front matter — the suspension is read, never
stored (decision 0059). Out: `record_task_status.sh`, whose silence on
such a merge is the documented rule, not the gap. Out: rule G, which
stays as it is. Out: any Stage 3 mirror surface — a comment or label on
the Issue when an amendment opens is parked as a possible follow-up,
not built here. Out: the promise-completeness check (spec-0038).

## Steps

1. The lister: for each in-flight task, derive suspension from both
   halves of the union — a spec in its `spec_ref` not `approved` or
   `implemented` on the checkout, or an open pull request whose file
   list touches one of its specs. The forge half reads per-PR file
   lists (`gh api repos/{owner}/{repo}/pulls/N/files --paginate`, the
   technique `new.sh` already uses) for pull requests whose branch
   carries no task id; it degrades exactly as the existing PR query
   does — absent `gh`, files alone still catch the on-branch half,
   which is the whole Stage 1 story. Tests inject file lists through a
   companion to `WRITRUN_PR_LIST` (shape decided here, e.g.
   `WRITRUN_PR_FILES`).
2. The skill: the resume step's instructions gain the re-check the
   algorithm now states — a suspended task is resumed by finishing or
   waiting out the amendment, never by implementing through it.
3. The gate: extend `check_queue_impact.sh` — already wired in the
   check workflow and already reading the range — or add a sibling
   check if its contract fits badly; fail with a message that names the
   task, its open pull request, and the one-line fix.
4. `make template-sync`; tests for all three surfaces.

## Acceptance criteria (EARS)

- When a task is in flight and an open pull request proposes returning
  one of its specs to `draft`, the lister shall name the task as paused
  beside that pull request's number.
- When a task is in flight and a spec in its `spec_ref` is not
  `approved` or `implemented` on the checkout, the lister shall name it
  the same way with no forge access at all.
- When no amendment touches an in-flight task, the lister's In-flight
  section shall read exactly as it does today.
- When a pull request returns an in-flight task's spec to `draft` and
  its body does not reference that task's open pull request, `writrun
  check` shall exit non-zero naming the task, the pull request it
  should have named, and the fix.
- When the same pull request's body carries the reference, the check
  shall pass.
- When the task whose spec is amended is at rest — `ready`, `backlog`,
  `blocked` — the gate shall not fire: the pre-implementation amendment
  flow is unchanged.

## Edge cases

- **The forge unavailable** (no `gh`, no auth, rate-limited): the
  lister reports files-only truth and says so, never implying nobody is
  suspended — the same degrade contract the taken-by query already
  states.
- **An amendment and its task's pull request by different authors**: the
  reference requirement is symmetric in the docs but only the amendment
  side is machine-gated — the task PR predates the amendment and
  cannot have named it at open; its side stays convention.
- **A task with several specs, one amended**: suspended — partial
  authorization is not authorization.
- **The amendment closes unmerged**: the suspension derived from the
  forge half disappears with it; the specs on the authority branch were
  never touched. If the completion gate still cannot pass, that is the
  original problem back on the worker's desk, not a machinery state.
- **An amendment for a task at rest that goes in flight before the
  amendment merges**: the gate ran at the amendment's open and saw a
  resting task; the lister still derives the suspension live, so the
  window is named even though the gate never fired.

## Tests required

Lister: suspension from files alone; suspension from an injected PR
file list; both at once; a healthy in-flight task unnamed; forge-absent
degrade message. Gate: amendment without the reference fails naming
task and PR; with it, passes; amendment of a resting task's spec
ignored. Mirror test proves `template/` carries it all.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] No task file gains or changes any field.
- [ ] Template synced; suite green.

## Proposed product changes

- none — the rule was authored first
  (`product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request`,
  `product/stage-1-tasks-and-specs/conflicts.md`); this change brings
  the machinery up to it.

## Proposed technical changes

- none — the resume-step cross-check was authored first
  (`technical/README.md#task-selection-algorithm`); decision 0059
  carries the why.

## Outcome

_(fill after execution)_
