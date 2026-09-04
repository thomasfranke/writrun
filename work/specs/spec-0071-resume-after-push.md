---
id: spec-0071
task_ref: task-0052
status: draft
created: 2026-09-04T19:27:30Z
---

# spec-0071 — The take recovers the half it can leave behind

**References:** [task-0052](../tasks/task-0052-resume-after-push.md) · [report-0026](../reports/report-0026-resume-hint-unreachable.md)

- **Goal:** the one state this act must not leave behind — a branch on
  the forge with no pull request — has a recovery that runs from the
  checkout that pushed it, and it is the line the failure prints.

## Scope

In: what `--resume` refuses and what it finishes, and the sentences the
act prints after the branch is cut.

Out: the fresh path's two branch-exists refusals. A branch that exists
with no `--resume` is work already begun, and taking it again is what
those refusals are for. Neither moves.

Out: a branch that reached the forge from a checkout this one is not.
`--resume` keeps its local-branch requirement, and recovering a branch
this clone never had would mean fetching someone else's ref and checking
it out — adopting a branch, not finishing a take.

Out: the shape of the two forge reads and the amendment suspension they
feed. This spec changes who consults the answer, not the question asked.

**The reason to defer has lapsed, and that is why this exists.**
[spec-0064](spec-0064-take-first-commit.md)'s Scope put this guard out by
name: widening it while the fresh path was still failing would have
papered over the cause. The cause was a branch with no commits for the
forge to open a pull request against, and spec-0064 removed it. What
survives is every other reason `gh pr create` can fail — a rate limit, a
dropped connection, branch protection — and for those the take still
lands in the state it declares unacceptable, still prints a `--resume`
line, and that line is still refused by `--resume`'s own guard, because
`git push -u` created the very `refs/remotes/origin/<branch>` the guard
reads.

**The guard stops asking where the branch got to.** Three approaches
were weighed:

- *Widen the refusal to "on the forge **and** carrying a pull request"
  with a read of its own* — rejected. Eight lines further down the
  script already asks the forge which pull requests are open and which
  tasks they carry. A second reader of one question agrees with the
  first until one of them is edited, which is the argument
  [spec-0066](spec-0066-carried-tags-inflight.md) made for one helper
  over a second parser.
- *Keep the remote-ref guard, excused where this run did the push* —
  rejected. The recovery has to work in the session after the failure,
  and a run cannot remember another run's push. The remote-tracking ref
  is a local cache besides: it says this checkout once pushed, not that
  the forge holds it now.
- *Drop the location question and let the pull request answer* —
  chosen. The push is idempotent, so how far the interrupted take got
  does not change what finishing it costs. What makes a resume wrong is
  a pull request that already exists, and that is the question the forge
  read answers already — the same question
  `technical/selection/visibility.md` gives step 0 when it decides that
  a flight state with no open pull request is stale and the task is
  resumable.

So `--resume` stops meaning "finish a branch that never reached the
forge" and starts meaning **finish a take that has no pull request**,
wherever it stopped.

**An unanswered read is not "no pull request".** Where the resume's only
guard is the forge's answer, a read that failed leaves the run unable to
tell the state it recovers from the state it refuses, and opening a
second pull request over a branch that has one is the failure this whole
act exists to avoid. The resume stops there. The fresh path is left as
it is: its own local guards still stand without that answer, and
narrowing it is a different question about a different guard.

## Steps

1. In `take_task.sh`'s `--resume` arm, delete the refusal that names a
   branch already on the forge. The arm keeps its local-branch
   requirement and nothing else.
2. Let the forge read stand where that refusal stood. The loop over open
   pull requests already refuses a task in flight on both paths, naming
   the pull request and its author — no second refusal is written; the
   resume simply now reaches it.
3. One question the fresh path never asks: whether a pull request, open
   or closed, ever carried this branch — `gh pr list --head`, all
   states, one read spent only on a resume. The open ones step 2
   already answers; a closed one means the flight ended, and finishing
   the branch now would open a second pull request over a base as old
   as the interruption — the second take the deleted refusal used to
   block by accident. The resume refuses, naming the closed pull
   request and the fresh take that follows it; the branch on the forge
   is that flight's leftover, deleted by hand or left to lie. An
   unanswered read here stops the run exactly as step 4 stops the
   unanswered open list.
