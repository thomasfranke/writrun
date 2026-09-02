# Technical overview

**How the methodology is structured and distributed.** For whoever builds
tooling on top of it, or adopts it into a new project.

What the methodology *is* is [`about.md`](../about.md); what it *prescribes*
for an adopting project is [`product/`](../product/README.md). This file is
the **router**: the folder layout, a table naming which chapter answers
which kind of task, and — below it — one stub per section that now lives in
a chapter, so every link written into the old single file keeps landing. The
dated why behind each piece — and what was rejected — is
[`decisions/`](decisions/README.md), one numbered file per decision, history
split out so this reference stays a short read.

**Read the chapter your task needs, not the whole reference.** That is what
the split is for: a session that touches one subsystem pays for one chapter.

## Folder layout an adopting project ends up with

```
docs/
  about.md            # shared context — what the project is, precedes the fork
  product/            # business rules, chapter by chapter — stakeholder-facing
  technical/          # architecture, testing, subsystems — decisions per subsystem, or one file each
work/
  tasks/              # the queue — front-matter only, no technical detail
  specs/              # the detail of one change — EARS criteria, proposed doc deltas
  reports/            # what was observed — findings, and which way triage sent each
AGENTS.md             # entry point for AI agents, links into the above
.writrun/             # WritRun's home: skills, scripts, shipped templates, conventions
.github/workflows/    # only what the platform dictates lives here
```

One split is structural and mandatory: `docs/` is the permanent half,
written by and for people; `work/` is the machine-managed queue. The
machinery prescribes paths **only under `work/`** and treats everything
under `docs/` as permanent documentation — the input tasks are created
from. **Inside `docs/`, the tree above is this repo's own layout, not a
requirement**: an adopting project shapes `docs/` entirely to its
stakeholders' taste. The audience split (principle 2) remains a rule
about *files* — product intent and technical design never share one —
not about folder names.

## Which chapter answers which task

| You are about to | Read |
|---|---|
| Write or read a task, spec or report file — any front matter at all | [`schemas.md`](schemas.md) |
| Commit, push, open a pull request, or decide whether a task needs a spec | [`settings.md`](settings.md) |
| Pick what to work on next, or resume something in flight | [`selection.md`](selection.md) |
| Record something observed, or triage a report | [`reporting.md`](reporting.md) |
| Work on the machinery — skills, scripts, workflows, the kit, a release | [`distribution.md`](distribution.md) |
| Ask why a piece is the way it is | [`decisions/`](decisions/README.md) |

## The sections that moved

Everything below is a stub: the heading, and the one link to where it now
lives. They exist so no reference written before the split — in a queue
file's `doc_ref`, an adopter's copy, a dated decision — ever stops
resolving.

## Task schema

Moved — see [`schemas.md#task-schema`](schemas.md#task-schema).

### `blocked` vs. `depends_on`

Moved — see [`schemas.md#blocked-vs-depends_on`](schemas.md#blocked-vs-depends_on).

## Spec schema

Moved — see [`schemas.md#spec-schema`](schemas.md#spec-schema).

## Proposed product changes

Moved — see [`schemas.md#proposed-product-changes`](schemas.md#proposed-product-changes).

## Proposed technical changes

Moved — see [`schemas.md#proposed-technical-changes`](schemas.md#proposed-technical-changes).

## Outcome

Moved — see [`schemas.md#outcome`](schemas.md#outcome).

## Report schema

Moved — see [`schemas.md#report-schema`](schemas.md#report-schema).

## Front matter is canonical

Moved — see [`schemas.md#front-matter-is-canonical`](schemas.md#front-matter-is-canonical).

## Settings

Moved — see [`settings.md#settings`](settings.md#settings).

### `stage`

Moved — see [`settings.md#stage`](settings.md#stage).

### `pr_title_style`

Moved — see [`settings.md#pr_title_style`](settings.md#pr_title_style).

### The conduct flags

Moved — see [`settings.md#the-conduct-flags`](settings.md#the-conduct-flags).

### `agent_coauthor`

Moved — see [`settings.md#agent_coauthor`](settings.md#agent_coauthor).

### The declarations

Moved — see [`settings.md#the-declarations`](settings.md#the-declarations).

### Observance is checked where it leaves a trace

Moved — see [`settings.md#observance-is-checked-where-it-leaves-a-trace`](settings.md#observance-is-checked-where-it-leaves-a-trace).

### The shape is a checked contract

Moved — see [`settings.md#the-shape-is-a-checked-contract`](settings.md#the-shape-is-a-checked-contract).

## Task selection algorithm

Moved — see [`selection.md#task-selection-algorithm`](selection.md#task-selection-algorithm).

## The report entry point

Moved — see [`reporting.md#the-report-entry-point`](reporting.md#the-report-entry-point).

## Distribution

Moved — see [`distribution.md#distribution`](distribution.md#distribution).

## Decisions

In [`decisions/`](decisions/README.md) — the dated why behind each piece
of machinery and what was rejected, append-only, one numbered file per
decision with the index carrying the chronology. This heading stays so
old links keep resolving; the entries live there.

