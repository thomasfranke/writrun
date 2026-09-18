# a proposed triage is not a triage, so a report mirror's close waits for the merge.

**2026-09-18**

`mirror_issues.sh` derived two things for a report from one diff row,
and only one of them asked whether the pull request had merged. The
**label** asked: an open pull request offers a report, so its mirror
read `status:proposed`. The **close** did not. A diff carrying
`tracked`, `authored`, `fixed`, `routed` or `declined` retired the Issue
where it stood, on a branch nobody had merged.

The forge's own record, three times in two days:

```
2026-09-17 19:48:12  #273 opened (triages report-0045)
2026-09-17 19:48:34  #268 closed completed          — 22s, PR open
2026-09-17 19:52:46  #269 closed completed          — PR #275 open
2026-09-18 17:18:26  #284 opened (triages report-0048)
2026-09-18 17:18:52  #282 closed completed          — 26s, PR open
```

Each time the authority branch still held the report `open`, and the
lister still listed it under *Open reports*. The two channels the
concept relies on disagreed for the length of each review — and the one
state the report mirror exists for is exactly the one that went missing.
`status:open` is *"a report nobody is prompted to read is a report that
rots"*; a closed Issue prompts nobody.

**The answer was already in the file, twice.** The task loop never
closes on an open pull request — [0044](0044-a-proposed-task-and.md) —
and a report *born* in a diff is mirrored `status:proposed` for the same
structural reason: the file is not on the authority branch yet. Only a
report whose **triage** was in flight was answered from the diff, and no
rule asked for that.

So the close belongs to the merge, and in the open window the label is
read from the base branch this workflow checks out — the same two
helpers, giving the same three answers, as the reconciliation that
answers a pull request closed unmerged: the branch does not carry the
report, so it is proposed; the branch carries it untriaged, so it is
open; the branch carries it triaged, so its mirror is closed and this
pull request is not what reopens it. The merge needs nothing new —
`mirror_issues.sh` runs there with `merged=true`, where the diff has
landed, and `rederive_labels.sh` projects from the queue as it then
stands.

This narrows [0060](0060-the-merged-close-has-one-owner.md)'s clause
that `status:proposed` is *"the one state no file can hold"*, for reports
only: a report's mirror in the open window can also read `status:open`,
which a file does hold, because the question that window asks is not
"what does this diff propose" but "what does the branch say today".

**Rejected: close early, and let the close heal it.** The reconciliation
for a pull request closed unmerged already restores a mirror an
abandoned branch closed, so the end state was never the defect — the
window was. Healing treats a correct state as drift and still leaves the
Issue gone for the whole review.

**Rejected: a label for the in-flight triage.** A fourth state — a
report *proposed triaged* — is one more thing for the machinery to keep
true, against [0048](0048-a-label-names-a-place.md)'s rule that a label
names a place in the pipeline. The report is in the place it was in: the
queue holds it open.

**Rejected: teaching the lister to skip a report a branch has triaged.**
The lister reads the authority branch and was right both times. Moving
the drift to the reader that had it correct is how two channels become
two rules that agree today.

One consequence is worth naming. **A report born already triaged now
stands open for the length of a review.** Recording rides any change, so
a report can arrive `fixed` or `declined` in an open pull request; it
used to be created closed and never stand as an open item. It is now
created `status:proposed`, which is honest — it is not on the authority
branch — and is what a task's mirror has always done, but it does put
one open Issue in the list until the merge. Born closed stays the
answer at the merge, where the file has landed.

And one window is left open on purpose: a pull request that neither
merges nor closes reconciles against nothing, so its report's mirror
holds whatever the branch last justified. That is now a mirror agreeing
with the queue rather than one contradicting it.