4. Where `--resume` was given and the read produced no answer (`gh` was
   not asked or answered nothing, `pr_source` is `none`), stop before
   the cut: exit 3, name that the one question a resume turns on went
   unanswered, and print the resume line, which runs once the forge is
   reachable. An unanswered read on the fresh path stays as it is.
5. Leave the push in the resumed act. Over a remote branch at the same
   commit it is a no-op; over a local branch that moved ahead it is the
   fast-forward the pull request should open over; and a divergence it
   refuses is a real one, which stays an exit 3 rather than a force
   push this act never makes.
6. Stop the sentences printed after the cut from claiming a location the
   run has not established — and no helper re-reads the remote-tracking
   ref to establish one, the record this spec has already ruled a cache:
   it says this checkout once pushed, not that the forge holds the
   branch now. Each site states what its own position proves. The range
   guard and the commit failure sit before any push and keep saying
   "kept local"; the push failure names what the refusal proves — a
   non-fast-forward means the forge holds the branch, a connection that
   dropped means only that this push did not complete; and the
   `gh pr create` arm's own sentence, after a push that succeeded, is
   already true and keeps its wording.
7. Correct the exit-3 line in the script's header comment: after the cut
   the branch is named wherever it got to, and `--resume` finishes the
   act.
8. `make template-sync` — `.writrun/` is mirrored into `template/`.
9. Update `technical/distribution/take-task.md`: the forge-failure
   sentence, and the paragraph that defines the carve-out by the
   branch's location.

## Acceptance criteria (EARS)

- When `--resume` is given for a task no open pull request carries, the
  system shall finish the act whether or not the branch already reached
  the forge.
- When `--resume` is given and an open pull request carries the task,
  the system shall refuse, naming that pull request and its author.
- When `--resume` is given and the only pull requests that ever carried
  the branch are closed, the system shall refuse, naming the closed
  pull request — an ended flight is finished by a fresh take, never
  resumed.
- When `--resume` is given and the forge did not answer which pull
  requests are open, the system shall exit 3 without pushing or opening,
  naming the unanswered read.
- When a resumed act pushes a branch the forge already holds at the same
  commit, the system shall treat the push as done and open the draft.
- When `gh pr create` fails after a successful push, the system shall
  print a `--resume` line that, run as printed, opens the draft.
- When the act fails after the cut, the system shall claim only a
  location its own evidence proves, and shall never describe a pushed
  branch as kept local.

## Edge cases

- **The draft was opened and the client did not hear it.** A
  `gh pr create` that timed out after the forge acted leaves a pull
  request nobody saw. The resume's read finds it and refuses "already in
  flight", which is correct — the act completed, and the failure was in
  the reporting.
- **The status line moved first.** Where the draft did open, the
  machinery writes `in-progress` — to `main`, which an interrupted
  checkout's working tree does not carry: its own task file still says
  `ready`, so the eligibility re-check passes and does not catch this.
  What refuses the rerun is the open-pull-request read, "already in
  flight" — the forge read is the guard on this path, not the
  eligibility gate.
- **The local branch diverged from its remote.** Someone pushed to the
  branch in between. The push refuses, the run exits 3, and the message
  names the branch as on the forge — the divergence is real and
  finishing it blind would need a force push.
- **A pull request carrying the task on another branch.** Refused today
  on the fresh path and now on the resumed one too, by the same read and
  the same sentence: resuming is not taking someone else's flight.
- **The branch is on the forge and this checkout does not have it.**
  Still refused on "does not exist locally", per the Scope above.
- **The checkout that pushed is gone.** A discarded worktree or a dead
  disk pushed the branch and never opened the draft. No surviving clone
  can resume it (the local-branch requirement, above) and the fresh
  take still refuses the branch on the forge — the residue the
  local-branch requirement costs, named plainly: the exit is
  `git push origin --delete <branch>` by hand, then a fresh take.
  Widening `--resume` into adopting another checkout's branch is a
  different act, left to a report of its own if practice ever produces
  this.
