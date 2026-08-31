---
id: spec-0029
task_ref: task-0021
status: implemented
created: 2026-08-31T03:06:42Z
---

# spec-0029 — Protection is recommended, and never gates adoption

- **Goal:** the machinery's comments match what the docs now state: the
  one hard requirement is that the Actions bot reaches `main`;
  protecting `main` with a ruleset is recommended where the forge
  offers the app on the bypass list (organization-owned repos), and on
  user-owned repos the achievable half — no force pushes, no deletions
  — is what runs. Nothing about protection is a condition for using
  WritRun.

## Scope

In: the comment in `writrun-approve.yml` that still explains itself by
`main` being unprotected (and its template mirror), and a dated
decision recording how the stance evolved from 0043 — with its row in
the decisions chronology.

> **Amended 2026-08-31, returned to `draft`.** Same omission as
> spec-0026's: the decision entry was promised and its index row was
> not, which `writrun-check-spec-deltas` reports as an undeclared
> permanent-doc change. The promise now names the file; the change
> itself is unmoved.

Out: the forge configuration itself (this repository's partial ruleset
is already live — a setting, not a file); decisions 0014 and 0043 as
written — append-only, superseded, never edited; any new check (a
protection rule cannot be verified from inside the repo and must not
gate anything).

## Steps

1. `.github/workflows/writrun-approve.yml`: the comment block explains
   the push lands because `main` stays reachable by the Actions token —
   whether unprotected, behind a partial ruleset (force-push/deletion
   blocking, which ordinary pushes pass), or behind a full ruleset with
   the app on bypass on an organization-owned repo. Same in
   `template/.github/workflows/writrun-approve.yml`.
2. Add a dated decision under `docs/technical/decisions/pull-requests/`
   superseding 0043's premise: the unprotected default gave way to
   recommended protection; the forge offers the app as bypass actor
   only on organization-owned repos (UI and API alike), so user-owned
   repos run the partial ruleset; adoption never depends on any of it.

## Acceptance criteria (EARS)

- When a reader follows `writrun-approve.yml`'s comments, they shall
  find the reachability requirement stated without any claim that
  `main` is, or should stay, unprotected.
- When the decision log is read in order, it shall record the
  unprotected default, the recommendation that superseded it, and the
  forge limitation that shapes it — each dated.
- When a merge lands on this repository with the partial ruleset
  active, the machinery's recording commit shall still reach `main`.

## Edge cases

- An adopter whose forge exposes no bypass list at all: the requirement
  stays reachability; the recommendation simply has no mechanism there.
- The first merge after any ruleset change: verify the recording push
  with a real merge, not an assumption — a silent 403 is exactly the
  failure this spec exists to surface.

## Tests required

None mechanical — workflow comments and a decision entry. The live
check is the verified recording push on the first merge after the
ruleset change; the template-mirror test covers the workflow copy.

## Definition of Done

- [ ] No "unprotected" claim left in the machinery's comments; template mirror byte-identical.
- [ ] Decision entry added, dated, superseding 0043's premise.
- [ ] A post-merge recording push confirmed on `main` with the partial ruleset active.

## Proposed product changes

- none — the rule was authored first (`README.md`'s repository setup,
  `CONTRIBUTING.md`); this change brings the machinery's comments up to
  it.

## Proposed technical changes

- `technical/decisions/pull-requests/` — new dated entry: protection
  became a recommendation bounded by the forge (app bypass is
  organization-only), reachability stays the requirement, 0043's
  unprotected default is superseded.
- `technical/decisions/README.md` — append that entry's row to the
  chronology table, for the same reason spec-0026 now names it: a
  decision is not added without its row
  ([0045](../../docs/technical/decisions/tasks-and-specs/0045-one-decision-per-file.md)),
  and the delta check reads paths, not intent.

## Outcome

Built as specified: `writrun-approve.yml`'s dependency block no longer
explains its push by `main` being unprotected. It states reachability as
the one hard requirement and lists the three shapes that satisfy it —
unprotected, a partial ruleset whose rules an ordinary fast-forward push
does not break, and a full ruleset with GitHub Actions on the bypass
list — with the forge limitation named: the bypass list accepts an
Integration actor on organization-owned repositories alone. Decision
0056 records the evolution from 0043's unprotected premise, and its row
is in the chronology. Decisions 0014 and 0043 were not edited.

**The third Definition-of-Done item is satisfied by observation, not by
assumption.** The `protect-main` ruleset is active on this repository
with exactly `creation`, `deletion`, `non_fast_forward` and
`required_linear_history`, and the merge of #63 produced recording
commit `d7b42ab` on `main` at 2026-08-31T04:45:39Z — the machinery's own
push, landing with the partial ruleset live. The silent 403 this spec
existed to surface did not occur.

Divergence: the spec was amended mid-flight for the same omission as
spec-0026 — the decision entry was promised and its chronology row was
not. See spec-0026's Outcome for the full account; scope unmoved.
