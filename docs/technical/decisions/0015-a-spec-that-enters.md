# a spec that enters the tree already `approved` is judged against the forge's review record.

**2026-08-22**

`check_state.sh` reads transitions
out of a diff, and a spec the pull request itself adds has no
`-status: draft` line to read — in the diff, the legitimate flip
(recorded after a maintainer approved, by `writrun approve` or by a fork
contributor's own hand per CONTRIBUTING) and self-approval look
identical. The difference between them is the review, and only the forge
holds it: `writrun check` accepts a born-approved spec only when the
pull request carries an approving review from an owner, member, or
collaborator — the same associations `writrun approve` requires before
writing the field, so the convenience and the guarantee agree on who
counts. Born `implemented` needs no API call and `check_state.sh`
rejects it outright: no legitimate path produces a spec past both gates
at birth. Rejected: hardening rule A to "an added spec must be draft",
which would also reject every legitimate recording of an approval — the
fork contributor's manual flip arrives on a push, and the check that
runs on that push would refuse the very transition the maintainer just
authorized.
