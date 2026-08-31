# an amendment in flight suspends the task; the pause is derived, and the forge carries the relation.

**2026-08-31**

An approved spec was amended while its task rode an open pull request —
task-0021, whose completion gate refused a finished branch over a promise
that named a decisions entry but not the index row decision
[0045](../tasks-and-specs/0045-one-decision-per-file.md) makes part of it. The
amendment flow ran correctly end to end. What it never did was record
that the task was waiting: for five minutes and twenty seconds `main`
asserted `in-progress`, `taken_by` set, `blocked_reason: null`, while the
only true statement of the pause was a prose line in the suspended pull
request's body, which nothing reads. Five minutes was this case's number;
the same shape with the maintainer asleep is a night.

Nothing existing could have recorded it, each exclusion individually
sound. `blocked` is forbidden in flight (check_state rule G) so a task
with an open pull request never reads as free. `depends_on` takes task
ids, and an amendment is a `queue/` change that deliberately carries
none. And the recording script sees the amendment merge and declines to
touch the task, by design: pulled back to `ready`, the task would
advertise itself as free under somebody's open pull request — a worse
lie than silence. The gap was that *protecting the flight state* and
*recording the pause* had been one decision when they are two.

**The pause is derived, never stored.** The condition is mechanical — a
task in flight with a spec whose approval is in question — and the grain
is [0008](../tasks-and-specs/0008-ready-for-development-is.md)'s: a
stored marker, written on the amendment's opening and cleared on its
merge, would add a second writer and a new species of drift — cleared
late, the queue lies again, now with a field whose whole purpose was not
lying. What settled the shape was a measurement: during the real pause
the authority branch still showed the specs as approved — the
amendment's proposal lived only on the forge — so a marker derived from
`main` alone was wrong *by construction*, not merely redundant. The pause
is visible in exactly one place: the union of the authority branch and
the open pull requests — the same union
[0051](0051-an-id-is-unique-across-open-prs.md) already made the
definition of the queue. So it is read from there — by the lister,
which names a suspended task beside its suspending pull request, and by
the selection
algorithm's resume step, which re-checks authorization before advancing
resumed work.

**The relation is recorded where relations between pull requests live.**
The real dependency ran between two pull requests — the work waiting on
the amendment — which no queue field can name and the forge already can.
The amendment's body names the pull request it suspends; the suspended
body names what it waits on; from Stage 2 `writrun check` fails an
amendment touching an in-flight task's spec that does not carry the
reference. The one prose line this case did produce was exactly right
and exactly unread — the fix is not more prose but a check that reads
it.

Rejected: a sixth working state, or a machinery-written `paused_by`
field. Both store what the forge already knows, both cost the whole
vocabulary new edges, and the field variant fails the measurement above:
there is no event on the authority branch at the moment the pause
begins.

Rejected: relaxing rule G so an in-flight task can be `blocked`. The
rule is load-bearing — `blocked` means *a person must release this*,
and this pause is self-resolving: the amendment's merge is the
re-approval. Self-resolving conditions are `depends_on`'s family, never
`blocked`'s.

Rejected: the amendment branch carrying the task's id. `queue/` branches
are id-less precisely so tracking never reads as flight; an id would
make the carried-task machinery land the work the amendment explicitly
is not carrying.

Rejected: leaving the class alone and relying on the flow's own
discipline. The companion rule lands with this one: a spec promise that
adds a dated decisions entry includes the index row, refused where the
spec enters — the whole class of late amendment this case belongs to,
moved to the point where amending costs nothing.
