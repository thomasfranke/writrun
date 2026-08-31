# protecting the authority branch is recommended, never a gate — superseding 0043's unprotected premise.

**2026-08-31**

[0043](0043-the-merge-is-this.md) moved the assenting act onto the merge
and named the cost where it landed: the recording now writes to `main`,
*"which is why `main` stays unprotected here, and protecting it later
means allowing the Actions token to push or the recording stops."*
Unprotected was the default that sentence left standing. It is no longer
the stance.

**Reachability is the requirement; protection is the recommendation.**
The machinery needs exactly one thing from the authority branch: the
Actions token can push to it. Everything else is the adopter's, and
three shapes all satisfy it —

- unprotected: the push lands, nothing stands in its way;
- a partial ruleset — creation, deletion, non-fast-forward, linear
  history: the push lands, because an ordinary fast-forward push breaks
  none of those rules;
- a full ruleset carrying the pull-request requirement: the push lands
  only with GitHub Actions on the bypass list.

**The forge is what bounds the recommendation.** The bypass list accepts
an Integration actor only on organization-owned repositories — in the UI
and through the API alike. A user-owned repository cannot put the app
there, so the pull-request rule on such a repo would block the very
push that records the merge it just gated. That is why the achievable
half — no force pushes, no deletions, linear history — is what this
repository runs, and what the setup chapter offers a user-owned adopter
as the whole of the recommendation. A limitation of the forge, stated,
beats a recommendation half the adopters silently cannot follow.

**None of it conditions adoption.** A project with no ruleset at all is
following the methodology exactly as one with the full set; the human
gates are the guarantee, and a gate asks for a human decision recorded,
never for a forge feature. The setup chapter's real content is the
inverse list — the rules that must stay *off*, each of which stops the
queue at the next merge — because that is the failure an adopter cannot
diagnose from the outside: a silent 403 on a push nobody was watching.

Rejected: a check that verifies protection. A ruleset is a repository
setting, invisible from inside the tree — no diff, no review, no merge
gate sees it — so a check could only ask the API and would then be
asserting the adopter's forge configuration, which is theirs. It would
also have to fail closed on a fork's read-only token, turning a
recommendation into a broken required check. Verification stays where
it can actually happen: the first merge after any ruleset change is
watched, and the recording push on `main` is the proof.

Rejected: keeping 0043's unprotected default and treating protection as
an advanced topic. The default branch of a repository whose queue *is*
its state deserves force-push and deletion blocking, both of which cost
the machinery nothing — recommending nothing was an accident of the
order the decisions landed in, not a position anyone held.
