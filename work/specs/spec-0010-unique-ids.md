---
id: spec-0010
task_ref: task-0013
status: implemented
created: 2026-08-28
---

# spec-0010 — Keep queue ids unique across open pull requests

## Scope

Prevention in the generator, detection in CI.

In scope: `new.sh` (consult open pull requests when a forge is
reachable) and a new `.writrun/scripts/check_unique_ids.sh` wired into
`writrun-check.yml`. Out of scope: renumbering anything that already
exists, and the id format itself — four sequential digits stay.

## Steps

1. `new.sh`: when `gh` is available and authenticated, list open pull
   requests' added `work/tasks/` and `work/specs/` files and fold their
   ids into the maximum it already computes from the tree and the
   history. Best-effort by design: no forge, no network, or no auth
   means today's behaviour, and it says which of the two answers it
   gave — a silently narrower scan is how the collision happened.
2. `check_unique_ids.sh <diff-range> <owner/repo> <pr-number>`: for every
   queue file the range **adds**, fail if that id already exists on the
   base branch, or is added by another open pull request. Read ids from
   the filename's prefix, so a slug never changes the answer.
3. Wire it into `writrun-check.yml` as its own job, read-only, no
   secrets beyond the token the other jobs already use.
4. The message names the other claimant — the base branch or the pull
   request number — because the fix is renumbering, and that is only
   obvious once you know what you collided with.

## Acceptance criteria

- When a change adds a queue file whose id the base branch already
  holds, the system shall reject the change.
- When two open pull requests add the same id, the system shall reject
  the one it is checking and name the other.
- When a change adds queue files with ids nobody else claims, the system
  shall pass.
- When a change adds no queue file, the system shall pass without
  consulting the forge.
- When a forge is reachable, `new.sh` shall mint above the ids open pull
  requests claim.
- When no forge is reachable, `new.sh` shall mint from the tree and
  history as before, and report that its view was local only.

## Edge cases

- A pull request that adds a file and another that only modifies the
  same id: modification is not a claim, so it does not collide.
- A draft pull request: it claims its ids like any other, since it will
  merge eventually or be closed.
- The pull request being checked appears in its own listing of open
  ones — it must not collide with itself.
- A queue file whose id prefix is malformed: already the canonical
  check's business, and not this one's to re-report.

## Tests required

One case per acceptance criterion, in a new `unique_ids` suite and the
`new` suite, with the forge stubbed as the mirror suites already do.

## Definition of Done

- `make tests` green, including the new cases.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — the authoring change stated the rule in `product/pipeline.md`
first.

## Proposed technical changes

none — the same authoring change covered `technical/README.md`.

## Outcome

Built as planned: prevention in `new.sh`, detection in
`.writrun/scripts/check_unique_ids.sh`, wired into `writrun-check.yml` as
a read-only `ids` job on the token the other jobs already use. The suite
went from 150 case files to 161 for this spec's own work, and to 162 with
the folded fix below.

Verified against the live forge before merge, which is worth recording
because it caught the bug in the act. `new.sh` in this checkout minted
`task-0015`, not `task-0014`: open pull request #29 already claims
`task-0014` and `spec-0011`, and no branch here can see them. The old
generator would have minted `0014` and collided at whichever of the two
merged second. The check, run against a probe commit that added
`task-0013-duplicate`, `task-0014-collide`, and `spec-0011-collide`,
named all three claimants correctly — the base branch for the first, #29
for the other two.

Three divergences:

- **The two halves ask the forge different questions.** Step 1 and step 2
  read as one lookup shared by both. They are not. The check needs each
  file's `status`, since a modification is not a claim (its own edge
  case), and only the per-pull-request file list carries it — so it pays
  one call per open pull request. The generator needs an upper bound, not
  an accusation: it asks `gh pr list --json files` once, for every path
  open pull requests touch, added or modified. Folding a modified path in
  can only agree with what the tree already said, so the coarser question
  is not merely cheaper, it is strictly safe.

- **The narrow-view report is on stderr, and the check makes one too.**
  Step 1 asked only that `new.sh` say which of the two answers it gave.
  The forge-less line is a caveat about what was *not* seen, so it goes to
  stderr while the forge-wide line goes to stdout. The check inherited the
  same treatment, which the steps did not mention: a clean pass whose
  forge half never ran says so, because reporting it as simply clean is
  how the collision this task exists for got merged.

- **`check_deltas.sh` was fixed in this change, which its scope did not
  cover.** Its spec resolver read `find work/specs -iname "<id>.md"`,
  which matches no spec the generator now writes — every slugged file, so
  every spec from `spec-0006` on. It returned exit 3 ("spec not found")
  for `spec-0010`, and the completion flow cannot proceed on anything but
  0, so the blocker was total: no task in the queue could be completed.
  The one-line fix and its case existed on an unpushed local branch,
  `fix/spec-deltas-slug-resolution`. Landing it separately first was the
  option that kept one kind per change; the maintainer chose to fold it in
  rather than gate this task behind a second merge, and it rides here as
  its own `fix(skills):` commit.
