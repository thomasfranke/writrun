---
id: spec-0043
task_ref: task-0031
status: approved
created: 2026-09-01T13:54:27Z
---

# spec-0043 — The machinery learns the report kind

**References:** [task-0031](../tasks/task-0031-report-kind.md)

- **Goal:** a report can be created, is checked like a task or a spec,
  and appears in Issues where somebody will see it.

## Scope

The machinery half of
[0064](../../docs/technical/decisions/tasks-and-specs/0064-a-report-is-an-artefact.md),
in three parts that ship together because each is useless alone: a
generator that mints reports, gates that recognise them, and the mirror
that surfaces them.

Out of scope: the task schema, which 0064 leaves untouched — nothing on
a task points back at a report, and no gate should start expecting one.
Also out of scope: any change to how titles, tasks or specs are handled;
the report is added beside them, never folded into them.

## Steps

**The generator**

1. `new.sh report "<title>" [--slug words] [--doc-ref path#anchor]` —
   a third subcommand. `next_id` and `queue_file` already take the kind
   as an argument, so the work is argument parsing, the front-matter
   block and the refusals. **No `--origin`** (a report has none — it is
   what `origin: report` refers to) and **no `--priority`** (a report
   commits to no work, so nothing prioritises it).
2. `.writrun/templates/report.md` — the shipped default body, with
   `{{id}}`, `{{title}}` and `{{references}}`, resolving through the
   same three layers as a task's. The body prompts for what was
   observed and the evidence, never for a plan.
3. `new.sh task --from-report report-NNNN` — appends the new task's id
   to that report's `task_ref` and stamps its `triaged` date, exactly
   as `new.sh spec` appends to a task's `spec_ref`. The append is the
   mechanical half of triage, and it is the reason it belongs in the
   generator rather than in an agent's memory.
4. `writrun-create-task-and-spec`'s SKILL.md — the third kind: when a
   report is the right artefact rather than a task, the status
   vocabulary, and the rule that recording rides any change.

**The gates**

5. `check_doc_shapes.sh` — the prefix map at its `task-`/`spec-` case
   gains `report-*) dir=reports`. A shown id must resolve to a real
   file, so this step also **records the first real report** and points
   the schema example at it; the block in `technical/README.md` then
   returns from ```text to ```yaml, which is the shape 0062 requires and
   the authoring change could not deliver without this code. The
   script's own header defines the ```text fence as "a chapter showing
   what the checker refuses, or a shape that is history" — the report
   schema is neither, and rode the fence only because the checker did
   not know the kind. Flipping the block back retires that third
   meaning; nothing in the header needs to gain it.
6. `check_front_matter.sh` — a third directory, and the report schema:
   the five-value status vocabulary, `task_ref` as a list even with one
   element, `doc_ref` resolved relative to `docs/` exactly as a task's,
   `created` and `triaged` as UTC timestamps with `triaged` null while
   `open`.
7. `check_unique_ids.sh` — report ids unique across open pull requests,
   the same three-view scan the other kinds get.
8. `check_state.sh` — the transitions a report may not make: a terminal
   report never returns to `open`, and never changes from one terminal
   value to another. A recurrence is a new report.

**The mirror**

9. `mirror_issues.sh` — a second kind alongside the first: the
   `writrun:report` filter, `[REPORT-NNNN]` titles, `status:proposed`
   before the creating pull request lands and `status:open` after, and
   the close on triage — completed for `tracked`, `authored` and
   `fixed`, not planned for `declined`. No `origin:` label is written.
10. `rederive_labels.sh` — the same projection, so a mirror that drifts
    is repaired for both kinds.

## Acceptance criteria (EARS)

- When `new.sh report` is run, the system shall write
  `work/reports/report-NNNN-<slug>.md` with every schema field present,
  `status: open`, `task_ref: []` and `triaged: null`.
- When `new.sh report` is run, the system shall mint the id above the
  directory, the git history and every open pull request, and shall
  never reuse one.
- When `new.sh task --from-report` is run, the system shall append the
  task's id to that report's `task_ref` and stamp its `triaged` date,
  without overwriting an existing entry.
