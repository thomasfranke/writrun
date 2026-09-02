---
id: spec-0044
task_ref: task-0033
status: implemented
created: 2026-09-02T01:28:43Z
---

# spec-0044 — check_state holds the tracked route to a report branch

**References:** [task-0033](../tasks/task-0033-tracked-route-gate.md)

- **Goal:** a diff that routes a report to `tracked` — or adds the task
  that route mints — passes CI only when the change is a reporting one,
  on a `report/` branch. The rule the doc states becomes a rule the
  door enforces.

## Scope

In scope: `check_state.sh` (one new rule, after rule J's report
transitions), `writrun-check.yml` (the head branch name reaches the
script through the environment), `writrun-check-task-state/SKILL.md`
(the rule is documented where the others are), unit cases, template
sync.

Out of scope: the docs stating the rule — they land with the authoring
change this spec derives from, which is why **Proposed product changes**
below says none. Also out of scope: the mirror scripts (no behaviour
change; the born-closed path already serves every route this rule
leaves riding) and anything about `fixed`/`declined`/`authored`, which
remain free to ride.

## Steps

1. `check_state.sh`: a new rule (K). Within the diff range, FORBIDDEN
   unless the head branch matches `report/*`:
   - a report file whose `status` reaches `tracked` — by transition
     (base ≠ `tracked`, head = `tracked`) or by entering the tree
     already `tracked`;
   - a task file **added** with `origin: report`.
2. The branch name: read `HEAD_REF` from the environment when set;
   otherwise `git rev-parse --abbrev-ref HEAD`. When neither yields a
   name (detached HEAD, no env), skip the rule and say so on stdout —
   a check that cannot read its input must be loud, and CI always
   provides the name.
3. `writrun-check.yml`: pass `HEAD_REF: ${{ github.head_ref }}` via
   `env`, never inline interpolation — a fork controls the string, and
   the script only ever prefix-matches it.
4. `writrun-check-task-state/SKILL.md`: the rule joins the documented
   list, with the same one-line reasoning the others carry.
5. `make template-sync` — the script and workflow live mirrored under
   `template/`.

## Acceptance criteria (EARS)

- When a diff on a non-`report/` branch moves a report's status to
  `tracked`, `check_state.sh` shall exit 1 naming the file and the
  rule.
- When a diff on a non-`report/` branch adds a task whose `origin` is
  `report`, `check_state.sh` shall exit 1 naming the file and the rule.
- When the same diff arrives on a `report/` branch, `check_state.sh`
  shall exit 0.
- When a report enters or moves to `authored`, `fixed` or `declined` on
  any branch, this rule shall not fire.
- When no branch name is readable and `HEAD_REF` is unset, the rule
  shall be skipped with a line on stdout saying so.

## Edge cases

- A report already `tracked` on the base and untouched in the range —
  no transition, no trigger.
- A report **born** `tracked` in one reporting PR (recorded and triaged
  together) — legal on `report/*`, the ordinary case.
- A report born `authored` riding a `docs/` branch — the authoring
  change is the route's own vehicle; the rule ignores `authored`.
- `HEAD_REF` present but empty (a push event) — treated as unset, local
  fallback applies.
- The machinery's own commits on `main` — not pull requests; the check
  never sees them.

## Tests required

Unit, under `tests/unit/check_state/`: the four verdicts above
(non-report branch tracked flip → 1; identical diff on `report/` → 0;
task added `origin: report` on `task/` → 1; `fixed`/`declined`/
`authored` riding → 0), plus `HEAD_REF` overriding the checked-out
branch name, and the loud skip when neither exists.

## Definition of Done

- [ ] Rule K in `check_state.sh`, `HEAD_REF` plumbed in the workflow.
- [ ] SKILL.md documents the rule.
- [ ] Unit cases green; full suite green; template in sync.

## Proposed product changes

- none — the docs land with the authoring change that derived this spec

## Proposed technical changes

- none — nothing under `docs/` changes. The machinery this spec builds
  is named in **Scope** and **Steps**, which is where it belongs: these
  two sections promise permanent docs, and a path written here is read
  relative to `docs/`.

## Amendment — 2026-09-02

Returned to `draft` before implementation. **No pull request is
suspended** — task-0033 is `ready` and untaken, so this is the ordinary
pre-implementation amendment, which costs nothing but the re-approval.

The Proposed technical changes listed five repository-root paths —
`check_state.sh`, its `SKILL.md`, the workflow, `tests/unit/check_state/`
and `template/`. Both Proposed-changes sections are read relative to
`docs/`, so `check_deltas` normalises each of those to
`docs/.writrun/…`, `docs/.github/…`, `docs/tests/…`, `docs/template/` —
paths no diff will ever touch. Every one would have reported `MISSING`
and the completion gate would have refused the finished branch, in CI
too through `check_promised_deltas.sh`
([report-0005](../reports/report-0005-delta-doc-paths.md)).

Nothing else moves: the goal, the scope, the steps, the criteria, the
edge cases and the tests are as approved. The work this spec authorizes
is unchanged — what changes is that the gate can now see the promise it
makes, which is `none`.

The precedent is [spec-0043](spec-0043-report-kind.md), implemented and
merged: it carries a generator, three gates and the mirror in its Scope
and Steps, and promises one `technical/README.md` anchor.

## Outcome

All five steps shipped as written. Rule K is one rule read at two
places, because the two are separable: a report flipped to `tracked` in
one change and its task added in another would pass a rule that watched
only the status line, so the task's `origin: report` is judged on its
own — in the tasks arm, where the born-task checks already are, rather
than beside the report half in the script's text.

**What landed.** Rule K in `check_state.sh` and in its header docblock;
the head branch resolved once, before the file loop, from `HEAD_REF`
then from `git rev-parse --abbrev-ref HEAD`, with `HEAD` (detached)
read as no name; `HEAD_REF: ${{ github.head_ref }}` on
`writrun-check.yml`'s lifecycle step, through `env:`; the two verdicts
in `writrun-check-task-state`'s SKILL.md table, the branch-name input
in its Steps, and one entry in its Never list; fourteen assertions in
`tests/unit/check_state/the_tracked_route_never_rides_test.sh`;
`template/` synced.

The rule fires on the state reached rather than on the number of steps
taken to it — `new = tracked` with `old ≠ tracked` covers the
transition and the birth in one condition, since an added file's base
read is empty. That is also what leaves the "already `tracked` on the
base and untouched in the range" edge case alone without a special
case for it.

### Divergences

- **None in behaviour.** Every acceptance criterion and every edge case
  is asserted, and two assertions were added the spec did not name: a
  task born `origin: rule` on a `task/` branch passes (the rule's other
  half must not be a rule about added tasks), and a report already
  `tracked` on the base and untouched in the range passes (the edge
  case was named but not listed under Tests required).

- **The environment variable name is a second one for a value the
  repository already names.** `HEAD_REF` is what this spec specified and
  what shipped; `writrun-progress.yml` and `writrun-approve.yml` pass
  the same value as `PR_HEAD_REF`. Not changed here — the spec is
  explicit, three times — and recorded instead as
  [report-0007](../reports/report-0007-the-head-branch.md), which rides
  this change the way recording is allowed to.
