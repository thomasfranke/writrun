# preflight tells its arguments apart by the task list's shape, and its warning reads the end the stages read.

**2026-09-17**

`preflight.sh` sorted its two positional arguments by the presence of
`..`, so a bare ref arrived as a second task list and the run died:
`PREFLIGHT: two task lists given ('task-0001' and 'origin/main')`. And
no other shape reaches the tree — `origin/main..` and `origin/main...`
both resolve their head end to `HEAD`. The one shape every stage-2 gate
reads as "this ref against the working tree" was the one shape preflight
would not take as a range (report-0046).

**The grammar stays two positional arguments.** An argument whose every
comma-separated entry is a task id is the task list; anything else is
the range. The report offered three remedies — accept a bare ref when
one argument is already a list, take the range through a named flag, or
have preflight reduce a two-ended range itself for the stages that
should read the tree. The first, generalised: no caller changes, no flag
is invented, and the ambiguity is one word wide — a ref spelled like a
task id, a branch literally named `0034`, reads as a list and is named
as a range by writing `0034..`. Stated in the chapter rather than
guarded against, because the guard would have to know which refs exist,
and a gate that consults the ref list to parse its own arguments has
made the parse a network question.

Reducing the range inside preflight was the tempting one and is the
wrong one: it would make this script's reading of a range differ from
every other reader's, so a run and the CI job it stands for would judge
different diffs while printing the same range.

**The warning follows the range, not the checkout.** The completion
warning exists because a run made before the completion edits passes the
state gate by having nothing to read. It read `completed` from the
checkout whatever the range — so a flow that writes the edits and
commits nothing handed the stages a two-ended range without them, and
the warning, reading the file the flow had just written, fell silent.
`PREFLIGHT OK` then printed over the one change those stages exist to
judge. Reading `completed` at the range's head — the checkout for the
bare shape, the head commit otherwise — makes the warning and the
stages read the same thing, which is the only arrangement in which the
warning can be about them. A task file absent at that head reads as no
completed date, because at that end it has none.

Rejected: a `--range` flag, which changes every caller to fix one
grammar; and silently defaulting to the bare shape when a task list is
given, which would make the default depend on the other argument.
