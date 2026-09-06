---
id: report-0037
status: tracked
task_ref: [task-0063]
doc_ref: null
created: 2026-09-06T03:58:52Z
triaged: 2026-09-06T05:30:22Z
---

# Two readers stand outside the fold, and preflight still clones the resolvers

**References:** [task-0063](../tasks/task-0063-fold-leftovers.md)

While spec-0087 folded the clone family, its body-signature sweep
surfaced two things it did not touch.

`mirror_issues.sh` carries a third front-matter reader with different
semantics on purpose: `fm_field <front-matter> <name>` reads a
delimiter-stripped front-matter *string* assembled from a patch and a
base file, unbounded by `---` lines, where "first line naming the
field wins" is load-bearing (the patch's fields are put first so they
beat the base file's). It is not a clone — `ql_fm_field_in` would
answer nothing on that input — but it wears the folded family's name,
and a reader finding two `fm_field`s with different answers has to
discover the difference the hard way.

`preflight.sh`, now sourcing `queue_lib.sh` for the field reader,
still defines `task_num` and `task_file` beside it — byte-similar to
`ql_task_num` and `ql_task_file`, and its own comment already defers
to the lib ("see ql_task_num, whose rule this is"). A resolver clone
one line away from the lib that holds the original is the shape
decision 0072 refuses, in the one file the fold's scope did not reach.
