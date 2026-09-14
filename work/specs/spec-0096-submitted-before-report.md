---
id: spec-0096
task_ref: task-0068
status: implemented
created: 2026-09-14T00:31:03Z
---

# spec-0096 — The marker the submitter applies, and the section that reads it

**References:** [task-0068](../tasks/task-0068-submitted-before-report.md)

- **Goal:** An issue offered as an observation is marked by whoever
  offers it, named where work is picked, and unmarked the moment it
  becomes a report — with the intake's gate untouched.

## Scope

Four places, none of which decides anything the rule did not already
decide.

- `.github/ISSUE_TEMPLATE/writrun-report.yml` — the form gains
  `labels: ["writrun:submitted"]`. Its header comment already explains
  why it sets no label; that comment is amended, not deleted, because
  the distinction it draws is the one this change depends on.
- `.writrun/AGENTS.md`, *When the defect is WritRun's* — the routing
  instruction passes `--label writrun:submitted` to `gh issue create`.
  This is the half the form cannot reach, and the exact route both
  missed findings took.
- `.writrun/skills/writrun-select-next-task/list_tasks.sh` — a section
  above `Open reports`, naming issues that carry the marker and mirror
  no file.
- `.writrun/scripts/stage-3-github-issues/intake_report.sh` — the marker
  is removed when the report is minted.

`.writrun/` is carried whole by `tests/kit_mirrors.txt`, so the kit
copies come from `make kit-sync`.

**Out of scope.** The gate does not move: `writrun:report` stays the only
label that mints anything, and `intake_report.sh`'s refusals are
untouched. Nothing reads an issue's body to decide whether it was meant
as a report — the rule is explicit that an unmarked issue is an ordinary
issue.

## Steps

1. Ensure the label exists before anything can apply it. `ensure_label`
   already does this idempotently in `mirror_issues.sh`; add
   `writrun:submitted` to the pass that runs on every push to the
   authority branch, so the form is never applying a label that is not
   there.
2. Add `labels:` to the issue form and amend its header comment to say
   what the marker is and is not.
3. Add `--label writrun:submitted` to the kit's routing instruction, and
   say in one clause why it is passed — an agent that does not know it is
   a marker will eventually decide it is the gate.
4. Add the lister section, reading the forge the way the pull request
   query already does and degrading the same way.
5. Remove the marker in `intake_report.sh`, in the same step that applies
   `status:open`.
6. `make kit-sync`.

## Acceptance criteria (EARS)

- When an issue is opened through the report form, it shall carry
  `writrun:submitted`.
- When an agent follows the kit's routing instruction, the issue it
  opens shall carry `writrun:submitted`.
- When `writrun:submitted` is applied, the machinery shall mint nothing,
  resolve nothing, and change no file under `work/`.
- When the lister runs and the forge is reachable, it shall name every
  issue carrying `writrun:submitted` that mirrors no file, in a section
  of its own above `Open reports`.
- When the lister names such an issue, it shall not enter the ordering,
  shall not be offered as the thing to take, and shall not change the
  exit code.
- When the lister cannot reach the forge, it shall say the section could
  not be answered rather than printing it empty.
- When the intake mints a report from an issue, it shall remove
  `writrun:submitted` from that issue.
- When an issue carries no marker, no behaviour shall change for it.

## Edge cases

- **The marker on an issue that already mirrors a file.** Applied by
  hand to a `[REPORT-NNNN]` issue, it must not produce a second listing:
  the section's filter is "carries the marker **and** mirrors no file",
  and the second half is what makes a hand-applied label harmless.
- **The label not existing yet** is why step 1 comes first. A form
  referencing an absent label silently drops it, which would make this
  change appear to work everywhere except where it matters.
- **An empty section and an unasked question look identical**, which is
  the failure `visibility.md` names for this section specifically. The
  degraded path says so; it does not print a heading with nothing under
  it.
- **A submission that is never triaged** stays listed indefinitely, and
  that is correct — the section is an ask, and an ask that ages out is
  the rot the rule was written against. No expiry.
- **Someone removes the marker by hand** to silence the section. Nothing
  prevents it and nothing should: the label is a convenience for
  querying, not a record. The issue remains, and the file was never
  owed.

## Tests required

- `tests/integration/` for the intake: minting a report from a marked
  issue leaves it unmarked; the gate still refuses a label that is not
  `writrun:report`.
