---
id: spec-0077
task_ref: task-0054
status: draft
created: 2026-09-05T12:57:30Z
---

# spec-0077 — A retitle re-records, and a close releases what it cannot claim

**References:** [task-0054](../tasks/task-0054-six-review-findings.md)

- **Goal:** a pull request retitled after its recording re-records, and
  a close over the ceiling relabels the mirrors it releases instead of
  turning `reflect` red.

## Scope

In: three faults on one path — the missing `edited` trigger, the
projector's exit on an over-ceiling `closed` event, and the exit code
an unknown event gets when the title is over the ceiling.

Out: the ceiling itself. `QL_CARRIED_MAX = 8` and the reasoning for it
stand ([decision 0068](../../docs/technical/decisions/pull-requests/0068-what-a-pull-request-claims-is-bounded.md));
nothing here loosens what a claim may be.

Out: `apply_pr_event.sh`'s close arm. #204 already exempts it, for the
reason that generalizes to the projector — releasing is not claiming.

Out: the fork-origin question. Decision 0068 leaves it open by name and
report-0028 carries it.

**This spec depends on #204.** Two of the three faults exist only after
it, and the third is the workaround it shipped.

### 1. A retitle never re-records — the root cause

`.github/workflows/writrun-progress.yml:31` lists `opened`, `reopened`,
`ready_for_review`, `converted_to_draft`, `review_requested` and
`closed`. It does not list `edited`. Both routes into the carried set —
the head branch and the title — are the author's to write, and one of
them can change after the recording without any event firing.

**This is the cause of the problem #204 worked around.** A pull request
recorded under a one-tag title, retitled to nine tags, then closed, was
stranded in flight: the close was refused as over-ceiling, and no
earlier event's record could be undone. #204's fix — exempt the close,
because it is the last event that can release them — is correct and
stays. It treats the symptom because the cause is a trigger list.

### 2. The projector refuses a close it should answer

`project_pr_tasks.sh` still exits 1 on an over-ceiling `closed` event.
Its caller is `writrun-progress.yml`'s `reflect` job, so that job goes
red and the mirror labels for every task the close just released stay
stale — the queue says `ready`, the mirror says `in-progress`, and
nothing comes back for it.

**Changing this is a decision, not a bug fix, and the spec must argue
it.** [spec-0069](spec-0069-bound-carried-claims.md) assigns the
projector "refuse loudly", and decision 0068 names exactly two callers
that bend the refusal: the merge recorder and the close arm of the
in-flight recorder. Both bends have the same warrant — the write in
question releases rather than claims — and the projector's close
relabels mirrors for tasks the recorder has *already* released, so it
claims nothing at all. The argument to make is that this is a third
instance of the existing exemption, not a new one.

### 3. An unknown event over the ceiling exits 1, not 3

Minor, and worth fixing while the path is open. In `apply_pr_event.sh`
after #204 the ceiling refusal sits before the event dispatch, so an
event name the script does not know, carried by an over-ceiling title,
exits 1 (ceiling) rather than 3 (usage). Both are non-zero, so nothing
downstream misbehaves; the exit code lies about which fault it hit,
which is what a caller reads when deciding whether to retry.

## Steps

1. Add `edited` to `writrun-progress.yml`'s `pull_request_target`
   types, and to the `template/` twin.
2. Decide what an `edited` event records. The event fires on body edits
   and base changes too, so the step must be cheap when the title did
   not change, and must re-derive the carried set when it did.
3. Establish what happens to a task the *old* title claimed and the new
   one does not. Re-recording adds; nothing here releases, and a task
   left in flight by a retitle is the same stranding one layer over.
   Say whether this change answers it or reports it.
4. Exempt the `closed` event in `project_pr_tasks.sh`, with a header
   comment carrying the argument from section 2 above.
5. Move the ceiling refusal in `apply_pr_event.sh` after the event
   dispatch's usage check, or check the event name first, so an unknown
   event exits 3.
6. Extend decision 0068 to name the third caller that bends the
   refusal, and record the criteria in `statuses.md` and `labels.md`.
7. Mirror into `template/` with `make template-sync`.

## Acceptance criteria (EARS)

- When a pull request's title is edited, the machinery shall re-derive
  what the pull request carries and record it.
- When a pull request's body or base is edited and its title is not,
  the machinery shall write nothing.
- When a title edit takes the claim over the ceiling, the machinery
  shall refuse the claim exactly as it refuses one at `opened`.
- When an over-ceiling pull request closes, the projector shall relabel
  the mirrors of the tasks the close released, and shall exit 0.
- When an over-ceiling pull request carries an event the recorder does
  not know, it shall exit 3.

## Edge cases

- **`edited` on a fork's pull request.** `pull_request_target` runs the
  base's workflow with write permissions, and the title is the fork's
  to write — which is report-0028's exposure, bounded by the ceiling
  and not widened here. The new trigger adds an occasion, not a
  capability.
- **A retitle that drops a tag.** The dropped task keeps `in-progress`
  and `taken_by` with no pull request claiming it. Step 3 must answer
  this or report it; leaving it unstated repeats the stranding this
  spec exists to end.
- **A retitle during the close.** `edited` and `closed` can land close
  enough together to race. The close must win: it releases, and a
  recording that re-claims after a release is the stranding again.
- **An `edited` burst.** A title edited five times in a minute fires
  five runs, each pushing a recording commit. The concurrency posture
  is #199's; check it holds before adding the trigger rather than
  after.
- **The projector's exemption and the merge path.** `rederive_labels.sh`
  is shared with the merge path. The exemption belongs in
  `project_pr_tasks.sh`, not in the labeller both call.

## Tests required

- An integration case: record under one tag, retitle to two, assert the
  second task is recorded.
- A case asserting a body-only edit writes nothing.
- A case asserting a title edit over the ceiling is refused like an
  `opened` one.
- A case asserting an over-ceiling close projects and exits 0 — the
  sibling of #204's `an_over_claim_still_releases_on_close_test.sh`,
  one layer up.
- A case asserting an unknown event over the ceiling exits 3.

## Definition of Done

- [ ] `edited` is in both workflow copies, and a body-only edit writes
      nothing.
- [ ] A retitle re-records; a retitle over the ceiling is refused.
- [ ] The dropped-tag case is answered or reported, in writing.
- [ ] The projector exits 0 on an over-ceiling close and relabels.
- [ ] An unknown event over the ceiling exits 3.
- [ ] Decision 0068 names three bends, not two.
- [ ] `template/` twins identical.

## Proposed product changes

- `product/stage-2-pull-requests/statuses.md#criteria` — a criterion
  that a title edit re-derives what the pull request carries. The
  recording rule currently reads events as though the claim were fixed
  at `opened`.
- `product/stage-3-github-issues/labels.md#criteria` — a criterion that
  a close relabels the mirrors of the tasks it released, whatever the
  title claimed.

## Proposed technical changes

- `technical/decisions/pull-requests/0068-what-a-pull-request-claims-is-bounded.md`
  — the "two callers bend the refusal" paragraph gains the third, with
  the same warrant: releasing is not claiming. The file arrives with
  #204, which this spec depends on; it is not on `main` yet.

## Outcome

_(fill after execution)_
