---
id: spec-0039
task_ref: task-0029
status: implemented
created: 2026-08-31T16:36:02Z
---

# spec-0039 — The merged close has one owner, and the label comes from the queue

**References:** [task-0029](../tasks/task-0029-mirror-pre-merge.md)

- **Goal:** one workflow answers a merged close, and the mirror's label
  comes from the queue on the authority branch after the recording
  commit — so the label a merge *causes* is the label that stands,
  instead of being overwritten seconds later by one derived from what
  the merge *carried*.

## Scope

The task reports the symptom correctly and the mechanism wrongly, and
the correction is this spec's premise. `mirror_issues.sh` never reads
the queue from disk: it derives "ready" from the spec statuses in the
pull request's own API patch (`SPEC_STATUSES`, `is_ready`), where the
merge has not yet flipped them. Its job's unnamed checkout ref is
therefore not the defect, and naming it would change nothing.

The defect is that three workflows answer one `pull_request_target:
closed` event and two of them write the same label. The forge's own
record, mirror #66:

```
15:04:48  status:proposed → status:ready     rederive_labels.sh   (writrun-approve)
15:04:51  status:ready    → status:backlog   mirror_issues.sh     (writrun-issues)
15:31:02  status:backlog  → status:ready     corrected by hand
```

Decision [0048](../../docs/technical/decisions/github-issues/0048-a-label-names-a-place.md)
already rejected "having the mirror read the base tree instead of the
diff, which races the approve workflow's own push", and put the
re-derivation sequentially inside that workflow — but it left
`mirror_issues.sh` deriving a label from the diff *and* still answering
the merged close. That is the gap this closes.

In: the three workflows' response to a merged close; the merged path of
`mirror_issues.sh`; the scope `record_task_status.sh` reports; their
tests; the template mirror.

Out: **the four standing mirrors** — #66, #67, #70 and #71 were
corrected by hand on 2026-08-31 at 15:31 and all read `status:ready`;
the task asked for a fix that no longer has a subject, and the Outcome
records that rather than the change re-doing it. Out: the open-pull-request
path, where the diff is the only source there is — the queue does not
hold a proposed task yet, and `status:proposed` stays derived exactly as
it is. Out: what the labels mean —
`product/stage-3-github-issues/labels.md` already carries the rule this
implements. Out: concurrency groups, which serialize runs without
deciding which runs last, and which nothing needs once one workflow owns
the event.

## Steps

1. `mirror_issues.sh`: on a merged close, stop writing any `status:`
   label. It keeps the half only the diff can answer — minting a mirror
   the queue is owed, adopting a stale one, retiring an orphan — and a
   mirror it mints on that path is created without a `status:` label,
   for the projection below to write. `SPEC_STATUSES` and `is_ready` go
   with the label they existed to derive.
2. `record_task_status.sh`: add a `scope=<id ...>` line to
   `$GITHUB_OUTPUT` naming every task the range put in scope, moved or
   not. `changed=` and `tasks=` keep their meanings — a task the merge
   created and settled without moving has no `moved` line and still owes
   its mirror a label.
3. `writrun-approve.yml`: a second stage gate output (3, beside the
   existing 2), and after the Commit step a stage-3-gated pair of steps
   in the same job — `mirror_issues.sh` for existence, then
   `rederive_labels.sh` with the flip's specs and the recording's
   `scope`. Sequential after the push, so both read the queue the
   recording just wrote.
4. `writrun-issues.yml`: its `mirror` job skips a merged close. The
   `closed` trigger stays — a close *without* a merge is still its
   retirement to run.
5. `writrun-progress.yml`: its `reflect` job skips a merged close. Its
   `record` job already no-ops there, and its projection is the third
   writer of the same label from a checkout that may predate the
   recording commit.
6. `technical/README.md#distribution`: the severability sentence, so it
   stays true — `approve` carries the merged close's mirror steps behind
   the stage-3 gate, and an adopter below Stage 3 still starts nothing.
7. Decision `0060` under `github-issues/`, and its row in the decisions
   index.
