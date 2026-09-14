# a marker is not a gate, and the submitter is the only one who applies it.

**2026-09-14**

Between an issue arriving and a maintainer labelling it there was a
state nothing named, and nothing could query. Issue #155 was routed here
from `writrun-cli` on 2026-09-04 by the kit's own instruction, never
carried a `writrun:` label, and was closed by hand: no report was born
from it and its evidence never left the forge. The same defect reached
the queue only because it was seen locally that morning and written down
as `report-0019`. Issue #161, the same day, was intaken correctly. The
difference between the two was that somebody remembered.

**`writrun:submitted` is applied by the submitter, never inferred.** The
report form sets it, and the kit's routing instruction passes
`--label writrun:submitted` to `gh issue create`; both are declarations
by whoever opened the issue — *this is meant as an observation* — and
that is the only claim the label carries. Rejected: having the intake
read an issue's title or body and decide it looks like a report. That is
the machinery guessing which strangers meant to file one, and guessing
is how the front door gets handed away — the property
[0011](0011-the-github-issues-mirror.md)'s one-direction mirror and the
"arrival creates nothing" rule exist to hold. An issue arriving by
neither route is an ordinary issue.

**The marker mints nothing, and the gate does not move.** A maintainer
applying `writrun:report` is still the only thing that makes a file, and
`intake_report.sh`'s refusals are untouched — including for this label,
which reaches the same "not the gate" arm every other label does. What
the marker buys is that the waiting set is *addressable*: the task
lister names it in a section of its own, above `Open reports`, and the
two are one ask at two ages. Rejected: a second gate, a second minting
path, or any reading of the marker by the workflows. A label nobody
could query was the whole defect; a label that decided something would
be a different one.

**It is removed at the intake, not kept as history.** The moment the
report is minted the issue is that report's mirror, and the mirror's
labels name a place inside the pipeline
([0048](0048-a-label-names-a-place.md)). A marker left behind would be a
second label claiming the same fact as `status:open`, and two of those
start disagreeing the first time one is written by hand. Rejected:
keeping it as a record of how the issue arrived — the record is the
report's body, which names the issue and its author, and the file is the
authority from there. The removal is a `DELETE` that tolerates a 404: an
issue routed by hand carries no marker and is owed no removal.

**The lister filters on "carries the marker *and* mirrors no file",
never on the label alone.** The label is a convenience for querying, not
a record, so nothing prevents it being applied by hand to an issue that
is already some file's mirror — and nothing should. The second half is
what makes that harmless. Both answers are asked for it: the
`[REPORT-NNNN]` or `[TASK-NNNN]` tag, which is the forge's own word for
a mirror and the read the intake makes before it mints; and the
`Issue #N` line every minted report opens with, because the retitle is
the intake's *last* write. A run that died between the push and the
retitle left the file on the authority branch, the issue untagged and
the marker still on it — and a title is a stranger's to edit besides.
The file, not the title, is what says a report exists.
