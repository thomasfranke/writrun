# Mirror labels

**The mirror projects the file, one to one.** Since the authority
branch now stores every pipeline state the moment its forge event lands
([statuses](../stage-2-pull-requests/statuses.md)), the `status:` label has
nothing left to derive: it restates the stored status, plus the one
state the file cannot hold. One label per state, no state sharing a
label with another:

| Label | The task is |
|---|---|
| `status:proposed` | proposed by an open pull request — not in the queue. The PR may still close unmerged, and the mirror retires with it. The one label with no stored twin, and the reason it cannot have one is structural: the file is not on the authority branch yet. |
| `status:backlog` | in the queue, with a spec it references not yet `approved`. |
| `status:ready` | ready for development — waiting for someone to take it. |
| `status:in-progress` | being worked on — an open draft PR, `taken_by` says by whom. Leave the worker alone. |
| `status:in-review` | waiting on review — the maintainer is the blocker. |
| `status:blocked` | stalled by something outside the queue — `blocked_reason` says what. |
| *(none — the mirror is closed)* | out of the pipeline: closed **completed** for `done`, closed **not planned** for `dropped`. |

**The mirror also says where the task came from.** Alongside its
`status:` label, every mirror carries one `origin:` label projecting
the task's stored `origin` field — `origin:rule` for a task derived
from an authored rule, `origin:report` for one born from a report — so
a reader scanning the Issues list tells planned rule-work from
reported defects at a glance, without opening anything. Unlike the
`status:` labels it never changes and never comes off: origin is a
fact about the task's birth, so it stays on the mirror through every
state, closed included.

**A closed mirror carries no `status:` label.** Every label above names a
place *inside* the pipeline, so any of them on a closed mirror is a
leftover from the step before last — and a leftover is not merely
useless, it is false: an issue closed as completed reading
`status:in-review` says the maintainer is still the blocker. The close
itself, with its reason, is the terminal state, and it is one the forge
records rather than one anybody has to remember to write.

**The label follows the file, after every recording commit.** The
machinery that writes a status onto the authority branch re-labels the
mirror from the queue as it then stands — never from a merge's own
diff, which reports what a merge *carried* and misses what it *caused*
(the merge that brings a task in is the merge that approves its specs,
so its diff still reads them `draft`).

## The report mirror

**Reports are mirrored too, as a separate kind.** A report's mirror
carries `writrun:report` where a task's carries `writrun:task`, and is
titled `[REPORT-NNNN] <report title>` — the same shape as a task's, so
the same lookup finds it and the two never meet in one filter.

| Label | The report is |
|---|---|
| `status:proposed` | proposed by an open pull request — not on the authority branch yet. The same structural reason a task's mirror has one. |
| `status:open` | recorded, awaiting triage. **This is the state the mirror exists for**: a report nobody is prompted to read is a report that rots, and rotting is the failure the concept exists to end. What the open Issue asks for is the evaluation — choose the route — never the fix itself; work enters the queue only through the `tracked` route's own reporting pull request ([report](../concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not)). |
| *(none — the mirror is closed)* | triaged, and out of the pipeline: closed **completed** for `tracked`, `authored`, `fixed` and `routed`, closed **not planned** for `declined`. |

The five ends collapse into two closes on purpose. A `route:` label
would carry the remaining distinction, and it is not worth a fifth
thing for the machinery to keep true — the file says which route was
taken, and the close already separates the report that was acted on
from the one that was not.

**A report's mirror can precede its file.** An observation from outside
the repository arrives as an issue first; the maintainer's label mints
the file, and the issue becomes its mirror from then on
([intake](intake.md)).

**A report's mirror carries no `origin:` label.** Origin is a fact about
how a *task* came to exist, and a report is one of the two answers to
it; a report has no origin of its own to project.

**Triage closes the mirror, and a task's mirror is what opens next.** On
the `tracked` route the report's Issue closes and the task's appears
beside it carrying `origin:report` — two Issues, linked by the ids their
titles spell. Nothing converts an Issue from one kind into the other.

**A pull request title never carries `[REPORT-NNNN]`.** The bracketed
tag on a PR title is how the machinery learns which *tasks* the pull
request carries; a report id there would be read as work in flight that
nobody is working.

## Criteria

- When a task is mirrored while the pull request that creates it is still
  open, the mirror shall report it as proposed, distinctly from a task
  the queue already holds.
- When a mirror is closed, it shall carry no `status:` label.
- When a task reaches `done`, the machinery shall close its mirror as
  completed; when a task is `dropped`, the machinery shall close it as
  not planned.
- When a recording commit changes a task's stored status, the machinery
  shall re-label that task's mirror from the queue as it then stands,
  rather than from the merge's own diff.
- When a task is mirrored, its mirror shall carry the `origin:` label
  matching the task's stored `origin`, and the label shall stay on the
  mirror through every state, closed included.
- When a report is mirrored, its mirror shall carry `writrun:report` and
  a title naming the report's id, distinctly from a task's mirror.
- When a report is recorded and awaiting triage, its mirror shall report
  it as open.
- When a report is triaged, the machinery shall close its mirror — as
  completed for `tracked`, `authored`, `fixed` and `routed`; as not
  planned for `declined`.
