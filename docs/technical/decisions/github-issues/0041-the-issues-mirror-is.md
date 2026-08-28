# the Issues mirror is severable, and the kit says so.

**2026-08-23**

The mirror was always a projection with the queue files as authority,
one direction only — nothing in the methodology reads an Issue back —
so an adopter who wants no GitHub Issues loses nothing structural by
not running it. What was missing was the statement: the kit shipped
"the four workflows" as one block, and severing two of them looked
like surgery when it is configuration. Named now, in `WRITRUN.md` and
in Distribution: delete `writrun-issues.yml` and
`writrun-progress.yml`, keep `check` and `approve`, done. For the
future CLI this is an install choice (`writ init` asking, or
`--no-issues` skipping the pair) — recorded here as intent, like the
rest of the CLI's scope, since the CLI lives in its own repository.
Rejected: a config flag the workflows read at runtime — two files an
adopter deletes need no switch, and a switch would be a second way to
say what absence already says.
