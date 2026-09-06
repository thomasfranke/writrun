# a shared helper has one copy, and it lives in `queue_lib.sh`.

**2026-09-06**

A helper two scripts under `.writrun/scripts/` both need is defined
once, in
[`queue_lib.sh`](../../../../.writrun/scripts/stage-2-pull-requests/queue_lib.sh),
and sourced — never copied. The general form is the primitive and a
wrapper is one line: the file-reading `ql_fm_field` delegates to the
stdin-reading `ql_fm_field_in`, and a script whose call sites speak a
different argument order keeps a one-line adapter, never a second body.
The `ql_` prefix marks what is shared. The stages ship as one tree, so
a stage-1 or stage-3 script sources the stage-2 lib by relative path —
the boundary between stages is what an adopter has enabled, not what a
script may read.

The rule was a comment before it was a rule — `queue_lib.sh`'s own
header, recording that private clones of the front-matter readers had
drifted and hidden a pipefail bug — and a comment binds nobody. Under
it the family kept growing: the bare-ref defect spec-0084 fixed had to
be found in one copy out of three, and the sweep that followed
([report-0036](../../../../work/reports/report-0036-wider-clone-family.md),
spec-0087) retired twenty-three copies across eleven scripts — two of
the scripts already sourced the lib for something else, one clone wore
a different name (`fm`, arguments swapped), and nine failure labels
had drifted from the commands beside them. Three incidents and a fold of
that size are the evidence: per-script self-containment is not a style
choice, it is a defect with a delay on it.

Enforced two ways, and the split is deliberate:
`tests/unit/queue_lib/no_private_copy_survives_test.sh` refuses the
known clones by name and by awk body — a body cannot be renamed past a
grep the way a name can — and this entry covers what a grep cannot
see: a clone with a new name and a new body is refused here, at
review, where the diff shows a second definition of a question the lib
already answers.

Rejected: per-script self-containment — the original state; three
incidents are its record. Rejected: a scripts-wide lib beside the
stage folders — nothing needs it that sourcing `queue_lib.sh` across
stages does not give, and a second shared home is a second place to
look for one answer.
