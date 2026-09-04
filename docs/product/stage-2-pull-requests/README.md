# Level `pull-requests`

What git and the forge add to [`tasks-and-specs/`](../stage-1-tasks-and-specs/README.md):
commits and branches, pull requests, CI, merge as assent. **This is
where git begins** — Stage 1 needs nothing but files, so everything
about commits lives here: the
[commit conventions](../../../.writrun/conventions/commits.md), the
adopter's word on the agent's own git actions (`auto_commit`) and on
whether the agent appears as a commit's co-author (`agent_coauthor` —
[settings](../../technical/settings/schema.md#settings)), and the
machinery that turns forge events into status lines. Nothing here is
required to claim adoption — it is mechanical enforcement of what a
person at Stage 1 does deliberately.

| File | Covers |
|---|---|
| [`setup.md`](setup.md) | the forge configuration — what is set, the owner-assent gate, and the commands an agent runs |
| [`statuses.md`](statuses.md) | the status machinery — forge events projected onto the queue, one writer per status line |
| [`taking.md`](taking.md) | flow 3 — taking a task, and the draft that reports it |
| [`finishing.md`](finishing.md) | flow 4 — the two checks and their order |
| [`approval.md`](approval.md) | flow 2 — the assenting act, and what records it |
| [`review.md`](review.md) | flow 5 — review and merge, and the pull request that dies |
| [`body.md`](body.md) | the pull request body — the three declarations, their links, and how to test |
