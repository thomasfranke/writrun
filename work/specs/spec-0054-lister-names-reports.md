---
id: spec-0054
task_ref: task-0038
status: implemented
created: 2026-09-02T19:43:45Z
---

# spec-0054 — The lister names what is waiting to be triaged

**References:** [task-0038](../tasks/task-0038-lister-names-reports.md)

- **Goal:** `list_tasks.sh` names every report still `open`, so the ask
  that `open` makes reaches the reader most likely to act on it — and
  names it in a way that can never be mistaken for work, because a
  report is not work.

## Scope

In: `list_tasks.sh`, one new printed section; its cases; the template
mirror; the two chapters that own the rules the section rests on; and
`writrun-select-next-task`'s SKILL.md, which today says the script
"prints up to four sections" and enumerates four — a count this change
makes wrong, and the file the Definition of Done holds to what the
script prints.

Out: the selection algorithm, which reads `work/tasks/` and keeps
reading only that. Out: `brief.sh`. Out: any change to the Stage 3
mirror, which already carries the ask to the forge and is not being
replaced — a second channel is being added beside it.

**The boundary is the deliverable, not the section.** Printing a list is
trivial; what earns a spec is holding the line that `work/reports/`
never becomes a second queue. Two properties do that, and each is an
acceptance criterion with a case of its own:

- An open report never enters the ordering, so it is never handed over
  as the thing to take.
- An open report never changes the exit code. 0 still means a task is
  available, 1 still means none is. Every caller that branches on the
  status would otherwise start seeing work that is not work.

**A section without a move is a section nobody acts on.** Every existing
section in the skill names one — resume it, take the first, name it and
do not take it over, treat it as a gate. This one names triage: an open
report is read and given an end (`tracked`, `authored`, `fixed`,
`declined`) by whoever is looking, and where that end is `tracked` the
route is a reporting change of its own. Naming without the move is how
the reported scenario reproduces itself — a session with nothing
available reads the list, has nothing to do with it, and stops.

## Steps

1. Read the reports directory for files whose `status` is `open`,
   guarded the way the task loop guards its own glob — a project that
   never recorded one has no such directory, and that is zero reports,
   not an error (`report_file`'s own fixture comment keeps this
   honest). It is a third positional, `${3:-work/reports}`, beside the
   two the script already takes: a caller pointing the script at a tree
   of its own would otherwise read tasks there and reports from `$PWD`,
   which is the shape `check_front_matter.sh`'s caller rule exists to
   stop ("takes all four directories or none",
   `technical/distribution.md#running-the-checks`).
2. Print them as their own labelled section, after `Held back` and
   before the completeness notes, in the `id  title` shape the other
   sections use. Skip `README.md` as the task loop does.
3. Leave the final `[ -n "$available" ]` untouched — the exit code is
   the contract this must not move.
4. `technical/selection.md` gains the rule; `product/concepts/report.md`
   stops saying the below-Stage-3 job is the adopter's `grep`, because
   it no longer is.
5. The skill's section list gains the fifth entry, with the move it
   asks for, and its count line is corrected.
6. `make template-sync`; cases.

## Acceptance criteria (EARS)

- When any report has `status: open`, the lister shall print a section
  naming each one by id and title.
- When every task is done or ineligible and open reports exist, the
  lister shall still exit 1 and still print `Nothing is available.`
- When a task is available and an open report exists, the lister shall
  exit 0 and print both sections.
- When a report has been triaged to `tracked`, `authored`, `fixed` or
  `declined`, the lister shall not name it.
- When no report is `open`, or `work/reports/` does not exist, the
  lister shall print no such section and shall not fail.
- When an open report is present, it shall never appear in the
  `Available` section.
- When a caller names the task and spec directories, it shall be able to
  name the reports directory too, and a run given none shall read
  `work/reports` as it does today.
- When the section prints, the skill shall name it in its section list,
  with the move it asks for, and shall state a count matching what the
  script prints.

## Edge cases

- **No `work/reports/` at all.** An adopter who never recorded one.
  Zero reports, silently.
- **Reports exist but none is `open`.** No section. A line reporting
  that nothing is waiting is billed to every run to serve none.
- **`work/reports/README.md`.** Skipped by name, as the task loop skips
  its own.
- **Many open reports.** The section grows with them, which is the
  intended pressure: a long list is the queue asking to be triaged, not
  a display problem to solve by truncating.
- **A report whose file has no `# ` title.** It is still named by id;
  the id is identity and the title is convenience.
- **A caller naming the task and spec directories but not the third.**
  Reports come from `work/reports` under the working directory, which is
  the default and not a silent mismatch — the existing cases `cd` into
  their fixture root and pass no arguments at all, so the default is what
  they exercise.

## Tests required

Under `tests/unit/list_tasks/`, one file per behaviour, mirroring the
existing cases: an open report named beside an empty queue *with exit 1
preserved*; an open report never in `Available` and never moving the
exit code off 0 when real work exists; a triaged report of each of the
four ends named nowhere; a project with no reports directory listing
normally; and a run given all three directories explicitly, naming the
reports under the one it was handed. The existing cases in that directory must stay green — the
section is additive and moves nothing they assert.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a case.
- [ ] The final `[ -n "$available" ]` is byte-identical to today's.
- [ ] The skill's section list matches what the script prints — the
      count included — and each entry names its move, staying
      run-and-interpret: the rules linked, not restated
      (`product/concepts/skill.md`).
- [ ] Template synced; suite green.

## Proposed product changes

- `product/concepts/report.md#the-mirror-shows-what-is-waiting` — the
  mirror is one channel and not the only one: the lister names every
  open report at every stage, and naming is not selecting. Replaces the
  sentence leaving the below-Stage-3 job to the adopter's `grep`.

## Proposed technical changes

- `technical/selection.md` — new section: an open report is named, never
  selected. States the two properties that hold the line (out of the
  ordering, out of the exit code) and why the section exists at all.

## Outcome

`list_tasks.sh` prints a fifth section, `Open reports — waiting to be
triaged, never selected`, after `Held back` and before the completeness
notes. It reads a third positional, `${3:-work/reports}`, guarded the way
the task loop guards its own glob and skipping `README.md` by name.

The two properties that hold the line are structural rather than
asserted: the section is built from its own accumulator and never
touches `available`, so it enters no ordering, and the final
`[ -n "$available" ]` is byte-identical to today's, so it moves no exit
code. Both have cases anyway — an open report beside an empty queue
still exits 1, and beside real work still exits 0.

Five case files, seventeen assertions, including the four triage ends
named nowhere and a run given all three directories explicitly.

The skill's section list says five and names the move: **triage it**,
with which end produces work and which do not. `technical/selection.md`
gains the rule and its reasoning; `product/concepts/report.md` no longer
leaves the below-Stage-3 job to the adopter's `grep`.

**No divergence.** The selection algorithm still reads `work/tasks/` and
only that, `brief.sh` is untouched, and the Stage 3 mirror is unchanged —
a second channel was added beside it, not a replacement.
