---
id: spec-0043
task_ref: task-0031
status: implemented
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

- [x] `new.sh report` mints a canonical file; `--from-report` closes the
      link.
- [x] All four gates recognise the kind, and the schema block in
      `technical/README.md` is ```yaml again, naming a real report.
- [x] The mirror projects reports as `writrun:report`, and triage closes
      them with the right reason.
- [x] No change to the task or spec schema, and the suite is green.

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

All ten steps shipped. The three parts really do ship together: the
generator writes a shape the gates hold, and the mirror reads the same
statuses the gates accept — each was checked against the other two rather
than against this document alone.

**What landed as written.** `new.sh report` with the shipped
`.writrun/templates/report.md` and both refusals; `new.sh task
--from-report`; the fourth directory and the report schema in
`check_front_matter.sh`; the third prefix in `check_unique_ids.sh` and
`check_doc_shapes.sh`; rule J in `check_state.sh`; the `writrun:report`
projection in `mirror_issues.sh` and `rederive_labels.sh`; the third kind
in `writrun-create-task-and-spec`'s SKILL.md. The schema block in
`technical/README.md` is ```yaml again and names
[`report-0001`](../reports/report-0001-conventions-scope.md), the first
one really recorded here — a finding from opening #93: a change about
`.writrun/conventions/` has no scope in the vocabulary that judges it,
and that vocabulary lives inside the same folder. Left `open`; triaging
it would be an authoring change, and this one is not.

### Divergences

- **`--from-report` writes three fields, not the two step 3 named.** A
  report still `open` becomes `tracked` in the same run. This is not
  scope added: step 6 requires `triaged` to be null while a report is
  `open`, so stamping the date without moving the status would produce a
  file this spec's own front-matter rule refuses. The two steps could
  not both be implemented as written.

- **`--from-report` states the origin, and refuses one that contradicts
  it.** The spec left `--origin` untouched, which would have allowed
  `--origin rule --from-report report-0001` — a task derived from a rule
  and born from a report at once. The flag now supplies `origin: report`
  and refuses any other value beside it. The required-flag rule is
  otherwise unchanged: an origin nobody stated still refuses.

- **`--from-report` refuses a report triage already ended.** Not named in
  the spec, and forced by the rule the same spec adds: step 8 makes
  terminal → terminal a `check_state.sh` failure, so a generator that
  wrote one would mint a change CI then rejects. A report already
  `tracked` still accepts a second task — that is the "several tasks from
  one report" edge case, and only that one.

- **`triaged` is paired with a terminal status both ways.** Step 6 named
  one direction ("null while `open`"). The reverse — a terminal report
  with no date — is refused too, following the shape
  `blocked`/`blocked_reason` already has: a judgement with no date is a
  judgement nothing can be ordered against, and ordering these strings is
  what every line-based reader here does with a timestamp.

- **The report directory is `check_front_matter.sh`'s fourth positional
  argument, and `check_doc_shapes.sh` passes a scratch one.** Not
  specified, and load-bearing: left to its default, the checker would
  walk the repository's real `work/reports/` while judging a block a
  chapter shows, and report a fault about a file that chapter has nothing
  to do with. A case asserts it.

- **The mirror reads `modified` report files, not only `added` ones.**
  The spec's "triaged while still proposed" edge case reasoned about a
  later commit on the same pull request — but the forge's file list is
  the *cumulative* diff against the base, so that report still arrives as
  `added`, carrying its final status. The case that genuinely needs
  `modified` is the one the spec did not name: a report already on the
  authority branch, triaged by a later pull request. Both are covered,
  and the id is read from the **filename** rather than the front matter,
  because an edit to a status line carries no `id:` in its patch. A patch
  that says nothing about the status leaves the mirror alone rather than
  guessing.

- **Step 10 needed wiring the spec did not name.** `rederive_labels.sh`
  projects a report, but nothing would have called it with one:
  `mirror_issues.sh` now emits `reports=` alongside `tasks=`, and
  `writrun-approve.yml` passes it. Without that the repair path existed
  and was unreachable — and for a report it is the *only* repair path,
  since no forge event corresponds to a triage.

- **`id_of_title` and `num_of_id` were generalized, not duplicated**, in
  both mirror scripts: the title is lowercased before the match instead
  of matched with a character class per letter, which is the same answer
  and legible. `check_front_matter.sh`'s `doc_ref` rule became one helper
  read by both kinds, for the same reason — a task and a report carry
  that field under the same contract.

- **Two `work/` READMEs were corrected.** `work/README.md` and
  `work/reports/README.md` both said the generator could not mint a
  report and told the reader to write one by hand. Neither is a permanent
  doc — `work/` is the ephemeral half, outside the delta check — but both
  were false the moment step 1 landed.

- **No `template/work/reports/`.** The kit ships no report directory, and
  that is the "a project with no `work/reports/`" edge case seen from the
  adopter's side: the generator creates it on the first run, and every
  gate reads its absence as zero reports. A case asserts all four.

### What this did not touch

The task and spec schemas, exactly as scoped: no field was added to
either, and `origin` still has its two values. `project_pr_tasks.sh` is
unchanged — a report has neither a `task/NNNN` branch nor a
`[TASK-NNNN]` tag, so it cannot reach one by design, and a case pins that
rather than trusting it.
