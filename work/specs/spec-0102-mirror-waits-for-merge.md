---
id: spec-0102
task_ref: task-0074
status: implemented
created: 2026-09-18T17:14:57Z
---

# spec-0102 — A proposed triage is not a triage, so the mirror waits for the merge

**References:** [task-0074](../tasks/task-0074-mirror-waits-for-merge.md)

- **Goal:** While a pull request only proposes a report's triage, the
  report's mirror says what the authority branch says; the merge that
  lands the status is what closes it.

## Scope

One rule, in one loop.

`mirror_issues.sh` derives two things for a report from the same diff
row: the label it should wear, and whether it should close. The label
asks whether the pull request is still open — an open one only proposes,
so its report is `status:proposed`. The close does not ask. A diff
carrying `tracked`, `authored`, `fixed`, `routed` or `declined` closes
the mirror on the spot, on a branch nobody has merged.

The task loop, a few hundred lines above, never closes on an open pull
request. The report loop's own reconciliation for a pull request closed
unmerged already asks the base branch, and already restores a mirror an
abandoned branch closed. This change gives the open window the answer
those two already give.

**The merge needs nothing new.** `rederive_labels.sh` runs at merge over
the reports the mint answered and projects each from the queue as it
then stands — `report_label_for` and `report_close_for` — and
`mirror_issues.sh` itself runs there with `merged=true`, where the close
from the diff is correct because the diff has landed.

**Out of scope.** The merged path is untouched, closes included. The
reconciliation for a pull request closed unmerged is untouched: it
already reads the branch. `project_pr_tasks.sh` is not taught about
reports — the reason this loop updates existing mirrors on every
synchronize stands, and this change alters what it writes there, not
whether it writes.

## Steps

1. In the report loop of
   `.writrun/scripts/stage-3-github-issues/mirror_issues.sh`, compute
   `want_close` only when the pull request is no longer open. While it
   is open, nothing closes.
2. While it is open, derive the label from the base branch rather than
   from the diff's status, with the two helpers the closed-unmerged
   reconciliation already uses: the branch does not carry the report →
   `status:proposed`; the branch carries it untriaged → `status:open`;
   the branch carries it already triaged → say nothing and leave the
   mirror alone.
3. Say why at the `want_close` line, in the comment that now explains
   the asymmetry: the diff is a proposal, and the authority branch is
   the only thing a mirror projects.
4. Rewrite the first case of
   `tests/integration/stage-3/mirror_issues/a_proposed_report_triaged_later_is_closed_test.sh`
   to assert the new answer, rename the file to match what it now says,
   and add the case the fix is for — a report on the branch, triaged by
   an open pull request, whose mirror stays open at `status:open`.
5. `make kit-sync`.
6. Record the decision, and add its row to the index.

## Acceptance criteria (EARS)

- When a pull request is open and its diff carries a report's terminal
  status, the machinery shall not close that report's mirror.
- When a pull request is open and the authority branch carries the
  report untriaged, the machinery shall label its mirror `status:open`.
- When a pull request is open and the authority branch does not carry
  the report, the machinery shall label its mirror `status:proposed`.
- When a pull request is open and the authority branch already carries
  the report triaged, the machinery shall leave its mirror alone.
- When the merge lands a report's terminal status, the machinery shall
  close its mirror with the reason that status implies, as today.
- When a pull request closes without merging, the machinery shall
  reconcile the report's mirror against the base branch, as today.

## Edge cases

- **A report born triaged in an open pull request.** It is created
  `status:proposed` and open, and the merge closes it. The Issue asks
  nobody to triage it — `status:proposed` says it is not on the
  authority branch yet — and the window it stands in is the window the
  pull request is in review.
- **Recorded and triaged inside one pull request's life.** The mirror
  goes `proposed` at the first push and stays there; the merge closes
  it. No pass writes a label it already wears.
- **The authority branch already has it triaged.** A later pull request
  editing that report must not reopen its mirror, which is why the
  branch's terminal status is a "say nothing" and not a label.
- **A diff that says nothing about the status** keeps saying nothing:
  the existing skip runs before any of this.
- **An unauthorized author** is still deferred to the merge, before the
  mirror is looked up — the gate does not move.
- **A draft pull request** is skipped whole, as today.

## Tests required

- Integration for the open window: a terminal status in the diff of an
  open pull request closes nothing; the mirror of a report the branch
  holds untriaged reads `status:open`; a report added in that diff
  reads `status:proposed`; a report the branch holds triaged is not
  touched.
- The merged cases in `triage_closes_the_report_mirror_test.sh`,
  `a_born_terminal_report_is_created_closed_test.sh` and
  `merged_report_waits_for_triage_test.sh` stay green unchanged — they
  are the merge path, and the merge path does not move.
- `closed_unmerged_answers_from_the_branch_test.sh` stays green
  unchanged.
- The kit mirror unit test passes with no new entry in
  `tests/kit_exceptions.txt`.

## Definition of Done

- [ ] An open pull request closes no report mirror.
- [ ] The label in that window comes from the authority branch, by the
      same two helpers the closed-unmerged path uses.
- [ ] The inverted test is renamed to what it asserts, and the new case
      is beside it.
- [ ] `make kit-sync` leaves the kit byte-identical.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- `product/stage-3-github-issues/labels.md#the-report-mirror` — the
  close row says which event closes the mirror, and one paragraph gives
  the in-flight triage the answer the table gives a report's birth.
- `product/stage-3-github-issues/labels.md#criteria` — the criterion:
  a pull request that only proposes a triage leaves the mirror at what
  the authority branch holds.

## Proposed technical changes

- `technical/decisions/github-issues/0082-a-proposed-triage-is-not-a-triage.md`
  — the record: why the close waits for the merge, why the label is read
  from the branch and not from the diff, and what a report born triaged
  costs in the open window.
- `technical/decisions/README.md` — the index gains the record's row.

## Outcome

Built as planned, with one sentence more to narrow than the plan counted
and one test case it did not name.

**A rule stated in three places had to be narrowed in all three.**
Step 3 asked for the *why* at the `want_close` line. Two texts above it
said something that this change makes false for reports: the script's
own header — *past the open event, `status:proposed` is the one state no
file can hold* — and, one level up, decision
[0060](../../docs/technical/decisions/github-issues/0060-the-merged-close-has-one-owner.md),
where that sentence comes from. A report's mirror in the open window can
now read `status:open`, which a file does hold, because the question that
window asks is what the branch says rather than what the diff proposes.
The header carries the narrowing and 0082 records it; 0060 keeps its
file and its number, as the folder's rule requires.

The comment marking the "triaged while still proposed" path also had to
be rewritten rather than left: its first claim — that the case runs
through there *to a close* — stopped being true, while the reason it
gives for updating existing mirrors at all stands unchanged.

**One case the plan folded and the tests had not.** The acceptance
criteria cover a report the branch does not carry, but the suite only
covered that report's *create* path at the merge
(`a_born_terminal_report_is_created_closed_test.sh`). A report born
already triaged in an **open** pull request is now created open at
`status:proposed`, and that is the visible cost named in the pull
request and in 0082, so it is asserted where the rule is:
`a_triage_in_flight_waits_for_the_merge_test.sh`.

The renamed test file lost nothing. Its two merged cases — a triage that
arrives as an edit, and an edit that says nothing — are the merge path,
which does not move, and they sit beside the four open-window cases in
the file whose name now says what it asserts.
