# the merge stays a separate manual act; approval does not auto-merge.

**2026-08-22**

`writrun approve` pushes the `draft → approved` commit to
the pull request's branch, so an automatic merge races it: either the
merge lands first and the specs reach `main` still `draft`, defeating the
point, or the commit lands on a branch that is already merged and gone.
Worse, the property this project relies on elsewhere — a push made with
`GITHUB_TOKEN` does not trigger workflows, which is what keeps the Issues
mirror from looping — becomes a deadlock here: the bot's commit never
re-triggers `writrun check`, so an auto-merge gated on that check waits
forever for a run that cannot start. The manual merge lives with the same
fact: nothing re-checks the flip commit either, so while `writrun check`
is a required check, the maintainer's merge goes through only because
branch protection does not bind administrators — a named bypass,
tolerable because the flip is deterministic and the checks passed on the
exact state it was derived from. Rejected: merging inside the approve
workflow itself (removes the race, but only by making `writrun check`
non-required, which turns the guarantee into advice), and a GitHub App
token, whose pushes *do* re-trigger checks and would make native
auto-merge work correctly — deferred rather than dismissed, since it is
the right answer once contributors other than the maintainer are
regularly opening pull requests. Until then, approving and merging are two
decisions and cost one click.
