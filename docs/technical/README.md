# Technical overview

**How the methodology is structured and distributed.** For whoever builds
tooling on top of it, or adopts it into a new project.

What the methodology *is* is [`about.md`](../about.md); what it *prescribes*
for an adopting project is [`product/`](../product/README.md). This file
covers the mechanics: folder layout, file schemas, the selection algorithm,
and how a project pulls the methodology in. The dated why behind each
piece — and what was rejected — is [`decisions/`](decisions/README.md),
one numbered file per decision, history split out so this reference stays
a short read.

## Folder layout an adopting project ends up with

```
docs/
  about.md            # shared context — what the project is, precedes the fork
  product/            # business rules, chapter by chapter — stakeholder-facing
  technical/          # architecture, testing, subsystems — decisions per subsystem, or one file each
work/
  tasks/              # the queue — front-matter only, no technical detail
  specs/              # the detail of one change — EARS criteria, proposed doc deltas
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

## Task schema

```yaml
---
id: task-0005                      # immutable identity, never an ordering
status: pending                    # pending | in-progress | blocked | completed
blocked_reason: null               # required non-null when status: blocked; null otherwise
spec_ref: [spec-0004]              # list — zero, one, or many specs
doc_ref: product/concepts/task.md#two-invariants   # any path under docs/; null only when the task originates in code or machinery, not in a doc
priority: medium                   # high | medium | low
depends_on: [task-0002]            # real technical blocking, not sequencing taste
milestone: v0.1-core
created: 2026-08-21T09:14:00Z      # by hand: when the task was drafted
queued: 2026-08-21T11:02:37Z       # machinery only: the merge that put it in the queue
completed: null                    # by hand: when the work was finished
merged: null                       # machinery only: the merge that took the work
---
```

- `id` is identity, never order. A task file is named
  `task-NNNN-<subject>.md` — the id plus an extremely short subject slug
  (`task-0005-multi-file-search.md`), so a directory listing reads as a
  queue summary. The slug is fixed at creation: reprioritising or
  retitling never renames a file, and identity lives in the id alone.
  **Whoever creates the file chooses those words**, because "which task
  is this, among these" is a judgement about the queue rather than a
  string operation on the title; a generator derives them only when
  nobody chose.
- **An id is unique across the queue *and* across every open pull
  request.** Minting the next one from the branch you are on is not
  enough: two branches that start from the same `main` both see the same
  highest id and both claim the next, and neither can tell until one
  merges. So the queue is the union of what the authority branch holds
  and what open pull requests propose — anything else is a claim on a
  number somebody else may already have taken.

  A number claimed by a branch that has not merged is **not yet an id**,
  and renumbering it costs nothing: identity begins at the merge that
  puts the file on the authority branch. "An id is never renumbered"
  binds from there, not from the moment a generator printed one.
- `spec_ref` is a list because the relationship is 0..N: a task can ship
  without a spec (trivial-but-tracked work) or span several (sequential phases,
  or parallel concerns of the same task). An empty list is valid and explicit
  — never omit the field to mean the same thing.
- The task precedes its specs. A spec is created for an existing task, never
  the other way around — an orphan spec is a structural error.
- `doc_ref` and any path inside `spec_ref`/`depends_on` point at a section
  anchor, resolved relative to `docs/`, never just a filename — this is what
  makes reverse traceability a grep, not a manual search.
- Status lives in front-matter, never in folder position — nothing moves
  between directories as work progresses, so `git log` stays readable without
  `--follow`.
- **Four dates, and who writes each is part of the contract** — the table
  is in [`product/tasks-and-specs/statuses.md`](../product/tasks-and-specs/statuses.md).
  `created` and `completed` are a person's, written on the branch;
  `queued` and `merged` are the machinery's, written after the merge each
  records. A date recording a merge is never hand-written: it would have
  to be typed before the event it describes.
- **Every date is a UTC timestamp, and always spelled with `Z`** —
  `2026-08-21T09:14:00Z`, never a local time and never an offset like
  `+02:00`. Two reasons, and both are about the line-based readers this
  schema exists for. A bare date cannot order two entries made the same
  day, which is most of them in an active queue. And with `Z` as the only
  spelling, sorting these strings lexicographically *is* sorting them
  chronologically — an offset form would break that silently, giving a
  `sort` that looks right and is wrong for exactly the entries that
  crossed a timezone.

### `blocked` vs. `depends_on`

Two different kinds of "can't start", kept structurally apart:

- **`depends_on`** — blocked *by another task in this queue*. Resolves itself:
  the selection algorithm skips the task until every dependency is
  `completed`. Machine-checkable, no human judgement needed.
- **`status: blocked`** — blocked *by something outside the queue*: an
  unanswered decision, an upstream release, a spike whose result could
  invalidate the plan. Requires a non-null `blocked_reason` stating what
  unblocks it. Only a human (or an agent explicitly told the blocker is gone)
  moves it back to `pending`.

A task never uses `blocked` for something `depends_on` can express — if the
blocker is a task, it's a dependency.

## Spec schema

```yaml
---
id: spec-0004
task_ref: task-0005                # a spec belongs to exactly one task
status: draft                      # draft | approved | implemented
created: 2026-08-20T16:02:00Z
---
```

A spec file is named `spec-NNNN-<subject>.md`, the same shape as a
task's — four-digit id plus an extremely short subject slug, fixed at
creation.

The `draft → approved` transition is a gate, and **who operates it is an
adopter decision, declared in `AGENTS.md`** — this methodology's own
`AGENTS.md` requires a human. An agent never self-approves a spec unless the
adopting project has explicitly written that policy down. `approved →
implemented` is mechanical: it happens when the task completes and the
Outcome section is filled.

A spec's body carries what a task's front-matter must not: scope, steps, EARS
acceptance criteria, edge cases, tests required, Definition of Done, and two
sections that close the loop between ephemeral and permanent docs:

```markdown
## Proposed product changes
- `product/coverage/ignore-patterns.md#pattern-with-no-match` — new rule: a
  pattern matching nothing warns and exits 0.
