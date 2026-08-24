---
name: writrun-check-spec-deltas
description: Use this skill before merging or completing a task in a project that follows the WritRun methodology — when the user asks to check, verify, or validate a spec against a diff, or before marking a spec as implemented. Verifies the diff touches every doc path promised in the spec's Proposed changes sections and nothing else permanent.
---

# Check spec deltas

Verifies a completed change against the merge contract a spec made when it
was drafted: the **Proposed product changes** and **Proposed technical
changes** sections list every permanent doc path the change should touch —
this skill checks that mechanically, rather than asking anyone to
self-attest.

## Why this is a script, not a prompt

This is the one WritRun check that must not be graded by the same agent that
made the change: "did I update everything I promised" is exactly the
question an agent under time pressure tends to answer generously. Path
presence in a diff is objective — so it's checked by
[`check_deltas.sh`](check_deltas.sh), a small deterministic script, not by
asking an LLM to review its own diff.

## Steps

1. Identify the spec id for the change being completed (e.g. `spec-004`).
2. Run:
   ```bash
   bash .writrun/skills/writrun-check-spec-deltas/check_deltas.sh spec-004
   ```
   Pass a specific diff range as a second argument if the default
   (working tree vs. `HEAD`) isn't right — e.g. a branch comparison:
   ```bash
   bash .writrun/skills/writrun-check-spec-deltas/check_deltas.sh spec-004 main...HEAD
   ```
   A change that implements **several specs at once** — completing a
   multi-spec task in one change — passes them all in one call,
   comma-separated:
   ```bash
   bash .writrun/skills/writrun-check-spec-deltas/check_deltas.sh spec-004,spec-005 main...HEAD
   ```
   MISSING is still judged per spec (each contract must be honoured in
   full, and the report names which spec's promise went unmet); UNDECLARED
   is judged against the union of their promises. Never run the specs one
   at a time against the same diff — each sibling's promised docs would be
   reported as undeclared for the other.
3. Read the exit code and output:
   - **0 / "OK"** — every promised path was touched, nothing undeclared in
     `docs/product/` or `docs/technical/` was modified. Safe to mark the
     spec `implemented` and the task `completed` (see the
     `writrun-create-task-and-spec` skill for how).
   - **1 / "MISSING"** — a path listed in Proposed changes was not touched.
     Either the doc update was forgotten, or the spec's promise was wrong
     and should be corrected — don't silently mark the task complete either
     way; ask the user which it is.
   - **2 / "UNDECLARED"** — a permanent doc outside the promise list was
     modified. Either the spec's Proposed changes section was incomplete
     (add the missing entry and re-run) or the change touched something it
     shouldn't have — surface this, don't paper over it.
   - **3** — usage error, the spec file wasn't found, or `git diff` failed
     (no git history yet, bad diff range); fix the invocation, or verify by
     hand if the repository has no history to diff against.

   MISSING and UNDECLARED can both occur in one run — every line prints, and
   the exit code is 1 when both are present. Read the output, not only the
   code.

## Never

- Never mark a spec `implemented` or a task `completed` on an exit code
  other than 0.
- Never treat a MISSING or UNDECLARED result as something to quietly fix by
  editing the spec's Proposed changes to match whatever the diff happened to
  do — that defeats the point of the contract. Surface the mismatch and let
  the user decide which side was wrong.
- Never skip running the script because "the change was small" — the check
  costs one command; a doc that silently drifted from the code costs more
  later.
