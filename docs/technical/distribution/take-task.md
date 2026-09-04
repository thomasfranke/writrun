# Taking

**The taking act in one command**, and the same act by hand. One chapter of [`distribution/`](README.md).

## `take_task.sh` — the taking act, in one command

Taking a task is one act with two halves — the branch reaching the forge
and the draft pull request opening — and a script is what keeps them one:

```bash
bash .writrun/scripts/stage-2-pull-requests/take_task.sh <task-id> \
  --title "<summary>" [--slug words] [--resume] [--confirm]
```

It refuses a dirty tree, fetches `origin main`, and re-applies selection
steps 2–4 (`ready`, every `depends_on` done, every `spec_ref` approved or
implemented) — naming the filter that held. Then it composes, touching
nothing: the branch `task/NNNN-<slug>`, defaulting to the slug the
filename already carries; the title, its `[TASK-NNNN]` tag prepended and
the given summary read against `stage_2.pr_title_style` and the two
vocabularies with the same grammar `check_observance.sh` applies — an
invalid summary refuses here, before anything exists; and the body from
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
`origin/main`, pushed, and the draft opened. A forge failure *after* the
cut also exits 3, naming the branch kept local and `--resume`, which
finishes the act — push and pull request only, never a second branch.
That carve-out is narrow on purpose: a local branch that never reached
the forge is the leftover of an interrupted take; a branch that exists
anywhere else is a refusal.

Exit codes: **0** taken; **1** a refusal, with nothing created; **2**
composed and waiting on the word; **3** git or the forge failed. It
writes no queue file — the status line has one writer, and it is the
machinery answering the draft this opens.

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

