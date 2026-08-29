# an approving review vouches for the pull request, not for a commit.

**2026-08-23**

`check_recorded_approvals.sh` accepts any authorized
approving review on the PR, including one older than the commits it
now covers — deliberately. Both legitimate recording paths push
*after* the review by construction (`writrun approve`'s recording
commit; the fork contributor's hand flip per CONTRIBUTING), so
pinning the review to the head commit would reject exactly the
transitions the review authorized — and the required "dismiss stale
approvals: off" setting means the forge itself keeps the review
standing across those pushes. What bounds the exposure is the merge:
content pushed after an approval still reaches `main` only through
the maintainer's own squash-merge, the last gate on everything.
Rejected: requiring the review to sit on the head commit (breaks both
legitimate recordings), and re-requesting review on every push —
that is the forge's dismiss-stale feature, deliberately off.