- When a queue file carries a status outside the five report values,
  `check_front_matter.sh` shall fail and name the file.
- When a diff returns a terminal report to `open`, or changes it from
  one terminal value to another, `check_state.sh` shall fail.
- When a report is added by an open pull request, the mirror shall
  create an Issue labelled `writrun:report` and `status:proposed`,
  titled `[REPORT-NNNN] <title>`.
- When a report lands on the authority branch still `open`, the mirror
  shall label it `status:open`.
- When a report is triaged, the mirror shall close its Issue —
  completed for `tracked`, `authored` and `fixed`; not planned for
  `declined` — and shall leave no `status:` label on it.
- When a report already mirrored `status:proposed` is triaged by a later
  commit on the same open pull request, the mirror shall close it on the
  next synchronize, without waiting for the merge.
- When a report id appears in a pull request title, the machinery shall
  not read it as a carried task.

## Edge cases

- **Recorded and triaged in one change.** Recording rides any change, so
  a report may arrive already terminal. The mirror must create the Issue
  closed rather than opening one it immediately closes, and must not
  treat the missing `open` phase as drift to repair.
- **Triaged while still proposed.** A report recorded `open` in one
  commit and triaged in a later one *of the same open pull request* has
  a mirror already labelled `status:proposed`. The re-projection path
  cannot reach it: `project_pr_tasks.sh` learns its ids from the head
  branch name and the `[TASK-NNNN]` tags in the title, and a report has
  neither by design. `mirror_issues.sh` must therefore update an
  existing proposed report mirror from the diff on every synchronize,
  not only create missing ones — or the Issue keeps saying `open` about
  a report the branch already ended.
- **A pull request that closes unmerged.** A `status:proposed` report
  mirror retires with it, exactly as a task's does.
- **Several tasks from one report.** `task_ref` is a list because triage
  can split a finding; the mirror closes once, on the first terminal
  status, and does not reopen when a second task is appended.
- **A duplicate report.** It ends `tracked` against a task that already
  exists, and is kept — two people hitting the same thing is evidence,
  and nothing deletes queue files.
- **Below Stage 3.** The generator and the gates work with no forge at
  all; the mirror simply does not run, and the stage gate says so rather
  than failing.
- **A project with no `work/reports/`.** An adopter who never records
  one has no directory; every gate must read that as zero reports, never
  as an error.

## Tests required

- Generator: the canonical file; the refusals (`--origin` and
  `--priority` rejected, an unknown flag rejected); the id minted above
  a history that deleted one; `--from-report` appending without
  overwriting.
- Front matter: each of the five statuses accepted, a sixth named; a
  `task_ref` that is not a list named; `triaged` set while `open` named.
- State: the two forbidden report transitions, each named.
- Unique ids: two open pull requests claiming one report id.
- Doc shapes: the schema block passes as ```yaml once the prefix map
  knows `report-` and the example names a real file.
- Mirror: proposed → open → closed-completed; the `declined` route
  closing not planned; the born-terminal report; the proposed report
  triaged on a later commit of the same pull request; no `origin:` label
  on a report mirror.
- The existing suite stays green — the task and spec paths are untouched
  by every step above, and that is the evidence for it.

## Definition of Done

- [ ] `new.sh report` mints a canonical file; `--from-report` closes the
      link.
- [ ] All four gates recognise the kind, and the schema block in
      `technical/README.md` is ```yaml again, naming a real report.
- [ ] The mirror projects reports as `writrun:report`, and triage closes
      them with the right reason.
- [ ] No change to the task or spec schema, and the suite is green.

## Proposed product changes

- none — the rules landed with the authoring change; this diff implements
  them.

## Proposed technical changes

- `technical/README.md#report-schema` — the shown schema returns from
  ```text to ```yaml once `check_doc_shapes.sh` knows the third prefix
  and the example names a real report. This is the one permanent doc the
  implementation touches, and it is the debt the authoring change
  deliberately left.

## Outcome

_(fill after execution)_
