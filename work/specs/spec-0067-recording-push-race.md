---
id: spec-0067
task_ref: task-0048
status: implemented
created: 2026-09-04T19:27:26Z
---

# spec-0067 — The recording survives a concurrent one

**References:** [task-0048](../tasks/task-0048-recording-push-race.md)

- **Goal:** a recording that loses the push to a concurrent one lands
  anyway, and a recording that cannot land at all ends a red step rather
  than a green one that wrote nothing.

## Scope

In: how a queue recording reaches the authority branch — the rebase and
the push both recording workflows make once their commit is composed.

- `writrun-progress.yml`'s `record` job, the step
  [report-0023](../reports/report-0023-recording-lost-push.md) watched
  fail.
- `writrun-approve.yml`'s `Commit` step. Same two commands, same window,
  and the more exposed of the two: a merge fires no second
  `pull_request_target` event, so a lost merge recording has not even the
  later event that hid the loss here.
- The shared piece becomes one script. The `record` job's own header
  states the rule — every step's logic lives in `.writrun/scripts/`,
  where the integration tier executes it, and YAML wires events onto
  scripts — and a budget, a retry test and an abort are logic. Two workflows
  carrying the same loop are two loops that agree until one is edited.

Out: `intake_report.sh`, which already loops and is already bounded at
three. Its retry is not a replay: each attempt re-checks whether the
commit that won the race claimed the id it minted, and re-mints when it
did — the content may change between attempts, and a helper that only
pushes a fixed commit again has no place for that check.

Out: `.github/scripts/readiness_heal.sh`, which pushes to `main` with the
same pattern. It is this repository's own CI, never shipped, and its loss
repairs itself — the next push to `main` runs readiness again,
regenerates, and commits the same sync. A recording has no next run, and
that asymmetry is the whole reason one needs the retry and the other does
not.

Out: re-deriving the write on a retry. What is replayed is the commit
composed once, and where the rebase replays it cleanly the write is the
same write. Where it does not — two events touching one task's status
line — the rebase conflicts and the step fails loudly, which is a
different outcome from the silent loss and is not the outcome this spec
undoes. Re-running `apply_pr_event.sh` against the state that landed
changes *what* is written, where this changes only *whether it lands*.

Out: `flip_task_status.sh`'s edge table. From `ready` there is genuinely
no edge to `in-review`, and "the next event succeeds writing nothing" is
that table behaving correctly over a queue left wrong by something else.
Widening it to heal a lost write would let the machine march a task
forward from a state it should not be in, which is what the table exists
to refuse.

Out: the `reflect` job's gate, which stays `!cancelled()`. A projection
that follows a failed recording is not the defect — see Edge cases.

**Why the push is retried rather than the runs serialized.** Three
answers were weighed:

- *A concurrency group on the `record` job* — rejected, on a fact this
  repository has already written down. `writrun-intake.yml`'s group is
  per issue for this exact reason: the forge "queues one pending run per
  group and cancels the rest, it does not serialize them". A shared group
  over the recording would let a third event cancel the second's pending
  run, and a cancelled recording is the same lost write wearing a green
  tick instead of a red one.
- *`--force-with-lease`* — rejected. It is the flag that fails when the
  ref moved under you, which is the failure being fixed; it would report
  the race more precisely and land nothing. Plain `--force` is worse than
  the defect: it discards the sibling recording that beat us, and the
  step's own comment already refuses it — an addition to the branch's
  history, never a replacement of it.
- *Rebase again and push again, bounded* — chosen. The loss is a push
  refused because `main` moved under a rebase that predates it, so the
  answer is to read `main` again and push again. The comment's intent is
  unchanged; what it gains is a second reading of a branch that does not
  stop changing while three runs are writing to it.

