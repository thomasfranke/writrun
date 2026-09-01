# a report is an artefact, and its status is the route triage took.

**2026-09-01**

[The report entry point](../../README.md#the-report-entry-point) said it
in as many words: *"the report is a trigger, not an artefact"* — one
free-form sentence, no form, no template, no schema, everything
structured produced downstream *from* it. Reversed here.

The premise was that a report's whole value is the work it generates, so
once triage has routed it there is nothing left to keep. That holds for
the one route that generates something. It fails for the others: a
trivial fix and a rule that had to be authored each consume the report
and leave no record it was ever made — and so does the observation
nobody triaged today, which is most of them. **Small findings during
development are the common case, not the edge**, and the methodology
gave them nowhere to go but a conversation.

So `work/reports/` joins `work/tasks/` and `work/specs/`:
`report-NNNN-<subject>.md`, numbered by the same generator, an id never
reused, minted above the queue, its history and every open pull request
like any other.

**Its status is the triage route, not a lifecycle.** `open`, then one of
`tracked`, `authored`, `fixed`, `declined` — the four ways a report
ends, which are the triage table's three plus the one it never had to
name while reports evaporated. A report is never worked and never
reopened; a recurrence is a new report, because an id is never reused
and a second occurrence is a second observation.

The tempting field is `resolved`, and it is **rejected**: whether the
underlying defect is fixed is the task's status, one hop away through
`task_ref`, and a second copy of that fact would need a second writer to
keep it true — the drift this project spends its checks preventing
everywhere else. What a report knows and nothing else does is which way
it went.

**The link runs one way.** The report names the tasks triage produced;
the task schema is untouched. Symmetry with `spec_ref` was rejected: it
changes a contract that every gate, template and generator already
reads, and buys a lookup that scanning `work/reports/` answers.

**Recording rides any change.** A report is not a rule and not work — it
is a note about what was observed — so the one-kind-per-change rule does
not reach it, for the same reason a typo is a commit rather than a task.
This is a deliberate exemption and it is the whole feasibility of the
feature: a finding that costs its own branch is a finding nobody writes
down.

The status has a human or an agent writer, always — unlike a task's,
which from Stage 2 is the machinery's alone. No forge event corresponds
to "triaged", and inventing one would mean deriving a judgement from a
merge.

**A report is mirrored at Stage 3, like a task.** `open` is a state that
needs somebody looking at it, and a file nobody is prompted to read is a
file that rots — the failure this concept exists to end, not one it can
afford to introduce. The mirror carries `writrun:report`,
`status:proposed` while the pull request creating it is open and
`status:open` once it lands, and it **closes when triage ends the
report**: completed for `tracked`, `authored` and `fixed`, not planned
for `declined`. That is the report's version of the `done`/`dropped`
split the task mirror already draws, and it needs no new shape to say
it.

Rejected: a folder per status, against
[0001](0001-blocked-is-a-status.md)'s standing rule that status lives in
front matter and nothing moves between directories. Also rejected: a
`route:` label projecting which of the four ends a report reached,
symmetric with `origin:`. The close reason already separates `declined`
from the rest, and the remaining distinction is one the file answers —
a label whose whole job is saving a reader one click is a fifth thing
the machinery has to keep true.
