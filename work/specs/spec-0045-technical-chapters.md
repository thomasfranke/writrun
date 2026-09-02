---
id: spec-0045
task_ref: task-0034
status: draft
created: 2026-09-02T06:02:26Z
---

# spec-0045 — the technical README becomes a router over chapters

**References:** [task-0034](../tasks/task-0034-session-cost.md)

- **Goal:** an agent touching one subsystem reads that subsystem's
  chapter (~3–16KB), not the whole 57KB README — and no anchor anyone
  links today, relative or absolute, stops resolving.

## Scope

In scope: `docs/technical/README.md`; five new chapter files beside it;
every in-repo relative reference to a moved anchor (in `docs/` —
`docs/technical/decisions/` included — `AGENTS.md`, `README.md`,
`CONTRIBUTING.md`); `AGENTS.md`'s reading order, which currently names
the whole README before any queue touch; the script comments and
stderr messages that cite `docs/technical/README.md` as the schemas'
address — bare repo paths, not URLs, and anchorless, so no stub can
keep them true.

Out of scope: the content itself — sections move verbatim, and any
rewording beyond what re-linking requires is a separate change. Also
out: moving `docs/technical/decisions/` (the folder stays; only the
two decision files whose relative links reach moved anchors are
re-linked, declared below); `.writrun/conventions/`, whose references
are absolute GitHub URLs that the stub headings keep valid (the
`SKILL.md` copies are spec-0046's); `template/`'s own kit docs, which
also reference by absolute URL; `work/` — a queue file's `doc_ref` is
never rewritten under another task's change.

## Steps

1. Create the chapters, each taking its sections from the README
   verbatim:
   - `docs/technical/schemas.md` — Task schema, Spec schema, Report
     schema, Front matter is canonical.
   - `docs/technical/settings.md` — Settings and all its subsections
     (the keys, the conduct flags, observance, the shape contract).
   - `docs/technical/selection.md` — Task selection algorithm.
   - `docs/technical/reporting.md` — The report entry point.
   - `docs/technical/distribution.md` — Distribution.
2. Rebuild `README.md` as the router: the intro, Folder layout, a
   routing table (which chapter answers which kind of task), the
   Decisions section — and one stub per moved `##`/`###` heading:
   the heading text verbatim, body a single line linking the
   heading's new home as `<chapter>.md#<same-slug>` (the chapter
   keeps the heading verbatim, so the slug survives — and a reader
   or tool landing on the stub has exactly one link to follow).
   Anchors are generated from headings, so every existing link into
   the README keeps landing.
3. Rewrite the in-repo relative references to point at the chapters
   directly (readers land on content, not stubs): the `docs/product/`
   chapters, `docs/about.md`, `AGENTS.md`, `README.md`,
   `CONTRIBUTING.md`, and the two `docs/technical/decisions/` files
   that reach the README by `../../README.md#`. Cross-references
   between moved sections are rewritten among the chapters —
   including the README's own bare `#fragment` links whose two ends
   now live in different chapters; a chapter ships with no dead
   fragment.
4. Retarget the script comments and stderr lines that send a reader
   to `docs/technical/README.md` for the schemas
   (`check_front_matter.sh`, `check_deltas.sh`, `new.sh`) at
   `technical/schemas.md` — an anchored link survives on a stub, but
   "the schemas: docs/technical/README.md" becomes false the moment
   no schema remains there, and these strings print as the
   explanation of a refusal.
5. `AGENTS.md` step 3 names the chapters: schemas before touching
   `tasks/` or `specs/`, selection for picking work, settings before
   committing — the whole-README instruction goes.
6. Full suite; `make template-sync` (two of the retargeted scripts
   live in mirrored skills); `check_doc_shapes.sh` scans `docs/`
   recursively, so the shown schemas are found at their new address
   without changes to it.

## Acceptance criteria (EARS)

- When an agent needs one schema, the chapter holding it shall be
  self-contained — readable without opening the README or a sibling
  chapter.
- When any pre-split anchor into `technical/README.md` is followed,
  it shall land on a README stub naming the chapter, or on the chapter
  itself.
- When the change is done, all three spellings a reference into the
  README takes today shall hold: every `technical/README.md#` hit
  over `docs/`, `AGENTS.md`, `README.md` and `CONTRIBUTING.md`
  resolves to a heading still present in the README; every relative
  `README.md#` hit under `docs/technical/decisions/` resolves there
  or was rewritten to its chapter; and every bare `](#…)` link
  inside `docs/technical/*.md` resolves to a heading in its own
  file.
- When `check_doc_shapes.sh` and the full suite run, they shall pass
  without modification.

## Edge cases

- Anchors referenced only by absolute URL from shipped adopter copies
  (`.writrun/conventions/*.md`) — the stubs are the guarantee; those
  files are deliberately not rewritten here. Script comments get the
  opposite treatment (step 4): theirs are bare repo paths, and three
  cite the README *file* for the schemas with no anchor for a stub to
  keep true.
- `work/` doc_refs into the README — untouched here; they land on
  stubs, which keep resolving, and spec-0047's `brief.sh` follows a
  stub's single link to the chapter, so a briefed reader still gets
  content.
- Duplicate heading text across chapters after the move — none exists
  today; the move keeps it that way (each heading leaves exactly once).
- `docs/writrun-instructions.md` — exempt from every check; untouched.

## Tests required

None new — a docs move. The existing suite (doc shapes, settings,
template mirror) must stay green.

## Definition of Done

- [ ] Five chapters exist; README routes and stubs every moved anchor.
- [ ] In-repo relative references land on chapters; script messages
      name `schemas.md`.
- [ ] `AGENTS.md` reading order names chapters, not the whole file.
- [ ] Full suite green.

## Proposed product changes

- `product/concepts/task.md` — link targets only: moved anchors now
  point at their chapters.
- `product/stage-2-pull-requests/README.md` — link targets only.
- `product/stage-2-pull-requests/taking.md` — link targets only.

The other product docs (`product/README.md`,
`product/concepts/technical-doc.md`) and `about.md` link the bare
file, which stays correct — the README remains the router — so they
carry no edit and are deliberately not promised.

## Proposed technical changes

- `technical/README.md` — becomes the router with stub anchors.
- `technical/schemas.md` — new: the four schema sections, verbatim.
- `technical/settings.md` — new: the settings sections, verbatim.
- `technical/selection.md` — new: the selection algorithm, verbatim.
- `technical/reporting.md` — new: the report entry point, verbatim.
- `technical/distribution.md` — new: the distribution section, verbatim.
- `technical/decisions/tasks-and-specs/0008-ready-for-development-is.md`
  — link target only: `../../README.md#task-selection-algorithm`
  becomes the chapter's.
- `technical/decisions/tasks-and-specs/0064-a-report-is-an-artefact.md`
  — link target only: `../../README.md#the-report-entry-point`
  becomes the chapter's.

## Outcome

_(fill after execution)_
