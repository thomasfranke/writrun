---
id: task-0063
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0089]
doc_ref: null
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-06T05:30:22Z
queued: 2026-09-06T05:40:23Z
completed: 2026-09-06T07:24:13Z
merged: 2026-09-06T08:11:32Z
provenance:
  - {by: agent, model: claude-opus-5, login: thomasfranke}
---

# The resolver clones fold and the string reader gets its own name

**References:** [spec-0089](../specs/spec-0089-resolvers-and-a-name.md)

Finish what report-0037 left standing after the fold. `preflight.sh`
still defines `task_num` and `task_file` beside the lib it now sources
— the first a byte-clone of `ql_task_num`, the second a variant that
has already drifted from `ql_task_file` in body while asking the same
question. And `mirror_issues.sh`'s deliberate third reader still wears
the folded family's name, `fm_field`, though it answers a different
question with different semantics.

It matters under decision 0072: a resolver clone one line away from
the lib that holds the original is the exact shape the rule refuses,
and the drifted `task_file` is the hazard mid-bite rather than
waiting. The name collision is the other half — the next reader who
finds two `fm_field`s with different answers has to discover the
difference the hard way, which is what a name is supposed to prevent.
