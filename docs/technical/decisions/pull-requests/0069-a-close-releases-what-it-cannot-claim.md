# a close releases the whole claim, in every writer, because releasing is not claiming.

**2026-09-05**

[0068](0068-what-a-pull-request-claims-is-bounded.md) bounds what one
pull request may claim, and names two writers that bend the refusal: the
merge recorder, and the close arm of the in-flight recorder. Both bends
have one warrant — the write in question hands work back rather than
takes it — but 0068 states them as two exemptions, granted to two
callers it had in front of it. Stated that way, the third writer on the
same path inherited the refusal it had no reason to be under.

That writer is `project_pr_tasks.sh`. On an over-ceiling `closed` event
it exited 1, so `writrun-progress.yml`'s `reflect` job went red and the
mirror of every task the close had just released kept the label it
carried in flight. The queue said `ready`; the mirror said
`in-progress`; and because a mirror is only ever rewritten by a later
pull-request event on the same tasks, nothing came back for it. A mirror
*behind* the file catches up. A mirror *ahead* of it asserts a state the
file never held, which is the one direction
[0060](../github-issues/0060-the-merged-close-has-one-owner.md) built
the single derivation to prevent.

So the rule is one rule, and it is about the act rather than the caller:
**a close releases the whole carried set, in every writer on the path,
and the ceiling does not stand in its way.** The projector claims
strictly less than the two writers 0068 already exempted — it writes no
status at all, only restating what the Stage-2 recording has already
committed to the queue. A refusal there does not protect the queue from
a claim; it withholds the truth about a release that already happened.

**This extends 0068; it does not supersede it.** The constant stays
eight. The whole-set refusal stays whole — no writer records the first
eight of nine. The reasoning behind both, and the measurement that sized
the constant, all stand, and 0068 is true about the two benders it knew.
What is added is the general form of the exemption those two were
instances of, so a fourth writer on this path is answered by the rule
instead of by a list. The log is append-only: 0068 keeps its file, its
number, and its text ([README](../README.md)).

**The narrowing that keeps this from swallowing 0068.** Releasing is a
write toward `ready` or `backlog` with `taken_by` cleared, or a
restatement of such a write. An event that puts a task *into* flight is
claiming however it is spelled, and stays refused above the ceiling —
including a title edit, which
[spec-0077](../../../../work/specs/spec-0077-retitle-window.md) makes a
recording event for the first time. The test is what the write does, not
which event carried it.

**A refused claim released nothing, so there is nothing to undo.** The
same spec makes a retitle re-record, and an over-ceiling title is read
there as claiming no task at all rather than re-read with the ceiling
lifted. That is the corollary of the whole-set refusal: if nothing was
written under the long title, none of the tasks it named are in flight
by way of it, and the edit that brings the title back under the ceiling
records all of them. Counting a refused claim as a claim would have left
the ceiling's own heal path recording nothing.

**What this does not answer.** A retitle that *drops* a tag leaves that
task in flight, and the close cannot release it either — the close reads
the title as it then stands, so the dropped tag is invisible there too.
Releasing it needs the close arm's survivor query, because a second open
pull request may still carry the task, and that is a claim question
wearing a release's clothes. It is recorded in spec-0077's Outcome and
left open, not decided here.
