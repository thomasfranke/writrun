# Preflight

**The three completion gates, in CI's own order**, runnable before the pull request is marked ready. One chapter of [`distribution/`](README.md).

## `preflight.sh` — the completion gates, in order

The three gates a change must pass before its pull request is marked
ready are CI's own three, and the order they run in is a rule:

```bash
bash .writrun/scripts/stage-1-tasks-and-specs/preflight.sh \
  [task-id[,task-id…]] [diff-range]
```

Task ids default to the `task-NNNN` marker in the branch name, and none
resolving is not an error — a reporting or docs branch carries none. The
range defaults to `origin/main...HEAD` after a `git fetch origin main`;
offline, the stale base is named out loud and the run continues, because
a gate nobody can run offline is a gate that does not run.

Then, stopping at the first failure and reprinting that check's own
output under a line naming the stage: **1/3** `check_front_matter.sh`,
its whole-queue sweep (the range plays no part in it); **2/3**
`check_promised_deltas.sh` with the range, which derives the specs the
range moved to `implemented` and runs `check_deltas.sh` on exactly that
set — when none moved, its "authoring change, deltas not applicable" line
prints and the stage passes *loudly*; **3/3** `check_state.sh` on the
range.

**The vacuous pass is encoded here.** The state gate exists to reject the
transitions the completion edits make, so a run before those edits passes
by having nothing to read. When a named or inferred task's `completed` is
still null, the run says so — the delta stage's not-applicable line is
that same fact seen mechanically — and the warning rides the summary
whether the run passed or stopped.

All green prints `PREFLIGHT OK` with the range and the specs the delta
stage checked, and exits 0. A failing stage exits with **that check's own
code**, printed under the stage's name: attribution is the named line,
never the number. Preflight's *own* failures — a malformed argument, an
explicit task id resolving to no file — exit **4**, a code no stage uses,
so a caller retrying on preflight's word never mistakes a stage's 3 for
preflight asking for different arguments.

It adds no rule of its own: the same three calls CI's `writrun-check.yml`
makes. One input differs, and it is rule K's — CI hands `check_state.sh`
the head branch as `HEAD_REF`, preflight hands it nothing and leaves the
script to read the checkout — so the two render the same judgement on the
same branch whenever the checkout *is* that branch, and only then. Run
from a detached HEAD, preflight skips rule K's **branch half** and can
still print `PREFLIGHT OK` on a commit CI judges by that half — the diff
half needs no name and runs there too, so a change carrying code outside
`work/` is refused either way.


## A bare ref reaches the working tree

**The two arguments are told apart by what a task list looks like,
never by the range's punctuation.** An argument whose every
comma-separated entry is a task id — `task-0034`, `0034`,
`task/0034-…` — is the task list; anything else is the range. So a
bare `origin/main` is a range, and it means what it means to every
stage-2 gate already: the ref against the **working tree**, the one
shape whose head end is the checkout rather than a commit.
`origin/main..` and `origin/main...` keep meaning `HEAD`, and two
ranges or two task lists are still refused as preflight's own failure.

The shape exists for the moment the completion edits are written and
not yet committed — the spec's `implemented`, the task's `completed`
date. A flow that writes them and then asks preflight over a two-ended
range hands stages 2 and 3 a range those edits are not in, and reads
`PREFLIGHT OK` over the very change the gates exist to judge. The bare
shape is how such a run sees them.

**The completion warning reads the end the stages read.** `completed`
is read at the range's head — the checkout for the bare shape, the head
commit for the two-ended ones — never from the working tree regardless
of range. A two-ended run over uncommitted completion edits therefore
says the task has no completed date in what it read and does not stand
for the edits, which is the vacuous pass named above, said out loud.
Read from the checkout instead, the same file would silence the warning
while the stages read nothing, and the run would be green on the one
input it never saw.