8. `make template-sync`; suite.

## Acceptance criteria (EARS)

- When a pull request closes merged, `writrun-issues.yml`'s mirror job
  and `writrun-progress.yml`'s reflect job shall not run.
- When a pull request closes without merging, `writrun-issues.yml` shall
  retire its mirrors exactly as before.
- When `mirror_issues.sh` runs on a merged close, it shall write no
  `status:` label, and a mirror it mints there shall carry
  `writrun:task` and its `origin:` label alone.
- When a merge is recorded, the mirror of every task the merge put in
  scope shall be labelled from the queue as it stands after the
  recording commit.
- When a merge puts a task in scope whose stored status the recording
  did not change, `record_task_status.sh` shall still name it in
  `scope=`.
- When a merge adds a task and the spec it references, that task's
  mirror shall end the run on `status:ready`.

## Edge cases

- **A recording that writes nothing.** The mirror steps must not reuse
  the Commit step's condition: a merge can put a task in scope without
  moving it, and a mirror the queue is owed still has to be minted and
  labelled.
- **A merge whose head is not a task branch.** An authoring or reporting
  merge carries no id, so `tasks=` is empty — `scope=` is not, because
  the range touched the task files themselves. That is the case every
  mislabelled mirror above came from.
- **An adopter below Stage 3.** The new steps sit behind `stage_gate.sh
  3`; deleting the two mirror workflows still removes the mirror, and
  the gate keeps `approve` from reaching for one that is not there.
- **A mirror another open pull request owns.** `mirror_issues.sh` still
  refuses to touch it; `rederive_labels.sh` has never read ownership and
  does not gain it here — the merged close is the moment the file became
  the truth, and the projection restates the file.
- **Two merges landing seconds apart.** Each run rebases before pushing
  and projects from its own checkout afterwards; the later projection is
  derived from the later queue, so the last write is also the most
  recent truth.
- **A fork's merged pull request.** `pull_request_target` carries the
  write token on the base branch, unchanged by any of this.

## Tests required

`mirror_issues.sh` on a merged close writes no `status:` label and mints
a mirror carrying only `writrun:task` and `origin:`; its unmerged-close
retirement and its open path are unchanged. `record_task_status.sh`
reports `scope=` including a task it did not move, with `tasks=`
unchanged. `rederive_labels.sh` labels a task id passed in scope that no
`moved` line named. An end-to-end case for the failure this exists to
close: a merge adding a task and its spec leaves the mirror on
`status:ready`. Template mirror test.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] Exactly one workflow writes a mirror's label on a merged close,
      and it writes it after the recording commit.
- [ ] No label derivation reads a pull request's diff outside the
      open-pull-request path.
- [ ] Template synced; suite green.

## Proposed product changes

