---
id: spec-0069
task_ref: task-0050
status: draft
created: 2026-09-04T19:27:28Z
---

# spec-0069 — What one pull request may claim is bounded

**References:** [task-0050](../tasks/task-0050-bound-carried-claims.md)

- **Goal:** the carried set has a ceiling, one ceiling, in the one helper
  every reader of it already asks — so a title cannot move the queue by
  being long.

## Scope

In: `ql_carried_of` in `queue_lib.sh`, and what each of its five callers
does when a pull request claims more than the ceiling allows.

Out: whether a fork's pull request may reach the recording at all. That
is a question about authority, not about volume, and it is answered
below by name rather than smuggled in beside a bound.

Out: the edge table. Terminal states are already out of reach and stay
that way.

Out: `.writrun/settings.json`. The ceiling is a constant, and the
reasoning is below.

**The damage this bounds, stated at its real size.** The write is two
front-matter lines on a task file — `status:` and `taken_by:` — in a
commit by `github-actions[bot]` on the default branch. No code from the
pull request's tree executes: every job checks out the default branch
explicitly, which is why the `gate` job admits a fork's
`pull_request_target` in the first place. `done`, `blocked` and
`dropped` are unreachable because no edge leads to them. `taken_by` is
documented as a record that entitles nobody
([statuses](../../docs/product/stage-2-pull-requests/statuses.md)), and
every write is reversible by a commit. This is queue vandalism, not a
compromise, and a spec that dressed it as one would be arguing for a
defence nobody can size.

It is still worth bounding. The queue is what this project's people read
to decide what to work on, and a few dozen false `in-progress` lines make
that read worthless while they stand. The harm is to the queue's
usefulness, and the queue's usefulness is the whole product.

**The ceiling is eight, and the evidence is this repository's own.**
Two numbers were measured rather than felt:

- Across all 111 pull requests this repository has ever opened, 44 carry
  a `[TASK-NNNN]` tag and **not one carries two**. `take_task.sh`
  composes exactly one tag, and a second is added by hand — so the
  observed maximum claim is one.
