---
id: spec-0016
task_ref: task-0019
status: draft
created: 2026-08-30T02:58:05Z
---

# spec-0016 — Write task status onto main from pull request events

- **Goal:** the machinery commits every working-status transition of a
  task onto the base branch as its forge event lands — `main` is the
  complete mirror, as current as the forge can make it — through a
  checked transition machine that stale events cannot march backwards.

## Scope

The forge side only: the workflow(s) and scripts that react to pull
request and review events and push recording commits to the base
branch. The local checks, the skills and `AGENTS.md` are spec-0017; the
`taken_by` writes ride these same commits per spec-0019.

- Extend `writrun-progress.yml` (or a sibling workflow on the same
  events) to write the in-flight transitions.
- Extend the post-merge recording in `writrun-approve.yml` — the same
  single commit that flips approved specs and stamps dates — to also
  move the tasks the merge affects: `backlog → ready` when it approves
  their specs, `ready → backlog` when it returns one to `draft`
  (amendment), `→ done` / `→ ready` for the work it carries.
- New script(s) under `.writrun/scripts/pull-requests/`, following the
  shape of `flip_approved_specs.sh` / `stamp_task_dates.sh`: pure,
  id-driven, executable by the test suite's integration tier.

## The transition machine

The script holds the legal-edge table from
`product/tasks-and-specs/statuses.md` and writes only those edges:

| Event | Edge |
|---|---|
| creating merge's recording commit approves every spec | `backlog → ready` |
| a merge returns a spec to `draft` | `ready → backlog` |
| draft PR `opened` / `reopened` | `ready → in-progress` (+`taken_by`) |
| PR `ready_for_review` | `in-progress → in-review` |
| PR `converted_to_draft` | `in-review → in-progress` |
| review submitted `changes_requested` | `in-review → in-progress` |
| `review_requested` | `in-progress → in-review` |
| PR `closed`, unmerged | `in-progress`/`in-review` `→ ready` (−`taken_by`) |
| merge carrying the `completed` date | `→ done` (`taken_by` kept) |
| merge carrying work without it | `→ ready` (−`taken_by`) |

An event whose edge does not match the status the task holds writes
nothing and exits 0 — an out-of-order echo (a stale replay, a reopen
against a `done` task) is not an error, and it never marches a task
backwards.

## Steps

1. Script: apply one named event to one named task, consulting the edge
   table; idempotent — no-edge or already-there writes nothing.
2. Workflow on PR events (`opened`, `reopened`, `ready_for_review`,
   `converted_to_draft`, `closed`) and review events
   (`pull_request_review` submitted, `review_requested`): derive the
   task id from the head branch name (`task/NNNN-*`; no id → exit
   without committing), apply the event, commit and push with the
   rebase-not-force pattern `writrun-approve.yml` already uses.
3. Close-unmerged only: skip the reversal when another open pull
   request still works the same task (ask the forge).
4. Post-merge recording: the `ready`/`backlog` moves the spec flips
   imply, and `done`/`ready` for each task whose work the merge range
   carries — same commit as the spec flips and date stamps; one event,
   one commit.
5. Integration tests for each edge and each echo, in the existing
   tiers.

## Acceptance criteria (EARS)

- When a forge event listed in the edge table lands for a task whose
  status matches the edge's origin, the machinery shall commit the
  edge's destination to the base branch.
- When a forge event matches no legal edge for the status the task
  holds, the machinery shall write nothing and exit 0.
- When the head branch of a pull request names no task, the workflow
  shall exit without committing.
- When a pull request closes unmerged while another open pull request
  works the same task, the machinery shall leave the status in place.
- When the recording push races another change on the base branch, the
  machinery shall rebase onto it rather than force-push.
- When a recording commit changes a task's status, the stage-3 mirror
  machinery shall re-label that task's mirror from the queue as it then
  stands.

## Edge cases

- A PR opened ready (never draft): `opened` still writes
  `in-progress`; the immediately following `ready_for_review` state is
  read from the payload's draftness — an open non-draft PR lands
  `in-review` in the same run, one commit.
- Fork PRs: `pull_request_target` carries the write token; the head
  branch name and logins are data, never executed — same trust posture
  as `writrun-approve.yml`, branch validated as `task/[0-9]+-` before
  use.
- Pushes made with `GITHUB_TOKEN` trigger no workflow runs — recording
  commits cannot loop.
- The base branch may be protected in an adopting project: the
  documented requirement (README, Stage 2) is that `main` accept the
  Actions bot — unprotected, or a ruleset with the GitHub Actions app
  on its bypass list. The workflow fails loudly, not silently, when it
  cannot push.
- A multi-task PR (`[TASK-NNNN]` tags beyond the branch's own id): the
  merge-time moves are range-driven and cover all carried tasks; the
  in-flight moves cover the branch's task — the one the taking flow
  names.
- This repository itself: maintainer-authored PRs receive no formal
  reviews, so the two review edges simply never fire here; they exist
  for adopters whose review flow produces them.

## Tests required

Integration-tier tests for the transition script: every legal edge,
every echo (event × wrong-origin status), unknown id, malformed branch
name, the one-commit open-ready case, and the merge-time derivation
(date present, date absent, multi-task range, spec amendment
regression).

## Definition of Done

- [ ] All acceptance criteria hold, each with a test.
- [ ] The recording remains one commit per forge event.
- [ ] `writrun check` and the full test suite pass.

## Proposed product changes

- none — the rule was authored first
  (`product/tasks-and-specs/statuses.md`,
  `product/pull-requests/taking.md`,
  `product/pull-requests/finishing.md`,
  `product/github-issues/labels.md`); this change brings the machinery
  up to a doc that already states it.

## Proposed technical changes

- `technical/README.md#task-schema` — the `status` field's who-writes
  contract: the working states are machinery-written, from forge
  events; `blocked` and `dropped` stay hand-written.
- `technical/README.md#distribution` — the workflow/script inventory
  gains the transition machinery.

## Outcome

_(fill after execution)_
