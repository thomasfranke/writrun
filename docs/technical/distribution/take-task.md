# Taking

**The taking act in one command**, and the same act by hand. One chapter of [`distribution/`](README.md).

## `take_task.sh` — the taking act, in one command

Taking a task is one act with two halves — the branch reaching the forge
and the draft pull request opening — and a script is what keeps them one:

```bash
bash .writrun/scripts/stage-2-pull-requests/take_task.sh <task-id> \
  --title "<summary>" [--slug words] [--coauthor "Name <address>"] \
  [--resume] [--confirm]
```

It refuses a dirty tree, fetches `origin main`, and re-applies selection
steps 2–4 (`ready`, every `depends_on` done, every `spec_ref` approved or
implemented) — naming the filter that held. Then it composes, touching
nothing: the branch `task/NNNN-<slug>`, defaulting to the slug the
filename already carries; the title, its `[TASK-NNNN]` tag prepended and
the given summary read against `stage_2.pr_title_style` and the two
vocabularies with the same grammar `check_observance.sh` applies — an
invalid summary refuses here, before anything exists, and the refusal
names the tag as the script's to prepend, because what it judged was the
summary alone; and the body from
`.writrun/templates/pull_request_template.md`, implementing half kept,
`Implements spec-…` filled from `spec_ref`.

**The conduct flags are honoured by the script, not by prose re-read per
session.** With `auto_push` and `auto_pr` both `true` it performs the act;
with either `false` it prints the composed branch, title and body, touches
neither the tree nor the forge, exits **2**, and names the `--confirm`
rerun that performs exactly what it printed. The forge reads sit *after*
that gate: a run the flags hold asks the forge nothing, because a network
call about work the adopter has not allowed is a trace left on someone
else's server for an act that is not happening.

On the acting path the forge is verified first — `gh` present,
authenticated, reachable — so a failure there leaves the repository
untouched (**3**). Then the same two reads `list_tasks.sh` makes: an open
pull request carrying this task refuses the take (resuming is not
taking), and an open pull request carrying **no** task id that touches one
of the task's specs suspends it, named. Only then is the branch cut from
`origin/main`, given its first commit, pushed, and the draft opened. A
forge failure *after* the cut also exits 3, naming the branch kept local
and `--resume`, which finishes the act — push and pull request only,
never a second branch and never a second commit.
That carve-out is narrow on purpose: a local branch that never reached
the forge is the leftover of an interrupted take; a branch that exists
anywhere else is a refusal.

Exit codes: **0** taken; **1** a refusal, with nothing created; **2**
composed and waiting on the word; **3** git or the forge failed. It
writes no queue file — the status line has one writer, and it is the
machinery answering the draft this opens.

### The first commit, and why it is empty

A branch identical to `origin/main` has no commits between the two, and
the forge refuses a pull request over nothing. So the push has to carry
something, and the take makes it: one commit on the new branch, before
the push, under the subject `chore(tasks): take task-NNNN`.

**It is empty, and that is the record.** The take produced no content,
and a commit with no diff is the honest account of that. The squash-merge
discards it, so nothing of it reaches `main`.

What it does *not* carry is a queue write. The status line has one
writer, and it is the machinery answering this draft
([statuses](../../product/stage-2-pull-requests/statuses.md)); a take
that stamped the task file would be the second writer on that line. Nor
does it open a provenance entry: the ledger is the one machine field a
branch writes, and only by appending, so an entry opened before any work
exists could never be filled in
([provenance](../../product/concepts/provenance.md)).

`--coauthor "Name <address>"` is what puts a `Co-Authored-By:` trailer on
it. Who ran the script is the one thing the script cannot read — an agent
commits under the same name and address as the person who ran it — so the
name is given rather than guessed at, and a take with no `--coauthor` is
a take by a person. Where `stage_2.agent_coauthor` is `false` the flag is
refused outright: this commit sits in the pull request's range like any
other, and the flag is read in both directions
([`settings/conduct.md`](../settings/conduct.md#agent_coauthor)).

**It is made once.** The guard is the range and not the `--resume` flag:
a branch already carrying a commit over `origin/main` is pushed as it
stands, and one interrupted before it committed is given the commit it
never got. What makes a second one wrong is that one is already there.

### By hand, and what the two flags change

The script is the act in one command; by hand it is the same act, and the
order is the whole of it. Branch as `task/NNNN-short-name`, push, and
open the pull request **as a draft before implementing** — the branch is
invisible until it reaches the forge, and the draft is the event the
machinery answers by writing `in-progress` and the author's login onto
`main` and moving the mirror to `status:in-progress`. Marking it ready
for review is the end of the work, not the start; that is what moves the
task to `in-review`.

**The push and the opening are one act**
([`conventions/prs.md`](../../../.writrun/conventions/prs.md)). With
`auto_push` and `auto_pr` both `true` an agent does both without asking.
With either at `false` it composes the branch, the title and the body,
presents them together, and puts nothing on the forge before the word —
which is why one flag at `false` holds the whole act, and why
`take_task.sh` exits 2 with the composition printed rather than doing
half of it.

**The task's status line has one writer, and it is not the agent**
([statuses](../../product/stage-2-pull-requests/statuses.md)). The taking
act writes no queue file; the machinery answers the draft.

