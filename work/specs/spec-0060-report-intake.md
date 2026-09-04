---
id: spec-0060
task_ref: task-0043
status: draft
created: 2026-09-04T06:26:06Z
---

# spec-0060 — The intake turns a labelled issue into a report

**References:** [task-0043](../tasks/task-0043-cross-repo-reports.md)

- **Goal:** a maintainer applying `writrun:report` to an issue that
  mirrors no file makes the machinery record it as the next
  `report-NNNN`, `status: open`, and turn the issue into that report's
  mirror — per
  [`intake.md`](../../docs/product/stage-3-github-issues/intake.md).

## Scope

The receiving machinery and the form that shapes a human submission.
Out: the `routed` status ([spec-0059](spec-0059-routed-status.md)),
the adopter-side guidance
([spec-0061](spec-0061-upstream-guidance.md)), and any write-back from
issue to file after minting — the mirror stays one-way once born.

## Steps

1. **The workflow** — `writrun-intake.yml`, the fifth kit workflow,
   beside the four in `template/.github/workflows/` and mirrored to
   this repository's root via `tests/template_mirrors.txt`. Trigger:
   `issues: [labeled]`; gate job on stage 3 via `stage_gate.sh`, then
   proceed only when the label is `writrun:report` and the title
   carries no `[REPORT-` / `[TASK-` tag (an existing mirror is
   another workflow's). YAML wires the event onto a script, logic in
   `.writrun/scripts/stage-3-github-issues/intake_report.sh` — the
   suite's integration tier executes scripts, not YAML.
2. **The script** — mints the next report id over the same three views
   `new.sh` reads (directory, history, open PRs); writes
   `work/reports/report-NNNN-<slug>.md` with `status: open`, `created`
   from the issue, the issue's title as the report title, its text as
   the body **passed through env, never interpolated** — the
   `writrun-issues.yml` pattern, since the body is a stranger's — plus
   a line naming the issue number and author; commits to the authority
   branch with the rebase-not-force pattern and a
   `commit_subject.sh` literal (scope `queue`); retitles the issue
   `[REPORT-NNNN] <title>`, adds `status:open`, comments the file
   path.
3. **The form** — `.github/ISSUE_TEMPLATE/writrun-report.yml` in the
   kit and mirrored to the root: what was observed, the evidence, the
   version consumed (`.writrun/VERSION` for a kit defect). The form
   carries no label an outsider could not set — the gate stays the
   maintainer's label, and the form is shape only.
4. **Concurrency** — one intake at a time (a concurrency group), so
   two labels racing cannot mint one id twice; the rebase push covers
   the queue-recording race that remains.
5. The kit prose that counts workflows — `template/WRITRUN.md`,
   `technical/distribution/kit.md` — says five where it says four; the
   ships-vs-names test reads the new directory entries.

## Acceptance criteria (EARS)

- When an issue is opened, the machinery shall write nothing to
  `work/` on that event.
- When `writrun:report` is applied to an unmirrored issue at stage 3,
  the machinery shall commit `report-NNNN` with `status: open`, retitle
  the issue `[REPORT-NNNN] <title>`, and label it `status:open`.
- When `writrun:report` is applied to an issue whose title already
  carries a mirror tag, the machinery shall change nothing.
- When the same label event is delivered twice, the second run shall
  find the mirror tag the first wrote and stop.
- When the issue body reaches the report file, it shall arrive as
  data through the environment, with no interpolation into shell or
  YAML.
- When the declared stage is below 3, the workflow's gate job shall
  end the run before any runner touches the queue.

## Edge cases

- The label applied by someone without triage rights — GitHub refuses
  the labeling itself; the workflow never fires.
- The issue is edited after minting — nothing writes back; the file is
  the authority from birth, as for every mirror.
- The label is removed and re-applied — the mirror tag in the title
  makes the re-run a no-op.
- An empty issue body — the report records the title and the
  provenance line; evidence can be thin, the bar is the label.
- A fork or outside collaborator opened the issue — irrelevant: the
  gate reads the labeler's rights, not the author's.

## Tests required

- Integration tier for `intake_report.sh`: mints past the highest id
  across the three views; refuses a mirrored title; writes body as
  data (a body carrying `$(...)`, backticks and YAML front matter
  arrives verbatim); commit subject matches the literal.
- The mirror-list unit test covers the fifth workflow and the form
  byte-for-byte.
- The ships-vs-names units read the new entries where the kit's prose
  names them.

## Definition of Done

- [ ] The labelled-issue path runs end to end on this repository.
- [ ] Arrival alone writes nothing; the label gate holds.
- [ ] Root and kit copies identical; `tests/template_mirrors.txt`
      names both new files.
- [ ] The intake's contract is documented in the technical chapter
      below.

## Proposed product changes

- none — the rule was authored ahead of this spec
  (`product/stage-3-github-issues/intake.md`); authoring closes the
  loop in advance.

## Proposed technical changes

- `technical/reporting/intake.md` — new chapter: the workflow, the
  script's contract, the id race and the concurrency answer, the
  body-is-data handling.
- `technical/reporting/README.md` — the chapter table gains the row.
- `technical/distribution/kit.md#the-kit` — what ships: five
  workflows, the issue form, and the mirror list naming both.

## Outcome

_(fill after execution)_