**The budget is five attempts, sized by the largest burst practice has
produced.** The incident was three runs; the biggest batch this
repository has assembled is five — the five drafts a five-task batch
opens seconds apart, the pile #184 routed at once. The worst-placed of
five runs can lose four races before its turn, so five attempts survive
that burst even when every sibling wins its turn. `intake_report.sh`
keeps its own bound of three, and the two numbers are not a fork of one
answer: an attempt here is spent only on proof a sibling landed, where
intake's attempts are unconditional. The budget belongs to the run
rather than to each obstacle — one fetch and one push per attempt, five
of each at worst.

**The retry neither waits nor reads stderr.** A retry is earned by the
branch having moved: the fetch that opens the next attempt shows whether
the tip left the commit the refused push was rebased onto, and an
unmoved tip means the refusal was never a race. That is the one
version-proof fact — git and the forge word a protected branch, a
revoked token and a required check differently across versions, and
parsing the words misreads one of them eventually. And no attempt
sleeps: every retry spent is a sibling's recording landing, so the loop
only loses while the queue advances, and a wait knob here would be a
second wait grammar beside `WRITRUN_MIRROR_REFRESH_WAIT` with no
measurement to size it.

## Steps

1. Add `.writrun/scripts/stage-2-pull-requests/push_recording.sh
   <branch>`: it takes a repository already carrying the recording commit
   and lands it. The caller composes and commits; this script only makes
   the commit reach the branch. Refuse a dirty working tree and refuse a
   `HEAD` with nothing ahead of the remote-tracking ref the checkout
   already carries — a caller that has not committed must hear so, not
   watch a no-op report success, and the guard fetches nothing: the
   loop's own first pull is the one fetch an attempt pays. A
   range git cannot answer is a refusal too, the posture `take_task.sh`
   already takes.
2. The loop: five attempts. Each opens with
   `git pull --rebase origin "$BRANCH"`, so every attempt is rebased onto
   the branch as it then stands, and closes with
   `git push origin "HEAD:${BRANCH}"`. No `--force` and no
   `--force-with-lease`, on any attempt.
3. A retry is earned, never assumed: a refused push buys the next attempt
   only when that attempt's fetch shows the branch moved past the commit
   the refusal was rebased onto. Unmoved, the run fails at once naming
   the branch as unmoved, spending none of the remaining attempts — the
   refusal was no race, and no stderr is read to say so.
4. A conflicting rebase aborts back to the recording commit and fails at
   once, spending none of the remaining attempts: the same commit meets
   the same conflict, and the tree must not be left carrying markers in
   the queue files the projection reads from disk.
   `writrun-approve.yml` carries this abort inline today and
   `writrun-progress.yml` carries none — the helper gives both.
5. Exhaust the budget and exit non-zero, naming the branch, the attempts
   spent, and the recovery: re-running the job re-derives the same write
   from the same event against `main` as it then stands.
6. Point both `Commit` steps at it, in place of their
   `git pull --rebase` / `git push` pair; approve's inline abort block
   goes with them.
7. `make template-sync` — `.writrun/` and both workflows are mirrored.
8. Give `product/stage-2-pull-requests/statuses.md#criteria` the
   criterion that separates a write the machinery had no reason to make
   from one it could not make.

## Acceptance criteria (EARS)

- When the recording's push is refused because the authority branch
  moved, the system shall rebase onto that branch as it then stands and
  push again, to a bound of five attempts in one run.
- When a push is refused and the branch has not moved past the commit
  the refusal was rebased onto, the system shall fail at once naming the
  branch as unmoved, and shall spend none of the remaining attempts.
- When the first attempt succeeds, the system shall have fetched once
  and pushed once.
- When a rebase leaves conflicts, the system shall abort back to the
  recording commit, exit non-zero, and spend none of the remaining
  attempts.
- When every attempt is refused, the system shall exit non-zero naming
  the branch and the attempts spent, and shall never exit 0 having
  written nothing.
- When a rebase finds the recording already on the authority branch and
  drops it, the system shall exit 0 — the write is where it belongs.
