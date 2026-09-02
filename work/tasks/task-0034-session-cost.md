---
id: task-0034
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0045, spec-0046, spec-0047, spec-0048, spec-0049, spec-0050]
doc_ref: about.md#personas
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-02T06:02:19Z
queued: null
completed: null
merged: null
provenance: []
---

# Cut the per-session reading cost of running the methodology

**References:** [about.md#personas](../../docs/about.md#personas) · [spec-0045](../specs/spec-0045-technical-chapters.md) · [spec-0046](../specs/spec-0046-lean-skills.md) · [spec-0047](../specs/spec-0047-task-brief.md) · [spec-0048](../specs/spec-0048-take-script.md) · [spec-0049](../specs/spec-0049-preflight-gate.md) · [spec-0050](../specs/spec-0050-session-card.md)

Make a working session cheap to start and cheap to run: an agent taking
a task reads the process material that task needs — not the whole of
it — and the flows that are mechanical (taking, briefing, the
completion gates, recovering the settings) run as one scripted act each
instead of being re-derived from prose every session.

Why it matters: [report-0004](../reports/report-0004-session-cost.md)
measures the prescribed reading path at ~97KB (~22–25k tokens) per
implementing session before any work starts, with the single largest
cost a 57KB technical README read whole for one section, and the
skills' prose restating what their own scripts already compute. The
cost is O(project): every task, spec and decision added makes the next
session more expensive, so it compounds exactly as the methodology is
exercised — the maintainer is already seeing sessions slow and token
spend grow. `about.md#personas` states the standard this violates: the
agent persona "needs a deterministic answer … that doesn't require
reading the whole repository to find out".

Six specs carve the work, in intended order: the technical README
becomes a router over chapters (spec-0045), the skills slim to
run-and-interpret with the prose living once in the docs (spec-0046),
and four mechanical flows gain a script each — the task brief
(spec-0047), the taking act (spec-0048), the completion gates
(spec-0049), and the settings an agent obeys (spec-0050).
