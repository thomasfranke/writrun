# Statuses, dates and what they mean

**Statuses.** These values and no others.

| | Values | Moved by |
|---|---|---|
| Task | `pending` → `in-progress` → `completed`, or `blocked` (needs `blocked_reason`) | whoever does the work |
| Spec | `draft` → `approved` → `implemented` | `approved` by a human only; the rest by whoever does the work |

**Dates.** A task carries four, and **who writes each is part of the
contract** — not a convention anyone may bend.

| Field | Records | Written by |
|---|---|---|
| `created` | the task was drafted | a person, on the branch |
| `queued` | the merge that brought it into the queue | the machinery, after that merge |
| `completed` | its work was finished | a person, on the branch |
| `merged` | the merge that took its work | the machinery, after that merge |

The split is not decoration. **A hand-written date cannot honestly record
a merge**: it would have to be typed before the event it claims to
describe, and would be wrong by however long review takes. So the two
halves answer different questions and neither substitutes for the other —
`completed` is when the worker finished, `merged` is when the project
took it. Where everything merges the same day they coincide; anywhere
else the gap between them *is* the review.

Three states are **derived, never stored**: *proposed* is a task whose
file an open pull request adds and the authority branch does not hold
yet; *ready for development* is a `pending` task whose every spec is
`approved`; *waiting for review* is an open PR. No field records any of
them.

**The merge of the pull request that creates a task is that task's
authorization.** Nothing else authorizes it, and nothing else needs to:
before that merge the file is not on the authority branch at all. That
absence is why a task carries no `draft` of its own the way a spec does —
a spec is `draft` *while already in the queue*, which is a state a task
never occupies. What a merged task might still be waiting on is covered
three ways that already exist: its spec's approval gate, `blocked` with
its reason, and `depends_on`.

## Criteria

- When a queue field records what a merge did, the machinery shall write
  it after that merge, and a person shall not write it by hand.
- When a queue file records a moment, it shall record it as a UTC
  timestamp, so that two entries made the same day remain orderable.
- When a change adds a queue file whose id the authority branch or
  another open pull request already claims, the machinery shall reject
  the change.
