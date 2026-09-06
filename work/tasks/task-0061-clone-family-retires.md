---
id: task-0061
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0087]
doc_ref: null
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-06T03:24:39Z
queued: 2026-09-06T03:41:51Z
completed: 2026-09-06T03:59:55Z
merged: 2026-09-06T05:12:46Z
provenance:
  - {by: agent, model: claude-fable-5, login: thomasfranke, input: 176, output: 86563, cache_read: 11044941, cache_write: 125882}
---

# The eight remaining scripts stop carrying their own git_read, range parse and fm_field

**References:** [spec-0087](../specs/spec-0087-helpers-one-copy.md)

Fold the last private copies of the shared helpers back into
`queue_lib.sh`. Eight stage-2 scripts still carry their own `git_read`;
seven of those also carry their own range-ends parse, and five their own
`fm_field`. Two of the eight already source the library for something
else, so nothing about the boundary keeps the copies alive — only that
spec-0086's scope named three scripts and stopped there.

It matters because the copies are not identical any more and were never
required to be. The private range parses keep only the range's left end
and read the right side from the checkout, so on the `A..B` shape they
compare one revision against a working tree they never checked — the
same class of defect spec-0084 had to find in one copy out of three.
That search is the cost `queue_lib.sh`'s header exists to record: the
clone family has bitten this repository twice, and eleven copies of a
question with one answer is the state that makes a third time a matter
of time rather than of luck.
