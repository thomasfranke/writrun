# Mirror labels

The mirror's `status:` label reports where the task is, and **a task an
open pull request merely proposes is not where a merged one is**. One
label per state, no state sharing a label with another:

| Label | The task is |
|---|---|
| `status:proposed` | proposed by an open pull request — not in the queue. The PR may still close unmerged, and the mirror retires with it. |
| `status:pending` | in the queue, with a spec it references not yet `approved`. |
| `status:ready` | ready for development: `pending`, every spec `approved`. |
| `status:in-progress` | being worked on — leave the worker alone. |
| `status:in-review` | waiting on review — the maintainer is the blocker. |
| *(none — the mirror is closed)* | out of the pipeline. The close and its reason carry the outcome: completed, or not planned. |

**A closed mirror carries no `status:` label.** Every label above names a
place *inside* the pipeline, so any of them on a closed mirror is a
leftover from the step before last — and a leftover is not merely
useless, it is false: an issue closed as completed reading
`status:in-review` says the maintainer is still the blocker. The close
itself, with its reason, is the terminal state, and it is one the forge
records rather than one anybody has to remember to write.

**A label is re-derived after the merge that approves the specs, not
only from that merge's own diff.** Since the assenting act is the merge
(flow 2), a task's specs are approved *by the very merge* that brings
them in — so a mirror labelled from that merge's diff reads them still
`draft` and reports `pending` for work that is already ready. Reading
the diff is right for what the merge *carried*; it is wrong for what the
merge *caused*. The machinery therefore labels again once the approval
is recorded, from the queue as it then stands.

The mirror reports *proposed* all the same, and that is not the mirror
inventing state the files lack: it projects the task's **situation**, of
which stored status is one input and the forge is another — exactly as it
already does for *ready* and *waiting for review*, neither of which any
field records. A stored `proposed` could not work even in principle: the
merge that makes a task real is the very commit that carries the file's
own words onto the authority branch, so the field would land already
false and need a second commit to correct itself. Git records where a
file is; the queue records what the work is. Neither restates the other.

## Criteria

- When a task is mirrored while the pull request that creates it is still
  open, the mirror shall report it as proposed, distinctly from a task
  the queue already holds.
- When a mirror is closed, it shall carry no `status:` label.
- When a merge records the approval of a task's specs, the machinery
  shall re-derive that task's label from the queue as it then stands,
  rather than from the merge's own diff.
