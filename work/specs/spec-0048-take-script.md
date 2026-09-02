---
id: spec-0048
task_ref: task-0034
status: implemented
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

1. `take_task.sh <task-id> --title "<summary>" [--slug words]
   [--resume] [--confirm]`: refuse on a dirty working tree;
   `git fetch origin main`; read the task and re-check selection
   steps 2–4 (`ready`, every `depends_on` done, every `spec_ref`
   approved/implemented) — refuse naming the failing filter; refuse
   when `taken_by` is set or the forge shows an open PR for the
   task; and re-check the lister's amendment half: an open pull
   request carrying no task id but touching any spec in the task's
   `spec_ref` suspends the take — refuse naming that pull request
   (the same forge read `list_tasks.sh` makes; the gate must not be
   weaker than the lister it re-checks).
2. Compose, touching nothing: the branch name `task/NNNN-<slug>`
   (`--slug` optional, defaulting to the task filename's subject —
   the slug a human chose at creation); the title — `[TASK-NNNN]`
   tag(s) prepended by the script, the given summary validated
   against `stage_2.pr_title_style` and the two vocabularies with
   the same grammar `check_observance.sh` applies, an invalid
   summary refusing here, before anything exists; the body from
   `.writrun/templates/pull_request_template.md`, implementing half
   kept, `Implements spec-…` filled from `spec_ref`.
3. Conduct flags, read from settings: `auto_push` and `auto_pr` both
   true → the act below. Either false → print the composed branch,
   title and body, touch neither the tree nor the forge, exit 2 —
   composed-and-waiting, the word is the human's, and the printout
   ends with the `--confirm` rerun that performs exactly the printed
   act once it is given.
4. The act, one motion: verify the forge first (`gh` present,
   authenticated, reachable — failing here is exit 3 with the tool's
   own words and the repository untouched); then branch from
   `origin/main`, push, `gh pr create --draft`. A forge failure
   *after* the branch is cut also exits 3 — the message names the
   branch kept local and says the rerun is `--resume`, which
   finishes the act (push and PR only, never a second branch).
5. Contract in `technical/distribution.md`; `AGENTS.md`'s taking
   paragraph names the script; unit tests; `make template-sync`.

## Acceptance criteria (EARS)

- When the task is eligible and both flags are true, the script shall
  push the new branch and open a draft PR titled with the task tag and
  the validated summary, and exit 0.
- When the task fails a selection filter, is already taken or in
  flight, or is suspended by an open amendment on one of its specs,
  the script shall refuse before creating a branch, naming the filter
  or the pull request, and exit 1.
- When either conduct flag is false, the script shall print the
  composed branch, title and body, create no branch, perform no push
  and no PR, exit 2, and name the `--confirm` rerun.
- When the summary does not parse against the declared style or its
  vocabulary, the script shall refuse before any forge action, exit 1.
- When `gh` or the network is unavailable before the branch is cut,
  the script shall exit 3 with the underlying error, leaving the
  repository unchanged; when the forge fails after the cut, it shall
  exit 3 naming the branch kept local and the `--resume` rerun that
  finishes the act.

## Edge cases

- A branch `task/NNNN-*` already existing locally or on the forge —
  refuse and name it: resuming is not taking. One carve-out: a local
  branch with no upstream and no open PR is the leftover of an
  interrupted take, and `--resume` finishes it; everything else
  stays a refusal.
- Several tasks in one change — out of scope: the lead task is taken;
  further tags are the agent's title edit on the open PR.
- Forge unreachable *after* the branch was cut — the branch stays
  local, exit 3 names it and `--resume` is the stated way to finish;
  a bare rerun hits the branch-exists refusal by design.
- `--title` omitted — required; the refusal shows one valid example in
  the declared style.

## Tests required

Unit, `tests/unit/take_task/`, with stub `git`/`gh` on `PATH`:
eligibility refusals (backlog, dep open, spec draft, `taken_by` set,
open amendment on a `spec_ref`, dirty tree, branch already existing),
slug defaulting from the filename, title validation per style, flag
gating (either flag false → exit 2; the `gh` stub records zero calls
and the `git` stub records no branch and no push — the eligibility
fetch is the one call allowed), the one-act ordering (no PR before
push), exit 3 with the repository untouched before the cut, the
post-cut exit 3 naming `--resume`, and `--resume` finishing with
push and PR only.

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

`take_task.sh` ships beside `queue_lib.sh` and reuses it for every
front-matter read. It refuses a dirty tree, fetches `origin main`,
re-applies selection steps 2–4 naming the filter that held, composes the
branch (slug defaulting to the filename's subject), the title (tag
prepended, summary read against the declared style with the vocabularies
extracted from `check_observance.sh` itself) and the body (the template's
implementing half, `Implements spec-…` filled from `spec_ref`), and then
performs the act: forge verified, branch cut from `origin/main`, pushed,
draft opened.

Divergence, and it is the one worth reading: **the forge reads moved
behind the conduct gate.** The spec's step 1 lists them with the
eligibility, and its test list requires that a held run record zero `gh`
calls — the two cannot both be true, so the gate order is: local
eligibility, compose, flags, then the forge. A run the flags hold now
asks the forge nothing, and the `--confirm` rerun makes both reads before
it acts. Two additions the spec did not name: an unfetchable `origin`
exits 3 with the repository untouched (the eligibility below it would
otherwise be read against a stale base), and `--resume`'s carve-out is
"no branch on the forge" rather than "no upstream", because
`git switch -c <branch> origin/main` sets an upstream of its own and the
narrower test would have refused every real leftover.

Nine cases in `tests/unit/take_task/` cover the eligibility refusals,
both forge gates, the title grammar, slug defaulting, flag gating with
the forge untouched, the one-act ordering, and every exit-3 path. The
contract is in `technical/distribution.md`; `AGENTS.md`'s taking
paragraph names the script and keeps the by-hand form.
