# The skills

**Why the methodology ships as skills**, and what each of the five carries. One chapter of [`distribution/`](README.md).

## The skills are the mandatory form

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
[Adoption's skills-namespacing note](../../product/adoption.md#skills-namespacing)
for how the two sets stay apart by path and by prefix:

- **`writrun-select-next-task`** — runs the [selection algorithm](../selection/algorithm.md#task-selection-algorithm)
  exactly as specified, so every agent session gets the same answer instead of
  each one re-deriving it from the prose.
- **`writrun-create-task-and-spec`** — turns `AGENTS.md`'s prose instructions on task
  and spec creation into an active, checklist-driven skill: what front-matter
  to fill, when a spec is warranted, how to fill the Proposed changes
  sections. Backed by `new.sh`, which scaffolds a schema-correct
  `task-nnn.md` / `spec-nnn.md` — id increment, list-typed fields, every
  field present — mechanically rather than from an agent's memory of the
  schema (see [Task's worked example](../../product/concepts/task.md#example)
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
  [Front matter is canonical](../schemas/front-matter.md#front-matter-is-canonical) is a checked
  contract, not an assumption — `check_front_matter.sh` validates every
  queue file against it, on files alone, no git and no forge, which makes
  it the one check available at every adoption stage.

