---
id: spec-0015
task_ref: task-0018
status: implemented
created: 2026-08-28T00:00:00Z
---

# spec-0015 — Page the generator's forge scan

**References:** [task-0018](../tasks/task-0018-generator-truncates.md)

## Scope

`new.sh`'s `forge_scan`, and the reasoning recorded around it.

In scope: how the generator asks the forge which paths open pull
requests touch. Out of scope: `check_unique_ids.sh`, which already reads
the file list a page at a time and is correct; and the id format.

## Steps

1. Replace the single `gh pr list --json files` call. That field is
   capped at 100 files per pull request and says nothing when it
   truncates, which is the whole defect.
2. Ask the same question `check_unique_ids.sh` asks: the open pull
   request numbers, then each one's file list through
   `gh api repos/OWNER/REPO/pulls/N/files --paginate`. One call per open
   pull request instead of one call total — the correct answer is worth
   more than the round trip, and the generator runs once per new file.
3. Keep the two consumers' shapes distinct on purpose: the check needs
   each file's `status`, the generator needs only the path. Sharing the
   call must not turn into sharing a claim rule — a modification is
   still not a claim, and folding one in still only raises the maximum
   toward a number already taken.
4. Correct the reasoning in `spec-0010`'s Outcome by reference, not by
   editing it: it argued the coarser question was "strictly safe", and
   the cap is the case that argument missed.

## Acceptance criteria

- When an open pull request adds a queue file beyond the first 100 files
  of its diff, the generator shall mint above that file's id.
- When several pull requests are open, the generator shall fold in every
  one of their queue files.
- When the forge does not answer, the generator shall mint from the tree
  and history and report its local-only view, as it does today.
- When no pull request is open, the generator shall mint exactly as it
  does from the tree and history alone.

## Edge cases

- A pull request whose file list is itself longer than one page —
  `--paginate` is what this spec is about, so the case is the point, not
  an aside.
- A very large number of open pull requests: the existing 200-PR limit
  still applies and still reports when it is hit.
- A fork's pull request: read like any other, since only paths are read
  and nothing is executed.

## Tests required

One case per acceptance criterion, in the `new` suite. The forge stub
gains a per-pull-request file list, the way the `unique_ids` suite's
already has one, including a case whose list spans more than one page.

## Definition of Done

- `make tests` green, including the new cases.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — the rule is already written in `product/pipeline.md`; this is the
machinery failing to honour it.

## Proposed technical changes

none — `technical/README.md` states the uniqueness rule and does not
describe how the generator asks.

## Outcome

Done as specified. `forge_scan` asks `gh pr list --json number` for the
open pull requests, then `gh api repos/{owner}/{repo}/pulls/N/files
--paginate --jq '.[].filename'` for each one's paths. The 100-file cap
that hid a 168-file pull request's whole queue contribution is gone: the
generator now mints above a queue file wherever it sits in a diff.

Four cases in the `new` suite, one per criterion — a queue file on the
105th file of a pull request, several open pull requests folded in at
once (tasks and specs numbered apart), an unavailable forge, and an empty
open list. The stub was checked against the defect rather than only
against the fix: with `--paginate` removed from the call the page case
fails and the other three still pass, which is what makes it a test of
this change and not of the stub.

`spec-0010`'s Outcome argued the coarser question — one
`gh pr list --json files` for every path — was "strictly safe". It is
safe about *modified* files, which is what that paragraph was reasoning
about, and wrong about completeness: the field it used stops at 100 files
per pull request without saying so. The correction is recorded here and
in `forge_scan`'s comment; that spec's body is history and stays as
written.

Four divergences:

- **A partial forge answer is treated as no answer.** Criterion 3 names
  the forge not answering; it does not say what a scan that answers for
  three pull requests and fails on the fourth should report. The scan is
  all or nothing — any failed call leaves `FORGE_VIEW` local and
  `FORGE_PATHS` empty. Keeping the paths already collected would mint
  higher, but the mint report would then claim a forge-wide view it did
  not have, and a scan that under-reports its own narrowness is the whole
  failure this task exists for.

- **The endpoint is addressed with `gh api`'s `{owner}/{repo}`
  placeholders**, where `check_unique_ids.sh` interpolates the
  `owner/repo` it is passed. The generator takes no such argument and
  should not grow one for this: it already infers the repository the same
  way `gh pr list` does, and if that inference fails, so did the call
  that precedes it.

- **The stub had to model the page boundary, not just the per-PR list.**
  Step 5 asked for a per-pull-request file list and a case spanning more
  than one page. A list the stub always serves whole cannot express that
  case — nothing would distinguish a paged call from an unpaged one. So
  `stub_forge` serves `$FORGE_PAGE` (100, GitHub's own) entries unless
  `--paginate` is passed, and it tells the two consumers apart by their
  jq expression, since both now read the same endpoint for different
  halves of it.

- **Two bare `created` dates were widened here, which this scope did not
  cover.** `task-0014` and `spec-0011` merged with PR #29 after the
  timestamp migration and were never migrated — the concurrent change
  `spec-0008`'s Scope predicted. `make tests` had been red on `main`
  since, on `repository_queue_is_canonical_test.sh` and on the release
  path that runs the suite, so this spec's Definition of Done was
  unreachable without touching them. Offered a separate fix PR or a
  fold-in, the maintainer chose the fold-in; it rides as its own untagged
  `fix(schema):` commit. Widening `spec-0011` edits a body under an
  approval, so it returns to `draft` in that commit and
  `flip_approved_specs.sh` flips it back on the merge.
