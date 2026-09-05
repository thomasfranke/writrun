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

Also observed: the reopening is silent. Nothing in the run names the
collision, and a maintainer reads it as a triaged finding coming back
on its own.