- Lister cases, using the existing forge seam rather than a live call:
  a marked issue with no mirror is named; a marked issue that mirrors a
  file is not; the section never moves the exit code; an unreachable
  forge says so.
- A case asserting the form's YAML carries the label, so a future edit
  that drops it fails rather than going quiet — this is the half with no
  runtime signal at all.
- The kit mirror unit test must pass with no new exception.

## Definition of Done

- [ ] Both submission routes apply the marker; the intake removes it.
- [ ] The lister names the marked-unmirrored set, and no case shows it
      entering the ordering or the exit code.
- [ ] `make kit-sync` leaves the kit byte-identical, no new entry in
      `tests/kit_exceptions.txt`.
- [ ] Issue #155 is the regression this is checked against: a finding
      routed by the kit's own instruction is now named by the lister
      without anyone remembering.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- none — the rule is already written. `intake.md#submitted-and-not-yet-a-report`,
  `visibility.md#a-submission-is-named-before-it-is-a-report` and
  `labels.md` were authored by the change this task derives from, and
  this one builds what they state.

## Proposed technical changes

- `technical/decisions/github-issues/0076-a-marker-is-not-a-gate.md` —
  the record: why the marker is applied by the submitter and never
  inferred from an issue's contents, why it is removed at intake rather
  than left as history, and why the lister filters on "mirrors no file"
  instead of trusting the label alone.
- `technical/decisions/README.md` — the index gains the record's line;
  a record that is not indexed is one the router cannot reach.

## Outcome

Built as planned, in the four places named. The report form carries
`labels: ["writrun:submitted"]` and its header comment is amended rather
than replaced; the kit's routing instruction passes
`--label writrun:submitted` to `gh issue create` with one clause saying
it is a marker and not the gate; `list_tasks.sh` prints a `Submitted`
section above `Open reports`; and `intake_report.sh` removes the marker
in the same step that applies `status:open`. `make kit-sync` carried all
of it, with no new entry in `tests/kit_exceptions.txt`.

**Step 1 landed unconditionally, because the pass it named does not
exist.** No workflow runs `mirror_issues.sh` on a push to the authority
branch: `writrun-issues.yml` runs it on a pull request's events and
`writrun-approve.yml` on the merged close. Declaring the label on the
open pass alone would leave a repository whose merges all arrive by
some other route without it, and a form referencing an absent label
drops it in silence — the one failure the step exists to prevent. So
`ensure_label "writrun:submitted"` sits outside the `open` guard, and a
comment says why it is the exception to the "only what this script
writes" rule the block above it states.

**The lister's mirror filter asks two questions, not one.** The spec's
edge case named the `[REPORT-NNNN]` title, which is the forge's own word
for a mirror and the read `intake_report.sh` makes before it mints. The
queue is asked too — the `Issue #N` line every minted report opens
with — because the retitle is the intake's *last* write: a run that died
between the push and the retitle leaves the file recorded, the issue
untagged and the marker still on it, and the section would ask for a
file that exists. That is the same reasoning the intake's own no-op
guard rests on.

**The degraded note prints with the other notes, at the end.** The
requirement is that the run say the section could not be answered rather
than print it empty, and this file already collects every such note
after the sections. It is its own `if` and not an arm of the pull
request chain: the two are separate calls, and one answering says
nothing about the other.

The forge seam is `WRITRUN_SUBMITTED_LIST`, spelled and degrading
exactly like `WRITRUN_PR_LIST` beside it; the unreachable-forge case is
driven through the existing `stub_forge` / `forge_unavailable` pair
instead, so the degradation is produced rather than declared.

**One test beyond the four groups, and one fewer file than the list
implies.** The form's YAML case also reads the kit's routing
instruction, and then that one spelling across the three machinery sites
that declare, read and remove the label — both routes have the same
problem the group was written for, which is no runtime signal at all, so
they are one case. And `mirror_issues.sh`'s declaration gained a case of
its own: step 1 is the half whose failure is silent everywhere else.

`intake_report.sh`'s header enumerates what the intake does to the
issue, so it gained the marker's removal; that is documentation of the
change, not an addition to it. The same holds for
`writrun-select-next-task/SKILL.md`, which enumerates the sections the
lister prints and said "five" — a skill that does not name a section is
a section the session never acts on.
