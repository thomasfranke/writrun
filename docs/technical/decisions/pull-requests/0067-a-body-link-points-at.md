# a pull request body's links are absolute, and point at `main`.

**2026-09-04**

[`spec-0028`](../../../../work/specs/spec-0028-clickable-refs.md) made the
queue navigable — a task's body links its specs, a spec's body links its
task, all as relative paths that resolve on the forge and in an editor —
and [`schemas/task.md`](../../schemas/task.md) carries the principle:
references are navigable, not just resolvable. The pull request body was
left out of that reach, and the omission was never argued: it was taken
for the same case one file over.

It is not the same case. A queue file is *in* the tree, so a relative path
has an anchor. A pull request body is a page at `/pull/NN`, and the forge
does not rewrite what it finds there: the href is served exactly as
written, and the browser resolves it under the pull request's own address.
Measured on this repository's own #160, whose body carried two relative
links to `docs/`:

```
gh api repos/{owner}/{repo}/pulls/160 -H "Accept: application/vnd.github.full+json" --jq .body_html
<a href="docs/product/concepts/report.md#routing-upstream"
```

Both resolve to `/writrun/pull/docs/...` and reach nothing. Every relative
link this project has written into a pull request body has been dead on
arrival. So a body link is a full URL, and the rule is stated where a
writer will meet it rather than left to be rediscovered per body.

**The branch was rejected as the target.** A link to
`blob/task/0043-…/work/specs/…` resolves for every file a pull request
touches, including the ones it creates — the strongest property on offer,
and it lasts exactly as long as the branch. This repository sets
`delete_branch_on_merge`, as a squash-only project generally does, so the
link breaks at merge: the moment the pull request stops being a
conversation and becomes the record someone reads in a year. A link whose
lifetime is the review is a link that works when nobody needs it.

`main` inverts the trade, and the losing half is smaller than it looks.
For an implementing pull request there is no loss at all — the spec was
approved and merged before the take, so the file is on `main` when
`take_task.sh` composes the body. For an authoring one the derived task
and spec are born in the pull request, and the `main` link resolves only
once the merge lands them. That window is the review, where the reviewer
has the files in the diff tab: the pull request *is* the file. And the
address is true rather than convenient — the merge is the assenting act,
so a link that begins working at merge says what the queue actually holds.

Rejected too: a permalink at the head commit's sha, which survives branch
deletion and is stable. It is composed after the commit exists, so
`take_task.sh` — which composes the body at take time, on an empty
branch — cannot write one; it also freezes to a revision later pushes
supersede. A form the machinery cannot produce is a form half the bodies
would not carry.

Nothing enforces this. `writrun check` reads the title against the
declared style and reads `## Derived work` for a declaration; it does not
fetch a URL, and a checker that did would fail on a private fork, offline,
and on every authoring pull request before its merge. The cost of a miss
is one dead link in one body, and the machinery writes the links it can:
`take_task.sh` composes the specs' bullets from `spec_ref`, so the case
that recurs most is the case no one types.
