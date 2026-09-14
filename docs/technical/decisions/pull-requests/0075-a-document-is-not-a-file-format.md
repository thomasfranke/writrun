# a document is not a file format, so neither gate tests the extension.

**2026-09-14**

[0065](0065-a-promise-is-judged-by-shape.md) gave the promise check two
conditions, and named the second **"not a document": the path ends in
neither `.md` nor `/`**. `check_front_matter.sh` held `doc_ref` to the
same test. Both were standing in for a question about *location* —
"is this a documentation path at all" — asked in a discussion entirely
about repository-root paths, where `tests/harness.sh` was the case and
the extension happened to separate it from `product/concepts/task.md`.

The proxy outlived the question. A drawing that states what a screen must
render, a `.json` stating the shape of a payload a push sends, a fixture
a rule is written against — each is read by a person, states what the
implementation must satisfy, and is touched by the diff that changes it,
which is everything either contract asks of a document except how it is
spelled.

**The two gates had already contradicted each other, and nobody had
looked.** `check_deltas.sh` reads `docs/` whole — every path under it is
permanent, with no extension in the case — so a non-Markdown file there
was `UNDECLARED` at the completion gate for not being promised, and
unpromisable at spec entry for not being Markdown. Neither touchable nor
declarable. The only way through was promising the containing folder,
which in a folder of five drawings promises nothing about which one
changed: the loop the Proposed-changes sections exist to close, left
open. Reported from a consuming project holding sixteen screen drawings
under `docs/product/screens/`
([report-0041](../../../../work/reports/report-0041-documentation-is-not.md)).

**What replaces it is the refusal the widening makes available.** A
promise without a trailing slash whose path names a directory *that is
there* is a folder promise missing its slash — `check_deltas.sh` would
compare it against file paths and never match. That is knowable at spec
entry, and saying so costs one edit where the completion gate would
otherwise report a promise that could never be kept. `doc_ref` gains the
same refusal, which also ends a smaller wrong: a folder written
`chapter` was caught by the shape rule while one written `chapter.md`
was reported *absent*, two messages for one mistake, and one of them
sending the author to hunt a typo in a path that is right there.

**Existence is still not the test, and this does not reintroduce it.**
The question is asked about the *directory* only. A spec legitimately
promises the document its own change creates, so an absent path stays
legal and is judged by shape alone — 0065's central holding, untouched.

**Condition one is untouched, and it is the one that was ever load
bearing.** `tests/harness.sh` is refused by the segment that names it,
read off the repository rather than a list, exactly as before. What the
extension test added on top of it was never protection; it was a second
reading of the same question, wrong for every project whose
documentation is not all prose.

**A document that is not Markdown can never declare itself a draft**, and
that is left as it is. The marker is `/// writrun:draft` on the first
line, which a JSON or binary document cannot carry, so the reader answers
false — the strict answer, and the one an absent declaration has always
meant. Widening the marker to other comment syntaxes is a different
question, and one no observation has asked yet.

**Rejected: a list of documentary extensions.** `.md`, `.excalidraw`,
`.svg`, `.json` and whatever the next adopter draws in would be a table
of the tree's shape by another name — the thing 0065 refused for the root
segments, wrong the first time someone adds a format, and judging an
adopter by this repository's habits. Location already answers the
question; the extension never did.