- The largest batch of *related* tasks any single merge ever produced is
  **five** (#184, routing five findings to the queue). That is the
  biggest pile of work this project has ever assembled at once, and the
  nearest thing to an upper bound on what one pull request could
  honestly carry.

So the ceiling must sit above five, where the largest real batch fits
with room, and far below fifty, which is the queue. Eight is that
number. Five was rejected: a ceiling equal to the record has no headroom,
and it would be chosen from a sample whose maximum is its only data
point. Twenty was rejected: nothing measured reaches it, and twenty tags
are 220 characters of title before the summary starts — at that width the
title has stopped being a subject read at its left edge, which is the
one property [`0046`](../../docs/technical/decisions/pull-requests/0046-the-task-tag-leads.md)
put the tag there for.

**The count is of the carried set, after dedup — not of tags.** The set
is what becomes writes, so it is what the rule is about. A title
repeating `[TASK-0001]` fifty times carries one task and passes, which
is correct: it claims one task, verbosely. The cost is the other
direction and is named in Edge cases.

**Overflow refuses the whole set, and says so loudly.** Three answers
were weighed:

- *Record the first eight* — rejected, and this is the strongest
  rejection here. It is a half-applied event by design, and a
  half-applied event is the failure this machinery has already been
  fixed for twice: `apply_pr_event.sh` ends on a remembered exit code
  precisely so a partial write never rides a green run
  ([spec-0066](spec-0066-carried-tags-inflight.md)). It also reproduces
  the silence `titles.md` warns about — a nine-task pull request
  reporting eight, with nothing anywhere saying the ninth was dropped.
- *Refuse only the title's tags and keep the branch's own id* —
  rejected. It reads well, because the branch is one id and the title is
  the amplifier. But it hands the same silent partial write back in a
  smaller wrapper: eight of nine tasks go unrecorded and the run stays
  green.
- *Refuse the set, write nothing, exit non-zero* — chosen. The cost is
  real and is not hidden: a legitimate pull request that trips the
  ceiling gets nothing recorded, including the task its branch names,
  which is the same shape of damage
  [report-0023](../reports/report-0023-recording-lost-push.md) describes
  — a task left `ready` with its work in flight, and `ready` has no edge
  to `in-review`. What makes it survivable is that the run is **red**,
  on the author's own pull request, at the moment they typed the title.
  The lost recording heals in one click: closing and reopening fires
  `reopened`, which is `take`, and `take` is legal from `ready`. That
  heal path is part of what this spec ships — it goes in the refusal's
  own message, not only in this paragraph. One path bends the exit,
  never the refusal: the merge, whose event cannot re-fire and whose
  commit sits behind a success-gated step — the caller inventory below
  says how and why.

**The ceiling lives in the helper, so the question has one answer.**
`ql_carried_of` has five callers today: the in-flight half
(`apply_pr_event.sh`), the merge half (`record_task_status.sh`), the
mirror projection (`project_pr_tasks.sh`), the amendment check
(`check_amendment_reference.sh`) and the take
(`take_task.sh`). A bound in the first alone would make "how many tasks
does this pull request carry" a question with two answers, which is the
divergence [spec-0066](spec-0066-carried-tags-inflight.md) existed to
end. The last two ask the question about *another*, stranger pull
request, and they get the ceiling too — an unbounded title there is not
harmless either: one over-ceiling open pull request makes `take_task.sh`
refuse a take for every task it names, up to the twenty-three the
forge's 256-character title cap admits, each with "already in flight on
pull request #N". And a sixth asker is already in flight beside this
spec: [spec-0068](spec-0068-survivor-every-route.md) has
`apply_pr_event.sh`'s close arm put the question to every row of the
open listing while building its survivor index. That site asks about
other pull requests, so it takes the reader posture below — skip the
row, notice, never die — whichever of the two specs lands second wires
it.

**Refusal is not the same act in every caller, and that is deliberate.**
The in-flight and projection writers refuse and go red — the claim is
the pull request's own and the pull request's author is the person who
can fix it. The merge writer refuses the claim but not the event: it
still records what the diff range proves and exits 0 with the refusal
printed, because a merged close fires no second event and the approve
workflow commits behind a `Commit` step whose `if:` carries the
implicit `success()` — a red merge writer would skip that commit and
turn one refused claim into a queue and a spec left permanently
unrecorded, trading two front-matter lines of vandalism for the loss
this machinery exists to prevent. The green run's silence is paid for
with the printed refusal, and the ceiling still meets its author red on
the in-flight path, at the moment the title was typed. The readers skip the
over-ceiling row and print a notice naming its number: failing a
person's own take because of somebody else's title would let one
hostile title stop all work, which is a denial the ceiling is supposed
to prevent, not cause.

**It is a constant, not a setting, and the schema decides that.**
`schema.md` requires every key's documented default to be the behaviour
from before the key existed — and here that behaviour is unbounded,
which is the defect. A key whose only honest default reinstates the bug
is not a setting. Three more reasons stack behind it: a settings key
costs `check_settings.sh`, `read_setting.sh`, the schema table, the
session card and the settings README, for a number nobody has come
within a factor of eight of in 111 pull requests; "a setting controls, it
never merely describes", so an adopter writing `1000` would be switching
a safety property off, which is close to the one thing Adoption says the
file may never do; and the tag itself is already declared not settable in
`titles.md#pr_title_style`, so a settable bound on an unsettable tag is
two rules that disagree by construction. No environment override either:
a test that needs nine tags writes nine tags.

**And the defence that is *not* shipped here, named rather than
implied.** The `gate` job already computes
`github.event.pull_request.head.repo.full_name == github.repository` —
it knows a fork when it sees one, and refusing fork events on the
`record` job is one condition away. It is not folded in, for two reasons.
It answers a different question: a ceiling bounds *how much* a
participant may claim, origin bounds *who may participate*, and a fork
inside the ceiling is still a stranger writing `taken_by`. And it is a
change of adoption posture — many projects take every contribution
through forks, and cutting them out of the recording is a rule an adopter
must choose, not a bug fix. Two kinds of change in one change is what
`AGENTS.md` forbids. The ceiling is the half that is true regardless of
origin, so it is the half that ships first — and the origin half has no
report and no task yet. Said without softening: completing this spec
closes report-0028 while the exposure that report measured — a fork
author writing `taken_by` to `main` through the `record` job's
`contents: write`, now bounded at eight per pull request instead of a
hundred — stays open with nothing tracking it, until the origin
question is routed through a report of its own.

## Steps

1. Give `ql_carried_of` the ceiling: `QL_CARRIED_MAX=8`, a constant
   beside the helper, with the comment stating what it bounds and why it
   is not a setting. Count the deduplicated set, not the tags.
2. On overflow, print the sentinel `over-ceiling:<count>` alone on
   stdout and exit 0 — a token no task id can be, in the stream every
   caller already reads. A distinct non-zero code was weighed and
   rejected: every existing call site assigns the helper's output bare
   under `set -euo pipefail`, through `ql_carried_from_env`, and a
   non-zero substitution kills such a caller with no message at all — a
   contract whose default failure is a silent death, defended only by a
   header comment, designs the hazard in rather than away. A sentinel a
   forgetful caller misses is a non-id token visible in its output that
   matches no task file, never a vanished run.
3. Document the sentinel in `queue_lib.sh`'s header beside the helper:
   a caller tests for it with one `case` before touching the ids, and
   `ql_carried_from_env` passes it through untouched.
4. `apply_pr_event.sh`: meeting the sentinel, write nothing and exit
   non-zero, with a message naming the count, the ceiling, and the heal
   — close and reopen. Its header's exit-code contract gains that exit.
5. `record_task_status.sh`: meeting the sentinel, drop the **carried**
   ids and keep the range-derived scope, printing the refusal — and
   exit 0 once the range is recorded. The diff is the repository's own
   evidence and the title is the author's claim; a merge still records
   everything its own files say, and it must, because the `Commit` step
   behind it is gated on success and a merged close fires no second
   event — a red exit here would lose the range's writes with the
   claim's.
6. `project_pr_tasks.sh`: meeting the sentinel, project nothing and exit
   non-zero, with the same message shape. A relabelling pass over
   dozens of mirrors is the same claim wearing Stage 3's clothes.
7. `check_amendment_reference.sh` and `take_task.sh`: meeting the
   sentinel on another pull request's row, skip that row — dropped from
   the listing everywhere it feeds, never passed on as an empty carried
   set — print a notice naming its number, and carry on with the rest.
   Skipped, not emptied: an empty set is what routes an open pull
   request into `take_task.sh`'s amendment-candidate list and its
   files probe, so "carrying nothing" would hand a hostile title a
   paginated files read and a suspended take — the denial the ceiling
   exists to prevent.
8. `make template-sync` — `queue_lib.sh` and all four scripts are
   mirrored into `template/`.
9. Close the loop on the docs: the criterion in `statuses.md`, the tag
   paragraph in `titles.md`, and a dated decision with its chronology
   row.

## Acceptance criteria (EARS)

- When a pull request's head branch and title together name more than
  eight distinct tasks, the system shall refuse the carried set and
  shall write no status line on that set's authority — a write the
  merge's own diff range earns is the range's, not the set's, and is
  made per the merge criterion below.
- When the carried set is refused, the system shall report the number
  claimed and the ceiling; the in-flight and projection writers shall
  exit non-zero, and the merge writer shall exit 0 once the range is
  recorded, the refusal printed in its output.
- When the carried set is refused on an in-flight event, the system shall
  name in that message the act that re-fires the event — closing and
  reopening the pull request.
- When a pull request names eight or fewer distinct tasks, the system
  shall behave exactly as it does today, in every caller.
- When a title repeats one task's tag more times than the ceiling, the
  system shall carry that one task and shall not refuse the set.
- When a merge's carried set is refused, the system shall still record
  every task its own diff range puts in scope, the branch's own task
  among them where the range touches it.
- When a reader meets the sentinel on another, still-open pull request's
  row, the system shall skip that row, shall say which pull request it
  was, shall not fail the act it was asked to serve, and shall not
  route the skipped pull request into any list an empty carried set
  feeds.

## Edge cases

- **Eight tags on a task branch naming a ninth task.** Nine distinct
  tasks, refused — every tag legitimate, and the set is still over. This
  is the honest cost of counting the set rather than the tags, and the
  refusal message must show both sources so the author can see where the
  ninth came from.
- **A title whose tags are not leading.** `ql_carried_of` stops at the
  first non-tag, so `[TASK-0001] hi [TASK-0002]` carries one. The ceiling
  never sees the trailing tags, and nothing changes here.
- **A title long enough to be truncated by the forge.** A title is capped
  at 256 characters, so at most about twenty-three tags can ever be
  parsed. The parse loop is already bounded by the input; no second bound
  on tag count is needed, and adding one would be a rule with no
  reachable case.
- **The refused pull request is the one holding a task in flight.** The
  take's reader skips its row, so that task reads as free and a second
  worker may take it. Accepted: the set is over a ceiling no real title
  has approached, and that pull request is already red on its own check.
- **`PR_TITLE` absent or empty.** The branch's id alone is one task, well
  under the ceiling; the degraded path is untouched.
- **An adopter mid-migration**, on a copy of these scripts from before
  the ceiling. Nothing here is a queue-file schema change, so an old
  script and a new one disagree only about refusal, never about what a
  file means.

## Tests required

- A `queue_lib` unit case per side of the boundary: eight distinct tasks
  carried and printed; nine answered with the sentinel alone on stdout
  and exit 0.
- A unit case where one tag repeats twenty times: one task carried,
  exit 0.
- An `apply_pr_event` integration case with a nine-task title: nothing
  written to any task file, non-zero exit, and the message naming the
  count, the ceiling and the reopen.
- A `record_task_status` integration case with a nine-task title over a
  range that touches the file of one of the nine: that task is recorded
  on the range's evidence, the other eight are not, the refusal is
  printed, and the exit is 0 — the overlap of claim and range is the
  common case, and this is where its answer is pinned.
- A `project_pr_tasks` integration case with a nine-task title: no forge
  call is made.
- A `take_task` unit case where an unrelated open pull request claims
  nine tasks and touches a spec file: the take proceeds, the notice
  names that pull request, and no files probe is made for it — the
  skipped row reaches neither the in-flight refusal nor the
  amendment-candidate list.
- Every existing case in the five callers must pass unchanged. This adds
  a refusal above eight; it changes nothing at or below it.

## Definition of Done

- [ ] `ql_carried_of` counts the set and answers above eight with the
      sentinel the header documents.
- [ ] The in-flight and projection writers refuse loudly; the merge
      writer records the range and prints the refusal; the readers skip
      the row, notice, and carry on.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] `statuses.md`'s criteria carry the bound, `titles.md` states it is
      not settable, and the decision is dated and indexed.
- [ ] The sequence in
      [report-0028](../reports/report-0028-fork-title-claims.md),
      replayed at the largest size the forge's 256-character title cap
      accepts — a title tagging every task it has room to name — moves
      nothing, and says why.

## Proposed product changes

- `product/stage-2-pull-requests/statuses.md#criteria` — the criteria
  already say the event's write reaches every task carried. They gain the
  bound on that set, and what a refused set does. This chapter owns the
  carried-set rule; a new chapter for the ceiling would be a second home
  for one rule.

## Proposed technical changes

- `technical/settings/titles.md#pr_title_style` — the paragraph stating
  that the tag is how the machinery learns which tasks a pull request
  carries gains the ceiling, and states it is not settable, beside the
  tag it already declares unsettable. This is `task-0050`'s `doc_ref`.
- `technical/decisions/pull-requests/` — a new dated entry: what a pull
  request may claim is bounded by a constant, the evidence the number
  came from, and the two rejected alternatives — a partial record, and
  refusing forks by origin.
- `technical/decisions/README.md` — that entry's row in the chronology.

## Outcome

_(fill after execution)_