- When the caller leaves the working tree dirty, or has committed nothing
  to land, the system shall refuse before it touches the remote.
- When a recording cannot be landed at all, the machinery shall report
  the failure rather than leave the queue silently unwritten.

## Edge cases

- **A push refused for a reason that is not a race** — a protected
  branch, a revoked token, a required check on `main`. None of these
  moves the branch, so the next attempt's fetch finds the tip where the
  refusal left it and the run fails after one push and one extra fetch.
  A permanent refusal that happens to overlap a sibling's landing spends
  the budget and ends in the exhausted-budget message instead — either
  way the log separates the two by eye, unmoved against attempts spent.
- **A rebase that conflicts.** Two events touching one task's status line
  — an `opened` and a `ready_for_review` seconds apart. The step fails,
  loudly, over a clean tree and an unaltered recording commit. That is
  strictly better than today and it is not resolved here: resolving it is
  re-deriving the write, which Scope puts out — and which nothing yet
  tracks. Report-0023's only task is this spec's own, so the class "a
  queue left wrong until a person reads a red run" stays open past this
  spec, named here rather than implied closed; closing it needs a report
  of its own.
- **Two runs that both lost to a third retry in lockstep.** One wins;
  the other loses again — to the winner, whose landing is the branch
  moving, which earns the next attempt. Lockstep spends attempts one
  landed sibling at a time, and the budget is sized to the siblings a
  batch can produce, so no wait is needed to break it.
- **The `reflect` job runs after a failed recording.** It is gated on
  `!cancelled()`, so the projection still runs and reads the file the
  recording could not change. The mirror stays faithful to the queue,
  which is the mirror's entire contract — report-0023 observed exactly
  this and called it faithful. Making the mirror skip would leave it on a
  state older still. The red step is what says the queue is wrong.
- **Nothing moved.** `writrun-progress.yml` leaves the step before it
  commits and `writrun-approve.yml`'s step is gated by its `if:`, so
  neither legitimate no-op reaches the helper. The helper's own refusal
  is there for a caller wired wrong, which is the failure
  `distribution/checks.md` says looks ordinary.
- **A re-run of a job whose recording did land.** The write is
  re-derived, committed, and dropped by the rebase as already applied.
  Exit 0, and `main` carries it once.

## Tests required

- An integration fixture beside the intake's — a bare `origin`, a clone
  shaped like the workflow's checkout, and a racer clone that lands
  commits on `origin`. `tests/intake_lib.sh` already builds the first
  two; the racer clone lives inline in
  `a_landed_sibling_forces_a_remint_test.sh` today, and it is hoisted
  into the lib rather than copied out of a test a second time.
- The window is made deterministic by a `pre-push` hook in the clone,
  never by timing: the hook lands the racer's commit on `origin` and lets
  the push proceed, so the push meets a branch that moved *after* the
  rebase — the refusal report-0023 recorded, reproduced without a sleep
  and without a flake.
- A case with no hook: one push, one fetch, the recording on
  `origin/main`.
- A case whose hook fires once: two pushes, the recording on
  `origin/main`, and the racer's commit still there — the rebase added,
  it did not replace.
- A case whose hook fires every time: exactly five pushes, exit
  non-zero, and the message naming the branch and the attempts spent.
- A case whose `origin` refuses the push with the branch unmoved — a
  `pre-receive` hook that exits non-zero and lands nothing: one push,
  immediate non-zero exit, and the message naming the branch as unmoved.
- A case where the racer writes the same lines: exit non-zero, one push
  at most, `git status --porcelain` empty and `HEAD` still the recording
  commit.
- A case where the racer lands the recording's own patch: exit 0, and the
  branch carries it once.
- The two refusals: a dirty tree, and a `HEAD` with nothing to land.
- The existing `apply_pr_event` and merge-recording cases must pass
  unchanged. This changes how a commit is landed, never what is in it.

