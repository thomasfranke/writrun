---
id: spec-0032
task_ref: task-0022
status: implemented
created: 2026-08-31T03:44:32Z
---

# spec-0032 — The machinery speaks reporting

**References:** [task-0022](../tasks/task-0022-queue-vocabulary.md)

- **Goal:** the third kind of change is called **reporting**
  everywhere the machinery speaks, and its branch prefix is
  `report/` — matching the docs, which already renamed it. No file an
  adopter receives still says "tracking" or `queue/` for this flow.

## Scope

In: the shipped conventions (`branches.md`, `prs.md`), any skill
instruction or workflow comment naming the old term or prefix, the
kit's `AGENTS.md` skeleton if it carries the change-kinds table, and
the template mirrors.

Out: decisions 0022 and earlier prose naming "tracking" — append-only,
dated, left as written; the generic verb *track* where it means
"justifies tracking" (principle 6's sense, unrelated to the change
kind); resolution of old `queue/` branches (none are open; no
compatibility shim is owed).

## Steps

1. `.writrun/conventions/branches.md`: the `queue/short-name` entry
   becomes `report/short-name` — reporting: same definition, same
   deliberate absence of a task id, same "records work, is not working
   it".
2. `.writrun/conventions/prs.md`: "Authoring and tracking PRs" becomes
   "Authoring and reporting PRs", both places.
3. Sweep `.writrun/skills/` and `.github/workflows/` comments for the
   old term used as the change-kind's name; repoint each.
4. The kit's skeletons: wherever the grafted `AGENTS.md` carries the
   change-kinds table, it ships the new column and prefix.
5. `make template-sync`.

## Acceptance criteria (EARS)

- When the conventions name the third kind of change, they shall call
  it reporting and its branch prefix `report/`.
- When a shipped file is searched for `queue/` as a branch prefix, no
  match shall remain.
- When the template mirrors are compared to the root files they copy,
  they shall be byte-identical.

## Edge cases

- The word *track* in its generic sense ("work that justifies
  tracking") stays — only the change-kind's proper name renames.
- A branch named `queue/...` pushed by an old clone: nothing parses
  the prefix, so nothing breaks; the PR simply reads off-convention
  and review says so.

## Tests required

No behaviour changes — the template-mirror test over the touched
files, and the suite green.

## Definition of Done

- [ ] Conventions, skills and workflow comments say reporting / `report/`.
- [ ] Kit skeletons ship the new vocabulary; mirrors byte-identical.

## Proposed product changes

- none — the rename was authored first (`AGENTS.md`'s table,
  `product/stage-1-tasks-and-specs/authoring.md`, the root README).

## Proposed technical changes

- none — conventions and comments only; nothing parses the prefix, so
  no behaviour moves.

## Outcome

Built as specified, and it was as small as it looked.
`.writrun/conventions/branches.md` names `report/short-name` —
reporting, same definition, same deliberate absence of a task id;
`prs.md` says "Authoring and reporting PRs" in both places; the kit's
`WRITRUN.md` says work found mid-flight enters as a `report/` PR. The
sweep over `.writrun/skills/` and `.github/workflows/` found one hit,
and it was the generic verb — "work that justifies tracking", principle
6's sense — so it stays, exactly as the scope said. No `queue/` remains
as a branch prefix in any file an adopter receives. No divergences; no
behaviour moved, and the template mirror is the check.
