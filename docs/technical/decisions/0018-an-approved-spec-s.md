# an approved spec's content changes only through draft.

**2026-08-22**

The body of an approved spec is what a human assented to. When it must
change — usually because a later authoring change moved the doc ahead of
the queue, and the doc always wins — the amendment returns it to `draft`
in the same change and passes the gate again (README: special flows).
Three pieces of machinery close the cycle: `writrun approve` also flips
back a spec the pull request itself moved `approved → draft`, so the
merged squash carries the amended body with net status unchanged, while
a spec parked in draft on `main` and merely edited is still never
flipped; `writrun check` treats an approved spec modified with no
status move exactly like one born approved — legitimate recording and
silent edit are indistinguishable in a diff, so the PR's own reviews
referee both; and a queue-impact job names, on any change under
`docs/`, the non-completed tasks whose `doc_ref` it touches — a
warning, never a failure, because file-level overlap is a signal and
whether the brief survived is the reviewer's judgement. Rejected:
freezing the doc's content into the spec so implementers never read the
doc (a second source of truth, drift by construction), and blocking the
authoring change on queue impact (the doc is the input; the queue
adjusts to it, never the reverse).