- none — the rule was authored first
  (`product/stage-3-github-issues/labels.md#criteria`, which already
  says the machinery re-labels from the queue as it then stands rather
  than from the merge's own diff); this change makes it true.

## Proposed technical changes

- `technical/README.md#distribution` — the severability sentence gains
  the merged close's mirror steps in `approve`, behind the stage-3 gate,
  so "delete exactly those two" stays an accurate instruction.
- `technical/decisions/github-issues/0060-the-merged-close-has-one-owner.md`
  — the dated why: one owner per event, and what 0048 left open.
- `technical/decisions/README.md` — the chronology row for 0060.

## Outcome

Implemented as specified. One workflow answers a merged close, and the
label is written from the queue after the recording commit.

**What shipped.** `mirror_issues.sh` lost `SPEC_STATUSES` and `is_ready`
along with the `spec_ref` column its records only carried for them; past
the open event it writes no `status:` label and mints bare.
`record_task_status.sh` reports `scope` beside `tasks`.
`writrun-approve.yml` gained a Stage 3 gate output and two steps after
its push — mint, then label, with `steps.status.outputs.scope` and no
condition on `changed`. `writrun-issues.yml`'s mirror job and
`writrun-progress.yml`'s reflect job stand down for a merged close and
keep every other event. Decision 0060 and its index row; the
`#distribution` severability sentence now names the two Stage-3-gated
steps `approve` carries.

**Divergences.**

- **The task's diagnosis was wrong, and the spec says so rather than the
  code working around it.** task-0029 blamed the mirror job's unnamed
  checkout ref; `mirror_issues.sh` never read the queue from disk, so
  that ref was never the defect. Correcting the read would have changed
  nothing, and naming it in the Scope was the premise the fix needed.
- **The four standing mirrors were out of scope and stayed out.** #66,
  #67, #70 and #71 had been corrected by hand at 15:31 on the day of the
  report, before this work started; all four read `status:ready`, and
  there was nothing left to fix.
- **Two tests were deleted rather than adapted.**
  `merged_ready_task_relabelled_ready_test.sh` and
  `merged_with_draft_spec_kept_pending_test.sh` asserted the
  diff-derived readiness this change removes. What they protected — a
  draft spec holds its task back, an approved one lets it through — is
  the projection's now, and `rederive_labels`' own cases already cover
  both directions. `merged_writes_no_status_label_test.sh` replaces them
  with the opposite assertion.
- **The end-to-end case landed in the integration tier**, at
  `tests/integration/stage-3/merged_close/`, not under `tests/e2e/`.
  That tier is for whole-path runs against a copy of this repository;
  this case drives three scripts — flip, record, mint, project — over
  fixtures, in the order `writrun-approve.yml` runs them, and asserts
  that the *last* label write to reach the forge is `status:ready`.
  "Which write is last" is the whole defect, so the assertion is on
  ordering rather than on any one call.
- **One test beyond the plan.**
  `merged_close/one_workflow_answers_it_test.sh` reads the three
  workflows as text: both stand-downs, the push → mint → label order in
  the owner, `scope` reaching the projection, and both mirror steps
  gated on Stage 3. The settlement is wiring, and no script run can
  observe wiring.

**Corrected before merge, from review.** Three defects in the change
above, all found while it was still in flight and fixed in the same
branch.

- **The mirror steps run on `!cancelled()`.** They carried only the
  Stage 3 condition, which inherits the implicit `success()`, so any
  earlier step failing — a push the base branch's ruleset refuses, a
  rebase that conflicts — skipped them both. With the other two
  workflows standing down for a merged close, that skip is the merged
  close answering nothing at all, and no event comes back for it. The
  Commit step now also aborts a conflicting rebase before failing, so
  the queue the projection reads from disk is never left holding
  conflict markers.
- **The severability sentence needed more than the added clause.**
  "delete exactly those two" is not made true by the Stage 3 gate:
  `stage` defaults to `3`, so an adopter who deletes the two mirror
  workflows and changes nothing else still gets mirrors from `approve`.
  `#distribution` now says severing the mirror *is* the `stage` setting,
  and notes that only `writrun-issues.yml` is severable by deletion at
  all — `writrun-progress.yml` also carries Stage 2's in-flight
  recording.
- **The mint reports its own set.** Which mirrors get minted is derived
  from the pull request's files; `scope` is derived from
  `merge_commit_sha~1...merge_commit_sha`. Equal for a squash or a merge
  commit, not for a rebase merge, where that range is only the last
  rebased commit — so a task minted from an earlier one fell outside
  `scope` and, minted bare by step 1 above, would have stayed label-less
  for good. `mirror_issues.sh` now reports `tasks=` through
  `$GITHUB_OUTPUT` and the projection is given it beside `scope`,
  leaving out any mirror the pass refused to touch. This goes beyond the
  Steps as written; 0060 carries the reasoning.

Suite green after the corrections: 253 case files, 0 failed — the whole
suite, not the tiers this change touched.

**Left alone, deliberately.** The body a merged-path mint writes still
closes with "Becomes ready for development when #N merges…", which reads
oddly on a mirror born at the merge. It predates this change and no
promise here covers it — a sentence for a commit, not for this diff.
