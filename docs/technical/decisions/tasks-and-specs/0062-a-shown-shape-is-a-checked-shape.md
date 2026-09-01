# a shape a document shows is checked like a file it stores.

**2026-08-31**

A schema is enforced where the machinery reads it. `check_front_matter.sh`
holds every file in `work/`, and holds it well — the canonical form is a
checked contract precisely because a line-based reader would misread
anything else in silence. What it never touched is the same shape printed
in a chapter.

So the examples drifted, and drifted in the direction that costs most.
`product/concepts/task.md` printed a task with no `origin`, no `queued`,
no `merged`, and `created: 2026-08-21` — a bare date the checker refuses
outright. The chapter exists to teach the shape; a reader who copied what
it showed got a file the first check rejected. Both halves of one contract
were in the repository, disagreeing, and the half a newcomer reads first
was the wrong one.

**An example is documentation that lies with a straight face.** Prose that
is merely out of date reads as prose, and a reader discounts it. A shape
is copied. That is what makes a stale example a different kind of defect
from a stale sentence, and what makes it worth a check rather than another
round of corrections — which is what the previous rounds were, and they
did not hold.

The check reads fenced `yaml` blocks and hands the whole ones to
`check_front_matter.sh` itself. **Not a second implementation of its
rules** — the moment the guard has its own copy of the contract, there are
two contracts, and the one in the guard is the one nobody updates.

Two things had to be decided for that to work.

**A teaching example's `doc_ref` points into an imaginary project**, and
the checker refuses a `doc_ref` naming no file. The path is *materialised*
in a scratch tree and handed over as the checker's third argument — which
is what that argument is for. Rejected: rewriting the examples to
reference this repository's own docs, which would hold the field at the
cost of teaching WritRun instead of teaching the shape; and exempting
`doc_ref` in shown blocks, which is the guard deciding which of the
checker's rules it believes in.

**An annotation is not the shape.** The schema chapters annotate every
field (`# machinery only: the merge that put it in the queue`), and the
canonical form has no comments. A trailing ` #` annotation is stripped
before the block is read, so the schema block a reader learns from is the
block the check holds. The alternative was to fence the annotated schemas
as `text`, which removes the guard from the most-copied blocks in the
repository to preserve a display convention — the wrong way round.

The escape stays, for what genuinely is not canonical: a block fenced as
```text is not read. **The language tag is the declaration of intent**, so
an escape is a visible line in a diff and never a silent exemption.

**The second half holds words, and it is deliberately dumber.** A retired
word — `pending`, `level` — is refused in its backticked form wherever the
documents instruct, and allowed under `docs/technical/decisions/` and in
`work/`, because a record has to be able to name what it retired. The
vocabulary is a hand-kept file, and that is a real cost: retire a word,
add its line, or the next round of this defect is already written. It is
the same two-lists-kept-in-step arrangement `commits.md` and
`check_observance.sh` already carry, and the same argument holds — the
file is prose an agent reads, not a format a script can derive.

Rejected: deriving the retired list from the schema's current vocabulary
by refusing every status-like word not in it. Nothing records that
`pending` ever existed, so the derivation has no source; and the words
that need refusing are exactly the ones the schema no longer mentions.

Rejected: holding `template/`'s prose to this repository's by a mirror,
the way `.writrun/` is held. The kit's `AGENTS.md` is a skeleton with
TODOs and its `work/` chapters address an adopter — a byte mirror would
be false and a diff would be noise. What the two share is the vocabulary,
and that is what is held.
