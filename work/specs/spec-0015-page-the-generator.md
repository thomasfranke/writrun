---
id: spec-0015
task_ref: task-0018
status: draft
created: 2026-08-28
---

# spec-0015 — Page the generator's forge scan

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

(filled when the task completes)
