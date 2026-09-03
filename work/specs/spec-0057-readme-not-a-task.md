---
id: spec-0057
task_ref: task-0041
status: approved
created: 2026-09-03T04:06:56Z
---

# spec-0057 — The state check reads task files by id, never by directory

**References:** [task-0041](../tasks/task-0041-readme-not-a-task.md)

- **Goal:** `check_state.sh` judges the files that carry an id and no
  others, so the kit stops refusing its own scaffolding on the one
  change every adopter has to make first.

## Scope

In: the three `case` selectors in `check_state.sh` and the
`work/specs/*.md` filter in its second loop; the tests; the template
mirror, which `.writrun` being a mirrored directory makes part of the
same change.

**Selection reads the filename's id, not the file's contents.** The
shape is already fixed — `task-NNNN-<subject>.md` for a task, the id
agreeing with the filename for a spec
([schemas](../../docs/technical/schemas.md#front-matter-is-canonical)) —
so `work/tasks/task-*.md` is the documented rule spelled as a glob, and
needs no new statement to justify it.

Rejected: **excluding `README.md` by name.** It fixes the one file the
queue happens to hold today and leaves the next non-task file — a
`.gitkeep`, a folder note, anything an adopter adds — to break the same
way, with the same message naming something that was never a task.

Rejected: **skipping files with no front matter.** It would make a task
whose front matter got mangled pass silently, which turns a gate into a
coin flip precisely when it matters. Absent front matter on a file
claiming an id is a finding, not an exemption — and `check_front_matter`
is where it is already found.

Out: the same directory globs in `check_queue_impact.sh`,
`check_amendment_reference.sh`, `check_unique_ids.sh` and
`stamp_task_dates.sh`. They share the shape and none refused the
observed diff; a sweep of four more scripts on a defect none of them
demonstrated is a second change, and it should carry its own evidence.

Out: any rule change. Every rule `check_state.sh` applies stays exactly
as written — this is about which files reach them.

## Steps

1. `check_state.sh`: narrow the three selectors in the main loop to
   `work/tasks/task-*.md`, `work/specs/spec-*.md` and
   `work/reports/report-*.md`, and the second loop's filter to
   `work/specs/spec-*.md`.
2. Tests under `tests/unit/check_state/`.
3. `make template-sync` — `.writrun` is mirrored, so the kit copy moves
   with the original or the mirror test goes red.

## Acceptance criteria (EARS)

- When a diff adds `work/tasks/README.md`, the check shall pass it
  without reading it as a task.
- When a diff adds `work/specs/README.md` or `work/reports/README.md`,
  the check shall pass them the same way.
- When a diff adds a real task outside `backlog` or `blocked`, the check
  shall still refuse it — the rule is untouched.
- When a diff adds all three READMEs together, as a first adoption does,
  the check shall exit 0.

## Edge cases

- **A file named `task-notes.md`.** Selected, judged, and refused for
  having no status — it claims the id shape, so the check reading it is
  the contract working. Naming a non-task by the reserved prefix is the
  finding.
- **A task file renamed.** Out of reach: renaming a task is already
  forbidden, and the rename map the check keeps is unchanged by this.
- **An adopter whose queue lives elsewhere.** Unaffected — the paths
  were already literal; this narrows what matches inside them.

## Tests required

The three READMEs added, together and singly, passing; a real task added
as `in-progress` still refused; a real task added as `backlog` still
passing. The existing state cases keep covering every rule.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] `make tests` green, mirror test included.
- [ ] Rehearsed against `writrun-cli`'s adoption pull request, the diff
      that surfaced this — it goes green with no change on its side.

## Proposed product changes

- none — no rule changes. Which files a check reads is machinery, and
  the shape it now reads by is already stated in the schema.

## Proposed technical changes

- none — `schemas.md#front-matter-is-canonical` already fixes the
  filename shape this makes the check obey; restating it beside the
  check would be the second copy that disagrees later.

## Outcome

_(fill after execution)_
