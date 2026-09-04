# Visibility

**What the files can show about work in flight, and what only the forge can.** One chapter of [`selection/`](README.md).

## Where step 0 can see, and where it cannot

From Stage 2 up the authority branch is the complete mirror, so an
in-flight task is visible on any current checkout. What step 0
distinguishes is whether the forge still shows an open pull request for
it: with one, the task is someone's; with none, the flight state is stale
and the task is resumable. Three things the files alone cannot show:

- **The recording window** — a draft opened seconds ago, whose commit is
  not yet on the authority branch. Only the forge query covers it.
- **A branch never pushed, or pushed without a pull request** — visible
  nowhere. This is the hiding place the taking flow closes by opening the
  pull request as a draft *before* the work starts; when resuming on a
  shared machine or checkout, the branch list is the last place to look.
- **An amendment still riding an open pull request** — the specs on the
  authority branch read `approved` for the whole window it is open, so
  the files report a healthy queue while the task cannot move
  ([statuses](../../product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request)).
  The forge query covers it; without one, the pause is reported as
  possibly hidden rather than absent.

## An open report is named, never selected

The lister prints a fifth section, after `Held back`, naming every report
whose `status` is `open`. It exists because `open` is the one state that
asks something of a person, and below Stage 3 nothing was asking: the
Issues mirror carries the ask to the forge, and every project under it
was left to remember a `grep`. The session picking work is the reader
most likely to act, and it is already running this script.

**Naming is not selecting, and two properties hold that line.** An open
report never enters the ordering, so it is never handed over as the
thing to take; and it never changes the exit code — 0 still means a task
is available, 1 still means none is. Both matter more than the section
does: `work/reports/` becoming a second queue is the failure the
[report concept](../../product/concepts/report.md#two-invariants) is built
to prevent, and a caller branching on the status would otherwise start
seeing work that is not work.

**The move the section asks for is triage**, never implementation. A
report is read and given an end — `tracked`, `authored`, `fixed`,
`declined` — and only the `tracked` route produces work, through a
reporting change of its own whose merge is the assent. A section naming
what is waiting without naming what to do with it reproduces the very
situation it was built for: a session with nothing available reads the
list, has nothing to do with it, and stops.

**A long list is the point.** The section grows with the reports, and
that pressure is the design — a queue asking to be triaged, not a
display problem to solve by truncating.

