# the merge is this repository's assenting act, because its maintainer cannot review his own pull requests.

**2026-08-28**

`writrun approve`
listened for `pull_request_review: submitted`, an event no forge will
ever emit here: every pull request in this repository is opened by the
maintainer, and GitHub does not let a person approve their own. The
gate was therefore unsatisfiable — and an unsatisfiable gate is worse
than none, because it gets worked around. It was, three times in one
session: specs sat `draft` while their work was done, and the flip was
typed by hand, off the record, which is precisely what the gate exists
to prevent. The assenting act becomes the merge, which the maintainer
performs anyway and which the forge does allow; `writrun approve`
triggers on a merged pull request and writes the flip to `main`. Whoever
may merge is exactly whoever may approve, so the gate loses no strength
— it only stops asking for a signal that cannot exist. The trade-off is
named where it lands: the recording now writes to `main`, which is why
`main` stays unprotected here, and protecting it later means allowing
the Actions token to push or the recording stops. `pipeline.md` needed
no new permission for any of this — it already said a project may
record assent however it likes; what it lacked was the instruction to
*name* the act, which it now carries as a criterion. Rejected: keeping
the review trigger and letting the maintainer hand-write the field —
that is the workaround, not the fix, and it leaves the machinery
describing a flow nobody can run. Also rejected: a second account to
cast the review — a credential invented to satisfy a check, which buys
a green tick and no actual second opinion.
