---
id: spec-0054
task_ref: task-0038
status: draft
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
mirror; the two chapters that own the rules the section rests on.

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

## Steps

1. Read `work/reports/` for files whose `status` is `open`, guarded the
   way the task loop guards its own glob — a project that never
   recorded one has no such directory, and that is zero reports, not an
   error (`report_file`'s own fixture comment keeps this honest).
2. Print them as their own labelled section, after `Held back` and
   before the completeness notes, in the `id  title` shape the other
   sections use. Skip `README.md` as the task loop does.
3. Leave the final `[ -n "$available" ]` untouched — the exit code is
   the contract this must not move.
4. `technical/selection.md` gains the rule; `product/concepts/report.md`
   stops saying the below-Stage-3 job is the adopter's `grep`, because
   it no longer is.
5. `make template-sync`; cases.

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

## Tests required

Under `tests/unit/list_tasks/`, one file per behaviour, mirroring the
existing cases: an open report named beside an empty queue *with exit 1
preserved*; an open report never in `Available` and never moving the
exit code off 0 when real work exists; a triaged report of each of the
four ends named nowhere; a project with no reports directory listing
normally. The existing cases in that directory must stay green — the
section is additive and moves nothing they assert.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a case.
- [ ] The final `[ -n "$available" ]` is byte-identical to today's.
- [ ] The skill's section list matches what the script prints, and
      stays run-and-interpret — the rules linked, not restated
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

_(fill after execution)_
