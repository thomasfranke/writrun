# `writrun-create-task-and-spec` gains a generator script (`new.sh`).

**2026-08-21**

A hand-written task deviated from the documented schema on
four fields (scalar `spec_ref` instead of a list, a bare filename instead
of a path+anchor for `doc_ref`, missing `blocked_reason`/`created`/
`completed`) while drafting this repository's own `product/` chapters —
direct evidence that prose instructions alone don't reliably prevent this
class of drift. Rejected: leaving `writrun-create-task-and-spec` prose-only, on
the same reasoning that already put a script behind `writrun-check-spec-deltas` —
a mechanically checkable step should be checked mechanically.