**What no case here proves, said plainly.** None of this reproduces two
GitHub runners interleaving. A suite cannot schedule them, and one that
tried — a background push, a sleep, a race won by luck — would be a
flaky test proving less than the hook does. What the fixture proves is
the script's behaviour against a remote that moves under it, which is the
whole of what the script decides. The interleaving itself is left to the
last line of the Definition of Done, on this repository, with real runs.

**And the two call sites are wiring the suite does not execute.**
`distribution/checks.md` already says what that costs: a miswired
workflow looks ordinary. The mirror test holds `template/` byte-identical
to the root and nothing more, so the call sites are read by eye at review
and confirmed afterwards by the same last line.

## Definition of Done

- [ ] Both recording workflows land their commit through
      `push_recording.sh`, and neither carries a rebase or a push of its
      own.
- [ ] A push refused because the branch moved is rebased and retried, to
      a bound of five; one refused with the branch unmoved fails at once.
- [ ] A conflicting rebase aborts, fails, and leaves a clean tree.
- [ ] An exhausted budget exits non-zero and names the branch and the
      attempts spent.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] `statuses.md`'s criteria separate a write the machinery had no
      reason to make from one it could not make.
- [ ] The sequence in
      [report-0023](../reports/report-0023-recording-lost-push.md) —
      three drafts opened seconds apart, three runs inside five seconds —
      moves all three tasks, and no run ends red.

## Proposed product changes

- `product/stage-2-pull-requests/statuses.md#criteria` — the criteria say
  what the machinery shall write, and say in one line when it shall write
  nothing; they say nothing about what happens when it cannot write at
  all. That silence is what report-0023 cost: a step that lost its push
  and a step that correctly found no legal transition were the same green
  run, and the queue and its mirror went on agreeing on the wrong answer
  until a person read the run log. They gain the criterion — a recording the
  machinery cannot land is reported, never left silent. Loop closure and
  not a new rule: "the machinery shall write it after that event" already
  obliges the write, and this states what the obligation looks like when
  it fails.

## Proposed technical changes

- none — and the reasoning is `intake.md`'s own. No technical chapter
  describes how a queue recording reaches the authority branch; the
  pattern is documented where it runs, in the script headers and the
  workflow comments, and `push_recording.sh`'s header is where this
  one's budget, retry test and abort belong. `technical/reporting/intake.md`
  and `technical/distribution/kit.md` each name "the rebase-not-force
  pattern the queue recording uses", and both stay true — the pattern is
  unchanged, only the number of times it is attempted.
  `technical/distribution/checks.md` holds the rules that belong to a
  *caller* of a script, which is why step 1 makes this script refuse a
  caller that has not committed rather than print an ordinary line: a
  hazard designed away needs no chapter, and a chapter promised for one
  is a promise the implementation would have to invent work to keep.

## Outcome

Built as specified. `.writrun/scripts/stage-2-pull-requests/push_recording.sh`
takes the branch, refuses a dirty tree and a `HEAD` with nothing ahead of
the remote-tracking ref the checkout already carries — both before the
remote is touched, and the range git cannot answer is a refusal too —
then runs five attempts, each opening with
`git pull --rebase origin "$BRANCH"` and closing with
`git push origin "HEAD:$BRANCH"`. No `--force`, no `--force-with-lease`,
no sleep, no stderr read. The retry test is the branch's movement: the
tip the attempt's own fetch reports, compared against the tip the refused
push was rebased onto. Unmoved, it fails at once naming the branch;
conflicting, it aborts back to the recording commit and fails; exhausted,
it exits non-zero naming the branch and the attempts spent. Both `Commit`
steps call it in place of their rebase-and-push pair, and
`writrun-approve.yml`'s inline abort block went with them.
`statuses.md#criteria` gained the one criterion, and nothing else under
`docs/` changed.

Divergences:

