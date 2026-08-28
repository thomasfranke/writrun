# a status transition is read from the front matter at the range's two ends, never grepped out of the diff.

**2026-08-23**

The checks used
to grep the diff text for lines like `^+status: approved` — which also
match a *quoted* status line in a body, and this repository's own
chapters quote the schema at column 0. That shape produced one false
positive and two quiet routes around gates: a body edit swapping a
quoted example read as a forbidden `draft → approved`; a quoted
`+status:` line exempted an approved spec's silent edit from the
review requirement; and a quoted `status: implemented` turned an
authoring change into loop closure, waiving its derived-work
declaration. Every reader now resolves the base side of its range
(the merge base for the three-dot form, the left rev for two-dot, the
rev itself when diffing the working tree) and compares the
front-matter block at both ends — `flip_approved_specs.sh` already
wrote only front matter; now every reader agrees with it. Rejected:
locating the front matter inside the unified diff by hunk arithmetic,
which re-derives fragilely what the two endpoints already know; and a
convention forbidding column-0 status quotes in bodies — this repo's
own docs break it, and a rule that outlaws documenting the schema is
self-defeating.
