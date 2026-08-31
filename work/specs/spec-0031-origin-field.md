---
id: spec-0031
task_ref: task-0022
status: draft
created: 2026-08-31T03:44:31Z
---

# spec-0031 — Tasks carry their origin

- **Goal:** every task records how it came to exist — `origin: rule`
  (derived from an authored rule declared finished) or
  `origin: report` (born from a report of work an existing rule
  already authorizes) — written by the generator at creation, readable
  by every line-based reader, and projected onto the mirror as an
  `origin:` label so the Issues list tells rule-work from reported
  defects at a glance.

## Scope

In: `new.sh`'s task subcommand and its canonical output, the
front-matter checker, the mirror workflow's labels, a backfill sweep
over the existing queue, tests, and the template mirrors.

Out: specs (a spec inherits everything from its task — no `origin` of
its own); any later rewrite of the field (a fact about birth, written
once); the selection algorithm (origin is information, never
eligibility).

## Steps

1. `new.sh task` gains `--origin rule|report` and writes the field
   between `doc_ref` and `priority`, exactly as the schema draws it.
   No default: an unstated origin is refused loudly — a wrong fact
   recorded silently is the failure the field exists to prevent.
2. `check_front_matter.sh` adds `origin` to the canonical form: always
   present on tasks, value `rule` or `report`, nothing else.
3. The mirror machinery (`writrun issues` / the labeler) applies
   `origin:rule` or `origin:report` when a mirror is created, creating
   the label on first use like every other; unlike `status:` it is
   never changed and never removed, closed mirrors included.
4. Backfill: every existing task gains its `origin` line, derived from
   the PR branch that created it (`docs/` → `rule`, `queue/` →
   `report`); where history is ambiguous, the judgement is made once,
   in the backfill diff, where review can see it.
5. The `writrun-create-task-and-spec` skill instructions name the flag
   and when each value applies.
6. Tests: generator writes the field in place; checker rejects a
   missing or misvalued `origin`; mirror test covers the label.
   `make template-sync`.
7. Remove the catch-up note from `technical/README.md`'s schema
   section.

## Acceptance criteria (EARS)

- When `new.sh task` runs with `--origin`, the generated front matter
  shall carry that value between `doc_ref` and `priority`.
- When `new.sh task` runs without `--origin`, it shall refuse, naming
  the flag.
- When a task file lacks `origin` or carries a value outside
  `rule | report`, `check_front_matter.sh` shall reject it.
- When a task is mirrored, the mirror shall carry the matching
  `origin:` label, and no later relabeling shall change or remove it.
- When the backfill lands, every task in the queue shall carry an
  `origin` and the full suite shall be green.

## Edge cases

- A task created by hand (no script available): the schema is
  normative either way — the writer picks the true value, and the
  checker holds the line.
- A pre-existing mirror without the label: the next recording commit's
  relabeling pass adds it, once, from the stored field.

## Tests required

Generator, checker and mirror cases above; the whole suite green over
the backfilled queue; template-mirror test green.

## Definition of Done

- [ ] Field written by the generator, enforced by the checker, projected by the mirror.
- [ ] Queue backfilled; catch-up note removed; suite green.
- [ ] Template mirrors byte-identical.

## Proposed product changes

- none — the rules were authored first
  (`product/stage-3-github-issues/labels.md`, the origin label;
  `product/stage-1-tasks-and-specs/authoring.md`, the reporting
  triage).

## Proposed technical changes

- `technical/README.md#task-schema` — remove the origin catch-up note
  once the generator writes the field and the queue is backfilled.

## Outcome

_(fill after execution)_