- **A git failure is three things, not two.** Scope reasons about a
  push the remote refused and a rebase that conflicted, and the loop as
  first written read every failure as one of those two. A failure that
  never reached the remote is neither, and reading it as either is what
  loses the recording: a pull that could not read the branch was
  reported as a conflict — the verdict that spends no attempts — and a
  push that never completed left the tip where it was, which the
  movement test reads as a ruleset. The script separates the three. A
  rebase in progress after a failed pull is the conflict, its absence an
  unread branch. A push exits 1 when the remote answered about the refs
  and dies with something else when it did not, and a push that never
  arrived does not arm the movement test at all. The acceptance criteria
  stand as written — "refused" is the remote answering — and still no
  stderr is read: the exit status is a status, not wording.
- **The abort is checked rather than assumed.** An abort that failed
  over a tree still carrying markers must not be reported as a restored
  tree, because the mirror steps that follow a failed recording parse
  those files from disk. The abort's own status and `git status
  --porcelain` after it both have to agree before the run says the
  recording commit is back.
- **A missing `<branch>` exits 3**, not the 1 `${1:?}` gives. It is a
  caller error like the two beside it, and 1 is the code that means the
  recording could not be landed.
- **The racer hoist brought company.** The spec asked for the racer
  clone to move into `tests/intake_lib.sh`; it went as `setup_racer` and
  `racer_lands`, and three more helpers went with it —
  `arm_racer_hook` (the `pre-push` window the spec names, parameterised
  by how many pushes it fires before), `recording_commit` (the caller's
  half, composed the same way in six cases), and `spy_git` / `spied` /
  `git_told_times`. The last is what the spec's own cases require and
  the lib had no way to answer: "one push, one fetch", "exactly five
  pushes" are counts of what a run costs the remote. The spy is a `PATH`
  shim logging each `git` line client-side, because a refused push and a
  landed one cost the same call and no server hook sees a fetch at all.
  `a_landed_sibling_forces_a_remint_test.sh` now calls the hoisted pair
  and passes unchanged in what it asserts.
- **The fetch a case counts is the pull.** The no-hook case asserts one
  `pull` and zero `fetch`, rather than one `fetch`: the attempt's fetch
  *is* `git pull --rebase`, and the zero is the assertion that the
  caller-side guard adds no fetch of its own.
- **The exhausted-budget case reads one run twice.** Its two message
  assertions are about a single spent budget; invoking the script a
  second time would spend a second one and make the five-push count
  prove nothing, so the run's output is captured once and replayed.
- **One existing case had to follow the wiring.** Tests required says
  the merge-recording cases pass unchanged, and in what they assert they
  do. But `merged_close/one_workflow_answers_it_test.sh` locates the
  push by grepping `writrun-approve.yml` for the literal
  `git push origin "HEAD:${BASE_REF}"`, to prove the queue is pushed
  before the mirror is minted and labelled. Step 6 removes that literal,
  so the case now finds the landing call by its path — the claim about
  the order is untouched, and only the line that spells the push moved.
  It is the one case in the suite that reads the wiring rather than
  running it, which is why it is also the one the change reached.
- **The fixture can make a git call fail.** Tests required names the
  hook that moves the branch; it has no way to produce a remote that was
  never reached, and the three-state taxonomy above is not testable
  without one. `remote_unreachable_for` and `git_noops_for` are
  injections in the spy shim — one shim rather than two, because two
  `PATH` shims would have to agree on which delegates to the other — and
  they carry git's own exit status for the class, since the status is
  what the script reads.
- **The hook the window rests on is pinned to `.git/hooks`.** A global
  `core.hooksPath` — husky, pre-commit, a corporate gitconfig on a dev
  machine or a runner image — is inherited by the clone and disables the
  `pre-push` hook silently. The race then never happens, and two cases
  go red naming `push_recording.sh` for a fault in the fixture.

The last line of the Definition of Done is unticked by construction: it
is the burst on this repository with real runs, which no suite can
schedule — the limit the Tests required section already states.
