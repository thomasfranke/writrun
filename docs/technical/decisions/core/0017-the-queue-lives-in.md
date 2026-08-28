# the queue lives in `work/`, not `docs/`.

**2026-08-22**

Permanent and
ephemeral never mix (principle 3), and they shared a roof: the queue sat
beside the permanent chapters under `docs/`. Tasks and specs are
machine-managed pipeline artefacts, not documentation for people, so
they moved to `work/tasks/` and `work/specs/` — named by the
methodology's own axis, permanent state vs. work in progress. The move
bought the simplification that is the real point: a permanent doc is now
simply anything under `docs/`, so the checks (`check_deltas`'
UNDECLARED, the derived-work gate) stopped enumerating `product/`,
`technical/`, `about.md` — which frees the inside of `docs/` for the
adopting project's own structure, while the audience split stays
prescribed as content rather than as the only tolerated tree. Rejected:
`flow/` and `pipeline/` as names, since both already name the process in
this repo's vocabulary and the folder holds what passes *through* the
process; and a hidden `.writrun/` — these files are the authority behind
the Issue mirror, and authority does not hide.
