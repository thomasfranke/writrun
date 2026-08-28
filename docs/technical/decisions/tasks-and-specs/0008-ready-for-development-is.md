# "ready for development" is derived, never stored.

**2026-08-22**

It is a
task that is `pending` with every spec in its `spec_ref` `approved` — two
facts the [selection algorithm](../README.md#task-selection-algorithm) already reads.
A status recording it would duplicate a derivable fact, and a duplicated
fact eventually disagrees with its source. The same reasoning applies to
"waiting for review", which is an open pull request and nothing else.
Rejected: adding `waiting-for-review` and `ready` to the task status
vocabulary — it puts a forge's own state into a file the forge does not
write.
