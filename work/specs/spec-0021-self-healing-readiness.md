---
id: spec-0021
task_ref: task-0019
status: implemented
created: 2026-08-30T03:33:06Z
---

# spec-0021 — Self-healing release readiness: the bot syncs the template on main

**References:** [task-0019](../tasks/task-0019-status-from-forge.md)

- **Goal:** a push to `main` that leaves the template drifted gets a
  sync commit from the machinery, not a red X demanding
  `make template-sync` — and the readiness verdict lands on the healed
  tree, in the same run that healed it. Red means something a script
  could not fix.

## Scope

`release-readiness.yml` only — this repository's own pipeline, never
shipped in the kit. The deterministic regeneration covered is the
template sync; nothing else on `main` is auto-repaired (queue
canonicality guards *hand* edits, and rejecting those is its job, not
drift).

The three failures this kills, all seen on `main`'s history: merges of
#29, #36 and #39 each left the template drifted and readiness red
until a person committed the sync by hand — while the queue recording
one workflow over already commits mechanical consequences of a merge
on its own.

## Steps

1. Reshape the workflow: one job, three phases — regenerate
   (`make template-sync`), heal (if the tree changed: commit
   `chore(template): sync the kit with the root it mirrors` and push
   with the rebase-not-force pattern `writrun-approve.yml` uses), then
   verdict (`bash tests/run.sh` on the tree as pushed).
2. Permissions: the job needs `contents: write` — today the workflow
   holds `read`. The push uses `GITHUB_TOKEN`; its pushes trigger no
   new runs, which is why the verdict must run in this same job rather
   than wait for a run the sync commit will never cause.
3. The fast `template in sync` gate job disappears into phase 1 — a
   check that only reports what the next phase repairs is a duplicate
   verdict.
4. Tests: the suite's e2e tier gains the heal case — a drifted
   template on a simulated main ends synced, committed, and green; a
   genuinely failing suite still exits red after the heal.

## Acceptance criteria (EARS)

- When a push to `main` leaves the template out of sync with the root,
  the pipeline shall commit the regenerated template to `main` and
  then run the full suite on the result.
- When the regeneration produces no diff, the pipeline shall commit
  nothing and run the suite directly.
- When the suite fails on the healed tree, the run shall fail — the
  heal never masks a genuine breakage.
- When the heal push races another commit to `main`, the pipeline
  shall rebase onto it rather than force-push.
- When the healing commit lands, no new workflow run shall be
  triggered by it.

## Edge cases

- The race with `writrun-approve`'s own recording commit (both fire
  after a merge): both sides use pull-rebase before push; order does
  not matter because the two touch disjoint paths (`template/` vs
  `work/`).
- A drift the sync cannot regenerate (a mirrored file deleted at the
  root): `make template-sync` itself fails, phase 2 never commits, the
  run is red — correctly, this needs thought.
- `main` protected later: same Stage-2 requirement already documented —
  the Actions bot on the ruleset's bypass list; the push fails loudly
  otherwise.

## Tests required

E2e-tier: drifted template healed, committed, suite green; no-drift
push commits nothing; suite failure after heal stays red; sync-failure
path stays red without a commit.

## Definition of Done

- [ ] All acceptance criteria hold, each with a test.
- [ ] `main`'s readiness history shows no red whose log says "run
      make template-sync".
- [ ] `writrun check` and the full test suite pass.

## Proposed product changes

- none — this repository's own CI, below the product surface; the rule
  lives in the technical layer.

## Proposed technical changes

- none — the rule was authored first (`technical/README.md#distribution`:
  a red `main` that a script can fix is the bot's to fix); this change
  brings the pipeline up to a doc that already states it.

## Outcome

Built as specified: `release-readiness.yml` is one job, three phases —
regenerate, heal (`.github/scripts/readiness_heal.sh`: commit and push
with the rebase-not-force pattern when the sync changed anything, loud
when it cannot), verdict (the full suite on the healed tree, in the
same run, since a GITHUB_TOKEN push triggers none). Permissions rose
to `contents: write`; the fast template gate folded into phase 1. The
e2e tier proves drift healed-and-pushed, no-drift committing nothing,
and a failed push staying red. Divergence: the heal logic lives in
.github/scripts/ (repo-own, never shipped) so the suite can execute
it, rather than inline YAML. A review pass switched the drift test to
`git status --porcelain` — a sync that creates a file is drift `git
diff` cannot see.
