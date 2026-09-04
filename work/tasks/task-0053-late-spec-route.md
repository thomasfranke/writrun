---
id: task-0053
status: ready
blocked_reason: null
taken_by: null
spec_ref: []
doc_ref: product/stage-1-tasks-and-specs/authoring.md
origin: report
priority: low
depends_on: []
milestone: null
created: 2026-09-04T21:14:33Z
queued: 2026-09-04T21:22:06Z
completed: null
merged: null
provenance: []
---

# State the route a spec takes when it lands after its task

**References:** [product/stage-1-tasks-and-specs/authoring.md](../../docs/product/stage-1-tasks-and-specs/authoring.md)

Write the rule that recognizes the shape
[report-0030](../reports/report-0030-spec-lands-later.md) observed: a
task tracked with `spec_ref: []` gets its spec drafted later, in a pull
request of its own, whose merge is the human assent the spec's
`draft → approved` gate requires.

Two places currently deny that shape by omission and should state it
instead: the `tracked` route's "presents the report, the task and the
spec together" sentence in `authoring.md`, and `AGENTS.md`'s kind
table, whose three "PR states" cells have no match for a spec-only pull
request. The rule should also say which branch kind carries it, so
review stops flagging every such pull request as matching no kind.

Why it matters: the practice is already in use — five spec-only pull
requests followed #184 — and each future one costs a review detour
through "is this allowed?" until the answer is written down where the
kinds are defined.
