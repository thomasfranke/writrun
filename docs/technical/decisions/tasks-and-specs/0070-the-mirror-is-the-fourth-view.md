# an id is minted above the mirror, because the mirror is the only record of it that survives a dropped branch.

**2026-09-05**

[0013](0013-new-sh-reads-git.md) added the git history as the second view
the mint reads, for a reason that generalises past what it answered: an
id must never be reused, and the tree alone cannot see a number whose
file is gone. The open pull requests came third, for numbers no branch
here has fetched. Between them the three views cover a file that landed,
a file that landed and was deleted, and a file still being proposed.

They do not cover the fourth thing that happens to a queue file: it is
minted on a branch, and the branch is dropped before it merges. The
working tree never held it. No commit reachable from here added it, so
`--diff-filter=A` says nothing. The pull request that carried it is
closed, so the open listing says nothing either. Every view the mint had
agrees the number was never spent, and the mint hands it out again.

**It was spent.** In `writrun-cli`, Issue #18 was triaged and closed; the
second mint of the same id reopened it and rewrote its `Introduced by`
row to name a pull request that never mentioned the finding the Issue's
title and body describe. A maintainer reading that tracker sees an open
item, wrongly attributed, and nothing distinguishes it from a real one.

So **the mirror is the fourth view.** It is the only record of the number
that outlives the branch that made it: an Issue, titled with the id, that
a person has read and may have linked to. A number that has been
published is spent whatever became of the file, which is what
`an id is never reused` already says
([report](../../../product/concepts/report.md#statuses--the-route-not-a-lifecycle)).

**Reading the mirror to decide this is not reading it as an authority.**
The file is the authority and the Issue is its projection
([stage 3](../../../product/stage-3-github-issues/README.md)), so asking
the mirror *what a report says* would be backwards. This asks something
else — whether the number was ever spent — and for that the Issue is the
better witness, because it is the half that was published.

**Rejected: a closed-pull-request scan.** It answers almost the same
question, by listing closed pull requests and paginating each one's file
list. Open pull requests are a working set and stay small; closed ones
are the repository's whole history and never shrink, so the mint's cost
would rise with the age of the project, on the path that runs at every
mint. And it answers a weaker question: a closed pull request says the
number was *proposed*, where the mirror says it was *published*.
Rejected too: both, which buys that cost for a set the mirror already
covers.

**The cost, named.** Two paginated Issue listings per mint, one per kind,
the same listings the mirror pass already reads on every pull-request
event — so the two readers agree by construction on what a mirror is, and
the project pays no new order of cost. Both are fetched whatever kind is
being minted, including for a spec, which can use neither: the mint runs
inside a command substitution and cannot make a forge call of its own, so
every call in that stack belongs to the one pre-pass that already owns
them, and a kind argument would be a second thing every caller must get
right silently.

**The degradation gains a middle state.** The forge view was
all-or-nothing: `forge` or `local`. Collapsing a failed mirror listing to
`local` would throw away a correct open-pull-request answer and make the
run claim less than it knew, so the halves fail apart — `forge`,
`open-pull-requests`, `local` — and the mint says which of the three it
had. A listing that succeeds and returns nothing is a complete answer,
not a failure: an adopter below Stage 3 has no mirrors.

**What this does not close.** Spec ids. Only tasks and reports are
mirrored, so a spec id dropped with its branch can still be re-minted.
That is the honest residue, and it is the small half: a spec is reached
through its task's `spec_ref`, which lives on the same branch and dies
with it, so a re-minted spec id has no public record to contradict.
