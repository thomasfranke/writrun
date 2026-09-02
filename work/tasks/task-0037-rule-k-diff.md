---
id: task-0037
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0053]
doc_ref: product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-02T19:43:14Z
queued: 2026-09-02T20:30:15Z
completed: null
merged: null
provenance: []
---

# Rule K reads what the change carries, not what the branch is called

**References:** [product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not](../../docs/product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not) · [spec-0053](../specs/spec-0053-rule-k-diff.md)

Rule K decides whether a change may route a report to `tracked` by
prefix-matching the head branch against `report/`. That is the whole
test, and it tests a name.

Nothing checks the converse — that a change on a `report/` branch
carries only reporting. So the gate is clearable by renaming: a
contributor whose implementation pull request is refused can rename its
head branch and the `tracked` flip rides again beside the
implementation. That is the failure
[report-0003](../reports/report-0003-tracked-rode.md) recorded, reached
through the check instead of around it.

The rule the check exists to hold is not about names. A change that is
only recording "touches no permanent doc and implements nothing"
(`stage-1-tasks-and-specs/authoring.md`), and the branch prefix is how
such a change is *named*, never what makes it one. task-0033 built the
check to turn a rule agents keep into a gate the door holds; judged on
the name alone, it is still a rule agents keep.

Teach it to read what the change carries. What a `report/` change
touches is the report, and the task and spec the route mints — nothing
else — and that is visible in the diff without trusting anyone's choice
of branch name.
