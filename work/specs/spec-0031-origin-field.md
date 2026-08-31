---
id: spec-0031
task_ref: task-0022
status: implemented
created: 2026-08-31T03:44:31Z
---

# spec-0031 — Tasks carry their origin

**References:** [task-0022](../tasks/task-0022-queue-vocabulary.md)

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
   never changed and never removed, closed mirrors included. Colors on
   first creation: `origin:report` `#d73a4a` (GitHub's stock bug red),
   `origin:rule` `#0075ca` (its documentation blue) — vocabulary any
   Issues reader already knows.
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

Built as specified. `new.sh task` gained `--origin rule|report`, with
no default: an unstated or invented value refuses at exit 3, naming the
flag, before anything is written. The field lands between `doc_ref` and
`priority`, exactly as the schema draws it, and joins `TASK_CONTRACT`
so a project template cannot redefine it.
`check_front_matter.sh` requires it on every task and accepts only the
two values. The mirror projects it: `mirror_issues.sh` labels a new
mirror `origin:rule` (`#0075ca`) or `origin:report` (`#d73a4a`) and
re-states the label in every relabelling PUT it makes, since each
replaces the whole set; `rederive_labels.sh` adds it from the stored
field when a mirror does not already wear one, and never rewrites one
that does.

Backfill: all 19 tasks gained the line, `rule` for the sixteen derived
from an authored rule and `report` for task-0016, task-0017 and
task-0018 — the three reported machinery defects. The catch-up note is
gone from `technical/README.md#task-schema`. Divergences: two, both
consequences rather than changes of plan. `issue_row_of` now carries
the mirror's label list so the origin label can survive a rewrite, and
a label the mirror already wears wins over the diff's field — the field
is written once, so a disagreement means the diff is the stale side.
Every existing `new.sh task` call in the suite gained `--origin rule`,
which is what "no default" costs.

Review, before merge, found a third consequence, and it is the same
kind: declaring `origin:rule` / `origin:report` in the repository ran
ahead of the paths that refuse to touch a mirror, so a run that logged
"not touching it" — and a pull request closed without merging — still
left a label behind that nothing wore. Declaring moved to the write
itself: in `mirror_issues.sh` a `put_status_labels` helper now owns the
three relabelling PUTs and declares the label as it writes them, and in
`rederive_labels.sh` the declaration sits past the closed-mirror
return. Two mirror cases cover it.
