# Adoption

What a project must have, at minimum, to claim it follows WritRun — and
where a project is free to shape that structure differently without it
counting as non-compliance.

## Three levels

Adoption is progressive. Each level adds to the one before it, and a project
declares which it is at in
[`settings.json`](../../.writrun/conventions/settings.json).

| Level | Adds | Needs |
|---|---|---|
| `tasks-and-specs` | the docs and the queue, as markdown | nothing but files |
| `pull-requests` | branches, pull requests, the CI checks, merge as assent | a forge |
| `github-issues` | the Issues mirror | Issues |

Ordered and cumulative, which is why the setting is one value and not three
switches: `github-issues` without `pull-requests` would ask for a projection
that pull-request events drive, with no pull requests to drive it.

Each level's rules live in the folder of its name —
[`pipeline.md`](pipeline.md) is true at every level; what the other two
add is marked there.

## Level `tasks-and-specs` — the minimum bar

**This level is a complete adoption**, not a partial one. The audience
split, the queue, the schemas and the four gates are all satisfiable with
files alone; what the higher levels add is *mechanical enforcement* of
things a person otherwise does deliberately.

All of the following, or the project is *adopting*, not *adopted*:

- **An About file** — shared context, stays short, never restates product
  or technical detail.
- **A product doc** — at least one real, checkable chapter reflecting
  actual behaviour. An empty `product/` with a table of planned chapters is
  pre-adoption, not adoption; a project may say so honestly rather than
  claim a status it hasn't reached.
- **A technical doc** — at least the machinery the product doc's rules
  depend on to be verifiable.
- **A task queue and a spec folder, structurally separate from the
  permanent docs** — the `docs/` / `work/` split — even if empty. The
  separation is what matters; an empty `work/tasks/` with the right schema
  and selection algorithm documented is adoption, an empty `work/tasks/`
  with no schema at all is not.
- **The four human gates**, named somewhere in the project's own
  `AGENTS.md`: who approves a doc change, who declares an authored rule
  finished, who approves a spec, and what an agent does when a task's
  brief is insufficient. Naming an agent as the operator of a gate is a
  valid answer — leaving the gate unnamed is not.

A project missing any one of these is not yet an adopter, regardless of how
much of the spirit it otherwise follows. [TOM](#worked-example-tom) is the
concrete case: strong `about.md`-equivalent, strong technical layer, real
per-feature product rules — and no task/spec pipeline at all. That gap
alone is what keeps it from claiming adoption today.

## Level `pull-requests`

Adds branches, pull requests and the CI checks — and with them, a merge
that can carry assent. Nothing here is required to claim adoption; what it
buys is that the rules above stop depending on anybody remembering them.

The four gates do not change, only who executes them: below this level a
person performs each directly, at it the machinery records what the person
decided. Its rules are in [`pipeline.md`](pipeline.md#flow-2--approval).

## Level `github-issues`

Adds the mirror: the queue projected into Issues, one direction only, for
people who read it in a browser. The files stay the authority at every
level, so a project that never turns this on loses no guarantee — only a
window. Its rules are in [`pipeline.md`](pipeline.md#flows-and-statuses).

## Mandatory core vs. documented variant

Two different kinds of divergence from what this methodology describes, and
they are not judged the same way:

- **Core, non-negotiable**: the audience split is structural (product/
  technical are separate files, never sections of one document); the
  permanent/ephemeral split is structural (tasks/specs never mixed into
  product/technical); a task holds no technical detail; a spec's
  Proposed-changes sections name every permanent doc a completed change
  will touch; an id is identity, never order; the four human gates exist
  and are named. A project that drops any of these isn't a variant of
  WritRun — it no longer follows it.
- **Variant, if written down**: everything WritRun leaves explicitly open
  — [decisions-log organization](concepts/technical-doc.md#where-decisions-live)
  (per-subsystem or one chronological log), whether a chapter in `product/`
  is organized by concept or by feature, id prefixes, whether a spec is
  mandatory for every task or only for the ones [Task](concepts/task.md)'s
  own guidance flags. A project is free to choose either side of any of
  these — the requirement is that the choice is **stated, not left to be
  reverse-engineered from the file tree**.

  **Where it is stated is
  [`settings.json`](../../.writrun/conventions/settings.json).** "Somewhere a
  reader would look" was honest about the obligation and vague about the
  address. One known path ends the hunt, and the machinery reads the same
  statement the reader does — so a choice cannot be declared in one place and
  contradicted by what the tooling does.

  Two limits. It carries **only what this section leaves open** — a key
  switching off something from the core list is refused, not discouraged. And
  it holds **values, never reasoning**: why a project chose a side stays in
  its prose.

## Worked example: TOM

Two real divergences, judged differently:

- **A global, numbered ADR log** (`docs/decisions/001-*.md` …) instead of
  one `decisions.md` per technical subsystem. [Technical doc](concepts/technical-doc.md#where-decisions-live)
  already leaves this choice open — TOM needs no special note to justify
  it, only to state which form it uses, since a reader shouldn't have to
  guess.
- **A per-feature permanent layer** (`docs/products/<feature>/doc.md`,
  stakeholder-maintained, checkable rules) alongside a separate vision doc
  (`docs/product/product.md`). This is a real, structural variant: it
  organizes the product doc by feature instead of by concept, and it
  splits what WritRun treats as one layer into two. It is a defensible
  choice — the per-feature docs are genuinely checkable, genuinely
  permanent — but it is exactly the kind of variant that needs to be
  written down, not left implicit in the directory name.

Neither divergence is what keeps TOM from claiming adoption. What does:
**there is no `work/tasks/` and no `work/specs/` anywhere in the repo.**
Work selection runs off a roadmap checklist instead, which means nothing
keeps the per-feature docs honest when behaviour changes — no spec's
Proposed-changes section ever forces them to be touched in the same change
that ships the behaviour. A project can satisfy the entire permanent side
of WritRun and still not be an adopter, because the ephemeral side is what
actually prevents drift.

## Skills namespacing

WritRun ships as four skills — `writrun-select-next-task`,
`writrun-create-task-and-spec`, `writrun-check-spec-deltas`,
`writrun-check-task-state` — and they live in **WritRun's own home**,
`.writrun/skills/`, never mixed into the project's skill folder. A project
that keeps its own repo-maintenance skills (swoop's `swoop-git-workflow`
and `swoop-pr-writer` are the real example, in its `.ai/skills/`) keeps
them exactly where they are: the two sets never share a directory, both
are activated only through the project's own `AGENTS.md` trigger table,
and every WritRun skill carries the `writrun-` prefix besides — provenance
is unmissable at the path *and* at the name.

## Criteria

- When a project's permanent docs exist but its `work/tasks/` and
  `work/specs/` folders do not, the project shall not claim adoption — it
  shall describe itself as adopting, in progress.
- When a project diverges from a WritRun default that is explicitly left
  open (decisions-log shape, concept- vs. feature-organized product
  chapters, id prefixes, spec-mandatory threshold), the choice shall be
  stated in a place a reader would look for it, not left implicit.
- When a project diverges from a core rule (audience split, permanent/
  ephemeral split, task holds no technical detail, spec's Proposed-changes
  contract, identity-never-order, the four named human gates), the project
  shall not claim adoption regardless of how much of the rest it follows.
- When WritRun's four skills are installed, they shall live under
  `.writrun/skills/`, apart from the project's own skill folder, and no
  skill across the two sets shall share a name.