- **The branch's pull request closed without merging.** The task landed
  back at `ready` when it closed. A resume run later — the printed line
  found in scrollback — meets step 3's read and is refused on the
  closed pull request; without that read it would have pushed a branch
  cut from a base as old as the closed flight and opened a second draft
  over it.
- **A conduct flag is `false`.** A resume without `--confirm` walks back
  into the gate and exits 2 having done nothing;
  `resume_command()` already carries `--confirm` through, and that is
  unchanged.
- **A resume of a branch that never reached the forge.** The case the
  suite covers today. It now costs the forge read that the remote-ref
  check used to spare it — a read this run was making anyway, three
  lines later.

## Tests required

- `the_resume_hint_finishes_the_act_test.sh` gains the sequence
  report-0026 recorded: the push succeeds, `gh pr create` fails, and the
  printed line — run as printed, as that file already runs it — opens
  the draft and exits 0. The fixture cannot express this yet: the stub's
  `unavailable` file fails every `gh` call, `gh auth status` included, so
  the resume would fail too. It needs a seam that refuses one
  subcommand.
- `a_branch_that_exists_is_not_a_take_test.sh` changes premise, and its
  header comment states the old one — the carve-out is a local branch
  "with no upstream and no pull request". It becomes a branch with no
  pull request. The file gains a resume over a pushed branch no pull
  request carries: exit 0, the draft opened, no second branch and no
  second commit; and a resume over a pushed branch an open pull request
  does carry: refused, naming that pull request. Its four existing
  cases — the local refusal, the forge-only refusal on the fresh path,
  the resume that finishes, and the resume with nothing to finish —
  stay as written, the last one because the local-branch requirement is
  a rule Scope keeps; note that the refusal being removed is asserted
  nowhere today, so what this file loses is a premise, not a case. It
  also gains a resume over a branch whose only pull request is closed:
  refused, naming the closed pull request, nothing pushed and nothing
  opened.
- `a_forge_failure_names_what_is_left_test.sh` gains a failure after the
  push: the message names the branch as on the forge without a pull
  request, and does not say "kept local". Its existing cases assert
  "kept local" over branches that genuinely never reached the forge and
  must stay green.
- A case over the unanswered read: `gh auth status` passes, the open
  pull request list fails, `--resume` exits 3 naming it, nothing is
  pushed and no pull request is opened. Same fixture seam as the first
  case.
- The resume cases in `the_first_commit_opens_the_draft_test.sh` must
  pass unchanged. None of them pushed before resuming, and the commit
  guard is the range and not the location.

## Definition of Done

- [ ] `--resume` finishes a branch already on the forge that no open
      pull request carries.
- [ ] `--resume` refuses on an open pull request that carries the task,
      refuses on a closed one that carried the branch, and stops where
      the forge did not answer.
- [ ] No message names a pushed branch as kept local.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] `take-task.md` states the carve-out as it is.
- [ ] The sequence in
      [report-0026](../reports/report-0026-resume-hint-unreachable.md) —
      the push succeeds, `gh pr create` fails, the printed line is run
      verbatim — ends with the draft open.

## Proposed product changes

- none — the rule already stands.
  `product/stage-2-pull-requests/taking.md#criteria` requires a task's
  pull request to be open as a draft before the work starts, and
  `technical/selection/visibility.md` already names a branch pushed
  without one as the hiding place that closes. A recovery that runs is
  those rules kept after a forge failure, not a new rule; restating
  either beside the script is the second copy that disagrees later.

## Proposed technical changes

- `technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command`
  — two claims in that section are false after the push and are
  corrected here: that a forge failure after the cut names "the branch
  kept local", and that the carve-out is narrow because "a local branch
  that never reached the forge is the leftover of an interrupted take".
  The carve-out is stated by what it turns on instead — a take with no
  pull request — together with what the resume does when the forge
  cannot say.

## Outcome

_(fill after execution)_
