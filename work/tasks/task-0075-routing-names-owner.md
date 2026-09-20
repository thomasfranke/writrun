---
id: task-0075
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0103]
doc_ref: product/concepts/report.md#routing-upstream
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-19T23:27:44Z
queued: null
completed: null
merged: null
provenance: []
---

# The kit names the repository that owns the defect, not the one the kit came from

**References:** [product/concepts/report.md#routing-upstream](../../docs/product/concepts/report.md#routing-upstream) · [spec-0103](../specs/spec-0103-routing-names-owner.md)

`.writrun/AGENTS.md`'s *When the defect is WritRun's* gives a routing
agent one address — the repository this kit came from — and `WRITRUN.md`
carries the same one and nothing else. An adopter consumes two things:
the methodology, and the `writ` binary that wraps it. Only one of them
is named in anything the kit ships.

The rule that section implements already says which repository is right:
a finding recorded downstream of *the repository that owns the defect*
is a finding lost with extra steps. The shipped instruction narrows that
principle to a single hardcoded URL, so an agent obeying it literally
routes against the rule rather than with it.

Make the shipped instruction name the owner instead of the origin — a
methodology defect to `writrun`, a defect in the binary to
`writrun-cli` — and point the composing agent at the submission shape it
already has on disk, `.github/ISSUE_TEMPLATE/writrun-report.yml`, rather
than restating three fields as a clause beside it.

It matters because report-0049's evidence is an agent that reached
`writrun-cli` on its own judgement, *against* the instruction. The next
one follows the section as written and files a `doctor` bug into the
methodology's queue, where the maintainers who can fix it never read it
— the exact loss the routing route exists to prevent.

**Not this task's to fix.** The same report shows two misses in the
submission itself: an inference stated as the consumer's implementation,
and evidence naming no repository state, stale nine minutes later.
Requiring either of those is a rule that is not true yet, and a rule is
authored, not implemented here.
