# the merged close has one owner, and the label is the queue's to project.

**2026-08-31**

[0048](0048-a-label-names-a-place.md) found that `status:ready` was
unreachable, and half-fixed it. It added the re-derivation from the
queue and put it sequentially inside `writrun-approve.yml` — explicitly
rejecting "having the mirror read the base tree instead of the diff,
which races the approve workflow's own push". What it did not do was
stop `mirror_issues.sh` deriving a label from the diff, or stop it
answering the merged close. So the correct write landed and then lost.
The forge's own record, mirror #66:

```
15:04:48  status:proposed → status:ready     rederive_labels.sh   (writrun-approve)
15:04:51  status:ready    → status:backlog   mirror_issues.sh     (writrun-issues)
15:31:02  status:backlog  → status:ready     corrected by hand
```

Three seconds, and the same shape on #67, #70 and #71. Two properties
made it worse than a stale read. It **never healed**: the correcting
write is the recording commit, pushed with the Actions token, and such a
push triggers no workflow — there was no second event to fix the label.
And it was **selectively invisible**: a task with an empty `spec_ref`
has nothing to misread, so it landed correctly and hid the defect. Every
task born with a spec was wrong; every task born without one was right.

**Three workflows answered `pull_request_target: closed` and two wrote
the same label.** A forge offers no ordering across workflows, so this
is not a race to arbitrate — it is a question of who owns the event.
`writrun-approve.yml` is the workflow that *writes* the queue, so it is
the only one that can label a mirror from a queue already holding what
the merge decided: it flips, stamps, records, commits, pushes, then
mints and labels, all in one job. `writrun-issues.yml` and
`writrun-progress.yml`'s `reflect` stand down for a merged close and
keep every other event, the unmerged close included.

The split inside the owner is by what each input can answer. **Which
mirrors must exist** is the diff's — the queue gained exactly the tasks
the pull request added, and a fork's deferred mirror is minted here.
**What they are labelled** is the file's. So `mirror_issues.sh` mints
bare past the open event and writes no `status:` label from the merge
on; `status:proposed` stays its own, because it is the one state no file
can hold. Rejected: a shared `concurrency` group, which serializes runs
without deciding which one runs last — it would have made a defect that
was always wrong into one that was sometimes wrong. Rejected too:
teaching `mirror_issues.sh` to read the queue from disk, which is 0048's
rejection again and would still have needed the ordering this settles.

One consequence is worth naming: the recording now reports `scope` as
well as `tasks`. A task the merge creates already resting where it
belongs — an empty `spec_ref`, or specs that same merge approved —
writes no `moved` line and still owes its mirror a label. Deriving that
set a second time from the range would be a second chance to disagree
with the recording, so the recording reports it.

Two further consequences of being the only owner, both found in review
before this shipped. **The mirror steps run on `!cancelled()`, not on
success.** They sit after the recording commit, so the implicit
`success()` would have skipped them whenever the push was refused or the
rebase conflicted — and with the other two workflows standing down, that
skip is the merged close answering nothing at all: no Issue for a task
the merge added, an existing one left on `status:proposed`, and no later
event to correct either. A failed push costs the recording; it must not
also cost the projection.

**And the mint reports what it minted.** Which mirrors must exist is
derived from the pull request's files; which get labelled was derived
from the commit range `merge_commit_sha~1...merge_commit_sha`. Those two
sets are equal for a squash or a merge commit and not for a rebase
merge, where that range is only the last rebased commit — so a task file
added in an earlier one is minted and falls outside the range, and being
minted without ever being labelled is again a state nothing comes back
to fix. `mirror_issues.sh` now reports its own set through
`$GITHUB_OUTPUT`, and the projection is given it alongside `scope`. Same
rule as `scope` itself: the pass that knows the answer reports it,
rather than a second derivation getting a second chance to disagree.
