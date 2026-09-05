# what one pull request may claim is bounded by a constant, and the constant is eight.

**2026-09-04**

Both routes into the carried set — the head branch and the title — are
the author's to write, and `writrun-progress.yml` runs on
`pull_request_target`, so a fork's title reaches the recording
([report-0028](../../../../work/reports/report-0028-fork-title-claims.md)).
Nothing bounded how many tasks a title could name: one pull request
titled `[TASK-0001]…` up to the forge's 256-character cap moved every
task it had room for to `in-progress`, `taken_by` naming its author, in
one commit on the default branch. Queue vandalism, not a compromise —
the write is two front-matter lines, reversible, and no code from the
pull request's tree runs — but the queue is what people read to decide
what to work on, and a few dozen false lines make that read worthless.

So `ql_carried_of` refuses a set of more than `QL_CARRIED_MAX=8`
distinct tasks, answering with the sentinel `over-ceiling:<count>` in
place of the ids. The count is of the deduplicated set, never of the
tags: the set is what becomes writes, so a title repeating one tag
fifty times claims one task, verbosely, and passes.

**Eight came from measurement, not feel.** Across all 111 pull requests
this repository had opened, 44 carried a `[TASK-NNNN]` tag and not one
carried two — `take_task.sh` composes exactly one, so the observed
maximum claim is one. The largest batch of related tasks any single
merge ever produced is five (#184). The ceiling must sit above five
with room and far below fifty, which is the queue. Five was rejected: a
ceiling equal to the record has no headroom, chosen from a sample whose
maximum is its only data point. Twenty was rejected: nothing measured
reaches it, and twenty tags are 220 characters of title before the
summary starts — no longer a subject read at its left edge, the one
property [0046](0046-the-task-tag-leads.md) put the tag there for.

**A partial record was rejected**, and hardest. Recording the first
eight — or only the branch's own id — is a half-applied event by
design, the failure this machinery was already fixed for twice: a
nine-task pull request reporting eight under a green run, with nothing
anywhere saying the ninth was dropped. Refusing the whole set is the
honest cost: the run goes red on the author's own pull request at the
moment they typed the title, and the refusal names the heal — close and
reopen, which re-fires `take` from `ready`. Two callers bend the
refusal, and both bend it toward writes the claim did not earn. The
merge recorder still writes what its own diff range proves and exits 0,
because a merged close fires no second event and the commit behind it is
success-gated — a red exit there would turn one refused claim into a
queue permanently unrecorded. The close arm of the in-flight recorder
still releases the whole set, because releasing is not claiming: a title
edited over the ceiling after the recording landed would otherwise leave
every task that recording moved stranded in flight, with no later event
able to free it. And the readers
that meet another pull request's over-ceiling row skip it with a
notice: failing a person's own take over somebody else's title would be
the denial the ceiling exists to prevent.

**Refusing forks by origin was rejected too**, by name. The `gate` job
already knows a fork when it sees one, and cutting fork events out of
the `record` job is one condition away. But origin answers who may
participate, the ceiling answers how much a participant may claim, and
a fork inside the ceiling is still a stranger writing `taken_by`. It is
also a change of adoption posture — many projects take every
contribution through forks — so it is an adopter's rule to choose, not
a bug fix to smuggle in beside a bound. The exposure report-0028
measured therefore stays open at eight-per-pull-request until the
origin question gets a report of its own.

**A constant, not a setting.** The schema requires a key's documented
default to be the behaviour from before the key existed, and here that
behaviour is unbounded — the defect itself. A setting controls, it
never merely describes, so an adopter writing `1000` would be switching
a safety property off; and the tag the bound rides on is already
declared unsettable in
[`titles.md`](../../settings/titles.md#pr_title_style). No environment
override either: a test that needs nine tags writes nine tags.
