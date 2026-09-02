---
id: spec-0048
task_ref: task-0034
status: draft
created: 2026-09-02T06:02:30Z
---

# spec-0048 — take_task.sh takes a task in one act

**References:** [task-0034](../tasks/task-0034-session-cost.md)

- **Goal:** taking a task is one command: eligibility re-checked, the
  branch cut from a fresh `origin/main`, pushed, and the draft PR
  opened with the template body and a style-valid title — the push and
  the opening as the one act the docs already require, and the conduct
  flags honoured by the script instead of by prose re-read per session.

## Scope

In scope: `take_task.sh` in
`.writrun/scripts/stage-2-pull-requests/` (beside `queue_lib.sh`,
which it reuses for front-matter reads); its contract in
`technical/distribution.md`; the taking flow in `AGENTS.md` naming it;
unit tests; template sync.

Out of scope: choosing what to work on (the lister's), the title's
`[Type][Scope]` summary judgement (stays the agent's, passed in and
validated), and everything after the draft exists — implementation,
ready-for-review, completion.

## Steps

1. `take_task.sh <task-id> --title "<summary>" [--slug words]`:
   refuse on a dirty working tree; `git fetch origin main`; read the
   task and re-check selection steps 2–4 (`ready`, every `depends_on`
   done, every `spec_ref` approved/implemented) — refuse naming the
   failing filter, and refuse when `taken_by` is set or the forge
   shows an open PR for the task.
2. Branch `task/NNNN-<slug>` from `origin/main` — `--slug` optional,
   defaulting to the task filename's subject (the slug a human chose
   at creation).
3. Title: `[TASK-NNNN]` tag(s) prepended by the script; the given
   summary validated against `stage_2.pr_title_style` and the two
   vocabularies with the same grammar `check_observance.sh` applies —
   an invalid summary refuses before anything touches the forge.
4. Body: `.writrun/templates/pull_request_template.md`, implementing
   half kept, `Implements spec-…` filled from `spec_ref`.
5. Conduct flags, read from settings: `auto_push` and `auto_pr` both
   true → push and open the draft in one act (`gh pr create --draft`).
   Either false → print the composed branch, title and body, touch
   nothing on the forge, exit 2 — composed-and-waiting, the word is
   the human's.
6. No `gh`, unauthenticated, or no network → exit 3 with the tool's
   own words; nothing pushed, nothing half-done.
7. Contract in `technical/distribution.md`; `AGENTS.md`'s taking
   paragraph names the script; unit tests; `make template-sync`.

## Acceptance criteria (EARS)

- When the task is eligible and both flags are true, the script shall
  push the new branch and open a draft PR titled with the task tag and
  the validated summary, and exit 0.
- When the task fails a selection filter or is already taken or in
  flight, the script shall refuse before creating a branch, naming the
  filter, and exit 1.
- When either conduct flag is false, the script shall print the
  composed branch, title and body, perform no push and no PR, and
  exit 2.
- When the summary does not parse against the declared style or its
  vocabulary, the script shall refuse before any forge action, exit 1.
- When `gh` or the network is unavailable, the script shall exit 3
  with the underlying error, leaving the repository unchanged.

## Edge cases

- A branch `task/NNNN-*` already existing locally or on the forge —
  refuse and name it: resuming is not taking.
- Several tasks in one change — out of scope: the lead task is taken;
  further tags are the agent's title edit on the open PR.
- Forge unreachable *after* the branch was cut — the branch stays
  local, the exit-3 message says exactly what remains to run.
- `--title` omitted — required; the refusal shows one valid example in
  the declared style.

## Tests required

Unit, `tests/unit/take_task/`, with stub `git`/`gh` on `PATH`:
eligibility refusals (backlog, dep open, spec draft, `taken_by` set),
slug defaulting from the filename, title validation per style, flag
gating (either flag false → exit 2 and the stubs record zero calls),
the one-act ordering (no PR before push), exit 3 propagation.

## Definition of Done

- [ ] `take_task.sh` with the contract above; `AGENTS.md` and the
      chapter name it.
- [ ] Unit green; template synced; full suite green.

## Proposed product changes

- none — the taking flow's rules are unchanged; this mechanizes them

## Proposed technical changes

- `technical/distribution.md` — the script's contract joins the
  operational half.

## Outcome

_(fill after execution)_
