---
id: report-0011
status: authored
task_ref: []
doc_ref: product/concepts/spec.md#the-doc-delta-contract
created: 2026-09-03T00:13:17Z
triaged: 2026-09-03T01:39:42Z
---

# The two promise gates disagree on what may be promised under docs/

**References:** [product/concepts/spec.md#the-doc-delta-contract](../../docs/product/concepts/spec.md#the-doc-delta-contract)

The two gates that read a spec's Proposed-changes sections do not agree
on what a promise may name, and a file under `docs/` that is not
Markdown falls between them.

`check_deltas.sh` asks that every touched path under `docs/` be
declared. The scope is structural and the comment says so — "Permanent
is structural: everything under docs/" — with one coded exception,
`docs/writrun-instructions.md`; anything else undeclared is UNDECLARED,
exit 2. `check_promise_paths.sh` accepts a promise ending in `/` or in
`.md`, and refuses the rest with exit 1.

So an adopter editing `docs/product/diagram.svg` has three moves and no
good one: leaving it undeclared is exit 2, declaring
`product/diagram.svg` is exit 1, and declaring `product/` passes both
by promising the whole folder — the coarse form the per-path promise
exists to avoid.

Observed while reviewing the pull request that adds
`check_promise_paths.sh` (#123), reading the two conditions against
their sibling rather than running them. No trigger today:
`find docs -type f ! -name '*.md'` returns nothing in this repository,
so both gates are green and have never disagreed in a real range.

`spec-0051` states the narrower reading twice — an acceptance criterion
("a path ending in neither `.md` nor `/` … shall exit non-zero") and an
edge case ("the second still holds it to `.md` or `/`") — so the two
gates disagreeing is a fact about the rules as approved, not a defect
against them. Which of the two readings is the one the methodology
wants is exactly what this report does not answer.

Not investigated: whether `check_deltas.sh`'s structural scope was ever
meant to reach a non-Markdown file, or whether `docs/` holding one is
itself the thing to rule out.

**Triage:** the rule nobody wrote is what a promise may name, and it is
now written — `product/concepts/spec.md#the-doc-delta-contract` gains
it, beside the companions rule already there. `authored` rather than
`tracked`: neither gate changes, so there is no work to queue.

The reading is the narrow one both gates already hold, stated from the
side the report found missing. A promise names a document or a folder,
and the per-path form is precise because a document carries the rule and
the anchor the promise points at. A diagram carries neither, so the
folder that holds it is the precise form for it — which is why the rule
also says where such a file goes: in a folder of its own, so the promise
that declares it declares no rule beside it. `product/assets/` is then
one good move, and the adopter's three bad ones are gone.

Widening `check_promise_paths.sh` to accept `product/diagram.svg` was
the alternative and it loses. Condition two is what catches
`technical/README` — a promise no diff will honour — at spec entry; drop
it and that promise passes the entry gate and fails at the completion
gate instead, which is the late refusal `spec-0051` exists to move
earlier.

The report's doc_ref moved with the answer, from
`technical/distribution.md#running-the-checks` to the contract itself.
That section carries rules about how a gate is *called*; this is a rule
about what a promise may say, so it belongs where the promise is
defined.

Nothing in this repository triggered either gate — `find docs -type f
! -name '*.md'` still returns nothing — and the rule is written for the
adopter who puts the first diagram there.
