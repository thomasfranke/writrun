# a proposed task and a queued one stop sharing a label.

**2026-08-28**

`mirror_issues.sh` labelled both `status:pending`: one line,
`if [ "$open" = "true" ] || ! is_ready $refs`, covered a task an open
pull request merely proposes and a task already merged whose spec is
still `draft`. The label's own description — "Task exists; its specs
are not approved yet" — was therefore false half the time it was
applied, since a task in an unmerged pull request does not exist in the
queue at all. Anyone reading Issues, the surface this mirror exists to
serve, could not tell a proposal that may never land from committed
work waiting on approval; the two ask opposite things of a reader.
`status:proposed` takes the open-pull-request case and `status:pending`
keeps the meaning its description already claimed. Rejected: a `draft`
status on the task file itself — the obvious symmetry with a spec, and
wrong, because a spec is `draft` while already in the queue whereas a
task in an unmerged pull request is simply absent from the authority
branch. Encoding that absence as a field would give one fact two
sources, and would need the selection algorithm to exclude a state that
file-absence already excludes. The defect was in the projection, not in
the queue, so the fix stays in the projection.
