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
