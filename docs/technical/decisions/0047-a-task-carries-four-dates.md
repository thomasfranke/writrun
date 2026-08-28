# a task carries four dates, and who writes each is the contract.

**2026-08-28**

A task recorded `created` and `completed`, both written by hand on the
branch. That was honest about the work and silent about the project:
`completed` is when the worker finished, and nothing recorded when the
project took it. In a repository that merges the same day the two look
identical, which is exactly why the gap went unnoticed here — anywhere
review takes a day, `completed` is systematically early.

Two dates are added, and the split is **who writes them**, not what they
mean. `queued` is the merge that brought the task into the queue;
`merged` is the merge that took its work. Both are written only by the
machinery, after the merge each records. A hand-written date cannot
honestly record a merge: it would have to be typed before the event it
claims to describe. `created` and `completed` stay hand-written and keep
their meanings unchanged.

This became possible only with
[0043](0043-the-merge-is-this.md): before the assenting act moved to the
merge, nothing in this project wrote to `main` after one, so a post-merge
stamp had nowhere to run. The same workflow now carries both jobs — what
the merge did to the specs, and what it did to the tasks.

Rejected: a single `approved` field meaning both moments, which the two
merges make ambiguous — a task is approved into the queue and its work is
approved later, and one field would silently record whichever fired last.
Also rejected: deriving both from `git log` instead of storing them. The
queue is read as files, which is the same reason `created` and
`completed` are fields rather than commit archaeology; a queue that
answers "when did this land" only by leaving the queue is not answering.
Also rejected: `approved`/`accepted` as the pair — near-synonyms, and
`approved` already names a spec status here, so the word would have meant
two things in one schema.
