---
id: report-0035
status: tracked
task_ref: [task-0060]
doc_ref: product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet
created: 2026-09-06T02:22:46Z
triaged: 2026-09-06T02:23:18Z
---

# A pre-release review of main carries one regression and five standing faults

**References:** [product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet](../../docs/product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet) · [task-0060](../tasks/task-0060-prerelease-fixes.md)

A review of `main` at 669c452 ahead of the next release cut — the full
suite green, the template mirror byte-identical — found one confirmed
regression from #225 and five faults standing beside it.

**The bare-ref range shape drops working-tree paths from the
derived-work gate.** `check_derived_work.sh`'s `case "$RANGE"` arm for a
single ref diffs against the working tree, but the draft filter #225
added probes `BASE:` and `HEADREF:` blobs. A staged-but-uncommitted rule
chapter under `docs/` resolves at neither ref, reads as a rule at
neither end, and leaves `perm` — confirmed empirically: on a sandbox
repo with such a chapter, `check_derived_work.sh main` exits 0 with "No
permanent doc changed" where the pre-#225 script exited 1. A dropped
path turning a refusal into a pass is the failure the script's own
comments call its worst, reached by the one range shape they did not
probe. CI's three-dot invocation is unaffected; every local bare-ref
run is. The same mechanism exempts a working-tree-only marker removal.
The mirrored copy under `template/.writrun/` carries the same bytes.

**The "deleting a draft owes none" test is vacuous, and no test holds a
deleted rule to its declaration.**
`tests/integration/stage-2/derived_work/a_draft_chapter_owes_nothing_test.sh:27`
creates, edits and deletes the draft all on the feature branch with no
merge to main, so `git diff --name-only main...HEAD -- docs` is empty
(verified) and the case passes under any implementation. No case in the
directory deletes a rule either, so spec-0082's own edge — "this spec
must not make deletion cheaper than it was" — is enforced by nothing.

**The `doc_ref` draft refusal reads history as if it were live
derivation.** `check_front_matter.sh:334` fails any queue file whose
`doc_ref` points into a draft chapter, with no status filter. The
derived-work gate explicitly supports demoting a rule to a draft with a
declaration — but once one merges, every completed task and triaged
report whose `doc_ref` points into that chapter fails the sweep on
every later run, blocking unrelated pull requests until historical
records are edited.

**`check_promise_paths.sh:151` carries a private clone of
`ql_fm_field`.** Identical awk body, identical signature, in a script
#225 made source `queue_lib.sh` — whose own header records that private
clones of these helpers drifted before and hid a pipefail bug.

**The range-ends parse now exists three times, divergently.**
`check_derived_work.sh` derives `BASE`/`HEADREF`,
`check_promise_paths.sh:95` derives `BASE` alone, `check_observance.sh`
derives `BASE`/`TIP` — three near-identical `case "$RANGE"` blocks
(beside three `git_read` clones) that a range-shape bug, like the one
above, has to be fixed in three times. Two of the three already source
`queue_lib.sh`.

**The `git_read` label at `check_derived_work.sh:92` names a command
that is not the one run.** The exit-3 diagnostic prints `git diff
--name-only <range> -- docs`, but the invocation carries
`-c core.quotePath=false` and `--no-renames`; reproducing the failure
from the message runs a different command and can get a different
answer.

**Triage:** one regression and five faults rules already standing
authorize → task-0060, specs 0084–0086.
