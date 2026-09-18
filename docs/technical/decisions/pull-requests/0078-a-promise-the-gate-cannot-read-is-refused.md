# a promise the gate cannot read is refused, never read as none — and the bullet reader has one copy.

**2026-09-17**

Both gates read a Proposed-changes bullet off the backtick that follows
the dash, each with its own awk line. A bullet written any other way — a
markdown link around the path, which is the form an adopter reached for
when the promise gate refused a code path — was read by both as no entry
at all: `check_promise_paths.sh` answered "nothing to judge" and passed,
and `check_deltas.sh` later judged every touched document UNDECLARED
against an empty promise set. Seven specs sat on that pass in
`writrun-cli` until it was found by accident (report-0044).

**Refused, not tolerated.** A reader that accepted the link form too
would be a second grammar for the same promise, and the next plausible
form — bold before the backtick, the path in prose — would be silent
again. The contract already says an incomplete promise is refused where
the spec enters; a bullet the gate cannot read is that, so the promise
gate names it, quotes it, and says what form the gates read. A `none`
bullet stays the one non-backticked bullet both accept, recognised by
its leading word so an adopter's own wording after the dash keeps
passing.

**One reader, in `queue_lib.sh`** ([0072](0072-a-shared-helper-has-one-copy.md)).
The two awk lines were identical the day they were written and would
have parted the day one was fixed: a bullet refused by one gate and
read by the other is worse than silence in both.

**The word came first.** The template seeded the technical section
with *"no machinery change"*, the schema's example repeated it, and the
skill gave a path as its only example without saying paths are read
relative to `docs/`. An author who follows the word writes code paths;
the link form was the answer to the refusal that followed. The three
texts now say *technical chapter*, and the fix to the wording is why
this record sits beside the fix to the reader.

Rejected: reading the link form as a promise — a second grammar, and
the silence returns one form later; teaching the form in the refusal
only, leaving the template's word — the refusal arrives after the
author has already learned the wrong reading.
