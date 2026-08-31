# the provenance ledger lives in the queue, and the agent's own transcript is a source, never the store.

**2026-08-31**

A task names whoever currently holds it and nothing about what the work
cost. `taken_by` looks like the missing half and is not, for two reasons
its own spec already stated: it is **cleared** every time a task returns to
the queue, so it cannot be summed over a quarter; and it carries the pull
request author's login, which on agent-driven work is the person who ran
the agent. It answers *under whose supervision* exactly, and *which agent*
never. spec-0019 said as much when it was built — *"the field is a pointer,
not a ledger"* — and this entry is the ledger it declined to be, not a
reinterpretation of the pointer.

**Where the numbers come from was the real question.** They exist: an agent
platform records, per message, the model and the full token usage, and this
repository's own sessions carry a git branch on every one of them — so
`task/NNNN-short-name`, a convention the methodology already had, is the
join key, and a per-task cost report can be produced today from files
nobody wrote for the purpose. Running it over this repository's own history
returned nineteen tasks with their models and counts.

That prototype is also the argument against making it the mechanism. The
data sits outside the repository, in one vendor's directory, on one
machine: absent from CI, absent from every other contributor's checkout,
prunable, and meaningless to an adopter on another platform. A methodology
whose claim is that *the repository answers* cannot answer from a file the
repository does not contain. So the entry is written **into the task**, at
completion, by whoever did the work — the platform's usage data is what
fills it in, and a reader of that data ships as a helper, never as the
record. Any agent anywhere can write a number; a person can write one by
hand; and the answer lands in the pull request diff, where it is reviewable
before it is trusted.

**Counts, not money.** Cache reads outrun the other columns by around two
orders of magnitude, so a ledger that priced only input and output would
not be imprecise, it would be wrong. And a stored currency figure becomes
false the moment a price changes, silently and retroactively. The entry
keeps the four counts the platform reported; conversion happens when the
question is asked, against the rate card of the day.

**Using an agent is not obligatory, and the shape says so.** `human` is an
actor in the vocabulary, not the absence of one: a task worked by hand
records a person's entry with no model and no counts, and no check may read
that as a gap. The proportion the ledger exists to report is only
meaningful because the human share is written down beside the agent's.

`provenance_ledger` therefore defaults to `false` — no ledger existed
before the key, and a project that keeps none satisfies every check by
keeping none. It sits in `stage_1` by the test
[0055](0055-conduct-flags-live-in-stage-2.md) set: the thing it governs is
a field in a task file, and task files are all Stage 1 has. No commit is
needed for a ledger to exist.

Rejected: deriving the report from the transcripts at query time and adding
no field. Cheapest by far, and it answers only on the maintainer's laptop,
only while the transcripts survive, only for one vendor's agent.

Rejected: entries as block mappings, each key on a line of its own. The
readers here are line-based and would see nothing; one flow mapping to
the line keeps the ledger greppable by the same tools that read every
other field.

Rejected: reporting a fraction of **lines** written by an agent. Agent work
is reviewed, edited and squash-merged by a person before it lands, so line
attribution after the fact is invention. The ledger reports work and spend
per task and the commits report participation; neither is a line count, and
promising one would have been the most quotable and least defensible number
in the file.

Rejected: letting the ledger feed review, priority or any gate. It is a
record, in the same sense `taken_by` is one — WritRun's non-goals rule out
a tracker, and a cost field that decided anything would be the tracker
arriving through the back door.
