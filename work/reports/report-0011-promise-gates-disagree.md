---
id: report-0011
status: open
task_ref: []
doc_ref: technical/distribution.md#running-the-checks
created: 2026-09-03T00:13:17Z
triaged: null
---

# The two promise gates disagree on what may be promised under docs/

**References:** [technical/distribution.md#running-the-checks](../../docs/technical/distribution.md#running-the-checks)

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
