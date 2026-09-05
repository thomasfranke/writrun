---
id: report-0031
status: open
task_ref: []
doc_ref: null
created: 2026-09-05T11:47:09Z
triaged: null
---

# An id the mirror still holds is minted again

In adopter `writrun-cli`, `report-0001` was minted on pull request #17
and removed from that branch before the merge; the squashed commit
carries no such file. Its mirror, Issue #18, kept the id and the title.
Minting a report on pull request #20 produced `report-0001` again, and
the mirror answered by **reopening** the triaged Issue #18 and
rewriting its `Introduced by` row to #20 — leaving an open Issue whose
title and body describe an unrelated finding about `take_task.sh`,
attributed to a pull request that never mentioned it.

`ql_next_id` reads three inputs (`queue_lib.sh:206-244`): the
directory, `git log --diff-filter=A` over it, and `QL_FORGE_PATHS` from
**open** pull requests. A file that only ever existed on a branch whose
merge dropped it is in none of the three — while the mirror, which is
the durable record of the id, is consulted by none of them either.
`TASK-0013` made ids unique across open pull requests; a closed one's
ids and the mirror's own are the gap left.

Repairing it downstream surfaced two more of the same shape, and all
three read a change the same way. `check_unique_ids.sh:130` collects
`--diff-filter=A` and compares it against `git ls-tree` of the base, so
a change that renumbers a file to free an id and then claims that id is
reported as a collision with itself; the repair had to be split across
two pull requests it cannot see are one. `mirror_issues.sh:321` collects
reports with `case "$fstatus" in added|modified) ;; *) continue ;; esac`,
and the forge reports a renumbered queue file as `status=renamed` — so
the file was skipped, the new id was minted no Issue, and the old Issue
kept a title describing something else. A report with no mirror is one
nobody can triage.

**The machinery reads additions and modifications, and a rename is
neither.** That is the one blind spot behind the reuse, the false
collision and the missing mirror.

Also observed: the reopening is silent. Nothing in the run names the
collision, and a maintainer reads it as a triaged finding coming back
on its own.
