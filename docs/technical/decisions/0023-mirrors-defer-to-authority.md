# mirrors defer to authority, and tell a draft from a review.

**2026-08-22**

Two refinements to the Issues mirror, one concern: the mirror
never says more than the forge knows. A pull request from an author
without authority (not owner, member, or collaborator — the same trio
every other check here uses) gets its task mirrors **at merge**, when
the queue really gains them, not at open — deferred, never denied, and
a drive-by fork PR cannot spray Issues into the repository. And an open
PR's mirror now distinguishes the two states the labels were built to
oppose: draft means `status:in-progress` (leave the worker alone),
ready means `status:in-review` (the maintainer is the blocker), with
`ready_for_review` and `converted_to_draft` flipping between them.
Rejected: skipping drafts entirely — a mirror frozen at `status:ready`
while someone visibly works is the exact lie the in-flight signal
exists to prevent.
