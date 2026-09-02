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
every in-repo relative reference to a moved anchor (in `docs/`,
`AGENTS.md`, `README.md`, `CONTRIBUTING.md`); `AGENTS.md`'s reading
order, which currently names the whole README before any queue touch.

Out of scope: the content itself — sections move verbatim, and any
rewording beyond what re-linking requires is a separate change. Also
out: `docs/technical/decisions/` (stays where it is);
`.writrun/conventions/` and script comments, whose references are
absolute GitHub URLs that the stub headings keep valid (the
`SKILL.md` copies are spec-0046's); `template/`'s own kit docs, which
also reference by absolute URL.

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
   the heading text verbatim, body a single line linking the chapter.
   Anchors are generated from headings, so every existing link into
   the README keeps landing.
3. Rewrite the in-repo relative references to point at the chapters
   directly (readers land on content, not stubs): the `docs/product/`
   chapters, `docs/about.md`, `AGENTS.md`, `README.md`,
   `CONTRIBUTING.md`. Cross-references between moved sections are
   rewritten among the chapters.
4. `AGENTS.md` step 3 names the chapters: schemas before touching
   `tasks/` or `specs/`, selection for picking work, settings before
   committing — the whole-README instruction goes.
5. Full suite; `check_doc_shapes.sh` scans `docs/` recursively, so the
   shown schemas are found at their new address without changes to it.

## Acceptance criteria (EARS)

- When an agent needs one schema, the chapter holding it shall be
  self-contained — readable without opening the README or a sibling
  chapter.
- When any pre-split anchor into `technical/README.md` is followed,
  it shall land on a README stub naming the chapter, or on the chapter
  itself.
- When `grep -rn 'technical/README.md#'` runs over `docs/`,
  `AGENTS.md`, `README.md` and `CONTRIBUTING.md` after the change,
  every remaining hit shall resolve to a heading still present in the
  README.
- When `check_doc_shapes.sh` and the full suite run, they shall pass
  without modification.

## Edge cases

- Anchors referenced only by absolute URL from shipped adopter copies
  (`.writrun/conventions/*.md`, script comments) — the stubs are the
  guarantee; those files are deliberately not rewritten here.
- Duplicate heading text across chapters after the move — none exists
  today; the move keeps it that way (each heading leaves exactly once).
- `docs/writrun-instructions.md` — exempt from every check; untouched.

## Tests required

None new — a docs move. The existing suite (doc shapes, settings,
template mirror) must stay green.

## Definition of Done

- [ ] Five chapters exist; README routes and stubs every moved anchor.
- [ ] In-repo relative references land on chapters.
- [ ] `AGENTS.md` reading order names chapters, not the whole file.
- [ ] Full suite green.

## Proposed product changes

- `product/README.md` — link targets only: moved anchors now point at
  their chapters.
- `product/concepts/task.md` — link targets only.
- `product/concepts/technical-doc.md` — link targets only.
- `product/stage-2-pull-requests/README.md` — link targets only.
- `product/stage-2-pull-requests/taking.md` — link targets only.
- `about.md` — link targets only.

## Proposed technical changes

- `technical/README.md` — becomes the router with stub anchors.
- `technical/schemas.md` — new: the four schema sections, verbatim.
- `technical/settings.md` — new: the settings sections, verbatim.
- `technical/selection.md` — new: the selection algorithm, verbatim.
- `technical/reporting.md` — new: the report entry point, verbatim.
- `technical/distribution.md` — new: the distribution section, verbatim.

## Outcome

_(fill after execution)_
