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
`.writrun/templates/pull_request_template.md`, the implementing section
kept and the authoring and reporting ones dropped, with `## Spec`
composed rather than left as a placeholder: one bullet per `spec_ref`
entry, in that order, carrying the id, the spec's own title with the
`spec-NNNN — ` prefix stripped, and an absolute URL to that file on
`main` ([body](../../product/stage-2-pull-requests/body.md)).

**A body composed without a usable remote carries ids and titles without
links.** The blob URL is derived from `git remote get-url origin`, in
both the `git@github.com:owner/repo.git` and
`https://github.com/owner/repo` forms; a remote that is missing,
unreadable or not on `github.com` yields no URL, because this path shape
is GitHub's and one composed for another forge would be a dead link that
reads as live. Every part degrades to the one above it — no URL leaves
id and title, no spec file leaves the bare id, no `spec_ref` at all
leaves the sentence that says so — because the act is the branch
reaching the forge with a draft on it, and a take that refused over a
heading it could not parse would trade the act for a bullet.

**Both questions have a section, and the fallback carries them too.**
`## How to verify` is the methodology's answer and `## How to test` is
the reviewer's. Where the template is missing the script composes the
same sections in the same order, so a project without one is not handed
a different contract.

**The conduct flags are honoured by the script, not by prose re-read per
session.** The act commits, pushes and opens, so all three flags are read:
with `auto_commit`, `auto_push` and `auto_pr` all `true` it performs the
act; with any of them `false` it prints the composed branch, the first
commit's full message, the title and the body, touches neither the tree
nor the forge, exits **2**, and names the `--confirm` rerun that performs
exactly what it printed. One flag at `false` holds the whole act, not its
own third of it — the commit, the push and the opening are one moment
before a pull request exists, and three prompts for one moment is not a
stricter gate ([`settings/conduct.md`](../settings/conduct.md)). The forge
reads sit *after* that gate: a run the flags hold asks the forge nothing,
because a network call about work the adopter has not allowed is a trace
left on someone else's server for an act that is not happening.

On the acting path the forge is verified first — `gh` present,
authenticated, reachable — so a failure there leaves the repository
untouched (**3**). Then the same two reads `list_tasks.sh` makes: an open
pull request carrying this task refuses the take (resuming is not
taking), and an open pull request carrying **no** task id that touches one
of the task's specs suspends it, named. Only then is the branch cut from
`origin/main`, given its first commit, pushed, and the draft opened. A
forge failure *after* the cut also exits 3, naming the branch wherever
its own evidence puts it — a push that never reached the remote leaves
it kept local, a non-fast-forward proves the forge holds it, a ref the
forge received and declined proves only that this push did not move it,
and a `gh pr create` that failed after a push that succeeded leaves it
on the forge with no pull request — and naming `--resume`, which
finishes the act: push and pull request only, never a second branch and
never a second commit. The evidence is git's own words, so the push is
made under a forced C locale; a translated message is one no arm can
read.

**The carve-out turns on the pull request, not the branch's location.**
What `--resume` finishes is a take that has no pull request, wherever it
stopped: the push is idempotent, so how far the interruption let the act
get does not change what finishing it costs, and the state this act must
never leave behind — a branch on the forge with no pull request — is
exactly the one a recovery has to be able to reach. So the forge answers
it. An open pull request carrying the task refuses the resume as it
refuses the fresh take — on the repo-wide list, and again on the read
scoped to this branch, which still holds this take's own pull request
past the point the capped list drops it. An ended pull request refuses
it too, because that flight ended and is finished by a fresh take rather
than resumed. That refusal turns on the commit the flight ended on:
branch names are deterministic, so a name an ended flight used is a name
every later take cuts again, and refusing on the name alone would burn
it. A fork's pull request on that name is not this take's flight either,
and is dropped. Every refusal here prints the deletions and the fresh
take that follow it — a resume refused over a branch that still exists
has no other way out. Where the forge could not say, the resume stops at
exit 3 without pushing or opening — an unanswered read is not "no pull
request", and opening a second pull request over a branch that has one
is the failure this act exists to avoid. What stays
local is the requirement that the branch be here: a branch this checkout
never had would have to be fetched and adopted, which is not finishing a
take.

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

**The value is judged here, not hours later.** One line, a name and an
address — a value carrying a newline would write arbitrary lines into the
commit body — and a name from the category vocabulary
`check_observance.sh` refuses (`ai`, `agent`, `claude`, …) is refused at
the door that offers the flag, read from that script's own assignment
line exactly as the title's two vocabularies are. A trailer this script
wrote and the completion gate then faulted would be the worst of both.

**`auto_commit` holds it,** like `auto_push` holds the push. The message
is composed with the branch, the title and the body and printed with
them, so what the adopter is asked about is the whole commit and not the
fact that one is coming.

**It is made once.** The guard is the range and not the `--resume` flag:
a branch already carrying a commit over `origin/main` is pushed as it
stands, and one interrupted before it committed is given the commit it
never got. What makes a second one wrong is that one is already there.

### By hand, and what the two flags change

The script is the act in one command; by hand it is the same act, and the
order is the whole of it. Branch as `task/NNNN-short-name`, **commit**,
push, and open the pull request **as a draft before implementing** — the
commit is not optional and not cosmetic: a branch identical to
`origin/main` has no commits between the two and the forge refuses a pull
request over nothing, which is the whole of
[the subsection above](#the-first-commit-and-why-it-is-empty). By hand it
is `git commit --allow-empty -m "chore(tasks): take task-NNNN"`, with the
`Co-Authored-By:` trailer where `agent_coauthor` is `true`. The branch is
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

