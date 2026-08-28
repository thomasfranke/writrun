# nothing in this methodology reserves a task.

**2026-08-22**

Reserving
work is a tracker's job, and `docs/about.md`'s non-goals already say so.
The `in-progress` status cannot serve as a reservation anyway: it rides on
the worker's branch and reaches `main` only at merge, by which point the
task is `completed` and the warning is worthless. What `list_tasks.sh`
reports instead is work **in flight** — an open pull request for a task,
the one real-time signal a forge can be asked for. That is not a lock, and
the lister says so; two people can still take the same task. Rejected:
making a tracker assignment the claim — it works, and it makes a core
mechanic depend on one vendor's feature while contradicting the non-goal
in the same move; a draft pull request opened at the start, which runs CI
on an empty branch, notifies watchers for days, and fills the review queue
with things that are not reviewable; and writing a reservation into `main`
from a workflow, which needs an App token to pass branch protection and
fails the way the one-direction mirror already rejected.
