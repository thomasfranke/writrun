# Conduct

**The adopter's word on the agent's own git actions**, and on the credit those actions leave written. One chapter of [`settings/`](README.md).

## The conduct flags

The adopter's word on the agent's own git actions, one flag per act:
`auto_commit` holds the commit, `auto_push` holds the push, `auto_pr`
holds the pull request. `true` — the default, and the behaviour from
before the keys existed — lets the agent take that action on its own as
its flow requires. `false` gates the action, never the work: the agent
still composes the whole thing — the full commit message, or the branch
and the pull request's complete title and body — presents it, and acts
only on an explicit yes. Approval is per action, never a session-wide
grant.

**`auto_push` exists because the push is the act that makes work
public.** A commit is private and a pull request is already a
conversation; between them sits the moment an adopter's work lands on
someone else's server, and until this key that moment was covered by
inference alone — read as `auto_pr`'s when a pull request was open, as
nobody's on a branch's first push. The inference covered the wrong half.
Taking a task pushes the branch and *then* opens the draft, so an
adopter who set `auto_pr: false` had their branch on the forge before
the gate they asked for was reached: what waited for the word was only
the pull request, half a step behind the act the gate exists to hold.

**Before a pull request exists, the push and the pull request are one
act, gated once.** The agent presents the branch, the title and the body
together, and `false` on either flag holds all of it — two prompts for
one moment is not a stricter gate, it is a worse one. Once the pull
request is open, a further push to its head branch is `auto_push`'s
alone: `auto_pr` has been answered, and what is being gated again is
work becoming visible.

**The flags outrank the agent platform's own autonomy mode.** An agent
running auto-accept, autonomous, or any mode in which its harness would
not ask, still stops: the platform's mode governs what the *harness*
asks, these flags govern what the *adopter* allowed — a setting that only
bound an agent already asking would control nothing, and a setting
controls (below). All three sit in `stage_2` because that is where the
actions they govern begin: git starts at Stage 2
([Adoption](../../product/adoption.md#three-stages)), so below it there is
neither a commit, a push nor a pull request for a conduct flag to gate —
Stage 1 needs nothing but files. No flag touches the commits the
machinery makes nor any workflow-driven write — those are not the
agent's actions.

## `agent_coauthor`

The adopter's word on whether an agent appears as a co-author of what it
writes. `true` — the default — obliges the agent to append a
`Co-Authored-By:` trailer **naming the model** to every commit it makes,
and a credit line to every pull request body it writes. `false` means both
carry the change alone: no co-author trailer, no session URL, no tool
mention; the message reads as any other in the history.

**`true` states a shape, not a permission.** The key formerly said the
agent kept "whatever credit its platform appends", which named no artifact
and so could not be checked at all in that direction — a promise with no
shape is a promise nothing holds. Naming the trailer makes both directions
checkable ([observance](observance.md#observance-is-checked-where-it-leaves-a-trace)),
and it is what lets the commit history answer, on its own, which model
worked a change. The obligation follows from that: on a platform that
appends no credit of its own, the agent **writes** the trailer rather than
having nothing to keep.

The model is named specifically, not as a category — `Co-Authored-By:
Claude Opus 5`, never "an AI" — because the record has to survive the next
model's arrival to be worth reading a quarter later.

An instruction from the agent's own platform, in either direction, yields
to this file, with the same precedence the conduct flags above state. The
flag speaks only to what the agent writes: authorship identity stays git
configuration, other authors' commits are untouched, and nothing rewrites
history — it binds from the write after the flip. It is deliberately not
an `auto_` flag: those gate whether the agent may act, this states what
the act leaves written. It is also not commit signing, which is git
configuration and unrelated.

This is one half of what [Provenance](../../product/concepts/provenance.md)
records. `provenance_ledger` is the other, and the two are independent:
turning either off never silently turns off the other.

