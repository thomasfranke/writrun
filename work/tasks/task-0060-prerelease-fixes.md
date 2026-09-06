---
id: task-0060
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0084, spec-0085, spec-0086]
doc_ref: null
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-06T02:23:18Z
queued: 2026-09-06T02:36:21Z
completed: null
merged: null
provenance: []
---

# The gates read every range shape, and read only what derives today

**References:** [spec-0084](../specs/spec-0084-bare-ref-worktree.md) · [spec-0085](../specs/spec-0085-doc-ref-history.md) · [spec-0086](../specs/spec-0086-shared-range-parse.md)

Close out everything report-0035 observed, in one change: make the
derived-work gate's draft filter see the working tree the bare-ref range
shape diffs against, give the vacuous draft-deletion test a real
scenario and the deleted rule the coverage it never had, scope the
front-matter `doc_ref` draft refusal to records that still derive, fold
the private `fm_field` clone back into the shared reader, lift the
thrice-copied range-ends parse to where the clones already source from,
and make the one `git_read` label name the command it runs.

It matters because the first of these is a refusal turned into a pass on
a gate — the exact failure class the gate's own comments name as its
worst — regressed by #225 and standing on `main` while a release is
being cut. The rest are the smaller faults the same review surfaced:
untested invariants beside that gate, a refusal that will misread
history the day a rule is demoted, and the clone-drift hazard
`queue_lib.sh`'s header exists to record.
