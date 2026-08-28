# one decision per file, numbered — reversing part of 0037.

**2026-08-28**

[0037](0037-decisions-are-history-split.md) moved this log out of
`README.md` and rejected "a numbered ADR directory" in the same breath,
on the grounds that this methodology's default is decisions-per-subsystem
and there is one subsystem. The default still is, and there still is one
— what changed is the thing that reasoning took for granted. The log was
~600 lines when it was written; it reached 714 across 43 entries five
days later, and a tenth of them were added in a single session. A file
whose only growth direction is append, in a project that generates
entries this fast, is a file nobody opens twice.

So the log becomes a folder: one entry per file, numbered in the order it
was taken, with `README.md` as the chronological index. Append-only is
unchanged and now cheaper to honour — a new decision is a new file rather
than an edit to a file everything else links to, so two changes in flight
stop conflicting on the same three lines. They already had, twice, in the
session that prompted this.

**The number is identity**, on the same rule the queue uses for tasks and
specs: never reused, never renumbered, and a superseded decision keeps
its file and its number rather than being rewritten — the entry that
replaces it names it, as this one names 0037.

Rejected: grouping entries by subject into a handful of files, which
needs a taxonomy nobody has and re-opens the "which file does this go in"
question on every append. Also rejected: keeping `decisions.md` as a
stub that points at the folder — 0037 kept a `## Decisions` heading in
`README.md` so old anchors would resolve, and that was right for a
heading inside a file people still read; a whole file kept only to say
"moved" is a file that will be read once and maintained forever.
