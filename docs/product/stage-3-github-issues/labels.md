# Mirror labels

**The mirror projects the file, one to one.** Since the authority
branch now stores every pipeline state the moment its forge event lands
([statuses](../stage-2-pull-requests/statuses.md)), the `status:` label has
nothing left to derive: it restates the stored status, plus the one
state the file cannot hold. One label per state, no state sharing a
label with another:

| Label | The task is |
|---|---|
| `status:proposed` | proposed by an open pull request — not in the queue. The PR may still close unmerged, and the mirror retires with it. The one label with no stored twin, and the reason it cannot have one is structural: the file is not on the authority branch yet. |
| `status:backlog` | in the queue, with a spec it references not yet `approved`. |
| `status:ready` | ready for development — waiting for someone to take it. |
| `status:in-progress` | being worked on — an open draft PR, `taken_by` says by whom. Leave the worker alone. |
| `status:in-review` | waiting on review — the maintainer is the blocker. |
| `status:blocked` | stalled by something outside the queue — `blocked_reason` says what. |
| *(none — the mirror is closed)* | out of the pipeline: closed **completed** for `done`, closed **not planned** for `dropped`. |

**A closed mirror carries no `status:` label.** Every label above names a
place *inside* the pipeline, so any of them on a closed mirror is a
leftover from the step before last — and a leftover is not merely
useless, it is false: an issue closed as completed reading
`status:in-review` says the maintainer is still the blocker. The close
itself, with its reason, is the terminal state, and it is one the forge
records rather than one anybody has to remember to write.

**The label follows the file, after every recording commit.** The
machinery that writes a status onto the authority branch re-labels the
mirror from the queue as it then stands — never from a merge's own
diff, which reports what a merge *carried* and misses what it *caused*
(the merge that brings a task in is the merge that approves its specs,
so its diff still reads them `draft`).

## Criteria

- When a task is mirrored while the pull request that creates it is still
  open, the mirror shall report it as proposed, distinctly from a task
  the queue already holds.
- When a mirror is closed, it shall carry no `status:` label.
- When a task reaches `done`, the machinery shall close its mirror as
  completed; when a task is `dropped`, the machinery shall close it as
  not planned.
- When a recording commit changes a task's stored status, the machinery
  shall re-label that task's mirror from the queue as it then stands,
  rather than from the merge's own diff.
