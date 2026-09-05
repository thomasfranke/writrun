---
id: task-0054
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0072, spec-0073, spec-0074, spec-0075, spec-0076, spec-0077]
doc_ref: product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-05T12:56:31Z
queued: 2026-09-05T13:33:10Z
completed: 2026-09-05T16:42:51Z
merged: null
provenance:
  - {by: agent, model: claude-opus-5, login: thomasfranke}
  - {by: agent, model: claude-opus-5, login: thomasfranke}
---

# Close the six findings the review of #199-#204 could not fix in place

**References:** [product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes](../../docs/product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes) · [spec-0072](../specs/spec-0072-suite-discovery.md) · [spec-0073](../specs/spec-0073-sentences-left-false.md) · [spec-0074](../specs/spec-0074-shared-listing-reader.md) · [spec-0075](../specs/spec-0075-spec-owed-gate.md) · [spec-0076](../specs/spec-0076-mirror-reads-landed.md) · [spec-0077](../specs/spec-0077-retitle-window.md)

Close the six findings [report-0032](../reports/report-0032-six-pr-review.md)
recorded. Each is authorized by a rule that already stands, and none
could ride the pull request that surfaced it: three would have edited
sentences outside that spec's declared deltas, and three are a
different kind of change from the one their pull request carries.

One task, six specs, because the six share nothing but their origin.
They touch the checks chapter, the status criteria, `queue_lib.sh`,
`check_state.sh`, `rederive_labels.sh`, two workflows and the test
runner — a single spec over that spread would bound nothing.

Why it matters: the last of the six is that `make test-integration`
runs 57 of 253 cases and exits 0. Until that is fixed no green from
these commands means anything, so
[spec-0072](../specs/spec-0072-suite-discovery.md) is implemented
first and the other five are verified against a suite that runs.

Three of the six depend on pull requests still open — spec-0073 on
#200 and #202, spec-0075 on #202, spec-0077 on #204 — and each spec
says which.