(or: "none — no behaviour change")

## Proposed technical changes
- `technical/engine/adapter.md` — document the new extension point.
- `technical/engine/decisions.md` — new dated entry: why warning over error.
(or: "none — no machinery change")

## Outcome
(filled when the task completes: what was actually built, anything that
diverged from the plan above, and why)
```

The **Proposed changes** sections are what a completed task is checked
against before merge — every listed path+anchor should appear touched in the
diff, and the diff shouldn't quietly touch a permanent doc that wasn't listed.
This turns "update the docs in the same PR" from a prose reminder into
something a script or a reviewing agent can verify mechanically.

## Front matter is canonical

The front matter above is a fixed shape, not general YAML. Every reader
in the machinery is line-based on purpose — plain `bash`/`awk`/`sed`, no
YAML parser, no runtime dependency — and YAML permits the same meaning
in forms a line-based reader cannot see: a block list under `spec_ref:`
reads as an empty list, a quoted value never matches a path comparison,
a folded scalar reads as nothing. Silently, in every case.

So the canonical form is a checked contract, not an assumption: one
field per line as `key: value`, values bare (no quotes, no `>`/`|`
block scalars), every schema field present exactly once even when
`null`, lists inline (`[]` or `[spec-0001, spec-0002]`), `id` agreeing
with the filename — exactly for a spec, as the `task-NNNN` prefix of
`task-NNNN-<subject>.md` for a task — statuses and priority drawn only from their
documented vocabularies, `blocked`/`blocked_reason` paired both ways,
every date an RFC 3339 UTC timestamp
(`2026-08-21T09:14:00Z`), and `doc_ref` written relative to `docs/`.
Unknown keys in canonical shape are allowed — an adopter may extend the
schema, not reshape it. Extensions enter through the project template's
own front-matter block: `new.sh` appends those fields to the generated
contract block, refuses a template that redefines a contract field or
writes a non-canonical line, and the agent fills their values the same
way it fills the body — the template's placeholder text is the
project's instruction for what belongs in each
(`writrun-create-task-and-spec`'s SKILL.md says so explicitly).

`.writrun/skills/writrun-check-front-matter/check_front_matter.sh` enforces all of it —
`writrun check` runs it before the lifecycle rules, so a file the
line-based readers would misread never merges — and `new.sh` only ever
generates this form, so the contract costs nothing on the happy path.

## Task selection algorithm

Deterministic, independent of file layout on disk:

0. **Resume before selecting.** If any task has `status: in-progress` with no
   active owner (for a single-agent setup: not owned by this session), resume
   it — do not pick new work while started work sits unfinished. Only when no
   resumable task exists does selection proceed.
1. Read the front-matter of every task.
2. Keep those with `status: pending` — `blocked` is excluded here by
   construction, with no extra rule needed.
3. Keep those whose every `depends_on` entry has `status: completed`.
4. Keep those whose every `spec_ref` entry has `status: approved` or
   `implemented`. A task with a spec still in `draft` is not authorized
   work: the approval gate has not been passed, so selecting it would hand
   an agent a brief nobody assented to. A task with an empty `spec_ref`
   passes this step by construction.
5. Sort by `priority` — `high`, then `medium`, then `low`.
6. Break ties by `created` ascending, then by `id` ascending.
7. Take the first. Read every entry in `spec_ref` (if any) and `doc_ref`
   (if set) before writing any code.

Steps 2 and 4 are what "ready for development" means, and it is derived, never
stored: a task is ready when it is `pending` and every spec it references is
`approved`. No status records it, because a status that duplicates a derivable
fact is a status that will eventually disagree with it.

**Steps 2–4 are eligibility; steps 5–6 are only order**, and the two bind
differently. The filters bind everyone: a task that is `blocked`,
dependency-gated, or whose spec is still `draft` is unavailable to anybody,
and no judgement overrides that — those are the gates, expressed as a
query. The sort binds agents only. It exists so repeated sessions reach the
same answer instead of each re-deriving one, not to claim the
highest-priority task is the only legitimate one. **A human may take any
eligible task, out of order, and bypasses nothing by doing so.** An agent
may not, because determinism is the whole property the sort provides.

Step 7 has to branch on an empty `spec_ref`: with no spec, the task's own body
plus `doc_ref` is the whole brief, and whether that's sufficient — or
whether the agent should stop and ask for a spec first — is a call this
methodology leaves to the adopting project, stated explicitly in its
`AGENTS.md`.

## Distribution

The operational half of the methodology — selecting the next task, drafting a
task or spec, checking a spec's promised deltas against a diff — ships as
**skills**: copied files, no binary, no install step. A CLI exists as a
separate, optional client (`writrun-cli`, below); the methodology itself
never depends on it. Three reasons the skills are the mandatory form:

- **The agent already writes the files.** An agent with file tools and
  `AGENTS.md` in context can create a correctly-shaped task or spec directly —
  a CLI subcommand that also writes the file duplicates work the agent
  already does natively.
- **No language lock-in.** Skills are markdown instructions, all five of them
  backed by a small deterministic script for the one step each that must
  not be self-graded or hand-derived from memory — see below. This keeps
  the methodology's own non-goal — "not tied to one language, framework, or
  agent platform" — true of its tooling, not just its docs.
- **Distribution is already solved.** Skills install through the same
  mechanism adopters already use for other reusable instructions — no
  install script, no binary to build per platform.

The five skills, in `.writrun/skills/` — WritRun's own home, never the
project's skill folder; see
[Adoption's skills-namespacing note](../product/adoption.md#skills-namespacing)
for how the two sets stay apart by path and by prefix:

- **`writrun-select-next-task`** — runs the [selection algorithm](#task-selection-algorithm)
  exactly as specified, so every agent session gets the same answer instead of
  each one re-deriving it from the prose.
- **`writrun-create-task-and-spec`** — turns `AGENTS.md`'s prose instructions on task
  and spec creation into an active, checklist-driven skill: what front-matter
  to fill, when a spec is warranted, how to fill the Proposed changes
  sections. Backed by `new.sh`, which scaffolds a schema-correct
  `task-nnn.md` / `spec-nnn.md` — id increment, list-typed fields, every
  field present — mechanically rather than from an agent's memory of the
  schema (see [Task's worked example](../product/concepts/task.md#example)
  for the drift this replaces).
- **`writrun-check-spec-deltas`** — verifying that a completed diff touches
  everything a spec's Proposed changes section promised, and nothing
  permanent it didn't, is objective, mechanical checking. An agent grading
  its own diff is the wrong shape for that — the skill wraps a small
  deterministic script (grep/diff based, no runtime dependency) instead of
  asking the agent to self-attest.
- **`writrun-check-task-state`** — the same argument applied to status rather than
  paths. The transition it exists to reject is `draft → approved`, which an
  agent may never make, including on a spec it wrote itself; asking that
  agent whether it respected the gate is asking the wrong party. Backed by
  `check_state.sh`, which also rejects the two ways of routing around the
  gate: `draft → implemented`, and completing a task whose spec is not
  `implemented`.
- **`writrun-check-front-matter`** — every reader above is line-based on
  purpose, and YAML permits shapes those readers silently misread: a block
  list that reads as empty, a quoted value that never matches a path
  comparison. So the canonical form of
  [Front matter is canonical](#front-matter-is-canonical) is a checked
  contract, not an assumption — `check_front_matter.sh` validates every
  queue file against it, on files alone, no git and no forge, which makes
  it the one check available at every adoption level.

The whole adoption kit ships as [`template/`](../../template), one folder
**shaped exactly like the destination root** — that is what a template
is: `.writrun/`, the four `writrun-*.yml` workflows, `work/`, the
skeletons for `AGENTS.md` and `docs/`, and the guide itself as
`WRITRUN.md` — a name that collides with nothing and stays behind as a
provenance pointer after adoption. Two of the four workflows are
severable: `writrun-issues.yml` and `writrun-progress.yml` are the
Issues mirror — a projection, never the authority — and an adopter that
wants no GitHub Issues deletes exactly those two; `check` and `approve`
stand alone, and nothing else reads the mirror. It names the kit's two collision
points — an existing `AGENTS.md` is grafted, never overwritten; existing
docs are kept — while everything else the copy lands is
WritRun-namespaced. The kit deliberately ships **no README.md**: the one
file whose blind copy would replace the adopting project's own. The mirrored parts are a
**deliberate full copy**, kept byte-identical to this repository's own
root files by a unit test (`make template-sync` refreshes; the mirror
list is `tests/template_mirrors.txt`, the single source of what ships).
This repository's own CI beyond the writrun workflows — the pull-request
suite in `.github/workflows/tests.yml` and the release-readiness
pipeline on `main`, `.github/workflows/release-readiness.yml` — is not
part of the kit and stays home.

**Skills are the plumbing; a CLI is welcome porcelain — in its own repo.**
Nothing above forbids a human-facing command line (`writ list`,
`writ init`, `writ doctor` — the binary is `writ`, per About); it forbids
the methodology *depending* on one. A CLI lives in a separate repository (`writrun-cli`), wraps the
same scripts and files, and everything here keeps working without it —
agents use skills, CI uses scripts, files stay the authority. What tooling
like that builds on is this file's **public contract**: the task and spec
front-matter schemas, the `docs/` + `work/` split, each script's arguments
and exit codes, and the handful of grep-level markers the machinery reads
— the `## Derived work` heading in a PR body, the two Proposed-changes
headings in a spec, a task file's `# ` title line, a `task-nnn` /
`spec-nnn` id at the start of a branch name, and the labels the machinery
owns and filters on: `writrun:task` and the four `status:*` values
(`pending`, `ready`, `in-review`, `in-progress`) — renaming any of these
means adapting the workflows. One carve-out runs the other way:
`docs/writrun-instructions.md` is process metadata, not project truth —
no task derives from it and every check ignores it. **Everything else about
commits, pull requests, and task/spec style is the adopter's convention,
not the methodology's**, and it lives in one editable folder at the
repository root — `.writrun/conventions/`: commit types and scopes, branch naming,
the PR title rule, the merge policy, task and spec taste. The one commit
the machinery makes has its title as a variable at the top of
`writrun-approve.yml`, and the PR template ships as an editable default
alongside. Versions are tags on `main`
(the first: `v0.0.01`, and the third field stays two digits) — everything merges to `main` continuously, and a
version exists when its tag does. The number measures this contract, not
the code, and it is computed, never typed: `make release` cuts one, with a
vocabulary that is deliberately WritRun's own rather than SemVer's —
`minor` bumps the third digit (the default), `major` the middle one,
`epoch` the first, reserved for historic milestones. The target derives
the next number from the latest tag, stamps it into `.writrun/VERSION` —
the kit carries the stamp, so an adopter, and the future `writ update`,
knows which tag a copy came from — syncs the template, runs the suite,
and only then commits, tags, pushes, and publishes the GitHub Release
with notes generated from the conventional commits. While the methodology
is alpha (0.x), the contract itself moves without notice; a client or an
adopter pins the tag it targets.

## Decisions

In [`decisions/`](decisions/README.md) — the dated why behind each piece
of machinery and what was rejected, append-only, one numbered file per
decision with the index carrying the chronology. This heading stays so
old links keep resolving; the entries live there.

