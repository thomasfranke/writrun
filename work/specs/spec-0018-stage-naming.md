---
id: spec-0018
task_ref: task-0019
status: implemented
created: 2026-08-30T03:04:06Z
---

# spec-0018 — Stage-prefixed names across docs, scripts, tests and settings

- **Goal:** anything that belongs to exactly one stage says so in its
  name (`stage-N-` prefix), the settings contract says `stage: 1|2|3`
  (unquoted integer), the queue speaks the community status vocabulary
  (`backlog`/`ready`/`in-progress`/`in-review`/`done`), and every
  reference — links, `doc_ref`s, labels, workflow paths, test fixtures
  — follows the rename, so nothing dangles.

## Scope

The mechanical sweep the naming rule
(`product/adoption.md#three-stages`) derives. Renames only — no
behaviour change anywhere.

The mapping:

| From | To |
|---|---|
| `docs/product/tasks-and-specs/` | `docs/product/stage-1-tasks-and-specs/` |
| `docs/product/pull-requests/` | `docs/product/stage-2-pull-requests/` |
| `docs/product/github-issues/` | `docs/product/stage-3-github-issues/` |
| `.writrun/scripts/pull-requests/` | `.writrun/scripts/stage-2-pull-requests/` |
| `.writrun/scripts/github-issues/` | `.writrun/scripts/stage-3-github-issues/` |
| settings `"level": "tasks-and-specs" \| "pull-requests" \| "github-issues"` | `"stage": 1 \| 2 \| 3` — unquoted integer; the settings shape check learns the type |
| test suites bound to one stage | under a `stage-N/` folder in their tier |
| status values `pending` / `completed` | `backlog` or `ready` (per the task's specs) / `done` — in the schema, the generator, the checks, and **every existing queue file**, migrated in this change |
| mirror labels `status:pending` | `status:ready` or `status:backlog`; label set gains `status:blocked`; every open mirror re-labelled by `rederive_labels.sh` on the day this merges |

Explicitly **not** renamed, per the rule's own carve-out: the skills
(cross-stage tools — every one of them works at Stage 1 and is reused
by CI at Stage 2), the workflows (functional names, stage stated where
they gate), `docs/product/concepts/` and `adoption.md` (they serve
every stage), and — never — any task or spec file: identity is never
order.

## Steps

1. `git mv` the three product chapters and the two script folders;
   sweep every relative link in `docs/`, `README.md`, `AGENTS.md`,
   `CONTRIBUTING.md`, the workflows, the scripts, the skills' SKILL.md
   files and the templates.
2. Settings: `level` key becomes `stage` with integer values 1–3;
   `check_settings.sh`, `level_gate.sh` and their callers read the new
   key; `writrun-check-front-matter`'s docs-dir handling and the
   settings tests follow. The gate's arguments become stage numbers.
3. Queue front matter: update the `doc_ref` of every task whose path
   the rename moved — front matter is contract, not assented prose, so
   this is a fix-up, not an amendment. Bodies of `implemented` specs
   stay untouched: they are history and may name the old paths.
4. Tests: move stage-bound suites under `stage-N/` in their tier;
   update `run.sh`/harness discovery if it globs by path.
5. Renumber nothing, and rename no task or spec file.

## Acceptance criteria (EARS)

- When the sweep lands, no link in `docs/`, `README.md`, `AGENTS.md` or
  `CONTRIBUTING.md` shall point at a pre-rename path.
- When the sweep lands, every non-completed task's `doc_ref` shall
  resolve.
- When `settings.json` declares `stage`, the machinery shall read it
  everywhere `level` was read, with the same gating semantics.
- When a folder serves exactly one stage, its name shall carry the
  `stage-N-` prefix; when it serves more than one, it shall not.
- When the sweep lands, no queue file, script, skill or workflow shall
  hold `pending` or `completed` as a **status value** — the `completed`
  *date* field keeps its name, recording what it always recorded.
- When the sweep lands, every open mirror shall carry the new label
  vocabulary.
- When the sweep lands, `writrun check` and the full test suite shall
  pass with no behaviour change.

## Edge cases

- Anchors: `#three-levels` became `#three-stages` in the authoring
  change; the sweep greps for any remaining `-levels` reference.
- The template kit (`template/`) mirrors the destination layout — it
  renames in lockstep or adopters copy a stale shape.
- `implemented` specs and closed history referencing old paths: left
  as-is, deliberately.
- An open PR at rename time rebases across a `git mv`; git follows the
  renames, but the PR's own new files in old folders land in a path
  that no longer exists — flag in the PR body that the sweep merges in
  a quiet queue.

## Tests required

Settings tests for the `stage` key (each value, missing, out of range);
a link-integrity pass over the renamed tree (extend the existing check
if one covers links, add a unit suite if none does); the moved suites
green in their new homes.

## Definition of Done

- [ ] All acceptance criteria hold.
- [ ] `rg` for the old folder names and the `level` key returns only
      history (`work/specs/` bodies, decisions).
- [ ] `writrun check` and the full test suite pass.

## Proposed product changes

- `product/stage-1-tasks-and-specs/` — the chapter renamed to its
  stage-prefixed home; content unchanged except links.
- `product/stage-2-pull-requests/` — the same rename.
- `product/stage-3-github-issues/` — the same rename.
- `product/README.md` — the chapter links follow the renames.
- `product/adoption.md` — its links follow the renames.
- `product/concepts/product-doc.md` — its links follow the renames.
- `product/concepts/technical-doc.md` — its links follow the renames.
- `about.md` — its links follow the renames.

## Proposed technical changes

- `technical/README.md` — every link into the three renamed product
  chapters follows the `git mv`; no prose changes — the `stage`
  contract, the schema and the algorithm were authored first and are
  already written.

## Amendment history

- 2026-08-30 — the Proposed product changes named the three renamed
  folders on one bullet (only the first path was machine-readable) and
  missed the five sibling docs whose links the rename sweeps
  (`product/README.md`, `adoption.md`, two concepts files, `about.md`).
  Split per path and named the five; returned to `draft` for
  re-approval. The elaboration was incomplete, not wrong — the scope is
  unchanged.

## Outcome

Built as specified, with two divergences worth their record. The
promises: as first approved they named the three folders on one bullet
and missed the five sibling docs the link sweep touches — amended
through `draft` and re-approved (see Amendment history) before this
completion; and `check_deltas.sh` now honours a folder promise (a path
ending in `/` covers everything under it), which is the shape this
spec's own contract was written in. The rename itself: `git mv` of the
five folders, every link and `doc_ref` swept, `stage: 3` as an unquoted
integer with `stage_gate.sh` gating by number, the status vocabulary
migrated across schema, generator, checks, every queue file and the
mirror labels, and the stage-bound integration suites grouped under
`stage-N/` with recursive discovery in `run.sh` (which now closes each
case's stdin — the discovery pipe was readable by the cases it fed).
`level_gate.sh` is gone; `rg` for the old names finds history only.
