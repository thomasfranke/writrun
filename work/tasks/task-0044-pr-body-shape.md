---
id: task-0044
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0062, spec-0063]
doc_ref: product/stage-2-pull-requests/body.md
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-04T14:51:04Z
queued: 2026-09-04T15:00:30Z
completed: 2026-09-04T19:05:00Z
merged: null
provenance: []
---

# Ship the pull request body the rule now states

**References:** [product/stage-2-pull-requests/body.md](../../docs/product/stage-2-pull-requests/body.md) · [spec-0062](../specs/spec-0062-body-references.md) · [spec-0063](../specs/spec-0063-how-to-test.md)

[`body.md`](../../docs/product/stage-2-pull-requests/body.md) now states
a shape the kit does not ship. A body still names its specs as a bare
list of numbers, the derived work as a table of numbers, a report
nowhere at all — and the links this project has written into pull
request bodies by hand resolve to nothing, because a relative path on a
`/pull/NN` page has no anchor. Nothing in the template asks how the
change is tested, so that answer lands wherever the author thinks to put
it, or nowhere.

Bring the kit up to the chapter: the template, the conventions, and
`take_task.sh`, which composes the body of every implementing pull
request and can write the bullets itself — the id from `spec_ref`, the
title from the spec's own heading, the link from the remote.

Why it matters: a reviewer decides on what the body shows them. Three
numbers with no titles is a decision made by opening three files or not
at all, and a dead link is worse than no link — it reads as navigable
until it is clicked.
