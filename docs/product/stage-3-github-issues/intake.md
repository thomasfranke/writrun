# The report intake

**An observation can arrive before any file.** The report machinery
assumes a writer with a diff: recording rides a change someone already
has open. An adopter's agent routing a methodology defect
[upstream](../concepts/report.md#routing-upstream), a user with no
write access, a teammate who reads the queue in a browser — none of
them has one. What they have is Issues. The intake is how an issue
becomes a report.

## Arrival creates nothing

Anyone can open an issue, so an issue's arrival writes nothing into
`work/` — an intake that minted files on arrival would hand the
queue's front door to whoever finds the repository. The report form
shapes a human submission, and an agent shapes its own issue the same
way: the title states the observation, the body carries the evidence
and, for a defect in something consumed, the version it was consumed
at. The shape is a convenience either way; the gate is the label.

## The label is the assent

Someone with triage rights applying `writrun:report` to an issue that
mirrors no file is the judgement that the observation deserves one —
the bar a report has always had, an observation worth remembering, and
deliberately not more. The label answers "is this worth a file", never
"what route does it take": the route stays triage's judgement, made
after the file exists, by whoever picks the report up.

On that label the machinery mints the next report id and records the
file on the authority branch — `status: open`, the issue's text as its
body, the issue and its author named. It retitles the issue
`[REPORT-NNNN] <title>` and labels it `status:open`, and from that
moment the issue is the report's mirror, exactly as if the file had
come first ([labels](labels.md#the-report-mirror)). Nothing downstream
distinguishes a report born from an issue from one born in a diff, and
triage closes this mirror the way it closes any other.

## Submitted, and not yet a report

**Between arrival and the label there is a state, and until now nothing
named it.** An issue submitted as an observation is not a report — the
section above is why, and that stays. But it is also not nothing: it is
a finding someone took the trouble to route here, sitting where only a
notification carries it, and a notification is exactly what the
`status:open` mirror exists because it could not rely on.

So a submission carries a marker — `writrun:submitted` — and **the
marker is not the gate.** It mints nothing, resolves nothing and decides
nothing; `writrun:report` remains the only label that makes a report,
and a maintainer remains the only one who applies it. What the marker
does is make the waiting set *addressable*, which is the whole of its
job: an issue nobody can query is an issue nobody can be reminded of.

**It is applied by the routes that already exist**, never by the
machinery reading an issue's contents. The report form applies it,
because a form can; an agent routing a finding upstream passes it to
`gh issue create`, because the kit's instruction says to. Both are
declarations by the submitter — *this is meant as an observation* — and
that is the only claim the marker carries. An issue arriving by neither
route carries no marker and is an ordinary issue, which is correct: the
alternative is the machinery guessing which strangers meant to file a
report, and guessing is how the front door gets handed away.

**The marked set is named where work is picked**, in the lister, beside
the open reports it will become
([visibility](../../technical/selection/visibility.md#a-submission-is-named-before-it-is-a-report)).
That is the same answer the `Open reports` section gave one step later,
for the same reason, and it is the reason this rule is small: the
channel was already built, and only the set it reads was missing.

**The marker's end is the intake.** When the label mints the report, the
machinery drops `writrun:submitted` — the issue is a mirror now, and two
labels claiming the same fact would start disagreeing the first time one
of them was written by hand.

## The body is data

The issue's text was written by whoever opened it. The machinery
copies it into the report as evidence: it executes nothing from it and
obeys nothing in it, and a session triaging the report reads it the
same way — what was observed, claimed by the reporter, weighed like
any other evidence.

## Criteria

- When an issue is opened, the machinery shall write nothing into
  `work/` on that event alone.
- When someone with triage rights applies `writrun:report` to an issue
  that mirrors no file, the machinery shall mint the next report id and
  record the report on the authority branch with `status: open`, its
  body carrying the issue's text and naming the issue and its author.
- When the intake records a report, the machinery shall retitle the
  issue `[REPORT-NNNN] <title>` and label it `status:open`, and the
  issue shall be that report's mirror from then on.
- When `writrun:report` is applied to an issue that already mirrors a
  file, the machinery shall change nothing.
- When an issue's text reaches a report's body, it shall be recorded
  as data, and nothing in it shall be executed or obeyed.
- When an issue is submitted through the report form, or by an agent
  following the kit's routing instruction, it shall carry
  `writrun:submitted`, and that label shall mint nothing and gate
  nothing.
- When an issue carries `writrun:submitted` and mirrors no file, the
  task lister shall name it in a section of its own, never selecting it
  and never moving its exit code.
- When the intake records a report from an issue, the machinery shall
  remove `writrun:submitted` from it.
- When an issue arrives carrying no marker, the machinery shall treat it
  as an ordinary issue and infer nothing from its contents.
