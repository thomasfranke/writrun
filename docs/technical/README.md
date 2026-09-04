# Technical overview

**How the methodology is structured and distributed.** For whoever builds
tooling on top of it, or adopts it into a new project.

What the methodology *is* is [`about.md`](../about.md); what it *prescribes*
for an adopting project is [`product/`](../product/README.md). This file is
the **router**: the folder layout, a table naming which folder answers
which kind of task, and — below it — one stub per section that once lived
in a single file, so every link written before the splits keeps landing.
The map of how the pieces fit is [`architecture.md`](architecture.md); the
dated why behind each piece — and what was rejected — is
[`decisions/`](decisions/README.md), one numbered file per decision,
history split out so this reference stays a short read.

**Read the chapter your task needs, not the whole reference.** That is what
the split is for: a session that touches one subsystem pays for one chapter,
and each folder's README is the index that names it.

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

## Which folder answers which task

| You are about to | Read |
|---|---|
| Hold the whole machinery in one view | [`architecture.md`](architecture.md) |
| Write or read a task, spec or report file — any front matter at all | [`schemas/`](schemas/README.md) |
| Commit, push, open a pull request, or decide whether a task needs a spec | [`settings/`](settings/README.md) |
| Pick what to work on next, or resume something in flight | [`selection/`](selection/README.md) |
| Record something observed, or triage a report | [`reporting/`](reporting/README.md) |
| Work on the machinery — skills, scripts, workflows, the kit, a release | [`distribution/`](distribution/README.md) |
| Ask why a piece is the way it is | [`decisions/`](decisions/README.md) |

## The sections that moved

Everything below is a stub: the heading, and the one link to where it now
lives. They exist so no reference written before the splits — in a queue
file's `doc_ref`, an adopter's copy, a dated decision — ever stops
resolving. The five chapter files this folder held before it was
foldered ([`schemas.md`](schemas.md), [`settings.md`](settings.md),
[`selection.md`](selection.md), [`reporting.md`](reporting.md),
[`distribution.md`](distribution.md)) are stubs of the same shape.

## Task schema

Moved — see [`schemas/task.md#task-schema`](schemas/task.md#task-schema).

### `blocked` vs. `depends_on`

Moved — see [`schemas/task.md#blocked-vs-depends_on`](schemas/task.md#blocked-vs-depends_on).

## Spec schema

Moved — see [`schemas/spec.md#spec-schema`](schemas/spec.md#spec-schema).

## Report schema

Moved — see [`schemas/report.md#report-schema`](schemas/report.md#report-schema).

## Front matter is canonical

Moved — see [`schemas/front-matter.md#front-matter-is-canonical`](schemas/front-matter.md#front-matter-is-canonical).

## Settings

Moved — see [`settings/schema.md#settings`](settings/schema.md#settings).

### `stage`

Moved — see [`settings/stage.md#stage`](settings/stage.md#stage).

### `pr_title_style`

Moved — see [`settings/titles.md#pr_title_style`](settings/titles.md#pr_title_style).

### The conduct flags

Moved — see [`settings/conduct.md#the-conduct-flags`](settings/conduct.md#the-conduct-flags).

### `agent_coauthor`

Moved — see [`settings/conduct.md#agent_coauthor`](settings/conduct.md#agent_coauthor).

### The declarations

Moved — see [`settings/declarations.md#the-declarations`](settings/declarations.md#the-declarations).

### Observance is checked where it leaves a trace

Moved — see [`settings/observance.md#observance-is-checked-where-it-leaves-a-trace`](settings/observance.md#observance-is-checked-where-it-leaves-a-trace).

### The shape is a checked contract

Moved — see [`settings/schema.md#the-shape-is-a-checked-contract`](settings/schema.md#the-shape-is-a-checked-contract).

## Task selection algorithm

Moved — see [`selection/algorithm.md#task-selection-algorithm`](selection/algorithm.md#task-selection-algorithm).

## The report entry point

Moved — see [`reporting/entry-point.md#the-report-entry-point`](reporting/entry-point.md#the-report-entry-point).

## Distribution

Moved — see [`distribution/README.md`](distribution/README.md).

## Decisions

In [`decisions/`](decisions/README.md) — the dated why behind each piece
of machinery and what was rejected, append-only, one numbered file per
decision with the index carrying the chronology. This heading stays so
old links keep resolving; the entries live there.
