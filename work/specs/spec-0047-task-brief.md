---
id: spec-0047
task_ref: task-0034
status: draft
created: 2026-09-02T06:02:28Z
---

# spec-0047 — brief.sh prints a task's whole brief in one call

**References:** [task-0034](../tasks/task-0034-session-cost.md)

- **Goal:** the whole brief of one task — the task file, every spec in
  its `spec_ref`, the section its `doc_ref` anchors — in one call and
  one output, replacing four to six whole-file reads with the ~section
  the selection algorithm's step 7 actually requires.

## Scope

In scope: `brief.sh` beside `list_tasks.sh` in
`.writrun/skills/writrun-select-next-task/`; one line in that skill
naming it as step 7's mechanical form; its contract in
`technical/selection.md`; unit tests; template sync.

Out of scope: any judgement — the doc-against-spec conflict check
stays the reader's; eligibility and cross-checks stay the lister's and
the gates'. `brief.sh` is a reader, no git, no network, no writes.

## Steps

1. `brief.sh <task-id>`: resolve `task-nnnn` (any spelling of the
   number) under `work/tasks/`; print a one-line header — id, status,
   priority, each spec's id and status — then the task file whole,
   then each `spec_ref` entry's file whole, then the `doc_ref`
   section, each part behind a `== <path> ==` divider.
2. `doc_ref` resolution: split `path#anchor`; the section runs from
   the heading whose GitHub-style slug equals the anchor to the next
   heading of the same or higher level. No anchor → the whole file.
   First match wins on a duplicate slug, and the divider says so.
3. Failure is loud and partial output is honest: task not found →
   exit 1; a `spec_ref` entry or the `doc_ref` anchor unresolvable →
   print what resolved, name what did not, exit 2.
4. Contract (arguments, output order, exit codes) documented in
   `technical/selection.md`; the select skill's step 7 names the
   script.
5. Unit tests; `make template-sync`.

## Acceptance criteria (EARS)

- When the task exists, `brief.sh` shall print header, task, every
  spec in `spec_ref` order, and the `doc_ref` section, in that order,
  and exit 0.
- When the task id does not resolve, it shall exit 1 naming what it
  looked for.
- When a spec or the anchor does not resolve, it shall print every
  part that did, name the missing one, and exit 2.
- When `spec_ref` is empty or `doc_ref` is null, it shall say so in
  the corresponding divider and exit 0 — an empty list is an answer,
  not an error.

## Edge cases

- `doc_ref` with an anchor whose heading contains punctuation — slug
  rule: lowercase, spaces to hyphens, punctuation stripped (the rule
  GitHub applies, which is what every `doc_ref` in the queue targets).
- A `doc_ref` into `technical/README.md` after spec-0045 — it lands on
  a stub; the stub's one line names the chapter, which the reader then
  briefs. Stale refs surface rather than silently truncating.
- A spec listed twice in `spec_ref` — printed once, noted.

## Tests required

Unit, `tests/unit/brief/`: the happy path (order and dividers), id
spellings (`34`, `task-0034`), exit 1, exit 2 with partial output,
empty `spec_ref`, null `doc_ref`, anchor-to-section extraction
including the next-same-level boundary.

## Definition of Done

- [ ] `brief.sh` with the contract above; skill and chapter name it.
- [ ] Unit green; template synced; full suite green.

## Proposed product changes

- none — machinery only

## Proposed technical changes

- `technical/selection.md` — the script's contract joins the chapter.

## Outcome

_(fill after execution)_
