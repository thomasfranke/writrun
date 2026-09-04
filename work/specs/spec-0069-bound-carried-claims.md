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
to decide what to work on, and a hundred false `in-progress` lines make
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
  own message, not only in this paragraph.

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
harmless either: a hundred-tag open pull request makes `take_task.sh`
refuse a hundred takes with "already in flight on pull request #N".

**Refusal is not the same act in all five, and that is deliberate.**
The three writers refuse and go red — the claim is the pull request's
own and the pull request's author is the person who can fix it. The two
readers treat an over-ceiling stranger as carrying nothing identifiable
and print a notice naming its number: failing a person's own take
because of somebody else's title would let one hostile title stop all
work, which is a denial the ceiling is supposed to prevent, not cause.

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
origin, so it is the half that ships first; the origin question belongs
to its own report and its own task.

## Steps

1. Give `ql_carried_of` the ceiling: `QL_CARRIED_MAX=8`, a constant
   beside the helper, with the comment stating what it bounds and why it
   is not a setting. Count the deduplicated set, not the tags.
2. On overflow, print nothing on stdout and return a distinct non-zero
   code, so a caller can tell "claims too much" from "carries nothing".
   The two are opposite conditions and today they would look identical.
3. Document the code in `queue_lib.sh`'s header beside the helper, and
   note that every caller assigning under `set -e` must capture it
   (`carried=$(ql_carried_of …) || rc=$?`) — the bare assignment would
   kill the caller with no message at all.
4. `apply_pr_event.sh`: on overflow write nothing and exit non-zero,
   with a message naming the count, the ceiling, and the heal — close and
   reopen. Its header's exit-code contract gains that code.
5. `record_task_status.sh`: on overflow drop the **carried** ids and keep
   the range-derived scope, printing the refusal. The diff is the
   repository's own evidence and the title is the author's claim; a merge
   still records everything its own files say.
6. `project_pr_tasks.sh`: on overflow project nothing and exit non-zero,
   with the same message shape. A relabelling pass over a hundred mirrors
   is the same claim wearing Stage 3's clothes.
7. `check_amendment_reference.sh` and `take_task.sh`: on overflow treat
   that pull request as carrying nothing identifiable, print a notice
   naming its number, and carry on with the rest of the listing.
8. `make template-sync` — `queue_lib.sh` and all four scripts are
   mirrored into `template/`.
9. Close the loop on the docs: the criterion in `statuses.md`, the tag
   paragraph in `titles.md`, and a dated decision with its chronology
   row.

## Acceptance criteria (EARS)

- When a pull request's head branch and title together name more than
  eight distinct tasks, the system shall treat the carried set as
  refused and shall write no status line for any of them.
- When the carried set is refused, the system shall report the number
  claimed and the ceiling, and shall exit non-zero from the reader that
  would have written.
- When the carried set is refused on an in-flight event, the system shall
  name in that message the act that re-fires the event — closing and
  reopening the pull request.
- When a pull request names eight or fewer distinct tasks, the system
  shall behave exactly as it does today, in all five readers.
- When a title repeats one task's tag more times than the ceiling, the
  system shall carry that one task and shall not refuse the set.
- When a merge's carried set is refused, the system shall still record
  every task its own diff range puts in scope.
- When a reader asks the carried set of another, still-open pull request
  whose claim exceeds the ceiling, the system shall treat that pull
  request as naming no task, shall say which pull request it was, and
  shall not fail the act it was asked to serve.

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
  take's reader sees it as carrying nothing, so that task reads as free
  and a second worker may take it. Accepted: the set is over a ceiling no
  real title has approached, and that pull request is already red on its
  own check.
- **`PR_TITLE` absent or empty.** The branch's id alone is one task, well
  under the ceiling; the degraded path is untouched.
- **An adopter mid-migration**, on a copy of these scripts from before
  the ceiling. Nothing here is a queue-file schema change, so an old
  script and a new one disagree only about refusal, never about what a
  file means.

## Tests required

- A `queue_lib` unit case per side of the boundary: eight distinct tasks
  carried and printed; nine refused with the distinct code and no stdout.
- A unit case where one tag repeats twenty times: one task carried,
  exit 0.
- An `apply_pr_event` integration case with a nine-task title: nothing
  written to any task file, non-zero exit, and the message naming the
  count, the ceiling and the reopen.
- A `record_task_status` integration case with a nine-task title over a
  range that touches one task file: the touched task is recorded, the
  nine claimed are not.
- A `project_pr_tasks` integration case with a nine-task title: no forge
  call is made.
- A `take_task` unit case where an unrelated open pull request claims
  nine tasks: the take proceeds, and the notice names that pull request.
- Every existing case in the five readers must pass unchanged. This adds
  a refusal above eight; it changes nothing at or below it.

## Definition of Done

- [ ] `ql_carried_of` counts the set and refuses above eight, with a
      distinct code the header documents.
- [ ] The three writers refuse loudly; the two readers notice and carry
      on.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] `statuses.md`'s criteria carry the bound, `titles.md` states it is
      not settable, and the decision is dated and indexed.
- [ ] The sequence in
      [report-0028](../reports/report-0028-fork-title-claims.md) — a
      title tagging a hundred tasks — moves nothing, and says why.

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
