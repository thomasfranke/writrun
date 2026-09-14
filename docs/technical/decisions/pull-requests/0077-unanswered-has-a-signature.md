# unanswered has a signature, so the body is guardable rather than only documentable.

**2026-09-14**

[0067](0067-a-body-link-points-at.md) closed with a sentence that read as
a limit of the subject and was a limit of the *question*: "nothing
enforces this", because fetching a URL fails on a private fork, offline,
and on every authoring pull request before its merge. Whether a section
was **answered** is a different question, and it is answerable without a
network beyond the one call that fetches the body.

#261 and #262 were marked ready in this repository with `## What`,
`## Why` and `## How to test` holding nothing but the comments
`take_task.sh` seeded, and every completion gate ran green over them.
A unit test confirms the take *writes* those headings; nothing asked
whether anyone had filled them.

**The headings are read off the body, never from a list.** A required
list would be a second copy of the template — wrong the first time an
adopter edits theirs, and judging every project by this repository's
habits. The template itself ships three kind-specific sections and
instructs a change to keep the one that applies and delete the others,
so even here the set differs per pull request. Reading what is there is
the same move [0065](0065-a-promise-is-judged-by-shape.md) made for a
promise: judge the shape of the thing in hand, not its membership of a
table maintained elsewhere. It also makes deletion the honest way out —
a body owes nothing for a heading it does not carry, which is the
opposite of the incentive a required list creates.

**The template's comments are load bearing.** The obvious tidy-up is to
strip the instructional comments so a seeded section looks empty; it
would also delete the only instructions an author ever reads at the
moment they are writing. They are kept, and the check is defined so it
does not care: what sits under a heading, with HTML comments and
whitespace removed, is empty. One definition covers a seeded section and
a bare heading both, and it needs no knowledge of what the comments say.
An answer written *inside* a comment is refused by the same rule, and
correctly — a comment renders as nothing, so it was never read by the
reviewer it was owed to.

**The test is presence, never quality.** One word passes. "Nothing
runnable ships here" passes, which is the same reasoning that makes an
authoring change declare Derived work "none" rather than leave it blank
([authoring](../../../product/stage-1-tasks-and-specs/authoring.md#declaring-derived-work)).
A gate that weighed the prose would be performing review, and the first
time it was wrong about a good answer every author would learn to route
around it. What is checkable without understanding a word is whether
anything is there at all.

**The moment is `ready`, never the taking.** Taking opens the draft
before the work starts — that is the whole point of taking: the branch
reaches the forge with a draft on it, and the body is composed from the
task and the spec alone. A gate at the taking would demand a body
written before its own change. So the check stands down on a draft and
says that is why, and the workflow gained `ready_for_review`, the one
event it had never listened for. `opened`, `synchronize`, `reopened` and
`edited` between them fire on everything except the transition the rule
names.

**Rejected: the event payload's `draft` flag.** It is free — the
workflow already has it — and it is the flag as it stood when the event
fired. The question being asked is what the pull request is *now*, and
the body has to be fetched from the forge in any case, so both reads go
to the same place and cannot disagree.

**Rejected: degrading when the forge goes quiet.** Its siblings do, and
they are right to: for `check_unique_ids.sh` the forge is the second half
of a question the base branch has already half-answered, so a narrow view
is still a view. Here it is the whole question. A run that reported
"every section answered" without having read the body would be asserting
precisely the thing it failed to look at, so an unanswered read exits
non-zero and says it could not look — the reasoning
`check_queue_impact.sh` states for its own advisory, which fails nothing
and still refuses to report on a diff it could not read.
