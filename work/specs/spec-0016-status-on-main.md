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
| creating merge's recording commit approves every spec — or finds `spec_ref` empty | `backlog → ready` |
| a merge returns a spec to `draft` | `ready → backlog` |
| draft PR `opened` / `reopened` | `ready`/`backlog` `→ in-progress` (+`taken_by`); already in flight → refresh `taken_by` and state per the new PR's draftness — newest wins |
| PR `ready_for_review` | `in-progress → in-review` |
| PR `converted_to_draft` | `in-review → in-progress` |
| review submitted `changes_requested` | `in-review → in-progress` |
| `review_requested`, **non-draft PR only** (GitHub fires it on drafts too, e.g. via CODEOWNERS) | `in-progress → in-review` |
| PR `closed`, unmerged, no other open PR on the task | leave flight: `→ ready`, or `backlog` if any spec is `draft` (−`taken_by`) |
| PR `closed`, unmerged, another open PR survives | re-derive in-flight state and `taken_by` from the newest survivor |
| merge carrying the `completed` date | `→ done` (`taken_by` kept) |
| merge carrying work without it | leave flight: `→ ready`, or `backlog` if any spec is `draft` (−`taken_by`) |

Leaving flight is a derivation, not a return: an amendment may have
regressed a spec while the work was in flight — no edge interrupts
flight to say so — so the resting state is read from the specs at exit
time, never assumed to be the state the task left.

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
3. Close-unmerged only: ask the forge for other open pull requests on
   the same task; with a survivor, re-derive state and `taken_by` from
   the newest one rather than landing the task — never skip silently,
   or `taken_by` strands on the closed PR's author.
4. Post-merge recording: the `ready`/`backlog` moves the spec flips
   imply (an empty `spec_ref` counts as approved), and `done` or the
   leave-flight derivation for each task whose work the merge range
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
- When a task with an empty `spec_ref` lands in the queue, the
  recording commit shall move it `backlog → ready` — no approval event
  exists for it, and `backlog` must not be a trap.
- When a task leaves flight, the machinery shall land it on `ready`,
  or on `backlog` if any of its specs is `draft` at that moment.
- When a pull request closes unmerged while another open pull request
  works the same task, the machinery shall re-derive the in-flight
  state and `taken_by` from the newest surviving pull request.
- When `review_requested` fires on a pull request still in draft, the
  machinery shall write nothing.
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

- none — the schema's who-writes contract and the machinery rules were
  authored first (`technical/README.md#task-schema`); this change
  builds what the doc already states.

## Outcome

_(fill after execution)_
