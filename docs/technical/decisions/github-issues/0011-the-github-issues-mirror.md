# the GitHub Issues mirror runs one direction only, and follows the pull request.

**2026-08-22**

The file under `work/tasks/` is the authority;
the Issue is a projection for people who read the queue in a browser.
Writing an edit made in an Issue back into the file requires pushing to a
protected `main`, which needs a GitHub App token, so that direction is
absent rather than half-built — a sync that silently fails one way is
worse than one that was never claimed. The mirror also has to move with
the work: it is created when the authoring pull request opens, relabelled
on merge, `status:in-review` while an implementation pull request is open,
and closed once a merge carries the task to `completed`. Closing keys on
an actual `+status: completed` line in the merged diff, because a pull
request can merge partial work and closing then would hide a task still
outstanding. `in-review` is a label of its own rather than part of
`in-progress` because the two ask opposite things of the maintainer: one
means leave the worker alone, the other means the maintainer is the
blocker. The mirror is found by task id prefix rather than by a stored
issue number, because an id is permanent and an issue number is not this
project's to depend on. On the naming this creates — a forge's "issue"
against this methodology's "task" — **task is the noun and the Issue is
only its mirror**, and the `writrun:task` label is what separates mirrors
from the bug reports and feature requests an adopting project also files
as Issues; every workflow filters on it. Rejected: making the Issue
authoritative (`writrun-select-next-task` reads files, and an agent working
offline would read a queue the browser disagrees with), and renaming the
concept to "issue" (it is the methodology's noun across every chapter,
`work/tasks/`, and `task_ref` — and it would still collide).
