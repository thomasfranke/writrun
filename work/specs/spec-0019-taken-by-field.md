---
id: spec-0019
task_ref: task-0019
status: draft
created: 2026-08-30T03:05:33Z
---

# spec-0019 — The taken_by field: who took the task, recorded by the machinery

- **Goal:** a task on `main` names who is working it — the forge login
  of the pull request's author, machinery-written in the same commit as
  the status flip, cleared whenever the task returns to `ready`, kept
  on `done` as the record of who completed it. A record, never an
  assignment.

## Scope

The field end to end: schema, generator, checks, and the write itself
riding spec-0016's commits. Reserving or assigning work stays a
non-goal — the field reports the forge, it entitles nobody.

- Task front-matter gains `taken_by` (string login or `null`), after
  `status`/`blocked_reason` in the canonical order.
- The generator (`new.sh`) writes `taken_by: null` on every new task.
- `check_front_matter.sh` knows the field and its canonical position;
  existing queue files are migrated in this change (a `null` line added
  — front matter is contract, not assented prose).
- The stage-2 workflow writes it: author login on the `in-progress`
  flip, `null` on the close-unmerged reversal, untouched at merge.
- `writrun-check-task-state` rejects a branch-side edit of `taken_by`,
  same as the status line: one writer.

## Steps

1. Schema + generator + front-matter check, with migration of the
   existing queue files.
2. Extend spec-0016's flip script to take an optional login and write
   both lines in one commit.
3. Extend spec-0017's branch-side rejection to cover the field.
4. Tests in the same suites the sibling specs touch.

## Acceptance criteria (EARS)

- When a draft pull request opens for a task, the recording commit
  shall set the task's `taken_by` to the pull request author's login.
- When the task returns to `ready` — its pull request closed unmerged,
  or a merge carried partial work without the `completed` date — the
  recording commit shall set `taken_by` back to `null`.
- When a merge moves a task to `done`, `taken_by` shall keep the login
  it holds — the record of who completed the work.
- When a newer pull request takes a task another had abandoned, the
  field shall follow the newest event.
- When a branch's diff edits `taken_by`, `writrun-check-task-state`
  shall exit non-zero.
- When the generator creates a task, it shall write `taken_by: null`.

## Edge cases

- A fork contributor: the login comes from the event payload
  (`pull_request.user.login`), which the forge authenticates — the
  head branch name is data, the login is the forge's own claim. Written
  as the bare login, no `@`, so nobody is pinged by a queue file.
- A bot author (renovate, a scheduled agent): its login is recorded
  like anyone's — the field reports, it does not judge.
- Two open pull requests for one task: last event wins, and the mirror
  plus the pull requests themselves carry the full story; the field is
  a pointer, not a ledger.
- Stage 1: no forge, field stays `null` — hand-editing it is rejected
  from Stage 2 up only, same gating as the status line.

## Tests required

Generator emits the field; front-matter check accepts canonical and
rejects misplaced/missing; flip script writes and clears it with the
status in one commit; check-task-state rejects a branch-side edit.

## Definition of Done

- [ ] All acceptance criteria hold, each with a test.
- [ ] Every queue file migrated, `check_front_matter.sh` green.
- [ ] `writrun check` and the full test suite pass.

## Proposed product changes

- none — the rule was authored first
  (`product/tasks-and-specs/statuses.md`); this change brings schema
  and machinery up to a doc that already states it.

## Proposed technical changes

- none — the field is already in the authored schema
  (`technical/README.md#task-schema`); this change builds the
  generator, checks and writes the doc already states.

## Outcome

_(fill after execution)_
