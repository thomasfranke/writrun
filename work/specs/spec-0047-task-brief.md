---
id: spec-0047
task_ref: task-0034
status: implemented
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
2. `doc_ref` resolution: split `path#anchor`; the path is written
   relative to `docs/` (the schema's contract —
   `check_front_matter.sh` refuses a `docs/` prefix), so the file
   read is `docs/<path>`, never `<path>` from the repository root.
   The section runs from the heading whose slug equals the anchor to
   the next heading of the same or higher level. No anchor → the
   whole file. Slugs follow GitHub's actual rule — lowercase, spaces
   to hyphens, backticks dropped, punctuation stripped *except*
   hyphens and underscores, and duplicate heading text taking
   `-1`/`-2` suffixes in document order — so every anchor names
   exactly one heading.
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
- When the resolved section is a spec-0045 stub — its whole body the
  one line linking the heading's new home — it shall follow that
  link once and print the chapter section it names, the divider
  showing both hops.

## Edge cases

- `doc_ref` with an anchor whose heading carries punctuation —
  `#pr_title_style` keeps its underscores and `#blocked-vs-depends_on`
  keeps hyphens and underscore while dropping the dot: the slug rule
  above is GitHub's own, which is what every `doc_ref` already in the
  queue targets; a strip-everything rule would resolve neither.
- A `doc_ref` into `technical/README.md` after spec-0045 — the anchor
  lands on a stub whose whole body is the one line linking the
  heading's new home; `brief.sh` recognises that shape and follows
  the link once, briefing the chapter's section, so the reader gets
  content and never a brief that looks complete while holding one
  link. The queue's refs stay README-shaped deliberately — spec-0045
  rewrites `docs/`, not `work/`.
- A spec listed twice in `spec_ref` — printed once, noted.

## Tests required

Unit, `tests/unit/brief/`: the happy path (order and dividers), id
spellings (`34`, `task-0034`), exit 1, exit 2 with partial output,
empty `spec_ref`, null `doc_ref`, anchor-to-section extraction
including the next-same-level boundary, the `docs/`-relative base (a
`doc_ref` never carries the prefix), underscore-keeping slugs, a
duplicate heading's `-1` suffix, the stub follow.

## Definition of Done

- [ ] `brief.sh` with the contract above; skill and chapter name it.
- [ ] Unit green; template synced; full suite green.

## Proposed product changes

- none — machinery only

## Proposed technical changes

- `technical/selection.md` — the script's contract joins the chapter.

## Outcome

`brief.sh` ships beside `list_tasks.sh`. One header line (id, status,
priority, each spec's id and status), then the task file, each `spec_ref`
entry in list order, and the `doc_ref` section, every part behind a
`== <path> ==` divider. Ids resolve by number at any width. Sections run
from the matching heading to the next of the same or higher level, with
GitHub's own slug rule — underscores and hyphens kept, `-1`/`-2` on
duplicate heading text — and `docs/<path>` as the base, never the
repository root.

Exit 1 for a task that resolves to nothing, 2 for a partial brief with
every resolved part still printed and the missing ones named, 0 for an
empty `spec_ref` or a null `doc_ref`, which the divider states as
answers. A spec listed twice is printed once and the duplication noted.
A spec-0045 stub is followed once, the divider showing both hops; a stub
whose link resolves to nothing is a partial brief rather than a
complete-looking one.

Eleven cases in `tests/unit/brief/` cover the behaviours above. The
contract is in `technical/selection.md`, and the select skill names the
script as step 7's mechanical form.

Divergence, found in review: the section reader is fence-aware. The first
cut treated any `#` at column 0 as a heading, and the reference's
chapters are full of shell comments and schema examples that spell one —
`schemas.md#spec-schema` was truncated at its own fenced example, losing
a third of the section while still exiting 0 as a complete brief. Fenced
lines are now content: they print, they never end a section, and they
take no number from the duplicate-heading counter, which is also what
GitHub does with them.
